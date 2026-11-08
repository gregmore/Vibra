import { assert, assertEquals } from "https://deno.land/std@0.208.0/assert/mod.ts";
import {
  type AffinityInput, type AffinityResult, buildGenreProfile, classifyGenre, computeAffinity, DEFAULT_WEIGHTS,
  diversityScore, MIN_GENRE_WEIGHT, readAffinityWeights, subgenreSimilarity, tierFor,
} from "./music_affinity.ts";
import { GENRE_CATALOG } from "./genre_catalog.ts";
import { affinityFingerprint, recomputeMatches } from "./music_sync.ts";

const g = (...pairs: Array<[string, number]>) => pairs.map(([genre, weight]) => ({ genre, weight }));
const a = (...names: string[]) => names.map((name) => ({ id: `sp-${name.toLowerCase().replace(/\W+/g, "-")}`, name }));
const ok = (x: AffinityInput, y: AffinityInput) => {
  const r = computeAffinity(x, y);
  if (r.status !== "ok") throw new Error(`expected a score, got ${JSON.stringify(r)}`);
  return r;
};

// Realistic Spotify labels for the brief's three listeners.
const TRAVIS: AffinityInput = {
  top_artists: a("Travis Scott", "Playboi Carti", "Future", "Young Thug"),
  top_genres: g(["rap", 1], ["trap", 0.95], ["hip hop", 0.9], ["cloud rap", 0.6], ["melodic rap", 0.5], ["atl hip hop", 0.5]),
};
const KANYE: AffinityInput = {
  top_artists: a("Kanye West", "Kendrick Lamar", "Don Toliver", "Metro Boomin"),
  top_genres: g(["hip hop", 1], ["rap", 0.95], ["conscious hip hop", 0.5], ["trap", 0.5], ["west coast rap", 0.4], ["chicago rap", 0.4], ["alternative r&b", 0.3]),
};
const METAL: AffinityInput = {
  top_artists: a("Metallica", "Slipknot", "Iron Maiden", "Korn"),
  top_genres: g(["metal", 1], ["thrash metal", 0.6], ["nu metal", 0.6], ["heavy metal", 0.5], ["hard rock", 0.5], ["rock", 0.4]),
};

Deno.test("catalogue: unique keys, every alias resolves, relations use known families", () => {
  const families = new Set(GENRE_CATALOG.families.map((f) => f.key as string));
  const keys = new Set<string>();
  for (const sub of GENRE_CATALOG.subgenres) {
    assert(!keys.has(sub.key), `duplicate ${sub.key}`);
    keys.add(sub.key);
    assert(families.has(sub.family), `${sub.key} → unknown family`);
    for (const alias of sub.aliases) assertEquals(classifyGenre(alias)?.subgenre, sub.key, alias);
  }
  for (const [x, y, w] of GENRE_CATALOG.relations) {
    assert(families.has(x) && families.has(y) && w > 0 && w < 1);
  }
});

Deno.test("normalisation: aliases, spelling variants, families and unknown labels", () => {
  assertEquals(classifyGenre("Trap")?.subgenre, "trap");
  assertEquals(classifyGenre("Trap")?.family, "hip-hop");
  assertEquals(classifyGenre("Cloud Rap")?.subgenre, "cloud-rap");
  assertEquals(classifyGenre("Alternative R&B"), { original: "Alternative R&B", family: "rnb", subgenre: "alternative-rnb" });
  assertEquals(classifyGenre("K-Pop")?.subgenre, "k-pop");
  assertEquals(classifyGenre("kpop")?.subgenre, "k-pop");
  assertEquals(classifyGenre("Drum & Bass")?.subgenre, "drum-and-bass");
  assertEquals(classifyGenre("Hip-Hop/Rap")?.family, "hip-hop");
  // Longest specific alias wins inside micro-genres.
  assertEquals(classifyGenre("italian trap")?.subgenre, "italian-hip-hop");
  assertEquals(classifyGenre("dark trap")?.subgenre, "trap");
  assertEquals(classifyGenre("rap metal")?.subgenre, "nu-metal");
  assertEquals(classifyGenre("atl hip hop")?.subgenre, "hip-hop");
  // Unknown labels are dropped, never forced into a family.
  assertEquals(classifyGenre("escape room"), null);
  assertEquals(classifyGenre(""), null);
  // Original Spotify label preserved; duplicates collapse in the profile.
  const profile = buildGenreProfile({ top_genres: g(["Trap", 0.4], ["trap", 1], ["TRAP", 0.2]) });
  assertEquals([...profile.subgenres], [["trap", 1]]);
});

