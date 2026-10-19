import { corsHeaders, handleOptions } from "../_shared/cors.ts";
import { createSupabaseServiceClient } from "../_shared/supabase.ts";
import { sendFcm } from "../_shared/fcm.ts";
import { notificationWorkerAuthorized } from "../_shared/notification_worker_auth.ts";
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
    const [{ data: users, error: usersError }, { data: events, error: eventsError }] = await Promise.all([
      db.from("users")
        .select("id,fcm_token,push_enabled,push_settings,last_active_at,last_latitude,last_longitude,privacy_preferences!inner(marketing_notifications)")
        .eq("is_test_user", false)
        .eq("privacy_preferences.marketing_notifications", true)
        .limit(1000).returns<User[]>(),
      db.from("events").select("id,name,artist_name,artist_spotify_id,event_date,city,latitude,longitude").eq("is_test_data", false).gte("event_date", new Date(now).toISOString()).order("event_date").limit(1000).returns<Event[]>(),
    ]);
    if (usersError) throw usersError; if (eventsError) throw eventsError;

    const nearbyEventIdsByUser = new Map<string, Set<string>>();
    if ((users?.length ?? 0) > 0 && (events?.length ?? 0) > 0) {
      const { data: distanceRows, error: distanceError } = await db.rpc(
        "nearby_event_distances_for_users",
        {
          p_user_ids: (users ?? []).map((user) => user.id),
          p_event_ids: (events ?? []).map((event) => event.id),
          p_radius_meters: 75000,
        },
      );
      if (distanceError) throw distanceError;

      for (const row of distanceRows ?? []) {
        const userId = String(row.user_id ?? "");
        const eventId = String(row.event_id ?? "");
        if (!userId || !eventId) continue;
        const userEventIds = nearbyEventIdsByUser.get(userId) ??
          new Set<string>();
        userEventIds.add(eventId);
        nearbyEventIdsByUser.set(userId, userEventIds);
      }
    }
    let created = 0, pushed = 0, skipped = 0;
    for (const user of users ?? []) {
      const { data: prefRow } = await db.from("notification_preferences").select("retention_enabled,digest_frequency,retention_max_per_week,timezone,quiet_hours_start,quiet_hours_end").eq("user_id", user.id).maybeSingle<Preference>();
      const pref: Preference = prefRow ?? { retention_enabled: true, digest_frequency: "weekly", retention_max_per_week: 2, timezone: "Europe/Rome", quiet_hours_start: 22, quiet_hours_end: 8 };
      if (!pref.retention_enabled || user.push_enabled === false || user.push_settings?.retention === false || isQuiet(pref)) { skipped++; continue; }
      const { count } = await db.from("notification_campaigns").select("id", { count: "exact", head: true }).eq("user_id", user.id).in("category", ["retention", "digest", "event_trigger"]).gte("sent_at", new Date(now - WEEK).toISOString());
      if ((count ?? 0) >= pref.retention_max_per_week) { skipped++; continue; }

      const inactiveDays = Math.floor((now - new Date(user.last_active_at).getTime()) / DAY);
      let category: "retention" | "digest" | "event_trigger" = "retention", triggerKey = "", type = "retention", title = "", body = "", data: Record<string, unknown> = {};
      const { data: profile } = await db.from("music_profiles").select("top_artists,top_genres,last_synced_at").eq("user_id", user.id).maybeSingle();
      const artists = new Set<string>((profile?.top_artists ?? []).map((a: { id?: string }) => a.id).filter(Boolean));
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
      const { data: notification, error: notificationError } = await db.from("notifications").insert({ user_id: user.id, type, title, body, data }).select("id").single();
      if (notificationError) continue;
      const { data: campaign, error: campaignError } = await db.from("notification_campaigns").insert({ user_id: user.id, notification_id: notification.id, category, trigger_key: triggerKey, variant: Math.random() < .5 ? "a" : "b", metadata: data }).select("id").single();
      if (campaignError) continue;
      created++;
      if (user.fcm_token) {
        const ok = await sendFcm(user.fcm_token, title, body, { type, event_id: String(data.event_id ?? ""), campaign_id: campaign.id });
        if (ok) { pushed++; await db.from("notification_campaigns").update({ delivered_at: new Date().toISOString() }).eq("id", campaign.id); }
      }
    }
    return new Response(JSON.stringify({ ok: true, created, pushed, skipped }), { headers: { ...corsHeaders, "Content-Type": "application/json" } });
  } catch (error) { return new Response(JSON.stringify({ error: "internal_error", message: String(error) }), { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }); }
});
