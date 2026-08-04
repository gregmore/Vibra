import { corsHeaders, handleOptions } from "../_shared/cors.ts";
import { createSupabaseServiceClient } from "../_shared/supabase.ts";
import { clamp, haversineKm, proximityScore } from "../_shared/geo.ts";
import { fetchSpotifyArtistsByIds } from "../_shared/spotify_app_token.ts";

type RecommendEventsRequest = {
  user_id: string;
  limit?: number;
  latitude?: number;
  longitude?: number;
};

type MusicProfileRow = {
  user_id: string;
  top_artists: Array<{ id: string; name: string; score: number }>;
  top_genres: Array<{ genre: string; weight: number }>;
};

type EventRow = {
  id: string;
  external_id: string;
  source: string;
  name: string;
  artist_name: string | null;
  artist_spotify_id: string | null;
  venue_name: string | null;
  city: string | null;
  country: string | null;
  latitude: number | null;
  longitude: number | null;
  event_date: string;
  ticket_url: string | null;
  price_min: number | null;
  price_max: number | null;
  image_url: string | null;
  description: string | null;
  distance_meters?: number;
};

Deno.serve(async (req) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;

  try {
    if (req.method.toUpperCase() !== "POST") {
      return new Response(JSON.stringify({ error: "Method not allowed" }), {
        status: 405,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const body = (await req.json()) as RecommendEventsRequest;
    if (!body?.user_id) {
      return new Response(JSON.stringify({ error: "user_id is required" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const limit = clamp(body.limit ?? 20, 1, 50);

    const supabase = createSupabaseServiceClient();

    // ── Load user music profile ──────────────────────────────
    const { data: profile, error: profileError } = await supabase
      .from("music_profiles")
      .select("user_id, top_artists, top_genres, embedding")
      .eq("user_id", body.user_id)
      .maybeSingle<MusicProfileRow & { embedding: string }>();

    if (profileError) throw profileError;
    if (!profile) {
      return new Response(
        JSON.stringify({
          error: "music_profile_not_found",
          message:
            "Profilo musicale non trovato. Esegui prima la sync Spotify.",
        }),
        { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const artistScoreBySpotifyId = new Map<string, number>();
    for (const a of (profile.top_artists ?? [])) {
      if (a?.id) artistScoreBySpotifyId.set(a.id, clamp(Number(a.score ?? 0), 0, 100));
    }

    const genreWeight = new Map<string, number>();
    for (const g of (profile.top_genres ?? [])) {
      const key = (g?.genre ?? "").toString().trim().toLowerCase();
      if (!key) continue;
      genreWeight.set(key, clamp(Number(g.weight ?? 0), 0, 1));
    }

    // ── Load events ─────────────────────────────────────────
    const now = new Date().toISOString();
    let events: EventRow[] = [];
    let eventsError = null;

    if (typeof body.latitude === "number" && typeof body.longitude === "number") {
      // Use PostGIS RPC per scaricare le distanze pesanti su database e limitare al raggio desiderato
      const { data, error } = await supabase.rpc("get_nearby_events_with_distance", {
        user_lon: body.longitude,
        user_lat: body.latitude,
        radius_meters: 100000 // default 100km per raccomandazioni
      });
      eventsError = error;
      events = (data ?? []).map((e: any) => ({
        ...e,
        latitude: e.location_lat,
        longitude: e.location_lon,
      }));
    } else {
      // Fallback
      const { data, error } = await supabase
        .from("events")
        .select(
          "id, external_id, source, name, artist_name, artist_spotify_id, venue_name, city, country, latitude, longitude, event_date, ticket_url, price_min, price_max, image_url, description, embedding"
        )
        .gte("event_date", now)
        .order("event_date", { ascending: true })
        .limit(600);
      eventsError = error;
      events = data as EventRow[] ?? [];
    }

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
      const genres = (a.genres ?? []).map((g) => g.toLowerCase());
      const followers = Number(a.followers?.total ?? 0);
      spotifyById.set(a.id, { genres, followers });
    }

    const followerValues = Array.from(spotifyById.values()).map((v) => v.followers);
    const maxFollowers = followerValues.length ? Math.max(...followerValues) : 0;
    const minFollowers = followerValues.length ? Math.min(...followerValues) : 0;

    function parseVector(v: any): number[] {
      if (!v) return [];
      if (Array.isArray(v)) return v;
      if (typeof v === "string") {
        try { return JSON.parse(v); } catch(e) { return []; }
      }
      return [];
    }

    function cosineSimilarity(vecA: number[], vecB: number[]) {
      if (!vecA || !vecB || vecA.length === 0 || vecA.length !== vecB.length) return 0;
      let dotProduct = 0, normA = 0, normB = 0;
      for (let i = 0; i < vecA.length; i++) {
        dotProduct += vecA[i] * vecB[i];
        normA += vecA[i] * vecA[i];
        normB += vecB[i] * vecB[i];
      }
      if (normA === 0 || normB === 0) return 0;
      return dotProduct / (Math.sqrt(normA) * Math.sqrt(normB));
    }

    const userVec = parseVector((profile as any).embedding);

    const withScores = (events ?? []).map((event) => {
      const artistId = event.artist_spotify_id ?? "";

      // artist_match_score: 0..100
      const artistMatchScore = clamp(artistScoreBySpotifyId.get(artistId) ?? 0, 0, 100);

      // genre_match_score: media pesata dei generi dell'artista nel profilo utente
      const artistGenres = spotifyById.get(artistId)?.genres ?? [];
      const genreWeights = artistGenres
        .map((g) => genreWeight.get(g))
        .filter((w): w is number => typeof w === "number");
      const avgGenreWeight = genreWeights.length
        ? genreWeights.reduce((a, b) => a + b, 0) / genreWeights.length
        : 0;
      const genreMatchScore = clamp(avgGenreWeight * 100, 0, 100);

      // Vector similarity (if available)
      const eventVec = parseVector((event as any).embedding);
      let vectorScore = 0;
      if (userVec.length > 0 && eventVec.length > 0) {
        vectorScore = clamp(cosineSimilarity(userVec, eventVec) * 100, 0, 100);
      }

      // proximity_score (S_geo)
      let proximity = 0;
      if (typeof event.distance_meters === "number") {
        proximity = proximityScore(event.distance_meters / 1000); // km
      } else if (
        typeof body.latitude === "number" &&
        typeof body.longitude === "number" &&
        typeof event.latitude === "number" &&
        typeof event.longitude === "number"
      ) {
        const d = haversineKm(body.latitude, body.longitude, event.latitude, event.longitude);
        proximity = proximityScore(d);
      }

      // popularity_score (S_social): normalizzazione follower 0..100
      const followers = spotifyById.get(artistId)?.followers ?? 0;
      let popularity = 0;
      if (maxFollowers > minFollowers) {
        popularity = ((followers - minFollowers) / (maxFollowers - minFollowers)) * 100;
      } else if (followers > 0) {
        popularity = 50;
      }
      popularity = clamp(popularity, 0, 100);

      // time_score (S_time): penalty per eventi più lontani. Max 100 per eventi odierni, 0 per eventi oltre i 6 mesi (~180 giorni)
      const eventDate = new Date(event.event_date);
      const daysDiff = (eventDate.getTime() - new Date(now).getTime()) / (1000 * 60 * 60 * 24);
      const timeScore = clamp(100 - (daysDiff / 180) * 100, 0, 100);

      // Se abbiamo il vectorScore usiamo quello, altrimenti il vecchio artistMatchScore
      const s_music = vectorScore > 0 ? vectorScore : artistMatchScore;

      // S_tot: Formula ibrida
      const total = (s_music * 0.45) +
        (proximity * 0.30) +
        (popularity * 0.15) +
        (timeScore * 0.10);

      return {
        event,
        score: {
          total: Number(total.toFixed(2)),
          artist_match_score: Number(artistMatchScore.toFixed(2)),
          genre_match_score: Number(genreMatchScore.toFixed(2)),
          vector_score: Number(vectorScore.toFixed(2)),
          proximity_score: Number(proximity.toFixed(2)),
          popularity_score: Number(popularity.toFixed(2)),
          time_score: Number(timeScore.toFixed(2)),
        },
      };
    });

    withScores.sort((a, b) => b.score.total - a.score.total);

    return new Response(
      JSON.stringify({
        user_id: body.user_id,
        limit,
        data: withScores.slice(0, limit),
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (e: any) {
    return new Response(
      JSON.stringify({
        error: "internal_error",
        message: String(e?.message ?? e),
      }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
