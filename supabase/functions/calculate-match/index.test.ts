import { assert, assertEquals } from "https://deno.land/std@0.208.0/assert/mod.ts";
import {
  eventCompatibility, rankWeight, weightedJaccard,
} from "../_shared/music_match.ts";
import { familiesOf, familyWeights } from "../_shared/genre_taxonomy.ts";

const artists = (ids: string[]) => ids.map((id, i) => ({ id, name: `Artist ${id}`, score: 100 - i }));
const genres = (pairs: Array<[string, number]>) => pairs.map(([genre, weight]) => ({ genre, weight }));

Deno.test("rank weight: #1 counts 1.00, #50 counts 0.51", () => {
  assertEquals(rankWeight(0), 1);
  assertEquals(rankWeight(49), 0.51);
});

Deno.test("weighted Jaccard is 1 for identical and 0 for disjoint profiles", () => {
  const a = new Map([["x", 1], ["y", 0.5]]);
  assertEquals(weightedJaccard(a, a), 1);
  assertEquals(weightedJaccard(a, new Map([["z", 1]])), 0);
  assertEquals(weightedJaccard(new Map(), new Map()), 0);
});

// People ↔ people affinity tests: _shared/music_affinity.test.ts.

Deno.test("Spotify micro-genres and Ticketmaster classifications share families", () => {
  assert(familiesOf("Hip-Hop/Rap").includes("hip-hop"));
  assert(familiesOf("italian hip hop").includes("hip-hop"));
  assert(familiesOf("Dance/Electronic").includes("electronic"));
  assert(familiesOf("deep house").includes("house"));
  assert(familiesOf("deep house").includes("electronic"));
  assert(familiesOf("indie rock").includes("indie") && familiesOf("indie rock").includes("rock"));
  assertEquals(familiesOf("Undefined"), []);
  assertEquals(familyWeights(genres([["indie pop", 0.5], ["indie rock", 1]])).get("indie"), 1);
});

Deno.test("event compatibility: top artist → 100, genre fit → ≤ 80, unrelated → 0", () => {
  const profile = { top_artists: artists(["sp1"]).map((a) => ({ ...a, name: "Calcutta" })), top_genres: genres([["italian indie pop", 1]]) };
  assertEquals(eventCompatibility(profile, { artist_name: "Calcutta", genres: ["Rock"] }).compatibility, 100);
  assertEquals(eventCompatibility(profile, { artist_spotify_id: "sp1" }).compatibility, 100);
  assertEquals(eventCompatibility(profile, { artist_name: "Other band", genres: ["Pop"] }).compatibility, 80);
  assertEquals(eventCompatibility(profile, { artist_name: "Metal band", genres: ["Metal"] }).compatibility, 0);
  // Names match on word boundaries only.
  assertEquals(eventCompatibility(profile, { name: "Calcuttarama festival", genres: [] }).compatibility, 0);
});
