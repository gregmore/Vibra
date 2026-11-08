import { rejectRevokedSession } from "../_shared/session-guard.ts";
import { corsHeaders, handleOptions } from "../_shared/cors.ts";
import { createSupabaseServiceClient } from "../_shared/supabase.ts";
import { requireEnv } from "../_shared/env.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";
import { rejectDisabledSpotify, spotifyUnavailableResponse } from "../_shared/spotify-feature.ts";
import { SpotifyRequestError } from "../_shared/spotify_api.ts";
import { recomputeMatches, refreshDnaSafely } from "../_shared/music_sync.ts";

const headers = { ...corsHeaders, "Content-Type": "application/json", "Cache-Control": "no-store" };
const reply = (status: number, body: unknown) => new Response(JSON.stringify(body), { status, headers });

// Recomputes the caller's affinities with the engine in
// _shared/music_affinity.ts (documented in docs/music-affinity-engine.md).
// Called after the user edits their genres, and after a manual sync.
// Also refreshes the caller's Musical DNA snapshot (docs/musical-dna.md).
// The hourly spotify-sync-worker does the same for every connected user.
Deno.serve(async (req) => {
  const rejected = await rejectRevokedSession(req, "calculate-match");
  if (rejected) return rejected;
  const preflight = handleOptions(req);
  if (preflight) return preflight;
  if (req.method.toUpperCase() !== "POST") return reply(405, { error: "Method not allowed" });

  try {
    const userClient = createClient(requireEnv("SUPABASE_URL"), requireEnv("SUPABASE_ANON_KEY"), {
      auth: { persistSession: false, autoRefreshToken: false },
      global: { headers: { Authorization: req.headers.get("Authorization") ?? "" } },
    });
    const { data: { user }, error: authError } = await userClient.auth.getUser();
    if (authError || !user) return reply(401, { error: "Unauthorized" });

    const unavailable = rejectDisabledSpotify();
    if (unavailable) return unavailable;

    // Works with a Spotify profile, hand-picked genres, or both. Without any
    // musical data the engine stores nothing (insufficient data), it never
    // invents a score.
    const admin = createSupabaseServiceClient();
    await refreshDnaSafely(admin, user.id);
    // The app calls this after every profile visit or genre edit: unchanged
    // inputs reuse the pairs computed in the last few hours.
    const matches = await recomputeMatches(admin, user.id, { onlyIfChanged: true });
    return reply(200, { success: true, matches_found: matches });
  } catch (e) {
    if (e instanceof SpotifyRequestError && e.status === 503) return spotifyUnavailableResponse();
    console.error("calculate-match failed", e instanceof Error ? e.message : e);
    return reply(500, { error: "internal_error" });
  }
});
