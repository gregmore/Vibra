import { corsHeaders, handleOptions } from "../_shared/cors.ts";
import { createSupabaseServiceClient } from "../_shared/supabase.ts";
import { limitedJson, searchTicketmaster } from "../_shared/ticketmaster.ts";
import { catalogueJobAuthorized } from "../_shared/catalogue_auth.ts";

const headers = { ...corsHeaders, "Content-Type": "application/json" };
Deno.serve(async (req) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;
  if (req.method !== "POST" || !await catalogueJobAuthorized(req)) {
    return new Response(JSON.stringify({ error: "Unauthorized" }), {
      status: 401,
      headers,
    });
  }
  const key = Deno.env.get("TICKETMASTER_API_KEY");
  if (!key) {
    return new Response(
      JSON.stringify({ error: "event_provider_not_configured" }),
      { status: 503, headers },
    );
  }
  let body: any;
  try {
    body = req.body ? await limitedJson(new Response(req.body), 2048) : {};
    if (!body || typeof body !== "object" || Array.isArray(body)) {
      throw new Error();
    }
  } catch {
    return new Response(JSON.stringify({ error: "invalid_request" }), {
      status: 400,
      headers,
    });
  }
  const countries: string[] = body.country_codes ?? ["IT"];
  if (
    !Array.isArray(countries) || countries.length < 1 || countries.length > 5 ||
    countries.some((c) => typeof c !== "string" || !/^[A-Z]{2}$/.test(c))
  ) {
    return new Response(JSON.stringify({ error: "invalid_countries" }), {
      status: 400,
      headers,
    });
  }
  const results = [], admin = createSupabaseServiceClient();
  try {
    for (const countryCode of [...new Set(countries)]) {
      const result = await searchTicketmaster(key, { countryCode });
      for (let offset = 0; offset < result.rows.length; offset += 200) {
        const { error } = await admin.from("events").upsert(
          result.rows.slice(offset, offset + 200),
          { onConflict: "source,external_id" },
        );
        if (error) throw new Error("catalogue_write_failed");
      }
      results.push({
        country: countryCode,
        imported: result.rows.length,
        total: result.total,
        pages: result.pages,
        truncated: result.truncated,
      });
    }
    return new Response(
      JSON.stringify({
        imported: results.reduce((n, r) => n + r.imported, 0),
        countries: results,
      }),
      { headers },
    );
  } catch {
    return new Response(
      JSON.stringify({
        error: "catalogue_sync_failed",
        completed_countries: results,
      }),
      { status: 502, headers },
    );
  }
});
