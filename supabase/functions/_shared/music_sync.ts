// Spotify → Vibra synchronisation for one connected user. Shared by the
// user-triggered `sync-music-profile` and the hourly `spotify-sync-worker`.
import { loadTopGenres } from "../sync-music-profile/genres.ts";
import {
  affinityDetails, ALGORITHM_VERSION, type AffinityInput, type AffinityWeights,
  computeAffinity, readAffinityWeights,
} from "./music_affinity.ts";
import {
  type ConnectionRow, SpotifyClient, SpotifyRequestError, SpotifyRevokedError,
} from "./spotify_api.ts";
import { refreshMusicalDna } from "./musical_dna.ts";

/** "Top artists" everywhere in Vibra (profile, matching, events): ~6 months. */
export const TOP_TIME_RANGE = "medium_term";
/** A full top-artists refresh is due once a day; plays are polled hourly. */
export const FULL_SYNC_INTERVAL_MS = 24 * 60 * 60 * 1000;
const DAY_LABELS = ["Lun", "Mar", "Mer", "Gio", "Ven", "Sab", "Dom"];

export type SyncOutcome =
  | { status: "synced"; profile: unknown; matches: number }
  | { status: "polled"; plays: number }
  | { status: "revoked" }
  | { status: "changed" };

// deno-lint-ignore no-explicit-any
type Admin = any;

export function heatmapFromCounts(counts: number[]): Array<{ day: string; value: number }> {
  const max = Math.max(1, ...counts);
  return DAY_LABELS.map((day, i) => ({ day, value: Number(((counts[i] ?? 0) / max).toFixed(4)) }));
}

function connectionSaver(admin: Admin, row: ConnectionRow) {
  return async (tokens: { accessTokenCiphertext: string; refreshTokenCiphertext: string | null; expiresAt: string }) => {
    const { data, error } = await admin.rpc("refresh_spotify_connection", {
      p_user_id: row.user_id,
      p_spotify_user_id: row.spotify_user_id,
      p_connected_at: row.connected_at,
      p_access_token_ciphertext: tokens.accessTokenCiphertext,
      p_refresh_token_ciphertext: tokens.refreshTokenCiphertext,
      p_token_expires_at: tokens.expiresAt,
    });
    if (error?.code === "PT503") throw new SpotifyRequestError(503, "spotify_temporarily_unavailable");
    return !error && data === true;
  };
}

async function pollRecentlyPlayed(admin: Admin, client: SpotifyClient, row: ConnectionRow) {
  const { data: latest } = await admin.from("spotify_listening_events")
    .select("played_at").eq("user_id", row.user_id)
    .order("played_at", { ascending: false }).limit(1).maybeSingle();
  const after = latest?.played_at ? Date.parse(latest.played_at) : NaN;
  const query = Number.isFinite(after) ? `&after=${after}` : "";
  const recent = await client.get(`/me/player/recently-played?limit=50${query}`);
  const playedAt = ((recent?.items ?? []) as Array<{ played_at?: unknown }>)
    .map((item) => item?.played_at)
    .filter((value): value is string => typeof value === "string" && Number.isFinite(Date.parse(value)));
  const { data: counts, error } = await admin.rpc("record_spotify_listening", {
    p_user_id: row.user_id,
    p_spotify_user_id: row.spotify_user_id,
    p_connected_at: row.connected_at,
    p_played_at: playedAt,
  });
  if (error?.code === "PT409") throw new SpotifyRequestError(409, "spotify_connection_changed");
  if (error?.code === "PT503") throw new SpotifyRequestError(503, "spotify_temporarily_unavailable");
  if (error) throw new Error("listening_write_failed");
  return { plays: playedAt.length, heatmap: heatmapFromCounts(Array.isArray(counts) ? counts : []) };
}

/** Candidates scored per run (find_affinity_candidates caps at 1000). */
const CANDIDATE_LIMIT = 500;

/**
 * Recompute and cache every eligible pair for this user with the affinity
 * engine (_shared/music_affinity.ts). Inputs are read from the database, so
 * Spotify data and hand-picked genres are always combined the same way.
 * Pairs that became ineligible or fell to insufficient data are removed in
 * the same transaction (save_affinity_matches), so a profile change never
 * leaves a stale score behind.
 */