Deno.test("same subgenre > sibling subgenre > related family > unrelated", () => {
  const same = subgenreSimilarity("trap", "trap");
  const sibling = subgenreSimilarity("trap", "drill");
  const related = subgenreSimilarity("trap", "alternative-rnb");
  const unrelated = subgenreSimilarity("trap", "thrash-metal");
  assert(same > sibling && sibling > related && related > unrelated);
  assertEquals(unrelated, 0);
  assertEquals(subgenreSimilarity("trap", "drill"), subgenreSimilarity("drill", "trap"));
});

Deno.test("TEST 1: identical genres and artists → very high (100)", () => {
  const r = ok(TRAVIS, TRAVIS);
  assertEquals(r.score, 100);
  assertEquals(r.tier, "exceptional");
});

Deno.test("TEST 2: related genres, different artists → high", () => {
  const r = ok(TRAVIS, KANYE);
  assertEquals(r.sharedArtistCount, 0);
  assert(r.score >= 65 && r.score < 80, `score ${r.score}`);
  assertEquals(r.tier, "high");
  assert(r.sharedFamilies.includes("hip-hop"));
  assert(r.sharedSubgenres.includes("trap"));
  // …and far above the metal listener.
  const metal = ok(TRAVIS, METAL);
  assert(metal.score <= 25, `metal ${metal.score}`);
  assert(r.score - metal.score >= 40);
});

Deno.test("TEST 3: identical artists, different secondary genres → high", () => {
  const x = { top_artists: TRAVIS.top_artists, top_genres: g(["trap", 1], ["hip hop", 0.8], ["alternative r&b", 0.5]) };
  const y = { top_artists: TRAVIS.top_artists, top_genres: g(["trap", 1], ["hip hop", 0.8], ["phonk", 0.5], ["house", 0.3]) };
  const r = ok(x, y);
  assert(r.score >= 80, `score ${r.score}`);
  assertEquals(r.sharedArtistCount, 4);
});

Deno.test("TEST 4: completely different genres → low, with a discovery reason", () => {
  const r = ok(TRAVIS, METAL);
  assert(r.score < 25);
  assertEquals(r.sharedFamilies, []);
  assert(r.reasons.some((x) => x.code === "discovery"));
});

Deno.test("TEST 5: Spotify disconnected, manual genres → valid genre-only score", () => {
  const manual: AffinityInput = { manual_genres: [{ genre_key: "trap", intensity: 90 }, { genre_key: "hip-hop", intensity: 80 }] };
  const r = ok(TRAVIS, manual);
  assertEquals(r.artist, null);
  assertEquals(r.weights, { genre: 1, artist: 0 });
  assert(r.score >= 80);
  // Unknown keys are ignored, not trusted.
  assertEquals(computeAffinity(TRAVIS, { manual_genres: [{ genre_key: "made-up", intensity: 100 }] }).status, "insufficient_data");
});

Deno.test("TEST 6: no musical information → insufficient data, never a number", () => {
  assertEquals(computeAffinity(TRAVIS, {}), { status: "insufficient_data", missing: ["b"] });
  assertEquals(computeAffinity({ top_artists: a("X"), top_genres: [] }, {}), { status: "insufficient_data", missing: ["a", "b"] });
  // Artists without any classifiable genre are not enough either.
  assertEquals(computeAffinity({ top_artists: a("X"), top_genres: g(["escape room", 1]) }, TRAVIS).status, "insufficient_data");
});

