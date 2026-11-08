// VIBRA music affinity engine (people ↔ people). Documented in
// docs/music-affinity-engine.md. Pure, deterministic and symmetric.
//
// 1. Every genre label (Spotify micro-genre or a genre the user picked) is
//    classified into the two-level catalogue in genre_catalog.json:
//    family ("hip-hop") → subgenre ("trap"). The original label is kept.
// 2. Each user becomes a weighted subgenre vector (0..1, strongest = 1).
// 3. Genre similarity is the soft cosine of the two vectors: identical
//    subgenres count fully, sibling subgenres partially, related families a
//    little (relation matrix in the catalogue). Different artists in the same
//    musical world therefore still score high.
// 4. Artist similarity is the √ of the weighted Jaccard of ranked artists.
// 5. score = round(100 × (w_g·G + w_a·A)), with weights redistributed when a
//    side has no artists, and an explicit insufficient-data result when either
//    side has no classified genres.
import { GENRE_CATALOG } from "./genre_catalog.ts";
import { normalizeArtistName, rankWeight, weightedJaccard } from "./music_match.ts";

export const ALGORITHM_VERSION = 2;

export type AffinityWeights = { genre: number; artist: number };
/** Configurable (see readAffinityWeights); must sum to 1. */
export const DEFAULT_WEIGHTS: AffinityWeights = { genre: 0.75, artist: 0.25 };
/** Lowest accepted genre weight (see readAffinityWeights). */
export const MIN_GENRE_WEIGHT = 0.7;

/** Similarity between two different subgenres of the same family. */
export const SIBLING_SIMILARITY = 0.6;
/** Similarity between a family's generic entry ("Hip-Hop") and its subgenres. */
export const GENERIC_SIMILARITY = 0.8;
/** Scale applied to the family relation matrix for cross-family pairs. */
export const RELATED_FAMILY_SCALE = 0.6;

type Subgenre = { key: string; family: string; label: string; aliases: readonly string[] };
const FAMILY_KEYS = new Set(GENRE_CATALOG.families.map((f) => f.key as string));
const SUBGENRES = new Map<string, Subgenre>(
  (GENRE_CATALOG.subgenres as readonly Subgenre[]).map((s) => [s.key, s]),
);
const RELATIONS = new Map<string, number>();
for (const [a, b, w] of GENRE_CATALOG.relations as readonly (readonly [string, string, number])[]) {
  RELATIONS.set(`${a}|${b}`, w);
  RELATIONS.set(`${b}|${a}`, w);
}