export async function recomputeMatches(
  admin: Admin,
  userId: string,
  options: { weights?: AffinityWeights; onlyIfChanged?: boolean } = {},
): Promise<number> {
  const { data: selfRows, error: selfError } = await admin.rpc("get_affinity_input", { p_user_id: userId });
  if (selfError?.code === "PT503") throw new SpotifyRequestError(503, "spotify_temporarily_unavailable");
  if (selfError) throw new Error("affinity_input_failed");
  const self = (Array.isArray(selfRows) ? selfRows[0] : selfRows) as AffinityInput | undefined;
  const weights = options.weights ?? readAffinityWeights((name) => Deno.env.get(name));
  // Incremental updates: an unchanged input scored recently is not scored
  // again (affinity_cached_count). A failure of the check never blocks the
  // recompute.
  const fingerprint = await affinityFingerprint(self ?? null, weights);
  if (options.onlyIfChanged) {
    const { data: cached, error: cacheError } = await admin.rpc("affinity_cached_count", {
      p_user_id: userId, p_fingerprint: fingerprint, p_max_age_seconds: AFFINITY_FRESH_SECONDS,
    });
    if (!cacheError && typeof cached === "number") return cached;
  }
  const { data: candidates, error } = await admin.rpc("find_affinity_candidates", {
    p_user_id: userId, p_limit: CANDIDATE_LIMIT,
  });
  if (error?.code === "PT503") throw new SpotifyRequestError(503, "spotify_temporarily_unavailable");
  if (error) throw new Error("match_candidates_failed");
  const list = (candidates ?? []) as Array<{ user_id: string } & AffinityInput>;
  const rows = [];
  for (const candidate of list) {
    const result = self ? computeAffinity(self, candidate, weights) : null;
    if (!result || result.status !== "ok" || result.score <= 0) continue;
    const [a, b] = userId < candidate.user_id ? [userId, candidate.user_id] : [candidate.user_id, userId];
    // Orient the explanation to the stored pair (a < b) so it is identical
    // whichever of the two users triggered the recompute.
    const oriented = a === userId ? result : computeAffinity(candidate, self!, weights);
    if (oriented.status !== "ok") continue;
    rows.push({
      user_id_a: a, user_id_b: b,
      compatibility: oriented.score,
      shared_artists: oriented.sharedArtistCount,
      shared_genres: oriented.sharedFamilies.length,
      details: affinityDetails(oriented, a, b),
      algorithm_version: ALGORITHM_VERSION,
    });
  }
  const { data: saved, error: saveError } = await admin.rpc("save_affinity_matches", {
    p_user_id: userId,
    p_rows: rows,
    p_considered: list.map((c) => c.user_id),
    p_complete: list.length < CANDIDATE_LIMIT,
  });
  if (saveError?.code === "PT503") throw new SpotifyRequestError(503, "spotify_temporarily_unavailable");
  if (saveError) throw new Error("match_write_failed");
  const { error: stateError } = await admin.rpc("record_affinity_fingerprint", {
    p_user_id: userId, p_fingerprint: fingerprint,
  });
  if (stateError) console.warn("affinity fingerprint not recorded", stateError.message ?? stateError);
  return typeof saved === "number" ? saved : rows.length;
}

/** A recent computation over identical inputs is reused for this long. */
export const AFFINITY_FRESH_SECONDS = 6 * 60 * 60;

/** Stable JSON: object keys sorted, so equal inputs hash equally. */
function stableJson(value: unknown): string {
  if (Array.isArray(value)) return `[${value.map(stableJson).join(",")}]`;
  if (value && typeof value === "object") {
    const entries = Object.entries(value as Record<string, unknown>)
      .filter(([, v]) => v !== undefined)
      .sort(([a], [b]) => (a < b ? -1 : a > b ? 1 : 0));
    return `{${entries.map(([k, v]) => `${JSON.stringify(k)}:${stableJson(v)}`).join(",")}}`;
  }
  return JSON.stringify(value ?? null);
}

/** SHA-256 of the affinity input, the algorithm version and the weights. */
export async function affinityFingerprint(
  input: AffinityInput | null,
  weights: AffinityWeights,
): Promise<string> {
  const bytes = new TextEncoder().encode(stableJson({ v: ALGORITHM_VERSION, input, weights }));
  const digest = await crypto.subtle.digest("SHA-256", bytes);
  return Array.from(new Uint8Array(digest), (b) => b.toString(16).padStart(2, "0")).join("");
}

