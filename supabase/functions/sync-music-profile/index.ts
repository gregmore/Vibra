import { rejectRevokedSession } from "../_shared/session-guard.ts";
import { corsHeaders, handleOptions } from "../_shared/cors.ts";
import { createSupabaseServiceClient } from "../_shared/supabase.ts";
import { requireEnv } from "../_shared/env.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";
import { rejectDisabledSpotify, spotifyUnavailableResponse } from "../_shared/spotify-feature.ts";
import { SpotifyRequestError } from "../_shared/spotify_api.ts";
import { syncConnection } from "../_shared/music_sync.ts";

const headers = { ...corsHeaders, "Content-Type": "application/json", "Cache-Control": "no-store" };
const reply = (status: number, body: unknown) => new Response(JSON.stringify(body), { status, headers });

// User-triggered full sync (first connection, pull-to-refresh in Music stats).
// The hourly spotify-sync-worker keeps the same data fresh in the background.
Deno.serve(async (req) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;
  if (req.method !== "POST") return reply(405, { error: "method_not_allowed" });
  const rejected = await rejectRevokedSession(req, "sync-music-profile");
  if (rejected) return rejected;

  try {
    const userClient = createClient(requireEnv("SUPABASE_URL"), requireEnv("SUPABASE_ANON_KEY"), {
      auth: { persistSession: false, autoRefreshToken: false },
      global: { headers: { Authorization: req.headers.get("Authorization") ?? "" } },
    });
    const { data: authData, error: authError } = await userClient.auth.getUser();
    if (authError || !authData.user) return reply(401, { error: "Unauthorized" });

    const unavailable = rejectDisabledSpotify();
    if (unavailable) return unavailable;

    const admin = createSupabaseServiceClient();
    const { data: row, error: rowError } = await admin
      .from("spotify_connections")
      .select("user_id, spotify_user_id, connected_at, access_token_ciphertext, refresh_token_ciphertext, token_expires_at")
      .eq("user_id", authData.user.id)
      .maybeSingle();
    if (rowError) throw new Error("connection_read_failed");
    if (!row?.access_token_ciphertext) return reply(409, { error: "spotify_not_connected" });

    const outcome = await syncConnection(admin, row, { full: true });
    switch (outcome.status) {
      case "synced":
        return reply(200, outcome.profile);
      case "revoked":
        // Access was removed from the Spotify account: Vibra has disconnected
        // it and deleted the synced data. The app shows "Connect" again.
        return reply(409, { error: "spotify_not_connected", reason: "revoked" });
      default:
        return reply(409, { error: "spotify_not_connected", reason: "changed" });
    }
  } catch (e) {
    if (e instanceof SpotifyRequestError) {
      if (e.status === 503) return spotifyUnavailableResponse();
      if (e.status === 429) return reply(429, { error: "spotify_rate_limited" });
    }
    console.error("sync-music-profile failed", e instanceof Error ? e.message : e);
    return reply(502, { error: "spotify_sync_failed" });
  }
});
