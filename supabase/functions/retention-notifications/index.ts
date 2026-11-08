import { corsHeaders, handleOptions } from "../_shared/cors.ts";
import { createSupabaseServiceClient } from "../_shared/supabase.ts";
import { sendFcm } from "../_shared/fcm.ts";
import { notificationWorkerAuthorized } from "../_shared/notification_worker_auth.ts";
import { forEachUserPage, keyset } from "../_shared/user_batches.ts";
import { skipDisabledSpotifyJob } from "../_shared/spotify-feature.ts";

type User = {
  id: string; fcm_token: string | null; push_enabled: boolean | null;
  push_settings: Record<string, boolean> | null; last_active_at: string;
  last_latitude: number | null; last_longitude: number | null;
};
type Preference = {
  retention_enabled: boolean; digest_frequency: "weekly" | "monthly" | "never";
  retention_max_per_week: number; timezone: string; quiet_hours_start: number; quiet_hours_end: number;
};
type Event = { id: string; name: string; artist_name: string | null; artist_spotify_id: string | null; event_date: string; city: string | null; latitude: number | null; longitude: number | null; };

const WEEK = 7 * 24 * 60 * 60 * 1000;
const DAY = 24 * 60 * 60 * 1000;
const USER_PAGE = 200;
const MAX_PAGES_PER_RUN = 20;
const RUN_BUDGET_MS = 100_000;

