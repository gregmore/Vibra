import { assertEquals } from "https://deno.land/std@0.208.0/assert/mod.ts";
import { isSpotifyTrackId, linkTrack, mapSpotifyTrack, spotifyApi, validQuery } from "./spotify_tracks.ts";

const raw = {
  id: "2xLMifQCjDGFmkHkpNLD9h",
  name: "SICKO MODE",
  preview_url: "https://p.scdn.co/mp3-preview/abc",
  artists: [{ name: "Travis Scott" }, { name: "Drake" }],
  album: {
    name: "ASTROWORLD",
    images: [
      { url: "https://i.scdn.co/image/640", width: 640 },
      { url: "https://i.scdn.co/image/300", width: 300 },
      { url: "https://evil.example/image.png", width: 300 },
    ],
  },
};

Deno.test("maps metadata, Spotify-hosted artwork and a link back; never audio", () => {
  const t = mapSpotifyTrack(raw)!;
  assertEquals(t, {
    provider: "spotify",
    track_id: "2xLMifQCjDGFmkHkpNLD9h",
    title: "SICKO MODE",
    artist: "Travis Scott, Drake",
    album: "ASTROWORLD",
    artwork_url: "https://i.scdn.co/image/300",
    external_url: "https://open.spotify.com/track/2xLMifQCjDGFmkHkpNLD9h",
  });
  assertEquals(JSON.stringify(t).includes("mp3"), false);
});

Deno.test("rejects malformed tracks and non-CDN artwork", () => {
  assertEquals(mapSpotifyTrack({ ...raw, id: "x" }), null);
  assertEquals(mapSpotifyTrack({ ...raw, artists: [] }), null);
  const noCdn = mapSpotifyTrack({ ...raw, album: { name: "A", images: [{ url: "https://evil.example/a.png" }] } })!;
  assertEquals(noCdn.artwork_url, null);
  assertEquals(isSpotifyTrackId("2xLMifQCjDGFmkHkpNLD9h"), true);
});

Deno.test("links from other providers keep only what the user typed", () => {
  assertEquals(linkTrack("https://music.apple.com/it/album/x/1", "Song", "Artist")?.artwork_url, null);
  assertEquals(linkTrack("https://example.com/song", "Song", "Artist"), null);
  assertEquals(linkTrack("https://soundcloud.com/a/b", "", "Artist"), null);
  assertEquals(validQuery("  "), null);
  assertEquals(validQuery("sicko"), "sicko");
});

Deno.test("rate limits: a short Retry-After is honoured once, a long one degrades", async () => {
  const waits: number[] = [];
  const wait = (ms: number) => (waits.push(ms), Promise.resolve());
  let calls = 0;
  const shortThenOk = (() => {
    calls++;
    return Promise.resolve(calls === 1
      ? new Response("", { status: 429, headers: { "Retry-After": "2" } })
      : new Response(JSON.stringify({ ok: 1 }), { status: 200 }));
  }) as typeof fetch;
  assertEquals(await spotifyApi("/x", "t", wait, shortThenOk), { data: { ok: 1 } });
  assertEquals(waits, [2000]);
  const long = (() => Promise.resolve(new Response("", { status: 429, headers: { "Retry-After": "60" } }))) as typeof fetch;
  assertEquals(await spotifyApi("/x", "t", wait, long), { unavailable: true });
  assertEquals(await spotifyApi("/x", null, wait, long), { unavailable: true });
});
