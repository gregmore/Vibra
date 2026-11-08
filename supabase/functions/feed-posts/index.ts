import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";
import { corsHeaders, handleOptions } from "../_shared/cors.ts";
import { rejectRevokedSession } from "../_shared/session-guard.ts";
import { createSupabaseServiceClient } from "../_shared/supabase.ts";
import { requireEnv } from "../_shared/env.ts";
import { getSpotifyAppAccessToken } from "../_shared/spotify_app_token.ts";
import { spotifyApi, validQuery } from "../_shared/spotify_tracks.ts";
import { linkItem, mapSpotifyItem, type StoryItem } from "../_shared/music_stories.ts";
import {
  artistKeys, artistsOf, feedPayload, genreKeys, ITEM_TYPES, type ItemType, parseFeedInput,
} from "../_shared/feed_posts.ts";

// VIBRA Feed (docs/vibra-feed.md).
//   { action: "search", item_type, q }  → Spotify tracks/albums/artists/playlists
//   { action: "post", kind, item_type, item_id | (url, title, subtitle), body,
//     rating, media_path, event_id, shared_post_id, visibility, comments_enabled }
// A Spotify item is always re-fetched from Spotify, so its title, artwork and
// link are the provider's. Its artists' genres are classified for relevance.

const headers = { ...corsHeaders, "Content-Type": "application/json", "Cache-Control": "no-store" };
const reply = (status: number, body: unknown) => new Response(JSON.stringify(body), { status, headers });

Deno.serve(async (req) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;
  if (req.method !== "POST") return reply(405, { error: "method_not_allowed" });
  const rejected = await rejectRevokedSession(req, "feed-posts");
  if (rejected) return rejected;

  try {
    const userClient = createClient(requireEnv("SUPABASE_URL"), requireEnv("SUPABASE_ANON_KEY"), {
      auth: { persistSession: false, autoRefreshToken: false },
      global: { headers: { Authorization: req.headers.get("Authorization") ?? "" } },
    });
    const { data: auth, error: authError } = await userClient.auth.getUser();
    if (authError || !auth.user) return reply(401, { error: "Unauthorized" });

    let body: Record<string, unknown> = {};
    try {
      body = await req.json();
    } catch {
      return reply(400, { error: "invalid_request" });
    }

    if (body.action === "search") {
      const type = ITEM_TYPES.find((t) => t === body.item_type);
      if (!type) return reply(400, { error: "invalid_item_type" });
      const { error: limit } = await userClient.rpc("consume_action_limit", { p_action: "track-search" });
      if (limit?.code === "PT429") return reply(429, { error: "rate_limited" });
      const q = validQuery(body.q);
      if (!q) return reply(400, { error: "invalid_query" });
      const token = await getSpotifyAppAccessToken();
      const result = await spotifyApi(`/search?type=${type}&limit=15&q=${encodeURIComponent(q)}`, token);
      if ("unavailable" in result) return reply(503, { error: "music_provider_unavailable" });
      const raw = (result.data?.[`${type}s`]?.items ?? []) as unknown[];
      const items = raw.map((x) => mapSpotifyItem(type, x)).filter((x): x is StoryItem => x !== null);
      return reply(200, { items });
    }

    if (body.action === "post") {
      const input = parseFeedInput(body, auth.user.id);
      if (!input) return reply(400, { error: "invalid_post" });
      let item: StoryItem | null = null;
      let genres: string[] = [];
      let artists: string[] = [];
      const type = input.item_type as ItemType | null;
      if (type) {
        if (typeof body.item_id === "string" && /^[A-Za-z0-9]{22}$/.test(body.item_id)) {
          const token = await getSpotifyAppAccessToken();
          const result = await spotifyApi(`/${type}s/${body.item_id}`, token);
          if ("unavailable" in result) return reply(503, { error: "music_provider_unavailable" });
          item = mapSpotifyItem(type, result.data);
          if (item) {
            const who = artistsOf(type, result.data);
            let labels: unknown[] = who.genres;
            if (who.ids.length) {
              // Genres live on artists, not tracks/albums. Best effort only.
              try {
                const more = await spotifyApi(`/artists?ids=${who.ids.join(",")}`, token);
                if (!("unavailable" in more)) {
                  labels = ((more.data?.artists ?? []) as { genres?: unknown[] }[])
                    .flatMap((a) => Array.isArray(a?.genres) ? a.genres : []);
                }
              } catch {
                labels = [];
              }
            }
            genres = genreKeys(labels);
            artists = artistKeys(who.names);
          }
        } else {
          item = linkItem(body.url, body.title, body.subtitle);
          if (item && type === "artist") artists = artistKeys([item.title]);
        }
        if (!item) return reply(400, { error: "invalid_item" });
      }
      const admin = createSupabaseServiceClient();
      const { data, error } = await admin.rpc("create_feed_post", {
        p_user_id: auth.user.id,
        p_post: feedPayload(input, item, genres, artists),
      });
      if (error) {
        const message = String(error.message ?? "");
        if (error.code === "PT429" || message.includes("rate")) return reply(429, { error: "rate_limited" });
        if (message.includes("duplicate_post")) return reply(409, { error: "duplicate_post" });
        if (message.includes("link") || message.includes("flood")) return reply(400, { error: "spam_detected" });
        if (message.includes("invalid_media")) return reply(400, { error: "invalid_media" });
        if (message.includes("invalid_share")) return reply(400, { error: "invalid_share" });
        throw error;
      }
      return reply(200, { id: data });
    }

    return reply(400, { error: "invalid_action" });
  } catch (e) {
    console.error("feed-posts failed", e instanceof Error ? e.message : e);
    return reply(502, { error: "feed_posts_failed" });
  }
});