Deno.test("TEST 7: symmetric — reversed order gives the same score and reasons", () => {
  for (const [x, y] of [[TRAVIS, KANYE], [TRAVIS, METAL], [KANYE, METAL]]) {
    const ab = ok(x, y), ba = ok(y, x);
    assertEquals(ab.score, ba.score);
    assertEquals(ab.genre, ba.genre);
    assertEquals(ab.artist, ba.artist);
    assertEquals(ab.reasons, ba.reasons);
    assertEquals(ab.sharedFamilies, ba.sharedFamilies);
    assertEquals(ab.topFamiliesA, ba.topFamiliesB);
  }
});

Deno.test("preference intensity: two Trap enthusiasts beat an occasional listener", () => {
  const fan = { top_genres: g(["trap", 1]) };
  const occasional = { top_genres: g(["trap", 0.2], ["heavy metal", 1]) };
  assert(ok(fan, fan).score > ok(fan, occasional).score);
});

Deno.test("explanations come only from data: shared artists named, no invented reasons", () => {
  const x = { top_artists: a("Travis Scott", "Future", "Metro Boomin"), top_genres: g(["trap", 1], ["hip hop", 0.8]) };
  const y = { top_artists: a("Metro Boomin", "Future", "Drake"), top_genres: g(["trap", 1], ["pop rap", 0.6]) };
  const r = ok(x, y);
  const artists = r.reasons.find((reason) => reason.code === "shared_artists");
  assertEquals(artists, { code: "shared_artists", count: 2, artists: ["Future", "Metro Boomin"] });
  assert(!r.reasons.some((reason) => reason.code === "discovery"));
  // Same family, different specific subgenres (house world) is explained.
  const house1 = { top_genres: g(["tech house", 1], ["house", 0.5]) };
  const house2 = { top_genres: g(["deep house", 1], ["house", 0.5]) };
  assert(ok(house1, house2).reasons.some((reason) => reason.code === "different_subgenres"));
});

Deno.test("weights are configurable and redistribute when one side has no artists", () => {
  assertEquals(readAffinityWeights(), DEFAULT_WEIGHTS);
  assertEquals(readAffinityWeights((n) => n === "AFFINITY_GENRE_WEIGHT" ? "0.8" : undefined), { genre: 0.8, artist: 0.2 });
  // Out-of-range overrides fall back to the documented defaults.
  assertEquals(readAffinityWeights(() => "0.1"), DEFAULT_WEIGHTS);
  assertEquals(readAffinityWeights(() => "0.6"), DEFAULT_WEIGHTS);
  const genreOnly = computeAffinity(TRAVIS, KANYE, { genre: 1, artist: 0 });
  assert(genreOnly.status === "ok" && genreOnly.score > ok(TRAVIS, KANYE).score);
});

Deno.test("tiers follow the documented bands", () => {
  assertEquals([95, 85, 70, 50, 30, 10].map(tierFor), ["exceptional", "very_high", "high", "moderate", "low", "very_low"]);
  assertEquals([90, 80, 65, 45, 25, 24].map(tierFor), ["exceptional", "very_high", "high", "moderate", "low", "very_low"]);
});

// ── Weight calibration ─────────────────────────────────────────────────────
// Why 75/25: the engine must connect people through genres even when their
// artists differ, while shared artists still lift a pair. Over the whole
// accepted range (0.70–1.00) these hold; below 0.70 the first one breaks.
const SAME_ARTISTS_OTHER_GENRES: AffinityInput = {
  top_artists: TRAVIS.top_artists, top_genres: g(["pop", 1], ["dance pop", 0.6]),
};
const scoreWith = (w: number, x: AffinityInput, y: AffinityInput) => {
  const r = computeAffinity(x, y, { genre: w, artist: Number((1 - w).toFixed(2)) });
  if (r.status !== "ok") throw new Error("expected a score");
  return r.score;
};

