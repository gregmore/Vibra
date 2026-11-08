import { assertEquals } from "https://deno.land/std@0.208.0/assert/mod.ts";
import {
  buildProfile, type Candidate, diversify, explorationTargets, genreKeysOf, QUOTAS, scoreCandidate,
  searchTermFor, toRows,
} from "./artist_discovery.ts";

const id = (n: number) => `A${String(n).padStart(21, "0")}`;
const input = {
  dna: {
    families: [{ key: "hip-hop", share: 0.7 }, { key: "rnb", share: 0.2 }],
    subgenres: [{ key: "trap", share: 0.5 }, { key: "melodic-rap", share: 0.3 }],
    artists: [{ key: "travis-scott", name: "Travis Scott" }],
  },
  top_artists: [{ id: id(1), name: "Travis Scott", genres: ["rap"] }],
  picked_genres: ["underground-hip-hop"],
  discovered_artists: ["sfera ebbasta, guè"],
  feedback: [
    { artist_id: id(2), name: "Nope", reaction: "not_interested", saved: false, genre_keys: ["country", "country-pop"] },
    { artist_id: id(3), name: "Known", reaction: "known", saved: false, genre_keys: ["trap"] },
    { artist_id: id(4), name: "Loved", reaction: "like", saved: false, genre_keys: ["drill", "hip-hop"] },
    { artist_id: id(5), name: "Later", reaction: null, saved: true, genre_keys: ["cloud-rap"] },
  ],
  shown: { [id(9)]: 3, [id(10)]: 1 },
};
const cand = (n: number, over: Partial<Candidate> = {}): Candidate => ({
  id: id(n), name: `Artist ${n}`, genres: ["trap"], popularity: 60, followers: 500_000, image_url: null,
  source: "genre", ...over,
});

Deno.test("profile uses DNA, picked genres, top and discovered artists, and feedback", () => {
  const p = buildProfile(input);
  assertEquals(p.topFamilies[0], "hip-hop");
  assertEquals(p.genres.has("underground-hip-hop"), true);
  for (const n of [1, 2, 3, 4, 5]) assertEquals(p.excludedIds.has(id(n)), true, `id ${n}`);
  assertEquals(p.excludedNames.has("guè"), true);
  assertEquals(p.likedGenres.get("drill"), 1);
  assertEquals(p.dislikedGenres.get("country"), 1);
});

Deno.test("dismissed, known, mine, discovered and over-shown artists are never recommended", () => {
  const p = buildProfile(input);
  for (const c of [cand(2), cand(3), cand(1), cand(9), cand(20, { name: "Sfera Ebbasta" })]) {
    assertEquals(scoreCandidate(c, p), null, c.name);
  }
  assertEquals(scoreCandidate(cand(10), p) !== null, true);
  assertEquals(scoreCandidate(cand(10), p)!.score < scoreCandidate(cand(11), p)!.score, true);
});

Deno.test("feedback steers: liked styles rise, disliked styles disappear", () => {
  const p = buildProfile({ ...input, feedback: [
    ...input.feedback,
    { artist_id: id(6), name: "Nope 2", reaction: "not_interested", saved: false, genre_keys: ["country"] },
  ] });
  assertEquals(scoreCandidate(cand(30, { genres: ["country"] }), p), null);
  const drill = scoreCandidate(cand(31, { genres: ["uk drill"] }), p)!;
  const plain = scoreCandidate(cand(32, { genres: ["uk drill"] }), buildProfile({ ...input, feedback: [] }))!;
  assertEquals(drill.score > plain.score, true);
});

Deno.test("popularity sorts into underground, emerging and the rest", () => {
  const p = buildProfile(input);
  assertEquals(scoreCandidate(cand(40, { popularity: 12, followers: 3_000 }), p)!.bucket, "underground");
  assertEquals(scoreCandidate(cand(41, { popularity: 40, followers: 40_000 }), p)!.bucket, "emerging");
  assertEquals(scoreCandidate(cand(42, { popularity: 70, source: "collaboration", seed_artist: "Travis Scott" }), p)!.bucket, "collaboration");
  assertEquals(scoreCandidate(cand(43, { popularity: 70 }), p)!.bucket, "similar");
  assertEquals(scoreCandidate(cand(44, { popularity: 70, source: "exploration", genres: ["neo soul"] }), p)!.bucket, "exploration");
  // Less popular ranks a little higher, all else equal.
  assertEquals(scoreCandidate(cand(45, { popularity: 30 }), p)!.score > scoreCandidate(cand(46, { popularity: 90 }), p)!.score, true);
});

Deno.test("diversity: every kind is represented and no genre or seed dominates", () => {
  const p = buildProfile(input);
  const many: Candidate[] = [];
  for (let i = 100; i < 160; i++) many.push(cand(i, { popularity: 75 })); // all "similar", all trap
  for (let i = 200; i < 205; i++) many.push(cand(i, { popularity: 15, genres: ["underground hip hop"] }));
  for (let i = 300; i < 305; i++) many.push(cand(i, { popularity: 70, source: "collaboration", seed_artist: "Travis Scott", genres: ["melodic rap"] }));
  for (let i = 400; i < 404; i++) many.push(cand(i, { popularity: 70, source: "exploration", genres: [["neo soul", "afrobeats", "uk garage", "jazz rap"][i - 400]] }));
  const scored = many.map((c) => scoreCandidate(c, p)).filter((s) => s !== null);
  const out = diversify(scored);
  const count = (b: string) => out.filter((s) => s.bucket === b).length;
  assertEquals(count("underground") > 0, true);
  assertEquals(count("exploration") > 0, true);
  assertEquals(count("collaboration") <= 2, true); // max 2 per seed artist
  assertEquals(out.filter((s) => s.genre_keys.includes("trap") && s.genre_keys[0] === "trap").length <= 3, true);
  assertEquals(new Set(out.map((s) => s.id)).size, out.length);
  // Kinds are interleaved, not grouped.
  assertEquals(out[0].bucket !== out[1].bucket, true);
  assertEquals(Object.values(QUOTAS).reduce((a, b) => a + b), 30);
});

Deno.test("exploration targets neighbouring families, rows carry facts only", () => {
  const p = buildProfile(input);
  const targets = explorationTargets(p);
  assertEquals(targets.length, 2);
  assertEquals(targets.includes("hip-hop"), false);
  assertEquals(searchTermFor("underground-hip-hop"), "underground hip hop");
  assertEquals(genreKeysOf(["italian trap"]).includes("italian-hip-hop"), true);
  const row = toRows([scoreCandidate(cand(50, { source: "collaboration", seed_artist: "Travis Scott" }), p)!])[0];
  assertEquals(row.reason.seed_artist, "Travis Scott");
  assertEquals(row.reason.shared_genres, ["Trap"]);
});
