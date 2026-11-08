import { assert, assertEquals } from "https://deno.land/std@0.208.0/assert/mod.ts";
import { computeMusicalDna } from "./musical_dna.ts";
import { eventGenres, haversineKm, passesFilters, scoreEvent, type UserTaste } from "./event_recommendation.ts";

const now = new Date("2026-11-10T12:00:00Z");
const milan = { lat: 45.4642, lon: 9.19 };

const dna = computeMusicalDna({
  top_artists: [
    { id: "ts", name: "Travis Scott", genres: ["rap", "trap"] },
    { id: "sza", name: "SZA", genres: ["r&b", "alternative r&b"] },
  ],
  manual_genres: [{ genre_key: "techno", intensity: 40 }],
});

const taste = (over: Partial<UserTaste> = {}): UserTaste => ({
  dna,
  topArtists: [{ id: "ts", name: "Travis Scott" }, { id: "sza", name: "SZA" }],
  trackArtists: ["Metro Boomin"],
  interestArtists: [],
  interestFamilies: [],
  ...over,
});

const ev = (over: Record<string, unknown> = {}) => ({
  id: "e1",
  name: "Live",
  artist_name: null,
  genres: [] as string[],
  event_date: "2026-11-20T20:00:00Z",
  latitude: 45.48,
  longitude: 9.2,
  ...over,
});

Deno.test("Ticketmaster labels map onto the catalogue", () => {
  assertEquals(eventGenres(["Hip-Hop/Rap", "Undefined"]).families, ["hip-hop"]);
  assert(eventGenres(["Dance/Electronic"]).families.includes("electronic"));
  assertEquals(eventGenres(["Comedy"]).families, []);
});

Deno.test("top artist: strongest signal, explained with the artist and rank", () => {
  const r = scoreEvent(ev({ artist_name: "Travis Scott", genres: ["Hip-Hop/Rap"] }), taste(), { now, origin: milan });
  assertEquals(r.relevance, 100);
  assertEquals(r.reasons[0], { code: "top_artist", artist: "Travis Scott", rank: 1 });
  assert(r.reasons.some((x) => x.code === "genre"));
  assert(r.reasons.some((x) => x.code === "distance"));
  assert(r.reasons.some((x) => x.code === "soon" && x.days === 10));
});

Deno.test("genre-only users get recommendations from their DNA", () => {
  const genreOnly = computeMusicalDna({ manual_genres: [{ genre_key: "techno", intensity: 100 }] });
  const r = scoreEvent(
    ev({ genres: ["Dance/Electronic", "Techno"] }),
    { dna: genreOnly, topArtists: [], trackArtists: [], interestArtists: [], interestFamilies: [] },
    { now, origin: milan },
  );
  assert(r.relevance >= 75, `${r.relevance}`);
  assertEquals(r.reasons[0], { code: "genre", genre: "techno", percent: 100 });
});

Deno.test("previous interest: a saved artist, or a family saved twice", () => {
  const saved = scoreEvent(ev({ artist_name: "Bonobo", genres: ["Electronic"] }), taste({ interestArtists: ["Bonobo"] }), { now });
  assert(saved.reasons.some((x) => x.code === "saved_artist"));
  const twice = scoreEvent(ev({ artist_name: "Unknown", genres: ["Jazz"] }), taste({ interestFamilies: ["jazz", "jazz"] }), { now });
  assert(twice.reasons.some((x) => x.code === "similar_to_saved"));
  const once = scoreEvent(ev({ artist_name: "Unknown", genres: ["Jazz"] }), taste({ interestFamilies: ["jazz"] }), { now });
  assertEquals(once.relevance, 0);
});

Deno.test("no musical signal: relevance 0 and no reasons (never invented)", () => {
  const r = scoreEvent(ev({ artist_name: "Opera Company", genres: ["Opera"] }), taste(), { now, origin: milan });
  assertEquals(r.relevance, 0);
  assertEquals(r.reasons, []);
});

Deno.test("distance only when both coordinates exist; filters apply", () => {
  const far = ev({ artist_name: "SZA", genres: ["R&B"], latitude: 41.9, longitude: 12.5 });
  const r = scoreEvent(far, taste(), { now, origin: milan });
  assert(r.distanceKm! > 400);
  assertEquals(passesFilters(r, far, { radiusKm: 100 }), false);
  assertEquals(passesFilters(r, far, { family: "rnb" }), true);
  assertEquals(passesFilters(r, far, { family: "metal" }), false);
  assertEquals(passesFilters(r, far, { artist: "sza" }), true);
  const noCoords = scoreEvent(ev({ artist_name: "SZA", latitude: null }), taste(), { now, origin: milan });
  assertEquals(noCoords.distanceKm, null);
  assert(!noCoords.reasons.some((x) => x.code === "distance"));
  assert(Math.abs(haversineKm(45.4642, 9.19, 41.9028, 12.4964) - 477) < 5);
});