export function normalizeGenreLabel(value: string): string {
  return value
    .normalize("NFKD").replace(/[̀-ͯ]/g, "")
    .toLowerCase()
    .replace(/&/g, " and ")
    .replace(/['’]/g, "")
    .replace(/[-_/.]+/g, " ")
    .replace(/[^a-z0-9 ]+/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

// Alias → subgenre, plus aliases sorted longest-first for contained matches.
const ALIASES = new Map<string, string>();
for (const sub of SUBGENRES.values()) {
  for (const alias of sub.aliases) ALIASES.set(normalizeGenreLabel(alias), sub.key);
}
const ALIASES_BY_LENGTH = [...ALIASES.keys()].sort((a, b) => b.length - a.length || a.localeCompare(b));

export type ClassifiedGenre = { original: string; family: string; subgenre: string };

/**
 * Classifies one label. Exact alias first; otherwise the longest alias that
 * appears as whole words inside the label ("italian trap" → Rap italiano,
 * "dark trap" → Trap, "rap metal" → Nu Metal). Unknown labels return null
 * rather than being forced into an unrelated family.
 */
export function classifyGenre(label: string): ClassifiedGenre | null {
  if (typeof label !== "string") return null;
  const normalized = normalizeGenreLabel(label);
  if (!normalized) return null;
  const direct = ALIASES.get(normalized) ?? (SUBGENRES.has(normalized.replace(/ /g, "-")) ? normalized.replace(/ /g, "-") : null);
  let key = direct;
  if (!key) {
    const padded = ` ${normalized} `;
    const alias = ALIASES_BY_LENGTH.find((a) => padded.includes(` ${a} `));
    key = alias ? ALIASES.get(alias)! : null;
  }
  if (!key) return null;
  const sub = SUBGENRES.get(key)!;
  return { original: label, family: sub.family, subgenre: sub.key };
}

export function isKnownGenreKey(key: string): boolean {
  return SUBGENRES.has(key);
}

export type RankedArtist = { id?: string | null; name?: string | null };
export type WeightedLabel = { genre: string; weight: number };
export type ManualGenre = { genre_key: string; intensity: number };
export type AffinityInput = {
  top_artists?: RankedArtist[] | null;
  top_genres?: WeightedLabel[] | null;
  manual_genres?: ManualGenre[] | null;
};

export type GenreProfile = {
  /** subgenre key → 0..1 (strongest = 1) */
  subgenres: Map<string, number>;
  /** family key → 0..1 (strongest subgenre in that family) */
  families: Map<string, number>;
};

const clamp01 = (v: number) => Number.isFinite(v) ? Math.max(0, Math.min(1, v)) : 0;

/**
 * Weighted genre profile from Spotify genres (weights already derived from
 * the user's ranked top artists) and genres picked by hand (intensity
 * 1..100). Each subgenre keeps the strongest signal; nothing is invented.
 */
export function buildGenreProfile(input: AffinityInput): GenreProfile {
  const raw = new Map<string, number>();
  const add = (key: string, weight: number) => {
    const w = clamp01(weight);
    if (w > 0) raw.set(key, Math.max(raw.get(key) ?? 0, w));
  };
  for (const item of input.top_genres ?? []) {
    const classified = item && classifyGenre(item.genre);
    if (classified) add(classified.subgenre, Number(item.weight));
  }
  for (const item of input.manual_genres ?? []) {
    if (item && SUBGENRES.has(item.genre_key)) add(item.genre_key, Number(item.intensity) / 100);
  }
  const max = Math.max(0, ...raw.values());
  const subgenres = new Map<string, number>();
  const families = new Map<string, number>();
  if (max > 0) {
    for (const [key, w] of raw) {
      const value = Number((w / max).toFixed(4));
      subgenres.set(key, value);
      const family = SUBGENRES.get(key)!.family;
      families.set(family, Math.max(families.get(family) ?? 0, value));
    }
  }
  return { subgenres, families };
}

/** Pairwise similarity between two subgenres (1 on the diagonal). */
export function subgenreSimilarity(a: string, b: string): number {
  if (a === b) return 1;
  const sa = SUBGENRES.get(a), sb = SUBGENRES.get(b);
  if (!sa || !sb) return 0;
  if (sa.family === sb.family) {
    return a === sa.family || b === sb.family ? GENERIC_SIMILARITY : SIBLING_SIMILARITY;
  }
  return RELATED_FAMILY_SCALE * (RELATIONS.get(`${sa.family}|${sb.family}`) ?? 0);
}

function softDot(a: Map<string, number>, b: Map<string, number>): number {
  let sum = 0;
  for (const [ka, wa] of a) {
    for (const [kb, wb] of b) {
      const s = subgenreSimilarity(ka, kb);
      if (s > 0) sum += wa * wb * s;
    }
  }
  return sum;
}

/**
 * Soft cosine similarity (Sidorov et al., 2014):
 *   G = aᵀSb / √(aᵀSa · bᵀSb)
 * Symmetric by construction; 0 when nothing is related, 1 for identical
 * profiles. Rewards intensity: two Trap enthusiasts beat a Trap enthusiast
 * and an occasional listener.
 */
export function genreSimilarity(a: GenreProfile, b: GenreProfile): number {
  if (!a.subgenres.size || !b.subgenres.size) return 0;
  const denom = Math.sqrt(softDot(a.subgenres, a.subgenres) * softDot(b.subgenres, b.subgenres));
  return denom > 0 ? clamp01(softDot(a.subgenres, b.subgenres) / denom) : 0;
}

type ArtistEntry = { weight: number; name: string };
function artistMap(artists: RankedArtist[] | null | undefined): Map<string, ArtistEntry> {
  const map = new Map<string, ArtistEntry>();
  (artists ?? []).slice(0, 50).forEach((artist, index) => {
    const name = typeof artist?.name === "string" ? artist.name : "";
    const key = artist?.id ? `id:${artist.id}` : name ? `name:${normalizeArtistName(name)}` : null;
    if (!key || map.has(key)) return;
    map.set(key, { weight: rankWeight(index), name });
  });
  return map;
}

export type AffinityTier = "exceptional" | "very_high" | "high" | "moderate" | "low" | "very_low";
export function tierFor(score: number): AffinityTier {
  if (score >= 90) return "exceptional";
  if (score >= 80) return "very_high";
  if (score >= 65) return "high";
  if (score >= 45) return "moderate";
  if (score >= 25) return "low";
  return "very_low";
}

// ── Musical diversity (shared with the Musical DNA) ───────────────────────
export type DiversityTier = "focused" | "balanced" | "eclectic";

/** Gini–Simpson index of a distribution (normalised here): 1 − Σp². */
function giniSimpson(values: Iterable<number>): number {
  const list = [...values].filter((v) => v > 0);
  const total = list.reduce((x, y) => x + y, 0);
  if (total <= 0) return 0;
  let sum = 0;
  for (const v of list) sum += (v / total) ** 2;
  return Math.max(0, 1 - sum);
}

/**
 * Diversity 0..100 of a taste: 70% across families (hip-hop + metal is more
 * varied than trap + drill), 30% across subgenres. Inputs are any
 * non-negative weights; they are normalised internally.
 */
export function diversityScore(familyWeights: Iterable<number>, subgenreWeights: Iterable<number>): number {
  return Math.round(100 * (0.7 * giniSimpson(familyWeights) + 0.3 * giniSimpson(subgenreWeights)));
}

export function diversityTier(score: number): DiversityTier {
  if (score < 35) return "focused";
  if (score < 65) return "balanced";
  return "eclectic";
}

/** Diversity of a genre profile, from its subgenre weights. */
export function profileDiversity(profile: GenreProfile): number {
  const families = new Map<string, number>();
  for (const [key, w] of profile.subgenres) {
    const family = SUBGENRES.get(key)!.family;
    families.set(family, (families.get(family) ?? 0) + w);
  }
  return diversityScore(families.values(), profile.subgenres.values());
}

export type AffinityReason =
  | { code: "shared_families"; families: string[] }
  | { code: "shared_subgenres"; subgenres: string[] }
  | { code: "different_subgenres"; family: string }
  | { code: "related_families"; families: [string, string] }
  | { code: "shared_artists"; count: number; artists: string[] }
  /** Families both listen to, but not both as a main sound. */
  | { code: "common_ground"; families: string[] }
  /** Both eclectic, both focused, or one broad and one focused. */
  | { code: "diversity"; pattern: "both_eclectic" | "both_focused" | "contrast" }
  | { code: "discovery" };

export type AffinityResult =
  | { status: "insufficient_data"; missing: Array<"a" | "b"> }
  | {
    status: "ok";
    score: number;
    tier: AffinityTier;
    genre: number;
    artist: number | null;
    weights: AffinityWeights;
    sharedFamilies: string[];
    sharedSubgenres: string[];
    sharedArtists: string[];
    sharedArtistCount: number;
    topFamiliesA: string[];
    topFamiliesB: string[];
    reasons: AffinityReason[];
  };

const SHARED_FAMILY_MIN = 0.35;
const SHARED_SUBGENRE_MIN = 0.25;

function topKeys(map: Map<string, number>, n: number, min = 0): string[] {
  return [...map].filter(([, w]) => w >= min)
    .sort((x, y) => y[1] - x[1] || x[0].localeCompare(y[0]))
    .slice(0, n).map(([k]) => k);
}

/** Shared keys ranked by the weaker side (what both really like), symmetric. */
function sharedKeys(a: Map<string, number>, b: Map<string, number>, min: number): string[] {
  const shared = new Map<string, number>();
  for (const [k, wa] of a) {
    const wb = b.get(k);
    if (wb !== undefined && Math.min(wa, wb) >= min) shared.set(k, Math.min(wa, wb) + Math.max(wa, wb) / 1000);
  }
  return topKeys(shared, 3);
}

export function readAffinityWeights(env: (name: string) => string | undefined = () => undefined): AffinityWeights {
  const genre = Number(env("AFFINITY_GENRE_WEIGHT"));
  // Below 0.7, two listeners of the same genres with different artists drop
  // under "high" (calibration test in music_affinity.test.ts), which breaks
  // the engine's purpose. Out-of-range values fall back to the defaults.
  if (Number.isFinite(genre) && genre >= MIN_GENRE_WEIGHT && genre <= 1) {
    return { genre: Number(genre.toFixed(3)), artist: Number((1 - genre).toFixed(3)) };
  }
  return DEFAULT_WEIGHTS;
}

/**
 * Compatibility between two users, 0..100, or insufficient_data.
 * Symmetric: computeAffinity(a, b) mirrors computeAffinity(b, a) (A/B fields
 * swap, score and reasons are identical).
 */
export function computeAffinity(
  a: AffinityInput,
  b: AffinityInput,
  weights: AffinityWeights = DEFAULT_WEIGHTS,
): AffinityResult {
  const profileA = buildGenreProfile(a), profileB = buildGenreProfile(b);
  const missing: Array<"a" | "b"> = [];
  if (!profileA.subgenres.size) missing.push("a");
  if (!profileB.subgenres.size) missing.push("b");
  if (missing.length) return { status: "insufficient_data", missing };

  const G = genreSimilarity(profileA, profileB);
  const artistsA = artistMap(a.top_artists), artistsB = artistMap(b.top_artists);
  const hasArtists = artistsA.size > 0 && artistsB.size > 0;
  let A: number | null = null;
  const shared: Array<{ name: string; rank: number }> = [];
  if (hasArtists) {
    const wa = new Map([...artistsA].map(([k, v]) => [k, v.weight]));
    const wb = new Map([...artistsB].map(([k, v]) => [k, v.weight]));
    A = Math.sqrt(weightedJaccard(wa, wb));
    for (const [key, entry] of artistsA) {
      const other = artistsB.get(key);
      if (other) shared.push({ name: entry.name || other.name, rank: entry.weight + other.weight });
    }
    shared.sort((x, y) => y.rank - x.rank || x.name.localeCompare(y.name));
  }
  // Without artists on one side, genres carry the whole score.
  const effective: AffinityWeights = hasArtists ? weights : { genre: 1, artist: 0 };
  const score = Math.max(0, Math.min(100, Math.round(100 * (effective.genre * G + effective.artist * (A ?? 0)))));

  const sharedFamilies = sharedKeys(profileA.families, profileB.families, SHARED_FAMILY_MIN);
  const sharedSubgenres = sharedKeys(
    new Map([...profileA.subgenres].filter(([k]) => !FAMILY_KEYS.has(k))),
    new Map([...profileB.subgenres].filter(([k]) => !FAMILY_KEYS.has(k))),
    SHARED_SUBGENRE_MIN,
  );
  const topFamiliesA = topKeys(profileA.families, 3, 0.2);
  const topFamiliesB = topKeys(profileB.families, 3, 0.2);

  const reasons: AffinityReason[] = [];
  if (sharedFamilies.length) reasons.push({ code: "shared_families", families: sharedFamilies });
  if (sharedSubgenres.length) reasons.push({ code: "shared_subgenres", subgenres: sharedSubgenres });
  // Same main family, but each side's favourite subgenre in it differs
  // (e.g. Tech House vs Deep House inside Electronic).
  const mainShared = sharedFamilies[0];
  if (mainShared) {
    const favourite = (p: GenreProfile) =>
      topKeys(new Map([...p.subgenres].filter(([k]) => k !== mainShared && SUBGENRES.get(k)!.family === mainShared)), 1)[0];
    const fa = favourite(profileA), fb = favourite(profileB);
    if (fa && fb && fa !== fb) reasons.push({ code: "different_subgenres", family: mainShared });
  }
  const topA = topFamiliesA[0], topB = topFamiliesB[0];
  if (topA && topB && topA !== topB && (RELATIONS.get(`${topA}|${topB}`) ?? 0) >= 0.3) {
    const pair = [topA, topB].sort() as [string, string];
    reasons.push({ code: "related_families", families: pair });
  }
  if (shared.length) {
    reasons.push({ code: "shared_artists", count: shared.length, artists: shared.slice(0, 3).map((s) => s.name) });
  }
  // Diversity: how broad each taste is. Symmetric (the pattern names no side).
  const divA = profileDiversity(profileA), divB = profileDiversity(profileB);
  const tierA = diversityTier(divA), tierB = diversityTier(divB);
  if (tierA === "eclectic" && tierB === "eclectic") reasons.push({ code: "diversity", pattern: "both_eclectic" });
  else if (tierA === "focused" && tierB === "focused" && sharedFamilies.length) {
    reasons.push({ code: "diversity", pattern: "both_focused" });
  } else if (Math.abs(divA - divB) >= 40) reasons.push({ code: "diversity", pattern: "contrast" });

  if (!sharedFamilies.length && score < 45) reasons.push({ code: "discovery" });

  // Every result carries an explanation from the data. When none of the
  // above applies (e.g. rock-first with some jazz vs jazz-first with some
  // rock), name the families both actually listen to.
  if (!reasons.some((r) => r.code !== "diversity")) {
    const common = sharedKeys(profileA.families, profileB.families, Number.MIN_VALUE);
    if (common.length) reasons.push({ code: "common_ground", families: common });
    else if (score >= 45) {
      // Nothing in common at all, yet related: name the closest related pair.
      // Strongest relation first; ties broken alphabetically so A↔B agree.
      const pairs: Array<{ pair: [string, string]; w: number }> = [];
      for (const fa of profileA.families.keys()) {
        for (const fb of profileB.families.keys()) {
          const w = RELATIONS.get(`${fa}|${fb}`) ?? 0;
          if (w > 0) pairs.push({ pair: [fa, fb].sort() as [string, string], w });
        }
      }
      pairs.sort((x, y) => y.w - x.w || x.pair.join().localeCompare(y.pair.join()));
      if (pairs.length) reasons.push({ code: "related_families", families: pairs[0].pair });
    }
    if (!reasons.some((r) => r.code !== "diversity")) reasons.push({ code: "discovery" });
  }

  return {
    status: "ok",
    score,
    tier: tierFor(score),
    genre: Number(G.toFixed(4)),
    artist: A === null ? null : Number(A.toFixed(4)),
    weights: effective,
    sharedFamilies,
    sharedSubgenres,
    sharedArtists: shared.slice(0, 5).map((s) => s.name),
    sharedArtistCount: shared.length,
    topFamiliesA,
    topFamiliesB,
    reasons,
  };
}

/** Compact, client-safe explanation stored with the cached pair. */
export function affinityDetails(result: Extract<AffinityResult, { status: "ok" }>, userA: string, userB: string) {
  return {
    v: ALGORITHM_VERSION,
    tier: result.tier,
    genre: result.genre,
    artist: result.artist,
    weights: result.weights,
    shared_families: result.sharedFamilies,
    shared_subgenres: result.sharedSubgenres,
    shared_artists: result.sharedArtists,
    shared_artist_count: result.sharedArtistCount,
    top_families: { [userA]: result.topFamiliesA, [userB]: result.topFamiliesB },
    reasons: result.reasons,
  };
}
