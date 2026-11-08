// VIBRA Musical DNA: a user's musical identity as a genre distribution that
// sums to 100%. Documented in docs/musical-dna.md. Pure and deterministic.
//
// Inputs are only what the user's own data contains:
// * Spotify top artists (medium term, ranked) with each artist's genres;
// * Spotify top tracks, which reinforce the artists that appear in them;
// * genres the user picked by hand (intensity 1..100).
// Genre labels go through the same catalogue as the affinity engine
// (classifyGenre), so "Hip-Hop/Rap", "trap italiana" and a picked "Trap"
// all land on the same family → subgenre keys. Unknown labels are skipped
// and reported as coverage; nothing is inferred or invented.
import {
  classifyGenre, diversityScore, diversityTier, type DiversityTier, isKnownGenreKey,
} from "./music_affinity.ts";
import { GENRE_CATALOG } from "./genre_catalog.ts";
import { normalizeArtistName, rankWeight } from "./music_match.ts";

export const DNA_VERSION = 1;
/** Share of the DNA taken by picked genres when Spotify data also exists. */
export const MANUAL_SHARE = 0.3;
/** Weight of one top track (rank-weighted) relative to a top-artist slot. */
export const TRACK_WEIGHT = 0.5;
/** Subgenres stored per snapshot (percentages are computed on all of them). */
export const MAX_STORED_SUBGENRES = 24;
/** Artists named per family in the DNA. */
export const ARTISTS_PER_FAMILY = 3;

const FAMILY_OF = new Map<string, string>(
  (GENRE_CATALOG.subgenres as readonly { key: string; family: string }[]).map((s) => [s.key, s.family]),
);

export type DnaArtist = { id?: string | null; name?: string | null; genres?: unknown };
export type DnaTrack = { name?: string | null; artist?: string | null };
export type DnaInput = {
  top_artists?: DnaArtist[] | null;
  top_tracks?: DnaTrack[] | null;
  top_genres?: Array<{ genre: string; weight: number }> | null;
  manual_genres?: Array<{ genre_key: string; intensity: number }> | null;
};

export type DnaFamily = { key: string; share: number; percent: number; artists: string[] };
export type DnaSubgenre = { key: string; family: string; share: number; percent: number };
/** One top artist as stored in the snapshot (for "recently discovered"). */
export type DnaArtistRef = { key: string; name: string };

export type MusicalDna = {
  version: number;
  /**
   * The Spotify top artists behind this snapshot, ranked. Comparing two
   * snapshots shows which artists a user recently started listening to.
   * Never returned to other users (get_musical_dna strips it).
   */
  artists: DnaArtistRef[];
  families: DnaFamily[];
  subgenres: DnaSubgenre[];
  diversity: { score: number; tier: DiversityTier; families: number; subgenres: number };
  sources: {
    spotify: boolean;
    manual: boolean;
    /** Top artists considered / with at least one recognised genre. */
    artists: number;
    artists_classified: number;
    tracks: number;
    manual_genres: number;
    /** "artists" = per-artist genres; "genres" = aggregated top genres (older syncs). */
    spotify_basis: "artists" | "genres" | null;
  };
};

const round4 = (v: number) => Number(v.toFixed(4));

/**
 * Integer percentages that add up to exactly 100 (largest remainder).
 * Ties keep the input order, so the output is deterministic.
 */
export function percentages(shares: number[]): number[] {
  const total = shares.reduce((a, b) => a + b, 0);
  if (total <= 0) return shares.map(() => 0);
  const exact = shares.map((s) => (s / total) * 100);
  const floors = exact.map(Math.floor);
  let left = 100 - floors.reduce((a, b) => a + b, 0);
  const order = exact.map((v, i) => [v - Math.floor(v), i] as const)
    .sort((a, b) => b[0] - a[0] || a[1] - b[1]);
  for (const [, i] of order) {
    if (left <= 0) break;
    floors[i] += 1;
    left -= 1;
  }
  return floors;
}

