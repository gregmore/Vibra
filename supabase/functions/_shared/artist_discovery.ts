// "Discover my next artist" (docs/artist-discovery.md): the pure engine.
// The discover-artists function gathers candidates from Spotify; this file
// scores, filters and diversifies them, so it can be tested without I/O.
import { GENRE_CATALOG } from "./genre_catalog.ts";
import { classifyGenre, subgenreSimilarity } from "./music_affinity.ts";

export type Bucket = "similar" | "collaboration" | "emerging" | "underground" | "exploration";

export type Candidate = {
  id: string;
  name: string;
  genres: string[];
  popularity: number | null;
  followers: number | null;
  image_url: string | null;
  /** How it was found. */
  source: "collaboration" | "genre" | "exploration";
  /** The user's artist it collaborated with (collaboration). */
  seed_artist?: string | null;
  /** The genre explored (exploration). */
  explored_genre?: string | null;
};

export type Feedback = {
  artist_id: string;
  name: string;
  reaction: "like" | "not_interested" | "known" | null;
  saved: boolean;
  genre_keys: string[];
};

export type DiscoveryProfile = {
  /** subgenre or family key → weight 0..1 */
  genres: Map<string, number>;
  topFamilies: string[];
  topSubgenres: string[];
  /** Spotify ids never to recommend: my top artists, known, not interested. */
  excludedIds: Set<string>;
  /** Lower-cased names never to recommend: top, DNA and discovered artists. */
  excludedNames: Set<string>;
  /** Genre keys of liked or saved artists (learned taste). */
  likedGenres: Map<string, number>;
  /** Genre keys of not-interested artists (learned dislikes). */
  dislikedGenres: Map<string, number>;
  /** How many times each artist was already shown. */
  shown: Record<string, number>;
};

export type Scored = Candidate & {
  bucket: Bucket;
  genre_keys: string[];
  shared_genres: string[];
  score: number;
};

const SUBGENRES = new Map<string, string>(
  (GENRE_CATALOG.subgenres as readonly { key: string; family: string }[]).map((s) => [s.key, s.family]),
);
const FAMILIES = new Set<string>(GENRE_CATALOG.families.map((f) => f.key));
const LABELS = new Map<string, string>([
  ...GENRE_CATALOG.families.map((f) => [f.key, f.label] as [string, string]),
  ...(GENRE_CATALOG.subgenres as readonly { key: string; label: string }[]).map((s) => [s.key, s.label] as [string, string]),
]);
export const genreLabel = (k: string) => LABELS.get(k) ?? k;

/** Catalogue keys (subgenres + their families) for Spotify genre labels. */
export function genreKeysOf(labels: string[]): string[] {
  const out = new Set<string>();
  for (const l of labels) {
    const c = classifyGenre(l);
    if (c) {
      out.add(c.subgenre);
      out.add(c.family);
    }
  }
  return [...out].slice(0, 12);
}

const norm = (n: string) => n.trim().toLowerCase();

