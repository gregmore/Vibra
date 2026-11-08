// Hourly background sync for every connected Spotify account.
//
// * every run: collects new plays (recently-played, after the last stored
//   play) so the listening heatmap covers weeks, not just the last 50 tracks;
// * once a day per user: refreshes top artists, tracks and genres and
//   recomputes that user's matches, so matching works while the app is closed.
//
// Invoked by pg_cron (vibra_private.enqueue_spotify_sync) with the dedicated
// server-to-server job credential. Paused Spotify → successful no-op.
import { corsHeaders, handleOptions } from "../_shared/cors.ts";
import { createSupabaseServiceClient } from "../_shared/supabase.ts";
import { catalogueJobAuthorized } from "../_shared/catalogue_auth.ts";
import { skipDisabledSpotifyJob } from "../_shared/spotify-feature.ts";
import { isFullSyncDue, syncConnection } from "../_shared/music_sync.ts";
import { SpotifyRequestError } from "../_shared/spotify_api.ts";

const headers = { ...corsHeaders, "Content-Type": "application/json", "Cache-Control": "no-store" };
/** Users per run; at ~1–4 Spotify requests each this stays well inside limits. */
const BATCH_SIZE = 25;
/** Stop claiming work before the edge wall clock (cron timeout is 140 s). */
const TIME_BUDGET_MS = 100_000;

Deno.serve(async (req) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;
  if (req.method !== "POST" || !await catalogueJobAuthorized(req)) {
    return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401, headers });
  }
  const skipped = skipDisabledSpotifyJob();
  if (skipped) return skipped;

  const started = Date.now();
  const admin = createSupabaseServiceClient();
  const totals = { claimed: 0, synced: 0, polled: 0, revoked: 0, changed: 0, failed: 0, rate_limited: false };
  const { data: batch, error } = await admin.rpc("claim_spotify_sync_batch", { p_limit: BATCH_SIZE });
  if (error) return new Response(JSON.stringify({ error: "claim_failed" }), { status: 500, headers });

  for (const row of batch ?? []) {
    if (Date.now() - started > TIME_BUDGET_MS) break;
    totals.claimed++;
    try {
      const outcome = await syncConnection(admin, row, { full: isFullSyncDue(row.last_synced_at) });
      totals[outcome.status]++;
    } catch (e) {
      if (e instanceof SpotifyRequestError && e.status === 429) {
        // The app-wide limit is shared: stop this run; claimed users are retried next hour.
        totals.rate_limited = true;
        break;
      }
      if (e instanceof SpotifyRequestError && e.status === 503) break;
      totals.failed++;
      console.error("spotify-sync-worker user failed", e instanceof Error ? e.message : e);
    }
  }
  return new Response(JSON.stringify({ ok: true, ...totals }), { headers });
});
