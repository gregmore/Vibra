import { corsHeaders } from "./cors.ts";

// The public launch pauses Spotify until the provider permits public access.
// Require an explicit opt-in so a missing/misspelled secret cannot re-enable it.
export function isSpotifyEnabled(value = Deno.env.get("SPOTIFY_ENABLED")): boolean {
  return value?.trim().toLowerCase() === "true";
}

export function rejectDisabledSpotify(): Response | null {
  if (isSpotifyEnabled()) return null;
  return spotifyUnavailableResponse();
}

// Also used when the database pause rejects an already-running worker whose
// Edge environment still predates the switch.
export function spotifyUnavailableResponse(): Response {
  return new Response(JSON.stringify({ error: "spotify_temporarily_unavailable" }), {
    status: 503,
    headers: { ...corsHeaders, "Content-Type": "application/json", "Cache-Control": "no-store" },
  });
}

// A deliberately paused scheduled job is successful, not an endlessly retried
// outage. Call this only after authenticating the internal worker.
export function skipDisabledSpotifyJob(): Response | null {
  if (isSpotifyEnabled()) return null;
  return spotifySkippedJobResponse();
}

export function spotifySkippedJobResponse(): Response {
  return new Response(JSON.stringify({ ok: true, skipped: "spotify_temporarily_unavailable" }), {
    headers: { ...corsHeaders, "Content-Type": "application/json", "Cache-Control": "no-store" },
  });
}