// deno-lint-ignore no-explicit-any
export function buildProfile(input: any): DiscoveryProfile {
  const genres = new Map<string, number>();
  const add = (k: unknown, w: number) => {
    if (typeof k !== "string" || !(SUBGENRES.has(k) || FAMILIES.has(k))) return;
    genres.set(k, Math.max(genres.get(k) ?? 0, Math.min(1, w)));
  };
  const dna = input?.dna ?? {};
  const share = (x: { share?: unknown; percent?: unknown }) =>
    typeof x?.share === "number" ? x.share : typeof x?.percent === "number" ? x.percent / 100 : 0;
  for (const f of Array.isArray(dna.families) ? dna.families : []) add(f?.key, share(f) * 1.4);
  for (const s of Array.isArray(dna.subgenres) ? dna.subgenres : []) add(s?.key, share(s) * 1.6);
  for (const k of Array.isArray(input?.picked_genres) ? input.picked_genres : []) add(k, 0.7);
  // Top artists' own genres, for users without a DNA snapshot yet.
  const top = Array.isArray(input?.top_artists) ? input.top_artists : [];
  if (!genres.size) {
    for (const a of top.slice(0, 20)) for (const k of genreKeysOf(Array.isArray(a?.genres) ? a.genres : [])) add(k, 0.5);
  }

  const likedGenres = new Map<string, number>();
  const dislikedGenres = new Map<string, number>();
  const excludedIds = new Set<string>();
  const excludedNames = new Set<string>();
  for (const a of top) {
    if (typeof a?.id === "string") excludedIds.add(a.id);
    if (typeof a?.name === "string") excludedNames.add(norm(a.name));
  }
  for (const a of Array.isArray(dna.artists) ? dna.artists : []) if (typeof a?.name === "string") excludedNames.add(norm(a.name));
  for (const n of Array.isArray(input?.discovered_artists) ? input.discovered_artists : []) {
    if (typeof n === "string") for (const part of n.split(",")) if (part.trim()) excludedNames.add(norm(part));
  }
  for (const f of (Array.isArray(input?.feedback) ? input.feedback : []) as Feedback[]) {
    if (f.reaction === "not_interested" || f.reaction === "known") excludedIds.add(f.artist_id);
    // Saved and liked artists are kept in their own list, not re-recommended.
    if (f.saved || f.reaction === "like") excludedIds.add(f.artist_id);
    const target = f.reaction === "not_interested" ? dislikedGenres
      : (f.reaction === "like" || f.saved) ? likedGenres : null;
    if (!target) continue;
    for (const k of f.genre_keys ?? []) target.set(k, (target.get(k) ?? 0) + 1);
  }
  const ranked = [...genres.entries()].sort((a, b) => b[1] - a[1]);
  return {
    genres,
    topFamilies: ranked.filter(([k]) => FAMILIES.has(k)).map(([k]) => k).slice(0, 4),
    topSubgenres: ranked.filter(([k]) => SUBGENRES.has(k) && !FAMILIES.has(k)).map(([k]) => k).slice(0, 5),
    excludedIds,
    excludedNames,
    likedGenres,
    dislikedGenres,
    shown: (input?.shown && typeof input.shown === "object") ? input.shown : {},
  };
}

/** Families next to mine in the catalogue that I don't listen to yet. */
export function explorationTargets(profile: DiscoveryProfile, max = 2): string[] {
  const mine = new Set(profile.topFamilies);
  const weights = new Map<string, number>();
  for (const [a, b, w] of GENRE_CATALOG.relations as readonly (readonly [string, string, number])[]) {
    for (const [from, to] of [[a, b], [b, a]]) {
      if (mine.has(from) && !mine.has(to) && !profile.genres.has(to)) {
        weights.set(to, Math.max(weights.get(to) ?? 0, w * (profile.genres.get(from) ?? 0.5)));
      }
    }
  }
  return [...weights.entries()].sort((x, y) => y[1] - x[1]).map(([k]) => k).slice(0, max);
}

/** A Spotify genre string to search for a catalogue key. */
export function searchTermFor(key: string): string {
  const sub = (GENRE_CATALOG.subgenres as readonly { key: string; aliases: readonly string[] }[]).find((s) => s.key === key);
  return sub?.aliases[0] ?? key.replace(/-/g, " ");
}

function compatibility(keys: string[], profile: DiscoveryProfile): { value: number; shared: string[] } {
  let value = 0;
  const shared: string[] = [];
  for (const k of keys) {
    if (profile.genres.has(k) && !FAMILIES.has(k)) shared.push(k);
    for (const [u, w] of profile.genres) {
      const s = k === u ? 1 : (SUBGENRES.has(k) && SUBGENRES.has(u)) ? subgenreSimilarity(k, u) : 0;
      value = Math.max(value, s * w);
    }
  }
  return { value: Math.min(1, value), shared: shared.slice(0, 3) };
}

