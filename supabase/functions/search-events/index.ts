import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";
import { corsHeaders, handleOptions } from "../_shared/cors.ts";
import { rejectRevokedSession } from "../_shared/session-guard.ts";
import { createSupabaseServiceClient } from "../_shared/supabase.ts";
import { requireEnv } from "../_shared/env.ts";
import { searchTicketmaster, limitedJson } from "../_shared/ticketmaster.ts";

const headers = { ...corsHeaders, "Content-Type": "application/json" };
function reply(status: number, error: string) { return new Response(JSON.stringify({ error }), { status, headers }); }
Deno.serve(async (req) => {
  const options = handleOptions(req); if (options) return options;
  if (req.method !== "POST") return reply(405, "method_not_allowed");
  const rejected = await rejectRevokedSession(req, "search-events"); if (rejected) return rejected;
  let body: any;
  try {
    body = await limitedJson(new Response(req.body), 4096);
  } catch { return reply(400, "invalid_request"); }
  const { latitude, longitude, radius_km: radiusKm } = body ?? {};
  if (![latitude, longitude, radiusKm].every((n) => typeof n === "number" && Number.isFinite(n)) ||
      Math.abs(latitude) > 90 || Math.abs(longitude) > 180 || radiusKm < 1 || radiusKm > 250)
    return reply(400, "invalid_area");
  const key = Deno.env.get("TICKETMASTER_API_KEY");
  if (!key) return reply(503, "event_provider_not_configured");
  try {
    const admin = createSupabaseServiceClient();
    // Shared, coarse public map areas; never store user ids or device GPS history.
    const queryLat = Math.round(latitude * 100) / 100;
    const queryLon = Math.round(longitude * 100) / 100;
    const queryRadius = Math.ceil(radiusKm / 5) * 5 + 2;
    const cacheKey = `${queryLat}:${queryLon}:${queryRadius}`;
    const { data: claimed, error: claimError } = await admin.rpc("claim_event_provider_search", { p_cache_key: cacheKey });
    if (claimError) return reply(500, "event_cache_unavailable");
    let total: number | null = null, truncated = false;
    if (claimed === true) {
      const result = await searchTicketmaster(key, { latitude: queryLat, longitude: queryLon, radiusKm: queryRadius });
      for (let offset = 0; offset < result.rows.length; offset += 200) {
        const { error } = await admin.from("events").upsert(result.rows.slice(offset, offset + 200), { onConflict: "source,external_id" });
        if (error) return reply(500, "event_sync_failed");
      }
      const { error } = await admin.from("event_provider_search_cache").update({ succeeded_at: new Date().toISOString() }).eq("cache_key", cacheKey);
      if (error) return reply(500, "event_cache_unavailable");
      total = result.total; truncated = result.truncated;
    }
    const caller = createClient(requireEnv("SUPABASE_URL"), requireEnv("SUPABASE_ANON_KEY"), {
      auth: { persistSession: false, autoRefreshToken: false },
      global: { headers: { Authorization: req.headers.get("Authorization") ?? "" } },
    });
    // Return through caller RLS; the service role cannot leak test-segment data.
    const { data: events, error } = await caller.rpc("find_events_in_radius", {
      p_latitude: latitude, p_longitude: longitude, p_radius_meters: radiusKm * 1000,
      p_status: null, p_limit: 500,
    });
    if (error) return reply(500, "event_read_failed");
    return new Response(JSON.stringify({ events: events ?? [], refreshed: claimed === true, provider_total: total,
      provider_truncated: truncated, result_limit: 500 }), { headers });
  } catch { return reply(502, "event_provider_unavailable"); }
});
