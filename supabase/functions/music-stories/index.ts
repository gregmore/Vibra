import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";
import { corsHeaders, handleOptions } from "../_shared/cors.ts";
import { rejectRevokedSession } from "../_shared/session-guard.ts";
import { createSupabaseServiceClient } from "../_shared/supabase.ts";
import { requireEnv } from "../_shared/env.ts";
import { getSpotifyAppAccessToken } from "../_shared/spotify_app_token.ts";
import { spotifyApi, validQuery } from "../_shared/spotify_tracks.ts";
import {
  linkItem, mapSpotifyItem, parseStoryInput, SEARCH_TYPES, storyPayload, type StoryItem,
} from "../_shared/music_stories.ts";

// Music Stories (docs/music-stories.md).
//   { action: "search", kind, q }   → Spotify tracks/artists/albums/playlists
//   { action: "post", kind, item_id | (url, title, subtitle), body, background,
//     visibility, allow_replies, media_path, event_id }
// A Spotify item is always re-fetched from Spotify, so its title, artwork and
// link are the provider's, never the client's.

const headers = { ...corsHeaders, "Content-Type": "application/json", "Cache-Control": "no-store" };
const reply = (status: number, body: unknown) => new Response(JSON.stringify(body), { status, headers });
const spotify = async (path: string) => spotifyApi(path, await getSpotifyAppAccessToken());

Deno.serve(async (req) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;
  if (req.method !== "POST") return reply(405, { error: "method_not_allowed" });
  const rejected = await rejectRevokedSession(req, "music-stories");
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
    const type = SEARCH_TYPES[String(body.kind)];

    if (body.action === "search") {
      if (!type) return reply(400, { error: "invalid_kind" });
      const { error: limit } = await userClient.rpc("consume_action_limit", { p_action: "track-search" });
      if (limit?.code === "PT429") return reply(429, { error: "rate_limited" });
      const q = validQuery(body.q);
      if (!q) return reply(400, { error: "invalid_query" });
      const result = await spotify(`/search?type=${type}&limit=15&q=${encodeURIComponent(q)}`);
      if ("unavailable" in result) return reply(503, { error: "music_provider_unavailable" });
      const raw = (result.data?.[`${type}s`]?.items ?? []) as unknown[];
      const items = raw.map((x) => mapSpotifyItem(type, x)).filter((x): x is StoryItem => x !== null);
      return reply(200, { items });
    }

    if (body.action === "post") {
      const input = parseStoryInput(body, auth.user.id);
      if (!input) return reply(400, { error: "invalid_story" });
      let item: StoryItem | null = null;
      if (type) {
        if (typeof body.item_id === "string" && /^[A-Za-z0-9]{22}$/.test(body.item_id)) {
          const result = await spotify(`/${type}s/${body.item_id}`);
          if ("unavailable" in result) return reply(503, { error: "music_provider_unavailable" });
          item = mapSpotifyItem(type, result.data);
        } else {
          item = linkItem(body.url, body.title, body.subtitle);
        }
        if (!item) return reply(400, { error: "invalid_item" });
      }
      const admin = createSupabaseServiceClient();
      const { data, error } = await admin.rpc("create_music_story", {
        p_user_id: auth.user.id,
        p_story: storyPayload(input, item),
      });
      if (error) {
        const message = String(error.message ?? "");
        if (error.code === "PT429" || message.includes("rate")) return reply(429, { error: "rate_limited" });
        if (message.includes("link") || message.includes("flood")) return reply(400, { error: "spam_detected" });
        if (message.includes("invalid_media")) return reply(400, { error: "invalid_media" });
        throw error;
      }
      return reply(200, { id: data });
    }

    return reply(400, { error: "invalid_action" });
  } catch (e) {
    console.error("music-stories failed", e instanceof Error ? e.message : e);
    return reply(502, { error: "music_stories_failed" });
  }
});