Deno.test("calibration: invariants hold for every accepted weight", () => {
  for (let w = MIN_GENRE_WEIGHT; w <= 1.0001; w += 0.05) {
    const weight = Number(w.toFixed(2));
    const sameGenresOtherArtists = scoreWith(weight, TRAVIS, KANYE);
    assertEquals(scoreWith(weight, TRAVIS, TRAVIS), 100);
    assertEquals(scoreWith(weight, TRAVIS, METAL), 0);
    assert(sameGenresOtherArtists >= 65, `w=${weight}: ${sameGenresOtherArtists} should be high`);
    assert(sameGenresOtherArtists > scoreWith(weight, TRAVIS, SAME_ARTISTS_OTHER_GENRES), `w=${weight}`);
  }
  // Just below the accepted range, same-genre listeners fall under "high".
  assert(scoreWith(0.65, TRAVIS, KANYE) < 65);
  // At the default, identical artists with unrelated genres stay below moderate.
  assert(scoreWith(DEFAULT_WEIGHTS.genre, TRAVIS, SAME_ARTISTS_OTHER_GENRES) < 45);
});

// ── Properties over random profiles ────────────────────────────────────────
function rng(seed: number) {
  return () => {
    seed = (seed * 1664525 + 1013904223) >>> 0;
    return seed / 2 ** 32;
  };
}
const LABELS = ["trap", "drill", "hip hop", "alternative r&b", "neo soul", "house", "techno", "deep house",
  "indie rock", "punk", "thrash metal", "jazz", "blues", "reggaeton", "afrobeats", "k-pop", "pop", "ambient",
  "classical", "folk", "country", "escape room"];
const ARTISTS = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"];
function randomProfile(next: () => number): AffinityInput {
  const pick = <T>(xs: T[], n: number) => [...xs].sort(() => next() - 0.5).slice(0, n);
  const profile: AffinityInput = {};
  if (next() < 0.8) profile.top_genres = pick(LABELS, 1 + Math.floor(next() * 6)).map((genre) => ({ genre, weight: Number((0.1 + next() * 0.9).toFixed(2)) }));
  if (next() < 0.6) profile.top_artists = pick(ARTISTS, Math.floor(next() * 6)).map((name) => ({ id: name, name }));
  if (next() < 0.4) profile.manual_genres = pick(["trap", "jazz", "techno", "metal", "rnb"], 1 + Math.floor(next() * 2)).map((genre_key) => ({ genre_key, intensity: 40 + Math.floor(next() * 60) }));
  return profile;
}
function present(input: AffinityInput) {
  const profile = buildGenreProfile(input);
  return { families: profile.families, names: new Set((input.top_artists ?? []).map((x) => x.name)) };
}

Deno.test("properties: symmetric, 0–100, always explained, only from shared data", () => {
  const next = rng(42);
  let scored = 0;
  for (let i = 0; i < 400; i++) {
    const x = randomProfile(next), y = randomProfile(next);
    const xy = computeAffinity(x, y), yx = computeAffinity(y, x);
    assertEquals(xy.status, yx.status);
    if (xy.status !== "ok" || yx.status !== "ok") continue;
    scored++;
    assertEquals(xy.score, yx.score);
    assertEquals(xy.reasons, yx.reasons);
    assert(Number.isInteger(xy.score) && xy.score >= 0 && xy.score <= 100);
    assertEquals(xy.tier, tierFor(xy.score));
    assert(xy.reasons.some((r) => r.code !== "diversity"), `no explanation for ${JSON.stringify([x, y])}`);
    const px = present(x), py = present(y);
    for (const r of xy.reasons as Extract<AffinityResult, { status: "ok" }>["reasons"]) {
      if (r.code === "shared_families" || r.code === "common_ground") {
        for (const f of r.families) assert(px.families.has(f) && py.families.has(f), `${r.code} ${f}`);
      }
      if (r.code === "shared_artists") {
        for (const name of r.artists) assert(px.names.has(name) && py.names.has(name), name);
      }
    }
  }
  assert(scored > 150, `only ${scored} scored pairs`);
});

