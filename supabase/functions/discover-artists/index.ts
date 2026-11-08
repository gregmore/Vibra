import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";
import { corsHeaders, handleOptions } from "../_shared/cors.ts";
import { rejectRevokedSession } from "../_shared/session-guard.ts";
import { createSupabaseServiceClient } from "../_shared/supabase.ts";
import { requireEnv } from "../_shared/env.ts";
import { getSpotifyAppAccessToken } from "../_shared/spotify_app_token.ts";
import { spotifyApi } from "../_shared/spotify_tracks.ts";
import {
  buildProfile, type Candidate, diversify, explorationTargets, scoreCandidate, searchTermFor, toRows,
} from "../_shared/artist_discovery.ts";

// "Discover my next artist" (docs/artist-discovery.md).
//   { action: "get", refresh?: boolean } → { artists, generated_at, empty_reason? }
// Candidates come from Spotify's catalogue with the app's credentials (never
// a user's Spotify token): collaborators on my artists' recent releases,
// artists in my genres, and artists in neighbouring genres. The pure engine
// scores and diversifies them; results are cached for 12 hours.

const headers = { ...corsHeaders, "Content-Type": "application/json", "Cache-Control": "no-store" };
const reply = (status: number, body: unknown) => new Response(JSON.stringify(body), { status, headers });
const FRESH_MS = 12 * 3600_000;
const MIN_REFRESH_MS = 2 * 60_000;
const SPOTIFY_ID = /^[A-Za-z0-9]{22}$/;
const ARTWORK = /^https:\/\/(i\.scdn\.co|mosaic\.scdn\.co|image-cdn-[a-z0-9]+\.spotifycdn\.com)\//;

// deno-lint-ignore no-explicit-any
const imageOf = (images: any): string | null => {
  const list = Array.isArray(images) ? images : [];
  const sorted = [...list].sort((a, b) => Math.abs((a?.width ?? 320) - 320) - Math.abs((b?.width ?? 320) - 320));
  const ok = sorted.find((i) => typeof i?.url === "string" && ARTWORK.test(i.url));
  return ok?.url ?? null;
};
// deno-lint-ignore no-explicit-any
const toCandidate = (a: any, extra: Partial<Candidate> & Pick<Candidate, "source">): Candidate | null =>
  a && typeof a.id === "string" && SPOTIFY_ID.test(a.id) && typeof a.name === "string"
    ? {
      id: a.id, name: a.name, genres: Array.isArray(a.genres) ? a.genres.slice(0, 10) : [],
      popularity: typeof a.popularity === "number" ? a.popularity : null,
      followers: typeof a.followers?.total === "number" ? a.followers.total : null,
      image_url: imageOf(a.images), ...extra,
    }
    : null;

// deno-lint-ignore no-explicit-any
async function gather(input: any, token: string): Promise<Candidate[]> {
  const profile = buildProfile(input);
  // One failed lookup (rate limit, restricted endpoint) only loses that
  // source of candidates; the others still produce recommendations.
  const get = async (path: string) => {
    try {
      return await spotifyApi(path, token);
    } catch {
      return { unavailable: true as const };
    }
  };
  const out: Candidate[] = [];

  // Seeds: liked/saved artists first (feedback), then my top artists.
  // deno-lint-ignore no-explicit-any
  const liked = (input.feedback ?? []).filter((f: any) => f.reaction === "like" || f.saved)
    // deno-lint-ignore no-explicit-any
    .map((f: any) => ({ id: f.artist_id, name: f.name }));
  // deno-lint-ignore no-explicit-any
  const top = (Array.isArray(input.top_artists) ? input.top_artists : []).map((a: any) => ({ id: a?.id, name: a?.name }));
  const seeds = [...liked.slice(0, 2), ...top.slice(0, 4)]
    .filter((s) => typeof s.id === "string" && SPOTIFY_ID.test(s.id)).slice(0, 6);

  // 1. Collaborations: featured artists on each seed's recent releases.
  const collaborators = new Map<string, string>();
  await Promise.all(seeds.map(async (seed) => {
    const albums = await get(`/artists/${seed.id}/albums?include_groups=album,single&limit=5`);
    if ("unavailable" in albums) return;
    // deno-lint-ignore no-explicit-any
    const ids = ((albums.data?.items ?? []) as any[]).map((a) => a?.id).filter((x) => SPOTIFY_ID.test(x)).slice(0, 3);
    if (!ids.length) return;
    const full = await get(`/albums?ids=${ids.join(",")}`);
    if ("unavailable" in full) return;
    // deno-lint-ignore no-explicit-any
    for (const album of (full.data?.albums ?? []) as any[]) {
      for (const track of album?.tracks?.items ?? []) {
        for (const a of track?.artists ?? []) {
          if (a?.id && a.id !== seed.id && SPOTIFY_ID.test(a.id) && !collaborators.has(a.id)) collaborators.set(a.id, seed.name);
        }
      }
    }
  }));
  const collabIds = [...collaborators.keys()].slice(0, 50);
  if (collabIds.length) {
    const details = await get(`/artists?ids=${collabIds.join(",")}`);
    if (!("unavailable" in details)) {
      // deno-lint-ignore no-explicit-any
      for (const a of (details.data?.artists ?? []) as any[]) {
        const c = toCandidate(a, { source: "collaboration", seed_artist: collaborators.get(a?.id) ?? null });
        if (c) out.push(c);
      }
    }
  }

  // 2. My genres: two pages per genre, the deeper one leans underground.
  const searches: { key: string; offset: number; source: Candidate["source"] }[] = [];
  for (const key of profile.topSubgenres.slice(0, 3)) {
    searches.push({ key, offset: 0, source: "genre" }, { key, offset: 40 + Math.floor(Math.random() * 40), source: "genre" });
  }
  // 3. Exploration: a neighbouring family I don't listen to yet.
  for (const family of explorationTargets(profile)) searches.push({ key: family, offset: 0, source: "exploration" });
  await Promise.all(searches.map(async (s) => {
    const q = encodeURIComponent(`genre:"${searchTermFor(s.key)}"`);
    const r = await get(`/search?type=artist&limit=20&offset=${s.offset}&q=${q}`);
    if ("unavailable" in r) return;
    // deno-lint-ignore no-explicit-any
    for (const a of (r.data?.artists?.items ?? []) as any[]) {
      const c = toCandidate(a, { source: s.source, explored_genre: s.source === "exploration" ? s.key : null });
      if (c) out.push(c);
    }
  }));
  // Keep the first sighting of each artist (collaboration wins over genre).
  const seen = new Set<string>();
  return out.filter((c) => !seen.has(c.id) && seen.add(c.id));
}