/** Scores one candidate; null when it must not be recommended. */
export function scoreCandidate(c: Candidate, profile: DiscoveryProfile): Scored | null {
  if (profile.excludedIds.has(c.id) || profile.excludedNames.has(norm(c.name))) return null;
  const shown = Number(profile.shown[c.id] ?? 0);
  // Shown three times without an answer: give it a rest.
  if (shown >= 3) return null;
  const keys = genreKeysOf(c.genres);
  const { value, shared } = compatibility(keys, profile);
  const like = keys.reduce((s, k) => s + Math.min(profile.likedGenres.get(k) ?? 0, 2), 0);
  const dislike = keys.reduce((s, k) => s + Math.min(profile.dislikedGenres.get(k) ?? 0, 2), 0);
  // A disliked style with no liked counterweight is not recommended at all.
  if (dislike >= 2 && like === 0 && c.source !== "collaboration") return null;

  const pop = c.popularity ?? 50;
  let score =
    (c.source === "exploration" ? 0.35 + value * 0.3 : value) +
    (c.source === "collaboration" ? 0.3 : 0) +
    Math.min(like, 3) * 0.08 -
    Math.min(dislike, 3) * 0.12 +
    // Prefer discovery over the obvious: less popular ranks a little higher.
    (1 - pop / 100) * 0.15;
  if (!keys.length) score -= c.source === "collaboration" ? 0.05 : 0.25;
  score *= Math.pow(0.8, shown);

  const bucket: Bucket = pop < 25 ? "underground"
    : pop < 50 && (c.followers ?? 0) < 250_000 ? "emerging"
    : c.source === "collaboration" ? "collaboration"
    : c.source === "exploration" ? "exploration"
    : "similar";
  return { ...c, bucket, genre_keys: keys, shared_genres: shared, score: Math.round(score * 1000) / 1000 };
}

export const QUOTAS: Record<Bucket, number> = {
  similar: 8, collaboration: 6, emerging: 6, underground: 5, exploration: 5,
};

/**
 * Picks a diverse set: each kind gets its share, no genre or seed artist
 * dominates, then the best of the rest fill the list.
 */
export function diversify(scored: Scored[], total = 30): Scored[] {
  const byScore = [...scored].sort((a, b) => b.score - a.score || a.name.localeCompare(b.name));
  const picked: Scored[] = [];
  const ids = new Set<string>();
  const perGenre = new Map<string, number>();
  const perSeed = new Map<string, number>();
  const primary = (s: Scored) => s.genre_keys.find((k) => SUBGENRES.has(k) && !FAMILIES.has(k)) ?? s.genre_keys[0] ?? "none";
  const fits = (s: Scored) =>
    !ids.has(s.id) && (perGenre.get(primary(s)) ?? 0) < 3 && (!s.seed_artist || (perSeed.get(s.seed_artist) ?? 0) < 2);
  const take = (s: Scored) => {
    picked.push(s);
    ids.add(s.id);
    perGenre.set(primary(s), (perGenre.get(primary(s)) ?? 0) + 1);
    if (s.seed_artist) perSeed.set(s.seed_artist, (perSeed.get(s.seed_artist) ?? 0) + 1);
  };
  for (const bucket of Object.keys(QUOTAS) as Bucket[]) {
    let n = 0;
    for (const s of byScore) {
      if (n >= QUOTAS[bucket] || picked.length >= total) break;
      if (s.bucket === bucket && fits(s)) {
        take(s);
        n++;
      }
    }
  }
  for (const s of byScore) {
    if (picked.length >= total) break;
    if (fits(s)) take(s);
  }
  // Interleave kinds for display: never a long run of one kind.
  const queues = new Map<Bucket, Scored[]>();
  for (const s of picked) queues.set(s.bucket, [...(queues.get(s.bucket) ?? []), s]);
  const out: Scored[] = [];
  while (out.length < picked.length) {
    for (const b of Object.keys(QUOTAS) as Bucket[]) {
      const q = queues.get(b);
      if (q?.length) out.push(q.shift()!);
    }
  }
  return out;
}

/** Rows for save_artist_recommendations. Reasons are facts only. */
export function toRows(list: Scored[]) {
  return list.map((s) => ({
    artist_id: s.id,
    name: s.name.slice(0, 200),
    image_url: s.image_url,
    genres: s.genres.slice(0, 10),
    genre_keys: s.genre_keys,
    popularity: s.popularity,
    followers: s.followers,
    bucket: s.bucket,
    reason: {
      seed_artist: s.seed_artist ?? null,
      shared_genres: s.shared_genres.map(genreLabel),
      explored_genre: s.explored_genre ? genreLabel(s.explored_genre) : null,
    },
    score: s.score,
  }));
}
