// Shared music helpers and the person ↔ event score (recommend-events).
// People ↔ people affinity lives in music_affinity.ts.
// Documented in docs/spotify-integration.md and docs/music-affinity-engine.md.
import { eventFamilies, familyWeights } from "./genre_taxonomy.ts";

export type RankedArtist = { id?: string | null; name?: string | null; score?: number | null };
export type WeightedGenre = { genre: string; weight: number };
export type MusicProfile = { top_artists?: RankedArtist[] | null; top_genres?: WeightedGenre[] | null };

/** Artist weight from rank position: #1 → 1.00, #50 → 0.51. */
export function rankWeight(index: number): number {
  return Math.max(0, 1 - index / 100);
}

export function normalizeArtistName(name: string): string {
  return name.normalize("NFKD").replace(/[̀-ͯ]/g, "").toLowerCase()
    .replace(/&/g, " and ").replace(/[^a-z0-9]+/g, " ").trim();
}

/** Artist key → weight. Spotify IDs when present, else normalised names. */
export function artistWeights(artists: RankedArtist[] | null | undefined): Map<string, number> {
  const weights = new Map<string, number>();
  (artists ?? []).slice(0, 50).forEach((artist, index) => {
    const key = artist?.id ? `id:${artist.id}` : artist?.name ? `name:${normalizeArtistName(artist.name)}` : null;
    if (!key || weights.has(key)) return;
    weights.set(key, rankWeight(index));
  });
  return weights;
}

/** Weighted Jaccard: Σ min(a,b) / Σ max(a,b) over the union of keys. 0..1. */
export function weightedJaccard<K>(a: Map<K, number>, b: Map<K, number>): number {
  let min = 0, max = 0;
  for (const key of new Set([...a.keys(), ...b.keys()])) {
    const x = a.get(key) ?? 0, y = b.get(key) ?? 0;
    min += Math.min(x, y);
    max += Math.max(x, y);
  }
  return max > 0 ? min / max : 0;
}

export type EventMusic = {
  artist_name?: string | null;
  artist_spotify_id?: string | null;
  name?: string | null;
  genres?: string[] | null;
};

/**
 * Event compatibility (0–100) for one user:
 *
 *   A = rank weight of the matching top artist (by Spotify ID, or by
 *       normalised name in the event's artist/title), else 0
 *   G = strongest of the user's family weights among the event's families
 *   score = round(100 × (1 − (1 − A) × (1 − 0.8 × G)))
 *
 * A top artist alone reaches 100; a perfect genre fit without a known artist
 * reaches 80; anything below shares neither.
 */
export function eventCompatibility(profile: MusicProfile, event: EventMusic) {
  const artists = profile.top_artists ?? [];
  let artistScore = 0;
  const title = normalizeArtistName(`${event.artist_name ?? ""} ${event.name ?? ""}`);
  artists.slice(0, 50).forEach((artist, index) => {
    if (artistScore > 0) return;
    const byId = !!artist?.id && artist.id === event.artist_spotify_id;
    const name = artist?.name ? normalizeArtistName(artist.name) : "";
    const byName = name.length >= 3 && ` ${title} `.includes(` ${name} `);
    if (byId || byName) artistScore = rankWeight(index);
  });
  const userFamilies = familyWeights(profile.top_genres ?? []);
  let genreScore = 0;
  for (const family of eventFamilies(event.genres ?? [])) {
    genreScore = Math.max(genreScore, userFamilies.get(family) ?? 0);
  }
  const score = Math.round(100 * (1 - (1 - artistScore) * (1 - 0.8 * genreScore)));
  return { compatibility: Math.max(0, Math.min(100, score)), artistScore, genreScore };
}
