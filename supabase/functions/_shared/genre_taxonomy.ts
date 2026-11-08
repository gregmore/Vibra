// One genre vocabulary for Spotify and Ticketmaster.
//
// Spotify describes artists with thousands of micro-genres ("italian indie
// pop", "deep house"); Ticketmaster classifies events with a short list
// ("Rock", "Hip-Hop/Rap", "Dance/Electronic") plus sub-genres. They never
// match 1:1, so both sides are normalised into the same families below and
// all comparisons (people ↔ people, person ↔ event) happen on families.
// A genre may belong to several families ("indie rock" → indie + rock).

export const GENRE_FAMILIES = [
  "pop", "rock", "indie", "alternative", "metal", "punk", "hip-hop", "rnb",
  "electronic", "house", "techno", "jazz", "blues", "classical", "folk",
  "country", "latin", "reggae", "world", "soundtrack", "italian",
] as const;
export type GenreFamily = typeof GENRE_FAMILIES[number];

// Ordered keyword rules, matched on word boundaries against a normalised
// genre string. Keep keywords lowercase ASCII.
const RULES: Array<[GenreFamily, string[]]> = [
  ["hip-hop", ["hip hop", "hiphop", "rap", "trap", "drill", "grime"]],
  ["rnb", ["r&b", "rnb", "soul", "funk", "neo soul", "motown"]],
  ["house", ["house", "uk garage"]],
  ["techno", ["techno", "minimal", "hardstyle"]],
  ["electronic", [
    "electronic", "electronica", "edm", "dance", "electro", "dubstep", "drum and bass",
    "dnb", "trance", "ambient", "synth", "idm", "downtempo", "house", "techno", "club",
  ]],
  ["metal", ["metal", "metalcore", "deathcore", "grindcore", "djent"]],
  ["punk", ["punk", "hardcore", "emo", "post-hardcore"]],
  ["indie", ["indie", "lo-fi", "lofi", "bedroom"]],
  ["alternative", ["alternative", "alt", "post-rock", "shoegaze", "grunge", "new wave", "post-punk"]],
  ["rock", ["rock", "grunge", "shoegaze", "britpop", "garage rock", "psych"]],
  ["pop", ["pop", "k-pop", "j-pop", "europop", "dance pop", "teen"]],
  ["jazz", ["jazz", "swing", "bebop", "bossa nova"]],
  ["blues", ["blues"]],
  ["classical", ["classical", "orchestra", "opera", "baroque", "chamber", "symphon", "piano"]],
  ["folk", ["folk", "singer-songwriter", "cantautor", "acoustic", "americana"]],
  ["country", ["country", "bluegrass"]],
  ["latin", ["latin", "reggaeton", "salsa", "bachata", "cumbia", "urbano", "flamenco"]],
  ["reggae", ["reggae", "dancehall", "ska", "dub"]],
  ["world", ["world", "afro", "afrobeat", "celtic", "balkan"]],
  ["soundtrack", ["soundtrack", "score", "musicals", "show tunes"]],
  ["italian", ["italian", "italiano", "cantautorato", "musica leggera"]],
];

export function normalizeGenre(value: string): string {
  return value
    .normalize("NFKD").replace(/[̀-ͯ]/g, "")
    .toLowerCase()
    .replace(/\//g, " ")
    .replace(/[^a-z0-9&\- ]+/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function containsKeyword(genre: string, keyword: string): boolean {
  // Word-boundary match so "rap" does not hit "trap" twice or "scrap".
  const escaped = keyword.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  return new RegExp(`(^|[ \\-])${escaped}($|[ \\-])`).test(genre) ||
    (keyword.length >= 6 && genre.includes(keyword));
}

/** Families for one genre label (Spotify or Ticketmaster). */
export function familiesOf(genre: string): GenreFamily[] {
  const normalized = normalizeGenre(genre);
  if (!normalized || normalized === "undefined" || normalized === "other") return [];
  const result = new Set<GenreFamily>();
  for (const [family, keywords] of RULES) {
    if (keywords.some((keyword) => containsKeyword(normalized, keyword))) result.add(family);
  }
  return [...result];
}

/**
 * Weighted family profile from weighted genres. Each family takes the
 * strongest weight among the genres that map to it, then the profile is
 * scaled so its strongest family is 1.
 */
export function familyWeights(genres: Array<{ genre: string; weight: number }>): Map<GenreFamily, number> {
  const weights = new Map<GenreFamily, number>();
  for (const { genre, weight } of genres) {
    const w = Number.isFinite(weight) ? Math.max(0, Math.min(1, weight)) : 0;
    if (w <= 0 || typeof genre !== "string") continue;
    for (const family of familiesOf(genre)) {
      weights.set(family, Math.max(weights.get(family) ?? 0, w));
    }
  }
  const max = Math.max(0, ...weights.values());
  if (max > 0) for (const [k, v] of weights) weights.set(k, Number((v / max).toFixed(4)));
  return weights;
}

/** Unweighted family set for an event's genre labels. */
export function eventFamilies(genres: string[]): Set<GenreFamily> {
  return new Set(genres.flatMap((genre) => familiesOf(genre)));
}
