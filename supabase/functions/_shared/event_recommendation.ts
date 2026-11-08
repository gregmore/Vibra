// Concert Intelligence: person ↔ event recommendations with reasons
// (docs/concert-intelligence.md). Pure and deterministic.
//
// Signals, all from the user's own data or the event's published data:
//   A  artist   – the event's artist is one of the user's Spotify top artists
//                 (rank weight), or performs on their top tracks (half weight)
//   G  genre    – the event's Ticketmaster genres, classified with the same
//                 catalogue as the Musical DNA, against the user's DNA shares
//   I  interest – the user saved / clicked tickets for this artist before, or
//                 for ≥ 2 events of this genre family
//   relevance = 1 − (1 − A)(1 − 0.8·G)(1 − 0.5·I)
//   total     = 0.60·relevance + 0.25·proximity + 0.15·soonness   (0–100)
// Events with no musical signal at all are not "recommended".
import { classifyGenre } from "./music_affinity.ts";
import type { MusicalDna } from "./musical_dna.ts";
import { normalizeArtistName, rankWeight } from "./music_match.ts";
import { clamp, proximityScore } from "./geo.ts";

export type RecEvent = {
  id: string;
  name: string;
  artist_name?: string | null;
  artist_spotify_id?: string | null;
  genres?: string[] | null;
  event_date: string;
  latitude?: number | null;
  longitude?: number | null;
};

export type UserTaste = {
  dna: MusicalDna | null;
  /** Spotify top artists, ranked. */
  topArtists: Array<{ id?: string | null; name?: string | null }>;
  /** Artists of Spotify top tracks, ranked. */
  trackArtists: string[];
  /** Artists of events the user saved or clicked tickets for. */
  interestArtists: string[];
  /** Families of events the user saved or clicked (with repeats). */
  interestFamilies: string[];
};

export type EventReason =
  | { code: "top_artist"; artist: string; rank: number }
  | { code: "track_artist"; artist: string }
  | { code: "saved_artist"; artist: string }
  | { code: "genre"; genre: string; percent: number }
  | { code: "similar_to_saved"; family: string }
  | { code: "distance"; km: number }
  | { code: "soon"; days: number };

export type EventRecommendation = {
  relevance: number; // 0–100
  total: number; // 0–100
  artist: number;
  genre: number;
  interest: number;
  proximity: number;
  soonness: number;
  distanceKm: number | null;
  families: string[];
  reasons: EventReason[];
};

const round2 = (v: number) => Number(v.toFixed(2));