/**
 * Sync one connection. `full` refreshes top artists/tracks/genres and
 * matches; otherwise only new plays (heatmap) are collected.
 * A revoked grant disconnects the account so the app shows "Connect" again.
 */
export async function syncConnection(
  admin: Admin,
  row: ConnectionRow,
  options: { full: boolean; request?: typeof fetch; sleep?: (ms: number) => Promise<void> },
): Promise<SyncOutcome> {
  try {
    const client = await SpotifyClient.fromConnection(row, connectionSaver(admin, row), {
      request: options.request, sleep: options.sleep,
    });
    const listening = await pollRecentlyPlayed(admin, client, row);
    if (!options.full) {
      const { error } = await admin.from("music_profiles")
        .update({ listening_heatmap: listening.heatmap }).eq("user_id", row.user_id);
      if (error?.code === "PT503") throw new SpotifyRequestError(503, "spotify_temporarily_unavailable");
      return { status: "polled", plays: listening.plays };
    }

    const artistsRes = await client.get(`/me/top/artists?limit=50&time_range=${TOP_TIME_RANGE}`);
    const tracksRes = await client.get(`/me/top/tracks?limit=50&time_range=${TOP_TIME_RANGE}`);
    const artists = (artistsRes?.items ?? []) as Array<{ id: string; name: string; genres?: string[] }>;
    const tracks = (tracksRes?.items ?? []) as Array<{ id: string; name: string; artists?: Array<{ name: string }> }>;
    const topTracks = tracks.map((track, index) => ({
      id: track.id, name: track.name, artist: track.artists?.[0]?.name ?? null, score: Math.max(100 - index, 0),
    }));
    const artistGenres = new Map<string, string[]>();
    const topGenres = await loadTopGenres(artists, (id) => client.get(`/artists/${encodeURIComponent(id)}`), artistGenres);
    // Each artist keeps its genres so the Musical DNA can attribute them.
    const topArtists = artists.map((artist, index) => ({
      id: artist.id, name: artist.name, score: Math.max(100 - index, 0), genres: artistGenres.get(artist.id) ?? [],
    }));

    const { data: saved, error: saveError } = await admin.rpc("save_connected_music_profile", {
      p_user_id: row.user_id,
      p_spotify_user_id: row.spotify_user_id,
      p_connected_at: row.connected_at,
      p_profile: {
        user_id: row.user_id,
        top_artists: topArtists,
        top_tracks: topTracks,
        top_genres: topGenres,
        audio_features: null,
        embedding: null,
        listening_heatmap: listening.heatmap,
        last_synced_at: new Date().toISOString(),
      },
    });
    if (saveError?.code === "PT503") throw new SpotifyRequestError(503, "spotify_temporarily_unavailable");
    if (saveError?.code === "PT409") return { status: "changed" };
    if (saveError) throw new Error("music_profile_write_failed");
    await refreshDnaSafely(admin, row.user_id);
    const matches = await recomputeMatches(admin, row.user_id);
    return { status: "synced", profile: saved, matches };
  } catch (error) {
    if (error instanceof SpotifyRevokedError) {
      // Access was revoked from Spotify: drop tokens and derived data.
      const { error: disconnectError } = await admin.rpc("disconnect_spotify_account", { p_user_id: row.user_id });
      if (disconnectError) throw new Error("spotify_disconnect_failed");
      return { status: "revoked" };
    }
    if (error instanceof SpotifyRequestError && error.status === 409) return { status: "changed" };
    throw error;
  }
}

/**
 * Musical DNA snapshot (docs/musical-dna.md). A failure is logged and does
 * not fail the sync or the match recompute: the DNA is refreshed next time.
 */
export async function refreshDnaSafely(admin: Admin, userId: string): Promise<void> {
  try {
    await refreshMusicalDna(admin, userId);
  } catch (error) {
    console.warn("musical DNA refresh failed", error instanceof Error ? error.message : error);
  }
}

export function isFullSyncDue(lastSyncedAt: string | null | undefined, now = Date.now()): boolean {
  const last = lastSyncedAt ? Date.parse(lastSyncedAt) : NaN;
  return !Number.isFinite(last) || now - last >= FULL_SYNC_INTERVAL_MS;
}