Deno.serve(async (req) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;
  if (req.method !== "POST") return reply(405, { error: "method_not_allowed" });
  const rejected = await rejectRevokedSession(req, "discover-artists");
  if (rejected) return rejected;

  try {
    const userClient = createClient(requireEnv("SUPABASE_URL"), requireEnv("SUPABASE_ANON_KEY"), {
      auth: { persistSession: false, autoRefreshToken: false },
      global: { headers: { Authorization: req.headers.get("Authorization") ?? "" } },
    });
    const { data: auth, error: authError } = await userClient.auth.getUser();
    if (authError || !auth.user) return reply(401, { error: "Unauthorized" });
    let body: Record<string, unknown> = {};
    try {
      body = await req.json();
    } catch {
      body = {};
    }
    if (body.action !== undefined && body.action !== "get") return reply(400, { error: "invalid_action" });

    const cached = async () => {
      const { data, error } = await userClient.rpc("get_artist_recommendations");
      if (error) throw error;
      return data ?? [];
    };

    const admin = createSupabaseServiceClient();
    const { data: input, error: inputError } = await admin.rpc("get_artist_discovery_input", { p_user_id: auth.user.id });
    if (inputError) throw inputError;
    const generatedAt = input?.generated_at ? Date.parse(input.generated_at) : 0;
    const age = Date.now() - generatedAt;
    const current = await cached();
    const wantsRefresh = body.refresh === true && age > MIN_REFRESH_MS;
    if (!wantsRefresh && age < FRESH_MS && current.length >= 8) {
      return reply(200, { artists: current, generated_at: input.generated_at });
    }
    if (wantsRefresh) {
      const { error: limit } = await userClient.rpc("consume_action_limit", { p_action: "discover-artists" });
      if (limit?.code === "PT429") return reply(429, { error: "rate_limited" });
    }

    const profile = buildProfile(input);
    if (!profile.genres.size && !(input?.top_artists ?? []).length) {
      return reply(200, { artists: current, generated_at: input?.generated_at ?? null, empty_reason: "no_profile" });
    }
    const token = await getSpotifyAppAccessToken();
    if (!token) return reply(503, { error: "music_provider_unavailable", artists: current });

    const candidates = await gather(input, token);
    const picked = diversify(
      candidates.map((c) => scoreCandidate(c, profile)).filter((s) => s !== null),
    );
    const { error: saveError } = await admin.rpc("save_artist_recommendations", {
      p_user_id: auth.user.id, p_rows: toRows(picked),
    });
    if (saveError) throw saveError;
    return reply(200, { artists: await cached(), generated_at: new Date().toISOString() });
  } catch (e) {
    console.error("discover-artists failed", e instanceof Error ? e.message : e);
    return reply(502, { error: "discovery_failed" });
  }
});
