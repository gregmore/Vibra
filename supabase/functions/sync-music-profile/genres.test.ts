import { loadTopGenres, SpotifyRequestError } from "./genres.ts";

function equal(actual: unknown, expected: unknown) {
  if (JSON.stringify(actual) !== JSON.stringify(expected)) {
    throw new Error(`Expected ${JSON.stringify(expected)}, got ${JSON.stringify(actual)}`);
  }
}

Deno.test("hydrates empty and missing genres for every artist, retaining existing genres", async () => {
  const requested: string[] = [];
  const genres = await loadTopGenres([
    { id: "a", genres: [" Rap ", "rap", "", null] },
    { id: "b", genres: [] },
    { id: "c" },
    { id: "a", genres: ["rap"] },
  ], async (id) => {
    requested.push(id);
    return { id, genres: id === "b" ? ["rap", "trap"] : ["pop"] };
  });
  equal(requested, ["b", "c"]);
  equal(genres, [
    { genre: "rap", weight: 1 },
    { genre: "pop", weight: 0.5 },
    { genre: "trap", weight: 0.5 },
  ]);
});

Deno.test("does not stop at the first artist when its full genres are empty", async () => {
  const genres = await loadTopGenres([{ id: "a", genres: [] }, { id: "b" }],
    async (id) => ({ id, genres: id === "a" ? [] : ["rock"] }));
  equal(genres, [{ genre: "rock", weight: 1 }]);
});

Deno.test("access and rate limits stop hydration but retain all supplied genres", async () => {
  for (const status of [401, 403, 429]) {
    let calls = 0;
    const genres = await loadTopGenres([
      { id: "a" }, { id: "b" }, { id: "c", genres: ["rock"] },
    ], () => {
      calls++;
      return Promise.reject(new SpotifyRequestError(status, "Unavailable"));
    });
    equal(calls, 1);
    equal(genres, [{ genre: "rock", weight: 1 }]);
  }
});

Deno.test("one failed artist does not discard other artists' genres", async () => {
  const genres = await loadTopGenres([{ id: "a" }, { id: "b" }], async (id) => {
    if (id === "a") throw new SpotifyRequestError(404, "Missing artist");
    return { id, genres: ["pop"] };
  });
  equal(genres, [{ genre: "pop", weight: 1 }]);
});

Deno.test("unavailable metadata stays empty without guessed genres", async () => {
  equal(await loadTopGenres([{ id: "a", genres: [] }], async () => ({})), []);
  equal(await loadTopGenres([], () => { throw new Error("Unexpected request"); }), []);
});
