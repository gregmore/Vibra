import { corsHeaders, handleOptions } from "../_shared/cors.ts";
import { requireEnv } from "../_shared/env.ts";
import { createSupabaseServiceClient } from "../_shared/supabase.ts";

// Invoke only with the service-role bearer token from a cron/job runner.
Deno.serve(async (req) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;
  if (req.method !== "POST" || req.headers.get("Authorization") !== `Bearer ${requireEnv("SUPABASE_SERVICE_ROLE_KEY")}`) {
    return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401, headers: corsHeaders });
  }
  const key = requireEnv("TICKETMASTER_API_KEY");
  const supabase = createSupabaseServiceClient();
  let page = 0, imported = 0, totalPages = 1;
  while (page < totalPages && page < 50) { // safety cap: 10k events per run
    const url = new URL("https://app.ticketmaster.com/discovery/v2/events.json");
    url.searchParams.set("apikey", key); url.searchParams.set("classificationName", "music");
    url.searchParams.set("size", "200"); url.searchParams.set("page", String(page));
    const response = await fetch(url);
    if (!response.ok) throw new Error(`Ticketmaster failed: ${response.status}`);
    const json = await response.json();
    totalPages = Math.min(Number(json.page?.totalPages ?? 0), 50);
    const rows = (json._embedded?.events ?? []).map((event: any) => {
      const venue = event._embedded?.venues?.[0];
      return { external_id: event.id, source: "ticketmaster", name: event.name,
        artist_name: event._embedded?.attractions?.[0]?.name ?? null, venue_name: venue?.name ?? null,
        city: venue?.city?.name ?? null, country: venue?.country?.countryCode ?? null,
        latitude: Number(venue?.location?.latitude) || null, longitude: Number(venue?.location?.longitude) || null,
        event_date: event.dates?.start?.dateTime ?? `${event.dates?.start?.localDate}T00:00:00Z`,
        ticket_url: event.url ?? null, image_url: event.images?.[0]?.url ?? null,
        price_min: event.priceRanges?.[0]?.min ?? null, price_max: event.priceRanges?.[0]?.max ?? null };
    });
    if (rows.length) { const { error } = await supabase.from("events").upsert(rows, { onConflict: "source,external_id" }); if (error) throw error; imported += rows.length; }
    page++;
  }
  return new Response(JSON.stringify({ imported, pages: page }), { headers: { ...corsHeaders, "Content-Type": "application/json" } });
});