function localHour(timezone: string) {
  try { return Number(new Intl.DateTimeFormat("en-GB", { timeZone: timezone, hour: "2-digit", hourCycle: "h23" }).format(new Date())); }
  catch (_) { return new Date().getUTCHours(); }
}
function isQuiet(pref: Preference) {
  const hour = localHour(pref.timezone);
  const { quiet_hours_start: start, quiet_hours_end: end } = pref;
  return start === end ? false : start < end ? hour >= start && hour < end : hour >= start || hour < end;
}
Deno.serve(async (req) => {
  const preflight = handleOptions(req); if (preflight) return preflight;
  if (!await notificationWorkerAuthorized(req)) return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } });
  if (req.method !== "POST") return new Response(JSON.stringify({ error: "Method not allowed" }), { status: 405, headers: { ...corsHeaders, "Content-Type": "application/json" } });
  const paused = skipDisabledSpotifyJob(); if (paused) return paused;
  try {
    const db = createSupabaseServiceClient();
    const now = Date.now();
    // Upcoming events are one bounded, shared set; users are visited in
    // keyset pages that resume on the next run (docs/performance.md).
    const { data: events, error: eventsError } = await db.from("events").select("id,name,artist_name,artist_spotify_id,event_date,city,latitude,longitude").eq("is_test_data", false).gte("event_date", new Date(now).toISOString()).order("event_date").limit(1000).returns<Event[]>();
    if (eventsError) throw eventsError;

    let created = 0, pushed = 0, skipped = 0;
    const handlePage = async (users: User[]) => {
      const ids = users.map((u) => u.id);
      // One query per page for preferences, profiles and distances instead
      // of one per user.
      const [{ data: prefRows, error: prefError }, { data: profileRows, error: profileError }] = await Promise.all([
        db.from("notification_preferences").select("user_id,retention_enabled,digest_frequency,retention_max_per_week,timezone,quiet_hours_start,quiet_hours_end").in("user_id", ids).returns<Array<Preference & { user_id: string }>>(),
        db.from("music_profiles").select("user_id,top_artists").in("user_id", ids).returns<Array<{ user_id: string; top_artists: Array<{ id?: string }> | null }>>(),
      ]);
      if (prefError) throw prefError; if (profileError) throw profileError;
      const prefs = new Map((prefRows ?? []).map((p) => [p.user_id, p]));
      const profiles = new Map((profileRows ?? []).map((p) => [p.user_id, p]));
      const nearbyEventIdsByUser = new Map<string, Set<string>>();
      if ((events?.length ?? 0) > 0) {
        const { data: distanceRows, error: distanceError } = await db.rpc("nearby_event_distances_for_users", {
          p_user_ids: ids, p_event_ids: (events ?? []).map((event) => event.id), p_radius_meters: 75000,
        });
        if (distanceError) throw distanceError;
        for (const row of distanceRows ?? []) {
          const userId = String(row.user_id ?? ""), eventId = String(row.event_id ?? "");
          if (!userId || !eventId) continue;
          const set = nearbyEventIdsByUser.get(userId) ?? new Set<string>();
          set.add(eventId);
          nearbyEventIdsByUser.set(userId, set);
        }
      }
    for (const user of users) {
      const pref: Preference = prefs.get(user.id) ?? { retention_enabled: true, digest_frequency: "weekly", retention_max_per_week: 2, timezone: "Europe/Rome", quiet_hours_start: 22, quiet_hours_end: 8 };
      if (!pref.retention_enabled || user.push_enabled === false || user.push_settings?.retention === false || user.push_settings?.updates === false || isQuiet(pref)) { skipped++; continue; }
      const { count } = await db.from("notification_campaigns").select("id", { count: "exact", head: true }).eq("user_id", user.id).in("category", ["retention", "digest", "event_trigger"]).gte("sent_at", new Date(now - WEEK).toISOString());
      if ((count ?? 0) >= pref.retention_max_per_week) { skipped++; continue; }

      const inactiveDays = Math.floor((now - new Date(user.last_active_at).getTime()) / DAY);
      let category: "retention" | "digest" | "event_trigger" = "retention", triggerKey = "", type = "retention", title = "", body = "", data: Record<string, unknown> = {};
      const profile = profiles.get(user.id);
      const artists = new Set<string>((profile?.top_artists ?? []).map((a) => a.id).filter((id): id is string => typeof id === "string" && id.length > 0));
      const nearEventIds = nearbyEventIdsByUser.get(user.id) ?? new Set<string>();
      const near = (events ?? []).filter((event) => nearEventIds.has(event.id));
      const artistEvent = near.find((e) => e.artist_spotify_id && artists.has(e.artist_spotify_id));
      const { data: nearbyMatchRows, error: nearbyMatchError } = await db.rpc(
        "nearby_recent_match_for_user",
        { p_user_id: user.id, p_radius_meters: 25000 },
      );
      if (nearbyMatchError) throw nearbyMatchError;
      const nearbyMatchRow = nearbyMatchRows?.[0];
      const nearbyMatch = nearbyMatchRow
        ? {
          id: String(nearbyMatchRow.match_id),
          compatibility: Number(nearbyMatchRow.compatibility),
          name: String(nearbyMatchRow.display_name),
        }
        : undefined;

      // Event-triggered content wins; it is always based on an actual artist/event.
      if (nearbyMatch) {
        category = "event_trigger"; triggerKey = `nearby_match:${nearbyMatch.id}`; type = "match";
        title = "Una nuova affinità è nella tua zona";
        body = `${nearbyMatch.name} ha un'affinità musicale del ${Math.round(nearbyMatch.compatibility)}% con te.`;
        data = { match_id: nearbyMatch.id, reason: "high_affinity_nearby" };
      } else if (artistEvent) {
        category = "event_trigger"; triggerKey = `artist_concert:${artistEvent.id}`; type = "artist_concert";
        title = `${artistEvent.artist_name ?? "Un tuo artista"} suona vicino a te`;
        body = `${artistEvent.name}${artistEvent.city ? ` a ${artistEvent.city}` : ""} il ${new Intl.DateTimeFormat("it-IT", { dateStyle: "medium" }).format(new Date(artistEvent.event_date))}.`;
        data = { event_id: artistEvent.id, reason: "top_artist" };
      } else if ([3, 7, 14, 30].includes(inactiveDays)) {
        const nearbyName = near[0]?.name;
        if (!nearbyName) continue; // Never send an empty "we miss you" notification.
        triggerKey = `inactive_${inactiveDays}d`;
        if (inactiveDays === 3) { title = "C'è nuova musica da vivere vicino a te"; body = `${nearbyName} è tra gli eventi che rispecchiano i tuoi ascolti.`; }
        else if (inactiveDays === 7) { title = "Una scoperta ad alta affinità ti aspetta"; body = `${nearbyName}: un evento scelto dai tuoi artisti e generi preferiti.`; }
        else { title = "Ecco cosa ti sei perso su Vibra"; body = `${nearbyName} e altri eventi in arrivo vicino a te.`; }
        data = { event_id: near[0].id, inactivity_days: inactiveDays };
      } else {
        const dueDays = pref.digest_frequency === "weekly" ? 7 : pref.digest_frequency === "monthly" ? 30 : 0;
        if (!dueDays || inactiveDays > 1) continue;
        const { data: prior } = await db.from("notification_campaigns").select("id").eq("user_id", user.id).eq("category", "digest").gte("sent_at", new Date(now - dueDays * DAY).toISOString()).limit(1);
        if (prior?.length || near.length === 0) continue;
        category = "digest"; triggerKey = `${pref.digest_frequency}_digest`; type = "digest";
        title = pref.digest_frequency === "weekly" ? "La tua settimana musicale" : "Il tuo mese su Vibra";
        body = `${near.length} eventi vicini, incluso ${near[0].name}${artists.size ? ", ispirati ai tuoi ascolti" : ""}.`;
        data = { event_id: near[0].id, event_count: near.length, digest_frequency: pref.digest_frequency };
      }
      if (!triggerKey) continue;
      if (category === "event_trigger") {
        const { data: alreadyAnnounced } = await db
          .from("notification_campaigns")
          .select("id")
          .eq("user_id", user.id)
          .eq("category", "event_trigger")
          .eq("trigger_key", triggerKey)
          .limit(1);
        if (alreadyAnnounced?.length) continue;
      }
      // One policy for every notification (record_notification): it stores
      // the notification and decides whether this push is allowed (category
      // switch, quiet hours, daily cap, one "updates" push a day).
      const { data: recorded, error: recordError } = await db.rpc("record_notification", {
        p_user: user.id, p_type: type, p_title: title, p_body: body, p_data: data,
        p_actor: null, p_group_key: triggerKey ? `${category}:${triggerKey}` : null,
      });
      if (recordError || !recorded?.id || recorded.grouped) continue;
      const { data: campaign, error: campaignError } = await db.from("notification_campaigns").insert({ user_id: user.id, notification_id: recorded.id, category, trigger_key: triggerKey, variant: Math.random() < .5 ? "a" : "b", metadata: data }).select("id").single();
      if (campaignError) continue;
      created++;
      if (recorded.push === true && typeof recorded.token === "string") {
        const ok = await sendFcm(recorded.token, title, body, { type, event_id: String(data.event_id ?? ""), campaign_id: campaign.id });
        if (ok) { pushed++; await db.from("notification_campaigns").update({ delivered_at: new Date().toISOString() }).eq("id", campaign.id); }
      }
    }
    };
    const batch = await forEachUserPage<User>(db, {
      job: "retention-notifications", pageSize: USER_PAGE, maxPages: MAX_PAGES_PER_RUN, budgetMs: RUN_BUDGET_MS,
      loadPage: async (cursor, limit) => {
        const { data, error } = await keyset(
          db.from("users")
            .select("id,fcm_token,push_enabled,push_settings,last_active_at,last_latitude,last_longitude,privacy_preferences!inner(marketing_notifications)")
            .eq("is_test_user", false)
            .eq("privacy_preferences.marketing_notifications", true),
          cursor, limit,
        ) as { data: User[] | null; error: unknown };
        if (error) throw error;
        return data ?? [];
      },
      handlePage,
    });
    return new Response(JSON.stringify({ ok: true, created, pushed, skipped, users: batch.users, pages: batch.pages, completed_pass: batch.completedPass }), { headers: { ...corsHeaders, "Content-Type": "application/json" } });
  } catch (error) { return new Response(JSON.stringify({ error: "internal_error", message: String(error) }), { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }); }
});
