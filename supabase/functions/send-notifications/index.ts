import { corsHeaders, handleOptions } from "../_shared/cors.ts";
import { createSupabaseServiceClient } from "../_shared/supabase.ts";
import { clamp, proximityScore } from "../_shared/geo.ts";
import { fetchSpotifyArtistsByIds } from "../_shared/spotify_app_token.ts";
import { deliver } from "../_shared/notification_delivery.ts";
import { notificationWorkerAuthorized } from "../_shared/notification_worker_auth.ts";
import { forEachUserPage, keyset } from "../_shared/user_batches.ts";
import { skipDisabledSpotifyJob, spotifySkippedJobResponse } from "../_shared/spotify-feature.ts";

type UserRow = {
  id: string;
  fcm_token: string | null;
  last_latitude: number | null;
  last_longitude: number | null;
  push_enabled: boolean | null;
  push_settings: Record<string, boolean> | null;
};

type MusicProfileRow = {
  user_id: string;
  top_artists: Array<{ id: string; score: number }>;
  top_genres: Array<{ genre: string; weight: number }>;
};

type EventRow = {
  id: string;
  name: string;
  artist_name: string | null;
  artist_spotify_id: string | null;
  city: string | null;
  event_date: string;
  ticket_url: string | null;
  latitude: number | null;
  longitude: number | null;
};

// Cron: ogni 6 ore → invia massimo N notifiche per utente
const MAX_ALERTS_PER_USER = 3;
const SCORE_THRESHOLD = 70;
const USER_PAGE = 200;
const MAX_PAGES_PER_RUN = 25;
const RUN_BUDGET_MS = 100_000;