export function haversineKm(lat1: number, lon1: number, lat2: number, lon2: number): number {
  const r = (d: number) => (d * Math.PI) / 180;
  const a = Math.sin(r(lat2 - lat1) / 2) ** 2 +
    Math.cos(r(lat1)) * Math.cos(r(lat2)) * Math.sin(r(lon2 - lon1) / 2) ** 2;
  return 6371 * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

/** Catalogue families and subgenres of an event's published genres. */
export function eventGenres(labels: string[] | null | undefined) {
  const subgenres = new Set<string>();
  const families = new Set<string>();
  for (const label of labels ?? []) {
    const c = classifyGenre(label);
    if (c) {
      subgenres.add(c.subgenre);
      families.add(c.family);
    }
  }
  return { subgenres: [...subgenres], families: [...families] };
}

function containsName(haystack: string, name: string): boolean {
  const n = normalizeArtistName(name);
  return n.length >= 3 && ` ${haystack} `.includes(` ${n} `);
}

export function scoreEvent(
  event: RecEvent,
  taste: UserTaste,
  options: { now: Date; origin?: { lat: number; lon: number } | null },
): EventRecommendation {
  const artistReasons: EventReason[] = [];
  const title = normalizeArtistName(`${event.artist_name ?? ""} ${event.name ?? ""}`);

  // ── Artist ──────────────────────────────────────────────────────────
  let artist = 0;
  taste.topArtists.slice(0, 50).forEach((a, index) => {
    if (artist > 0) return;
    const byId = !!a?.id && a.id === event.artist_spotify_id;
    if (byId || (a?.name && containsName(title, a.name))) {
      artist = rankWeight(index);
      artistReasons.push({ code: "top_artist", artist: a?.name ?? event.artist_name ?? "", rank: index + 1 });
    }
  });
  if (artist === 0) {
    const track = taste.trackArtists.findIndex((name) => containsName(title, name));
    if (track >= 0) {
      artist = 0.5 * rankWeight(track);
      artistReasons.push({ code: "track_artist", artist: taste.trackArtists[track] });
    }
  }

  // ── Genre (Musical DNA) ─────────────────────────────────────────────
  const { subgenres, families } = eventGenres(event.genres);
  let genre = 0;
  let genreReason: EventReason | null = null;
  const dna = taste.dna;
  if (dna && dna.families.length) {
    const topFamily = dna.families[0].share || 1;
    const topSub = Math.max(...dna.subgenres.map((s) => s.share), 0) || 1;
    for (const key of subgenres) {
      const s = dna.subgenres.find((x) => x.key === key);
      if (s && s.key !== s.family) {
        const w = clamp(s.share / topSub, 0, 1);
        if (w > genre) {
          genre = w;
          genreReason = { code: "genre", genre: s.key, percent: s.percent };
        }
      }
    }
    for (const key of families) {
      const f = dna.families.find((x) => x.key === key);
      if (f) {
        const w = 0.8 * clamp(f.share / topFamily, 0, 1);
        if (w > genre) {
          genre = w;
          genreReason = { code: "genre", genre: f.key, percent: f.percent };
        }
      }
    }
  }
  // A weak genre fit (< 10% of the DNA) is not a reason to recommend.
  if (genreReason && genreReason.code === "genre" && genreReason.percent < 10) {
    genre = 0;
    genreReason = null;
  }

  // ── Previous interest ───────────────────────────────────────────────
  let interest = 0;
  let interestReason: EventReason | null = null;
  const savedArtist = taste.interestArtists.find((a) => containsName(title, a));
  if (savedArtist) {
    interest = 1;
    interestReason = { code: "saved_artist", artist: savedArtist };
  } else {
    const counts = new Map<string, number>();
    for (const f of taste.interestFamilies) counts.set(f, (counts.get(f) ?? 0) + 1);
    const family = families.find((f) => (counts.get(f) ?? 0) >= 2);
    if (family) {
      interest = 0.5;
      interestReason = { code: "similar_to_saved", family };
    }
  }
  // Most specific first: the artist, then the genre, then past interest.
  const reasons: EventReason[] = [
    ...artistReasons,
    ...(genreReason ? [genreReason] : []),
    ...(interestReason ? [interestReason] : []),
  ];

  const relevance = 1 - (1 - artist) * (1 - 0.8 * genre) * (1 - 0.5 * interest);

  // ── Place and time ─────────────────────────────────────────────────
  let distanceKm: number | null = null;
  if (options.origin && typeof event.latitude === "number" && typeof event.longitude === "number") {
    distanceKm = haversineKm(options.origin.lat, options.origin.lon, event.latitude, event.longitude);
  }
  const proximity = distanceKm === null ? 0 : proximityScore(distanceKm);
  const days = (Date.parse(event.event_date) - options.now.getTime()) / 86_400_000;
  const soonness = clamp(100 - (days / 180) * 100, 0, 100);
  if (relevance > 0) {
    if (distanceKm !== null) reasons.push({ code: "distance", km: Math.max(1, Math.round(distanceKm)) });
    if (days >= 0 && days <= 14) reasons.push({ code: "soon", days: Math.max(0, Math.floor(days)) });
  }

  const relevance100 = Math.round(relevance * 100);
  return {
    relevance: relevance100,
    total: round2(relevance100 * 0.6 + proximity * 0.25 + soonness * 0.15),
    artist: round2(artist * 100),
    genre: round2(genre * 100),
    interest: round2(interest * 100),
    proximity: round2(proximity),
    soonness: round2(soonness),
    distanceKm: distanceKm === null ? null : Number(distanceKm.toFixed(1)),
    families,
    reasons,
  };
}

export type RecFilters = {
  family?: string | null;
  artist?: string | null;
  radiusKm?: number | null;
};

/** Applies the user's filters that need computed data (genre, distance). */
export function passesFilters(rec: EventRecommendation, event: RecEvent, f: RecFilters): boolean {
  if (f.family && !rec.families.includes(f.family)) return false;
  if (f.artist) {
    const q = normalizeArtistName(f.artist);
    const hay = normalizeArtistName(`${event.artist_name ?? ""} ${event.name ?? ""}`);
    if (q && !hay.includes(q)) return false;
  }
  if (f.radiusKm && rec.distanceKm !== null && rec.distanceKm > f.radiusKm) return false;
  return true;
}