export { diversityTier };

function addTo(map: Map<string, number>, key: string, value: number) {
  if (value > 0) map.set(key, (map.get(key) ?? 0) + value);
}

function normalize(map: Map<string, number>): Map<string, number> {
  const total = [...map.values()].reduce((a, b) => a + b, 0);
  const out = new Map<string, number>();
  if (total > 0) for (const [k, v] of map) out.set(k, v / total);
  return out;
}

function artistGenres(artist: DnaArtist): string[] {
  if (!Array.isArray(artist?.genres)) return [];
  return artist.genres.filter((g): g is string => typeof g === "string" && g.trim().length > 0);
}

/**
 * Builds the DNA, or returns null when there is no classifiable genre at all
 * (no Spotify genres and no picked genres): no percentages are produced
 * without data.
 */
export function computeMusicalDna(input: DnaInput): MusicalDna | null {
  const artists = (input.top_artists ?? []).slice(0, 50).filter((a) => a && (a.id || a.name));
  const tracks = (input.top_tracks ?? []).slice(0, 50).filter((t) => t && t.artist);

  // ── Spotify: per-artist genres, reinforced by top tracks ──────────────
  // Each top-track slot adds TRACK_WEIGHT × its rank weight to the artist who
  // made it, so an artist the user plays song after song counts more.
  const trackBoost = new Map<string, number>();
  tracks.forEach((track, index) => {
    addTo(trackBoost, normalizeArtistName(String(track.artist)), TRACK_WEIGHT * rankWeight(index));
  });

  const spotifyMass = new Map<string, number>();
  const familyArtists = new Map<string, Map<string, number>>();
  let classifiedArtists = 0;
  const hasArtistGenres = artists.some((a) => artistGenres(a).length > 0);
  let basis: MusicalDna["sources"]["spotify_basis"] = null;

  if (hasArtistGenres) {
    basis = "artists";
    artists.forEach((artist, index) => {
      const name = typeof artist.name === "string" ? artist.name : "";
      const keys = new Set<string>();
      for (const label of artistGenres(artist)) {
        const c = classifyGenre(label);
        if (c) keys.add(c.subgenre);
      }
      if (keys.size === 0) return;
      classifiedArtists += 1;
      const weight = rankWeight(index) + (name ? trackBoost.get(normalizeArtistName(name)) ?? 0 : 0);
      // An artist's weight is split across its subgenres, so an artist tagged
      // with five genres does not count five times.
      const part = weight / keys.size;
      const familiesTouched = new Map<string, number>();
      for (const key of keys) {
        addTo(spotifyMass, key, part);
        const family = FAMILY_OF.get(key)!;
        familiesTouched.set(family, (familiesTouched.get(family) ?? 0) + part);
      }
      if (name) {
        for (const [family, value] of familiesTouched) {
          const byArtist = familyArtists.get(family) ?? new Map<string, number>();
          byArtist.set(name, (byArtist.get(name) ?? 0) + value);
          familyArtists.set(family, byArtist);
        }
      }
    });
  } else if ((input.top_genres ?? []).length > 0) {
    // Profiles synced before per-artist genres were stored: the aggregated
    // top genres are already weighted by the ranks of the artists carrying
    // them. Synonym labels of one subgenre keep the strongest weight.
    basis = "genres";
    const best = new Map<string, number>();
    for (const item of input.top_genres ?? []) {
      const c = item && classifyGenre(item.genre);
      const w = Number(item?.weight);
      if (c && Number.isFinite(w) && w > 0) best.set(c.subgenre, Math.max(best.get(c.subgenre) ?? 0, w));
    }
    for (const [k, v] of best) spotifyMass.set(k, v);
  }

  // ── Picked genres ─────────────────────────────────────────────────────
  const manualMass = new Map<string, number>();
  let manualCount = 0;
  for (const item of input.manual_genres ?? []) {
    const intensity = Number(item?.intensity);
    if (!item || !isKnownGenreKey(item.genre_key) || !Number.isFinite(intensity) || intensity <= 0) continue;
    manualCount += 1;
    addTo(manualMass, item.genre_key, Math.min(intensity, 100) / 100);
  }

  const spotify = normalize(spotifyMass);
  const manual = normalize(manualMass);
  if (spotify.size === 0 && manual.size === 0) return null;
  if (spotify.size === 0 && basis === "genres") basis = null;

  const [ws, wm] = spotify.size > 0 && manual.size > 0
    ? [1 - MANUAL_SHARE, MANUAL_SHARE]
    : spotify.size > 0 ? [1, 0] : [0, 1];
  const shares = new Map<string, number>();
  for (const [k, v] of spotify) addTo(shares, k, ws * v);
  for (const [k, v] of manual) addTo(shares, k, wm * v);

  const familyShares = new Map<string, number>();
  for (const [k, v] of shares) addTo(familyShares, FAMILY_OF.get(k)!, v);

  const subList = [...shares].sort((a, b) => b[1] - a[1] || a[0].localeCompare(b[0]));
  const subPercents = percentages(subList.map(([, v]) => v));
  const famList = [...familyShares].sort((a, b) => b[1] - a[1] || a[0].localeCompare(b[0]));
  const famPercents = percentages(famList.map(([, v]) => v));

  // Diversity: mostly across families (a hip-hop + metal listener is more
  // varied than trap + drill), partly across subgenres.
  const score = diversityScore(familyShares.values(), shares.values());

  const artistRefs: DnaArtistRef[] = [];
  if (spotify.size > 0) {
    const seen = new Set<string>();
    for (const artist of artists) {
      const name = typeof artist.name === "string" ? artist.name : "";
      const key = artist.id ? `id:${artist.id}` : name ? `name:${normalizeArtistName(name)}` : "";
      if (!key || seen.has(key)) continue;
      seen.add(key);
      artistRefs.push({ key, name });
    }
  }

  return {
    version: DNA_VERSION,
    artists: artistRefs,
    families: famList.map(([key, share], i) => ({
      key,
      share: round4(share),
      percent: famPercents[i],
      artists: [...(familyArtists.get(key) ?? new Map<string, number>())]
        .sort((a, b) => b[1] - a[1] || a[0].localeCompare(b[0]))
        .slice(0, ARTISTS_PER_FAMILY)
        .map(([name]) => name),
    })),
    subgenres: subList.slice(0, MAX_STORED_SUBGENRES).map(([key, share], i) => ({
      key,
      family: FAMILY_OF.get(key)!,
      share: round4(share),
      percent: subPercents[i],
    })),
    diversity: { score, tier: diversityTier(score), families: familyShares.size, subgenres: shares.size },
    sources: {
      spotify: spotify.size > 0,
      manual: manual.size > 0,
      artists: basis === "artists" ? artists.length : 0,
      artists_classified: classifiedArtists,
      tracks: spotify.size > 0 ? tracks.length : 0,
      manual_genres: manualCount,
      spotify_basis: spotify.size > 0 ? basis : null,
    },
  };
}

// deno-lint-ignore no-explicit-any
type Admin = any;

/**
 * Recomputes the user's DNA from the database and stores today's snapshot
 * (save_musical_dna). With no musical data left, every snapshot is removed.
 */
export async function refreshMusicalDna(admin: Admin, userId: string): Promise<MusicalDna | null> {
  const { data, error } = await admin.rpc("get_musical_dna_input", { p_user_id: userId });
  if (error) throw new Error("dna_input_failed");
  const input = (Array.isArray(data) ? data[0] : data) as DnaInput | undefined;
  const dna = input ? computeMusicalDna(input) : null;
  const { error: saveError } = await admin.rpc("save_musical_dna", { p_user_id: userId, p_dna: dna });
  if (saveError) throw new Error("dna_write_failed");
  return dna;
}
