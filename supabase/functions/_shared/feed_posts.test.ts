import { assertEquals } from "https://deno.land/std@0.208.0/assert/mod.ts";
import { artistKeys, artistsOf, feedPayload, genreKeys, parseFeedInput } from "./feed_posts.ts";

const USER = "11111111-1111-4111-8111-111111111111";
const POST = "22222222-2222-4222-8222-222222222222";

Deno.test("each kind requires what it is about", () => {
  assertEquals(parseFeedInput({ kind: "song" }, USER)?.item_type, "track");
  assertEquals(parseFeedInput({ kind: "recommendation" }, USER), null);
  assertEquals(parseFeedInput({ kind: "recommendation", item_type: "artist" }, USER)?.item_type, "artist");
  assertEquals(parseFeedInput({ kind: "review", item_type: "playlist", body: "ok", rating: 4 }, USER), null);
  assertEquals(parseFeedInput({ kind: "review", item_type: "album", body: "Great", rating: 6 }, USER), null);
  assertEquals(parseFeedInput({ kind: "review", item_type: "album", body: "Great", rating: 5 }, USER)?.rating, 5);
  assertEquals(parseFeedInput({ kind: "opinion", body: " " }, USER), null);
  assertEquals(parseFeedInput({ kind: "share", shared_post_id: "x" }, USER), null);
  assertEquals(parseFeedInput({ kind: "share", shared_post_id: POST }, USER)?.shared_post_id, POST);
  assertEquals(parseFeedInput({ kind: "podcast" }, USER), null);
});

Deno.test("photos only from the caller's folder; defaults are explicit", () => {
  const other = `${POST}/33333333-3333-4333-8333-333333333333.png`;
  assertEquals(parseFeedInput({ kind: "concert_photo", media_path: other }, USER), null);
  const own = parseFeedInput({ kind: "concert_photo", media_path: `${USER}/33333333-3333-4333-8333-333333333333.png` }, USER)!;
  assertEquals(own.visibility, "everyone");
  assertEquals(own.comments_enabled, true);
  assertEquals(parseFeedInput({ kind: "opinion", body: "Hi", visibility: "connections", comments_enabled: false }, USER)?.visibility, "connections");
});

Deno.test("genres become catalogue keys; artists are matched by name", () => {
  const keys = genreKeys(["italian trap", "dark trap", "unknown thing", 42]);
  assertEquals(keys.includes("italian-hip-hop"), true);
  assertEquals(keys.includes("hip-hop"), true);
  assertEquals(keys.includes("trap"), true);
  assertEquals(artistKeys([" Björk ", "björk", null]), ["björk"]);
  const who = artistsOf("track", { artists: [{ id: "2xLMifQCjDGFmkHkpNLD9h", name: "Sfera Ebbasta" }, { id: "x" }] });
  assertEquals(who.ids, ["2xLMifQCjDGFmkHkpNLD9h"]);
  assertEquals(artistsOf("artist", { name: "Björk", genres: ["art pop"] }).genres, ["art pop"]);
});

Deno.test("payload never carries audio", () => {
  const input = parseFeedInput({ kind: "song" }, USER)!;
  const payload = feedPayload(input, {
    provider: "spotify", item_id: "2xLMifQCjDGFmkHkpNLD9h", title: "T", subtitle: null,
    artwork_url: null, external_url: "https://open.spotify.com/track/2xLMifQCjDGFmkHkpNLD9h",
  });
  assertEquals(JSON.stringify(payload).includes("preview"), false);
  assertEquals(payload.item_type, "track");
});
