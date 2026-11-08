import { assert, assertEquals } from "https://deno.land/std@0.208.0/assert/mod.ts";
import {
  computeMusicalDna, diversityTier, MANUAL_SHARE, percentages, refreshMusicalDna,
} from "./musical_dna.ts";

const sum = (xs: number[]) => xs.reduce((a, b) => a + b, 0);

Deno.test("percentages: largest remainder always adds up to 100", () => {
  assertEquals(percentages([1, 1, 1]), [34, 33, 33]);
  assertEquals(sum(percentages([0.401, 0.249, 0.15, 0.12, 0.08])), 100);
  assertEquals(percentages([]), []);
  assertEquals(percentages([0, 0]), [0, 0]);
});

Deno.test("no musical data → no DNA (never invented)", () => {
  assertEquals(computeMusicalDna({}), null);
  assertEquals(computeMusicalDna({ top_artists: [{ id: "a", name: "X", genres: ["escape room"] }] }), null);
  assertEquals(computeMusicalDna({ manual_genres: [{ genre_key: "not-a-genre", intensity: 90 }] }), null);
});

Deno.test("per-artist genres: rank, track reinforcement and artists per family", () => {
  const dna = computeMusicalDna({
    top_artists: [
      { id: "1", name: "Travis Scott", genres: ["rap", "trap"] },
      { id: "2", name: "Metallica", genres: ["thrash metal", "metal"] },
      { id: "3", name: "Unknown Band", genres: ["escape room"] },
    ],
    // Metallica fills the top tracks, so it outweighs its #2 artist slot.
    top_tracks: [
      { name: "One", artist: "Metallica" },
      { name: "Master of Puppets", artist: "Metallica" },
      { name: "Enter Sandman", artist: "Metallica" },
    ],
  })!;
  assertEquals(dna.families.map((f) => f.key), ["metal", "hip-hop"]);
  assertEquals(sum(dna.families.map((f) => f.percent)), 100);
  assertEquals(sum(dna.subgenres.map((s) => s.percent)), 100);
  assertEquals(dna.families[0].artists, ["Metallica"]);
  assertEquals(dna.families[1].artists, ["Travis Scott"]);
  assertEquals(dna.sources.artists, 3);
  assertEquals(dna.sources.artists_classified, 2);
  assertEquals(dna.sources.spotify_basis, "artists");
  // Every top artist is kept (ranked) for "recently discovered" comparisons.
  assertEquals(dna.artists.map((x) => x.key), ["id:1", "id:2", "id:3"]);
  // Travis Scott: rank 1.00 split over hip-hop + trap.
  const trap = dna.subgenres.find((s) => s.key === "trap")!;
  const hipHop = dna.subgenres.find((s) => s.key === "hip-hop")!;
  assertEquals(trap.share, hipHop.share);
});

Deno.test("an artist with many tags is not counted many times", () => {
  const dna = computeMusicalDna({
    top_artists: [
      { id: "1", name: "A", genres: ["trap", "drill", "phonk", "rage", "plugg"] },
      { id: "2", name: "B", genres: ["house"] },
    ],
  })!;
  const hip = dna.families.find((f) => f.key === "hip-hop")!;
  const elec = dna.families.find((f) => f.key === "electronic")!;
  // A (1.00) vs B (0.99): close to 50/50, not 5:1.
  assert(Math.abs(hip.share - elec.share) < 0.02, `${hip.share} vs ${elec.share}`);
});

Deno.test("older profiles fall back to aggregated top genres", () => {
  const dna = computeMusicalDna({
    top_artists: [{ id: "1", name: "A" }],
    top_genres: [{ genre: "trap", weight: 1 }, { genre: "dark trap", weight: 0.4 }, { genre: "rnb", weight: 0.5 }],
  })!;
  assertEquals(dna.sources.spotify_basis, "genres");
  assertEquals(dna.sources.artists, 0);
  // "dark trap" collapses onto Trap, keeping the stronger weight.
  assertEquals(dna.subgenres.map((s) => s.key), ["trap", "rnb"]);
  assertEquals(dna.subgenres.map((s) => s.percent), [67, 33]);
});

Deno.test("picked genres alone, and blended with Spotify", () => {
  const manualOnly = computeMusicalDna({
    manual_genres: [{ genre_key: "jazz", intensity: 100 }, { genre_key: "soul", intensity: 40 }],
  })!;
  assertEquals(manualOnly.sources.spotify, false);
  assertEquals(manualOnly.artists, []);
  assertEquals(manualOnly.sources.manual_genres, 2);
  assertEquals(manualOnly.subgenres.map((s) => [s.key, s.percent]), [["jazz", 71], ["soul", 29]]);

  const blended = computeMusicalDna({
    top_artists: [{ id: "1", name: "A", genres: ["techno"] }],
    manual_genres: [{ genre_key: "jazz", intensity: 70 }],
  })!;
  const jazz = blended.families.find((f) => f.key === "jazz")!;
  assertEquals(jazz.share, MANUAL_SHARE);
  assertEquals(blended.sources.spotify && blended.sources.manual, true);
});

Deno.test("diversity: one genre is focused, many families are eclectic", () => {
  const focused = computeMusicalDna({ manual_genres: [{ genre_key: "trap", intensity: 100 }] })!;
  assertEquals(focused.diversity.score, 0);
  assertEquals(focused.diversity.tier, "focused");
  const eclectic = computeMusicalDna({
    manual_genres: ["trap", "techno", "jazz", "metal", "reggae", "classical"].map((k) => ({ genre_key: k, intensity: 80 })),
  })!;
  assertEquals(eclectic.diversity.tier, "eclectic");
  assertEquals(eclectic.diversity.families, 6);
  assertEquals(diversityTier(34), "focused");
  assertEquals(diversityTier(35), "balanced");
  assertEquals(diversityTier(65), "eclectic");
});

Deno.test("deterministic: same input, same DNA", () => {
  const input = {
    top_artists: [{ id: "1", name: "A", genres: ["house", "techno"] }, { id: "2", name: "B", genres: ["techno"] }],
    manual_genres: [{ genre_key: "ambient", intensity: 50 }],
  };
  assertEquals(computeMusicalDna(input), computeMusicalDna(structuredClone(input)));
});

Deno.test("refreshMusicalDna stores the snapshot, or clears it without data", async () => {
  const calls: Array<[string, unknown]> = [];
  const admin = (input: unknown) => ({
    rpc: (name: string, args: unknown) => {
      calls.push([name, args]);
      return Promise.resolve(name === "get_musical_dna_input" ? { data: [input], error: null } : { data: null, error: null });
    },
  });
  const dna = await refreshMusicalDna(admin({ manual_genres: [{ genre_key: "trap", intensity: 90 }] }), "u1");
  assertEquals(dna?.families[0].key, "hip-hop");
  assertEquals(calls[1][0], "save_musical_dna");
  assertEquals((calls[1][1] as { p_dna: unknown }).p_dna, dna);

  calls.length = 0;
  assertEquals(await refreshMusicalDna(admin({}), "u1"), null);
  assertEquals((calls[1][1] as { p_dna: unknown }).p_dna, null);
});