Deno.test("explanations: overlap without a shared main sound, and diversity", () => {
  const rock = { top_genres: g(["rock", 1], ["jazz", 0.3]) };
  const jazz = { top_genres: g(["jazz", 1], ["rock", 0.3]) };
  const r = ok(rock, jazz);
  assertEquals(r.reasons.filter((x) => x.code !== "diversity"), [{ code: "common_ground", families: ["jazz", "rock"] }]);

  const wide = (order: string[]) => ({ top_genres: order.map((genre, i) => ({ genre, weight: 1 - i * 0.05 })) });
  const e1 = wide(["trap", "techno", "jazz", "thrash metal", "reggae", "folk"]);
  const e2 = wide(["drill", "house", "blues", "punk", "afrobeats", "country"]);
  assert(ok(e1, e2).reasons.some((x) => x.code === "diversity" && x.pattern === "both_eclectic"));
  const trapOnly = { top_genres: g(["trap", 1]) };
  assert(ok(trapOnly, { top_genres: g(["trap", 1], ["drill", 0.2]) }).reasons
    .some((x) => x.code === "diversity" && x.pattern === "both_focused"));
  assert(ok(trapOnly, e1).reasons.some((x) => x.code === "diversity" && x.pattern === "contrast"));
  assertEquals(diversityScore([1], [1]), 0);
});

// ── Pipeline (fake service client) ─────────────────────────────────────────

type Call = { fn: string; args: Record<string, unknown> };
function fakeAdmin(
  self: AffinityInput,
  candidates: Array<{ user_id: string } & AffinityInput>,
  extra: Record<string, unknown> = {},
) {
  const calls: Call[] = [];
  return {
    calls,
    rpc(fn: string, args: Record<string, unknown>): Promise<{ data: unknown; error: unknown }> {
      calls.push({ fn, args });
      if (fn in extra) return Promise.resolve({ data: extra[fn], error: null });
      if (fn === "get_affinity_input") return Promise.resolve({ data: [{ user_id: args.p_user_id, ...self }], error: null });
      if (fn === "find_affinity_candidates") return Promise.resolve({ data: candidates, error: null });
      if (fn === "save_affinity_matches") return Promise.resolve({ data: (args.p_rows as unknown[]).length, error: null });
      return Promise.resolve({ data: null, error: { message: "unexpected" } });
    },
  };
}
const ME = "00000000-0000-0000-0000-00000000000b";
const LOW = "00000000-0000-0000-0000-00000000000a"; // sorts before ME
const HIGH = "00000000-0000-0000-0000-00000000000c";

Deno.test("TEST 8: a profile change replaces the cache in one transaction", async () => {
  const before = fakeAdmin(TRAVIS, [{ user_id: LOW, ...KANYE }, { user_id: HIGH, ...METAL }]);
  await recomputeMatches(before, ME, { weights: DEFAULT_WEIGHTS });
  const first = before.calls.find((c) => c.fn === "save_affinity_matches")!.args;
  // After the user's taste changes, the same pair gets a new score and the
  // write is flagged complete, so pairs no longer supported are deleted.
  const after = fakeAdmin(METAL, [{ user_id: LOW, ...KANYE }, { user_id: HIGH, ...METAL }]);
  await recomputeMatches(after, ME, { weights: DEFAULT_WEIGHTS });
  const second = after.calls.find((c) => c.fn === "save_affinity_matches")!.args;
  const score = (args: Record<string, unknown>, other: string) =>
    (args.p_rows as Array<{ user_id_a: string; user_id_b: string; compatibility: number }>)
      .find((r) => r.user_id_a === other || r.user_id_b === other)?.compatibility;
  assert(score(first, LOW)! > score(second, LOW)! || score(second, LOW) === undefined);
  assertEquals(score(second, HIGH), 100);
  assertEquals(second.p_complete, true);
  assertEquals(second.p_considered, [LOW, HIGH]);
});

Deno.test("pipeline: pairs stored as (a < b) with the same explanation from either side", async () => {
  const fromMe = fakeAdmin(TRAVIS, [{ user_id: LOW, ...KANYE }]);
  await recomputeMatches(fromMe, ME, { weights: DEFAULT_WEIGHTS });
  const fromOther = fakeAdmin(KANYE, [{ user_id: ME, ...TRAVIS }]);
  await recomputeMatches(fromOther, LOW, { weights: DEFAULT_WEIGHTS });
  const rowA = (fromMe.calls.findLast((c) => c.fn === "save_affinity_matches")!.args.p_rows as unknown[])[0];
  const rowB = (fromOther.calls.findLast((c) => c.fn === "save_affinity_matches")!.args.p_rows as unknown[])[0];
  assertEquals(rowA, rowB);
  assertEquals((rowA as { user_id_a: string }).user_id_a, LOW);
});

