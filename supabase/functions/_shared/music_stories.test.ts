import { assertEquals } from "https://deno.land/std@0.208.0/assert/mod.ts";
import { linkItem, mapSpotifyItem, parseStoryInput, storyPayload } from "./music_stories.ts";

const ID = "2xLMifQCjDGFmkHkpNLD9h";
const USER = "11111111-1111-4111-8111-111111111111";

Deno.test("maps each Spotify kind to metadata, CDN artwork and a link back", () => {
  const track = mapSpotifyItem("track", {
    id: ID, name: "SICKO MODE", preview_url: "https://p.scdn.co/mp3-preview/x",
    artists: [{ name: "Travis Scott" }], album: { name: "ASTROWORLD", images: [{ url: "https://i.scdn.co/image/a", width: 300 }] },
  })!;
  assertEquals(track.subtitle, "Travis Scott · ASTROWORLD");
  assertEquals(JSON.stringify(track).includes("mp3"), false);
  const artist = mapSpotifyItem("artist", {
    id: ID, name: "Björk", genres: ["art pop", "electronica"], images: [{ url: "https://evil.example/a.png" }],
  })!;
  assertEquals(artist.external_url, `https://open.spotify.com/artist/${ID}`);
  assertEquals(artist.artwork_url, null);
  assertEquals(artist.subtitle, "art pop, electronica");
  const album = mapSpotifyItem("album", {
    id: ID, name: "Homogenic", release_date: "1997-09-22", artists: [{ name: "Björk" }],
    images: [{ url: "https://i.scdn.co/image/b", width: 640 }],
  })!;
  assertEquals(album.subtitle, "Björk · 1997");
  const playlist = mapSpotifyItem("playlist", {
    id: ID, name: "Night drive", owner: { display_name: "Ada" },
    images: [{ url: "https://mosaic.scdn.co/640/abc" }],
  })!;
  assertEquals(playlist.artwork_url, "https://mosaic.scdn.co/640/abc");
  assertEquals(mapSpotifyItem("playlist", { id: ID, name: "Mine", public: false }), null);
  assertEquals(mapSpotifyItem("show", { id: ID, name: "Podcast" }), null);
});

Deno.test("links from other providers keep only what the user typed", () => {
  assertEquals(linkItem("https://soundcloud.com/a/b", "Mix", null)?.artwork_url, null);
  assertEquals(linkItem("https://example.com/a", "Mix", null), null);
  assertEquals(linkItem("https://music.apple.com/x", "", "A"), null);
});

Deno.test("story input: photos only from the caller's folder, opinions need text", () => {
  assertEquals(parseStoryInput({ kind: "opinion" }, USER), null);
  assertEquals(parseStoryInput({ kind: "podcast" }, USER), null);
  const other = "22222222-2222-4222-8222-222222222222/33333333-3333-4333-8333-333333333333.png";
  assertEquals(parseStoryInput({ kind: "concert_photo", media_path: other }, USER), null);
  const own = `${USER}/33333333-3333-4333-8333-333333333333.png`;
  const photo = parseStoryInput({ kind: "concert_photo", media_path: own, background: "neon", visibility: "public" }, USER)!;
  assertEquals(photo.background, "aurora");
  assertEquals(photo.visibility, null);
  const opinion = parseStoryInput({ kind: "opinion", body: "  Vinyl > streaming ", media_path: own }, USER)!;
  assertEquals(opinion.media_path, null);
  assertEquals(storyPayload(opinion, null).body, "Vinyl > streaming");
});
