import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";
import { corsHeaders, handleOptions } from "../_shared/cors.ts";
import { rejectRevokedSession } from "../_shared/session-guard.ts";
import { createSupabaseServiceClient } from "../_shared/supabase.ts";
import { requireEnv } from "../_shared/env.ts";
import { getSpotifyAppAccessToken } from "../_shared/spotify_app_token.ts";
import {
  isSpotifyTrackId, linkTrack, mapSpotifyTrack, spotifyApi, validQuery, type VibeTrack,
} from "../_shared/spotify_tracks.ts";

// Daily Vibe (docs/daily-vibe.md).
//   { action: "search", q }                      → Spotify tracks (metadata only)
//   { action: "post", track_id, caption, expires, visibility }
//   { action: "post", url, title, artist, caption, expires, visibility }
// A Spotify vibe is always re-fetched from Spotify, so its title, artist and
// artwork are the provider's, never the client's.

const headers = { ...corsHeaders, "Content-Type": "application/json", "Cache-Control": "no-store" };
const reply = (status: number, body: unknown) => new Response(JSON.stringify(body), { status, headers });

const spotify = async (path: string) => spotifyApi(path, await getSpotifyAppAccessToken());

Deno.serve(async (req) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;
  if (req.method !== "POST") return reply(405, { error: "method_not_allowed" });
  const rejected = await rejectRevokedSession(req, "daily-vibe");
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
      const { error: limit } = await userClient.rpc("consume_action_limit", { p_action: "track-search" });
      if (limit?.code === "PT429") return reply(429, { error: "rate_limited" });
      const q = validQuery(body.q);
      if (!q) return reply(400, { error: "invalid_query" });
      const result = await spotify(`/search?type=track&limit=15&q=${encodeURIComponent(q)}`);
      if ("unavailable" in result) return reply(503, { error: "music_provider_unavailable" });
      const tracks = ((result.data?.tracks?.items ?? []) as unknown[])
        .map(mapSpotifyTrack).filter((t): t is VibeTrack => t !== null);
      return reply(200, { tracks });
    }

    if (body.action === "post") {
      let track: VibeTrack | null = null;
      if (isSpotifyTrackId(body.track_id)) {
        const result = await spotify(`/tracks/${body.track_id}`);
        if ("unavailable" in result) return reply(503, { error: "music_provider_unavailable" });
        track = mapSpotifyTrack(result.data);
      } else {
        track = linkTrack(body.url, body.title, body.artist);
      }
      if (!track) return reply(400, { error: "invalid_track" });
      const visibility = body.visibility === "everyone" ? "everyone" : "connections";
      const admin = createSupabaseServiceClient();
      const { data, error } = await admin.rpc("create_daily_vibe", {
        p_user_id: auth.user.id,
        p_track: track,
        p_caption: typeof body.caption === "string" ? body.caption : null,
        p_expires: body.expires !== false,
        p_visibility: visibility,
      });
      if (error) {
        const message = String(error.message ?? "");
        if (error.code === "PT429" || message.includes("rate")) return reply(429, { error: "rate_limited" });
        if (message.includes("link") || message.includes("flood")) return reply(400, { error: "spam_detected" });
        throw error;
      }
      return reply(200, { id: data });
    }

    return reply(400, { error: "invalid_action" });
  } catch (e) {
    console.error("daily-vibe failed", e instanceof Error ? e.message : e);
    return reply(502, { error: "daily_vibe_failed" });
  }
});