Deno.test("pipeline: insufficient data and zero scores are never stored", async () => {
  const admin = fakeAdmin(TRAVIS, [{ user_id: LOW }, { user_id: HIGH, ...METAL }]);
  await recomputeMatches(admin, ME, { weights: DEFAULT_WEIGHTS });
  const args = admin.calls.findLast((c) => c.fn === "save_affinity_matches")!.args;
  const stored = (args.p_rows as Array<{ compatibility: number }>);
  assert(stored.every((r) => r.compatibility > 0));
  assert(!JSON.stringify(stored).includes(LOW));
  // …but both were considered, so stale cached pairs with them are removed.
  assertEquals(args.p_considered, [LOW, HIGH]);
});

Deno.test("TEST 9/10: only candidates returned by the database are ever scored", async () => {
  // Blocked users, opted-out users and the other test segment are filtered
  // by find_affinity_candidates (pgTAP: supabase/tests/database/15_*). The
  // engine must not add anyone on its own.
  const admin = fakeAdmin(TRAVIS, []);
  await recomputeMatches(admin, ME, { weights: DEFAULT_WEIGHTS });
  assertEquals(admin.calls.findLast((c) => c.fn === "save_affinity_matches")!.args.p_rows, []);
});

Deno.test("stored details never carry tokens or listening history", async () => {
  const admin = fakeAdmin(TRAVIS, [{ user_id: HIGH, ...KANYE }]);
  await recomputeMatches(admin, ME, { weights: DEFAULT_WEIGHTS });
  const details = JSON.stringify((admin.calls.findLast((c) => c.fn === "save_affinity_matches")!.args.p_rows as Array<{ details: unknown }>)[0].details);
  for (const forbidden of ["token", "played_at", "heatmap", "sp-"]) assert(!details.includes(forbidden), forbidden);
});

// ── Incremental updates (docs/performance.md) ─────────────────────────────

Deno.test("fingerprint is stable across key order and changes with the input", async () => {
  const a = await affinityFingerprint(TRAVIS, DEFAULT_WEIGHTS);
  const reordered = Object.fromEntries(Object.entries(TRAVIS).reverse()) as AffinityInput;
  assertEquals(await affinityFingerprint(reordered, DEFAULT_WEIGHTS), a);
  const changed = { ...TRAVIS, top_artists: [...(TRAVIS.top_artists ?? []).slice(1)] } as AffinityInput;
  assert((await affinityFingerprint(changed, DEFAULT_WEIGHTS)) !== a);
  assertEquals(a.length, 64);
});

Deno.test("unchanged inputs reuse the cached pairs without scoring candidates", async () => {
  const admin = fakeAdmin(TRAVIS, [{ user_id: HIGH, ...TRAVIS }], { affinity_cached_count: 7 });
  assertEquals(await recomputeMatches(admin, ME, { weights: DEFAULT_WEIGHTS, onlyIfChanged: true }), 7);
  assertEquals(admin.calls.map((c) => c.fn), ["get_affinity_input", "affinity_cached_count"]);
});

Deno.test("a changed input is recomputed and its fingerprint recorded", async () => {
  const admin = fakeAdmin(TRAVIS, [{ user_id: HIGH, ...TRAVIS }], {
    affinity_cached_count: null, record_affinity_fingerprint: null,
  });
  await recomputeMatches(admin, ME, { weights: DEFAULT_WEIGHTS, onlyIfChanged: true });
  assertEquals(admin.calls.map((c) => c.fn).slice(-2), ["save_affinity_matches", "record_affinity_fingerprint"]);
  assertEquals(
    admin.calls.find((c) => c.fn === "record_affinity_fingerprint")!.args.p_fingerprint,
    admin.calls.find((c) => c.fn === "affinity_cached_count")!.args.p_fingerprint,
  );
});
