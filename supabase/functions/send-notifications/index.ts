import { corsHeaders, handleOptions } from "../_shared/cors.ts";
import { createSupabaseServiceClient } from "../_shared/supabase.ts";
import { clamp, haversineKm, proximityScore } from "../_shared/geo.ts";
import { fetchSpotifyArtistsByIds } from "../_shared/spotify_app_token.ts";
import { sendFcmLegacy } from "../_shared/fcm.ts";

type UserRow = {
  id: string;
  fcm_token: string | null;
  last_latitude: number | null;
  last_longitude: number | null;
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

Deno.serve(async (req) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;

  try {
    // Tipicamente verrà invocata da cron/scheduler (service role). Manteniamo POST.
    if (req.method.toUpperCase() !== "POST") {
      return new Response(JSON.stringify({ error: "Method not allowed" }), {
        status: 405,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const supabase = createSupabaseServiceClient();

    // Carica utenti con token push registrato
    const { data: users, error: usersError } = await supabase
      .from("users")
      .select("id, fcm_token, last_latitude, last_longitude")
      .not("fcm_token", "is", null)
      .limit(500)
      .returns<UserRow[]>();

    if (usersError) throw usersError;

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

    for (const user of (users ?? [])) {
      const { data: profile, error: profileError } = await supabase
        .from("music_profiles")
        .select("user_id, top_artists, top_genres")
        .eq("user_id", user.id)
        .maybeSingle<MusicProfileRow>();

      if (profileError) {
        // skip user
        continue;
      }
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

        let prox = 0;
        if (
          typeof user.last_latitude === "number" &&
          typeof user.last_longitude === "number" &&
          typeof event.latitude === "number" &&
          typeof event.longitude === "number"
        ) {
          const d = haversineKm(user.last_latitude, user.last_longitude, event.latitude, event.longitude);
          prox = proximityScore(d);
        }

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

        const { error: insertError } = await supabase.from("notifications").insert({
          user_id: user.id,
          type: "event_alert",
          title,
          body,
          data: {
            event_id: pick.event.id,
            event_name: pick.event.name,
            event_date: pick.event.event_date,
            ticket_url: pick.event.ticket_url,
            score: Number(pick.total.toFixed(2)),
          },
        });

        if (!insertError) inserted++;

        if (user.fcm_token) {
          const ok = await sendFcmLegacy(
            user.fcm_token,
            title,
            body,
            {
              type: "event_alert",
              event_id: pick.event.id,
            },
          );
          if (ok) pushed++;
        }
      }
    }

    return new Response(
      JSON.stringify({
        ok: true,
        users: users?.length ?? 0,
        notifications_inserted: inserted,
        pushes_sent: pushed,
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (e) {
    return new Response(
      JSON.stringify({
        error: "internal_error",
        message: String(e?.message ?? e),
      }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});