Deno.serve(async (req) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;

  // SECURITY: Verify the request is authorized (e.g. from internal webhook or cron)
  if (!await notificationWorkerAuthorized(req)) {
    return new Response(JSON.stringify({ error: "Unauthorized" }), {
      status: 401,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  try {
    // Tipicamente verrà invocata da cron/scheduler (service role). Manteniamo POST.
    if (req.method.toUpperCase() !== "POST") {
      return new Response(JSON.stringify({ error: "Method not allowed" }), {
        status: 405,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const paused = skipDisabledSpotifyJob();
    if (paused) return paused;
    const supabase = createSupabaseServiceClient();

    // Carica eventi futuri (set condiviso per scoring base)
    const now = new Date().toISOString();
    const { data: events, error: eventsError } = await supabase
      .from("events")
      .select("id, name, artist_name, artist_spotify_id, city, event_date, ticket_url, latitude, longitude")
      .gte("event_date", now)
      .order("event_date", { ascending: true })
      .limit(600)
      .returns<EventRow[]>();

    if (eventsError) throw eventsError;

    const spotifyArtistIds = Array.from(
      new Set(
        (events ?? [])
          .map((e) => e.artist_spotify_id)
          .filter((x): x is string => !!x && x.length > 0),
      ),
    );
    const spotifyArtists = await fetchSpotifyArtistsByIds(spotifyArtistIds);
    const spotifyById = new Map<string, { genres: string[]; followers: number }>();
    for (const a of spotifyArtists) {
      spotifyById.set(a.id, {
        genres: (a.genres ?? []).map((g) => g.toLowerCase()),
        followers: Number(a.followers?.total ?? 0),
      });
    }
    const followerValues = Array.from(spotifyById.values()).map((v) => v.followers);
    const maxFollowers = followerValues.length ? Math.max(...followerValues) : 0;
    const minFollowers = followerValues.length ? Math.min(...followerValues) : 0;

    let inserted = 0;
    let pushed = 0;
    let jobPaused = false;

    const handlePage = async (users: UserRow[]) => {
      // The in-app inbox must work even on a device without an FCM token. Push
      // delivery is evaluated later for the users who have one.
      const ids = users.filter((u) => u.push_settings?.event_alert !== false).map((u) => u.id);
      if (ids.length === 0 || (events?.length ?? 0) === 0) return;
      // One query per page instead of one per user.
      const { data: profileRows, error: profilesError } = await supabase
        .from("music_profiles")
        .select("user_id, top_artists, top_genres")
        .in("user_id", ids)
        .returns<MusicProfileRow[]>();
      if (profilesError) throw profilesError;
      const profiles = new Map((profileRows ?? []).map((p) => [p.user_id, p]));
      const distanceByUserEvent = new Map<string, number>();
      const distanceKey = (userId: string, eventId: string) => `${userId}:${eventId}`;
      {
        const { data: distanceRows, error: distanceError } = await supabase.rpc(
          "nearby_event_distances_for_users",
          {
            p_user_ids: ids,
            p_event_ids: (events ?? []).map((event) => event.id),
            p_radius_meters: 250000,
          },
        );
        if (distanceError) throw distanceError;

        for (const row of distanceRows ?? []) {
          const userId = String(row.user_id ?? "");
          const eventId = String(row.event_id ?? "");
          const meters = Number(row.distance_meters);
          if (userId && eventId && Number.isFinite(meters)) {
            distanceByUserEvent.set(distanceKey(userId, eventId), meters);
          }
        }
      }

      for (const user of users) {
        if (jobPaused) return;
        const profile = profiles.get(user.id);
        if (!profile) continue;

        const artistScore = new Map<string, number>();
        for (const a of (profile.top_artists ?? [])) {
          if (a?.id) artistScore.set(a.id, clamp(Number(a.score ?? 0), 0, 100));
        }

        const genreWeight = new Map<string, number>();
        for (const g of (profile.top_genres ?? [])) {
          const key = (g?.genre ?? "").toString().trim().toLowerCase();
          if (!key) continue;
          genreWeight.set(key, clamp(Number(g.weight ?? 0), 0, 1));
        }

        const scored = (events ?? []).map((event) => {
          const artistId = event.artist_spotify_id ?? "";
          const artistMatch = clamp(artistScore.get(artistId) ?? 0, 0, 100);

          const genres = spotifyById.get(artistId)?.genres ?? [];
          const weights = genres
            .map((g) => genreWeight.get(g))
            .filter((w): w is number => typeof w === "number");
          const avg = weights.length ? weights.reduce((a, b) => a + b, 0) / weights.length : 0;
          const genreMatch = clamp(avg * 100, 0, 100);

          const distanceMeters = distanceByUserEvent.get(
            distanceKey(user.id, event.id),
          );
          const prox = distanceMeters == null ? 0 : proximityScore(distanceMeters / 1000);

          const followers = spotifyById.get(artistId)?.followers ?? 0;
          let pop = 0;
          if (maxFollowers > minFollowers) {
            pop = ((followers - minFollowers) / (maxFollowers - minFollowers)) * 100;
          } else if (followers > 0) {
            pop = 50;
          }
          pop = clamp(pop, 0, 100);

          const total = (artistMatch * 0.75) + (prox * 0.15) + (pop * 0.10);
          return { event, total };
        });

        scored.sort((a, b) => b.total - a.total);
        const picks = scored
          .filter((x) => x.total >= SCORE_THRESHOLD)
          .slice(0, MAX_ALERTS_PER_USER);

        for (const pick of picks) {
          // evita duplicati: stesso evento nelle ultime 24h
          const since = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();
          const { data: existing, error: existingError } = await supabase
            .from("notifications")
            .select("id")
            .eq("user_id", user.id)
            .eq("type", "event_alert")
            .gte("created_at", since)
            .filter("data->>event_id", "eq", pick.event.id)
            .limit(1);

          if (existingError) continue;
          if (existing && existing.length > 0) continue;

          const title = `${pick.event.artist_name ?? "Nuovo evento"} vicino a te`;
          const body = `${pick.event.name} — compatibilità: ${Math.round(pick.total)}/100`;

          // One policy for every notification: stored in-app, pushed only if
          // preferences, quiet hours and daily caps allow (record_notification).
          let result;
          try {
            result = await deliver(supabase, {
              userId: user.id,
              type: "event_alert",
              title,
              body,
              groupKey: `concert:${pick.event.id}`,
              data: {
                event_id: String(pick.event.id),
                event_name: String(pick.event.name ?? ""),
                event_date: String(pick.event.event_date ?? ""),
              },
            });
          } catch (e) {
            // A pause may commit after this worker started with an older Edge
            // environment: never push after the database refused it.
            if ((e as { code?: string })?.code === "PT503") {
              jobPaused = true;
              return;
            }
            continue;
          }
          if (!result.stored || result.grouped) continue;
          inserted++;
          if (result.pushed) pushed++;
        }
      }
    };

    // Every user is visited, one page at a time; the cursor carries over
    // to the next run (docs/performance.md).
    const batch = await forEachUserPage<UserRow>(supabase, {
      job: "send-notifications",
      pageSize: USER_PAGE,
      maxPages: MAX_PAGES_PER_RUN,
      budgetMs: RUN_BUDGET_MS,
      loadPage: async (cursor, limit) => {
        const { data, error } = await keyset(
          supabase.from("users").select("id, fcm_token, last_latitude, last_longitude, push_enabled, push_settings"),
          cursor,
          limit,
        ) as { data: UserRow[] | null; error: unknown };
        if (error) throw error;
        return data ?? [];
      },
      handlePage: async (rows) => {
        if (!jobPaused) await handlePage(rows);
      },
    });
    if (jobPaused) return spotifySkippedJobResponse();

    return new Response(
      JSON.stringify({
        ok: true,
        users: batch.users,
        pages: batch.pages,
        completed_pass: batch.completedPass,
        notifications_inserted: inserted,
        pushes_sent: pushed,
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (e) {
    return new Response(
      JSON.stringify({
        error: "internal_error",
        message: String(e instanceof Error ? e.message : e),
      }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
