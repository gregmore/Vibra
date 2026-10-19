import { rejectRevokedSession } from "../_shared/session-guard.ts";
import { createSupabaseServiceClient } from "../_shared/supabase.ts";
import { corsHeaders, handleOptions } from "../_shared/cors.ts";

const headers = { ...corsHeaders, "Content-Type": "application/json" };
const reply = (status: number, error: string) => new Response(JSON.stringify({ error }), { status, headers });
function https(value: unknown): string | null {
  if (typeof value !== "string") return null;
  try { const url = new URL(value); return url.protocol === "https:" && !url.username && !url.password ? url.href : null; }
  catch { return null; }
}
async function json(response: Response, maximum: number): Promise<any> {
  const reader = response.body?.getReader(); if (!reader) throw new Error("empty response");
  const chunks: Uint8Array[] = []; let size = 0;
  while (true) {
    const { done, value } = await reader.read(); if (done) break;
    size += value.length;
    if (size > maximum) { await reader.cancel(); throw new Error("payload too large"); }
    chunks.push(value);
  }
  const bytes = new Uint8Array(size); let offset = 0;
  for (const chunk of chunks) { bytes.set(chunk, offset); offset += chunk.length; }
  return JSON.parse(new TextDecoder().decode(bytes));
}

Deno.serve(async (req) => {
  const options = handleOptions(req); if (options) return options;
  if (req.method !== "POST") return reply(405,"method_not_allowed");
  const rejected = await rejectRevokedSession(req,"resolve-event"); if (rejected) return rejected;
  let body;
  try { body = await json(new Response(req.body),4096); } catch { return reply(400,"invalid_request"); }
  if (!body || typeof body.source !== "string" || typeof body.external_id !== "string" ||
      !/^[a-z_-]{1,40}$/.test(body.source) || !/^[a-zA-Z0-9_-]{1,200}$/.test(body.external_id)) return reply(400,"invalid_event_identity");
  const admin = createSupabaseServiceClient();
  // Enforce the same segment visibility as the events SELECT policy before
  // returning a synthetic event read through the admin client.
  const { data: { user }, error: authError } = await admin.auth.getUser((req.headers.get("Authorization") ?? "").replace(/^Bearer /,""));
  if (authError || !user) return reply(401,"unauthorized");
  const { data: existing, error: lookupError } = await admin.from("events").select("id,is_test_data").eq("source",body.source).eq("external_id",body.external_id).maybeSingle();
  if (lookupError) return reply(500,"event_lookup_failed");
  if (existing) {
    if (existing.is_test_data && user.app_metadata?.is_test_user !== true && user.app_metadata?.is_test_user !== "true") return reply(404,"event_not_found");
    return new Response(JSON.stringify({id:existing.id}),{headers});
  }
  try {
    let row: Record<string, unknown>;
    if (body.source === "ticketmaster") {
      const key=Deno.env.get("TICKETMASTER_API_KEY"); if (!key) return reply(503,"event_provider_not_configured");
      const url=new URL(`https://app.ticketmaster.com/discovery/v2/events/${encodeURIComponent(body.external_id)}.json`);
      url.searchParams.set("apikey",key);
      const response=await fetch(url,{redirect:"error",signal:AbortSignal.timeout(10000)});
      if (!response.ok) return reply(response.status===404?404:502,"event_provider_unavailable");
      const event=await json(response,2*1024*1024);
      if (event.id!==body.external_id) return reply(502,"event_identity_mismatch");
      const venue=event._embedded?.venues?.[0];
      row={name:event.name,artist_name:event._embedded?.attractions?.[0]?.name??null,
        venue_name:venue?.name??null,city:venue?.city?.name??null,country:venue?.country?.countryCode??null,
        latitude:venue?.location?.latitude==null?null:Number(venue.location.latitude),
        longitude:venue?.location?.longitude==null?null:Number(venue.location.longitude),
        event_date:event.dates?.start?.dateTime??`${event.dates?.start?.localDate}T00:00:00Z`,
        ticket_url:https(event.url),image_url:https(event.images?.[0]?.url),
        price_min:event.priceRanges?.[0]?.min??null,price_max:event.priceRanges?.[0]?.max??null,
        description:event.info??null};
    } else if (body.source === "bandsintown") {
      const key=Deno.env.get("BANDSINTOWN_APP_ID"); if (!key) return reply(503,"event_provider_not_configured");
      if (typeof body.artist_name!=="string" || body.artist_name.length<1 || body.artist_name.length>200) return reply(400,"invalid_artist");
      const url=new URL(`https://rest.bandsintown.com/artists/${encodeURIComponent(body.artist_name)}/events`);
      url.searchParams.set("app_id",key);url.searchParams.set("date","upcoming");
      const response=await fetch(url,{redirect:"error",signal:AbortSignal.timeout(10000)});
      if (!response.ok) return reply(502,"event_provider_unavailable");
      const events=await json(response,2*1024*1024);
      const event=Array.isArray(events)?events.find(e=>String(e.id)===body.external_id):null;
      if (!event) return reply(404,"event_not_found");
      row={name:event.title||event.lineup?.join(", ")||"Concerto",artist_name:event.lineup?.[0]??null,
        venue_name:event.venue?.name??null,city:event.venue?.city??null,country:event.venue?.country??null,
        latitude:event.venue?.latitude==null?null:Number(event.venue.latitude),
        longitude:event.venue?.longitude==null?null:Number(event.venue.longitude),
        event_date:event.datetime,ticket_url:https(event.offers?.[0]?.url??event.url),
        image_url:https(event.artist?.image_url),description:event.description??null};
    } else return reply(400,"unsupported_event_provider");
    if (typeof row.name!=="string" || !row.name || !Number.isFinite(Date.parse(String(row.event_date)))) return reply(502,"invalid_provider_event");
    const {data,error}=await admin.from("events").upsert({...row,source:body.source,external_id:body.external_id},{onConflict:"source,external_id"}).select("id").single();
    if (error) return reply(500,"event_sync_failed");
    return new Response(JSON.stringify({id:data.id}),{headers});
  } catch { return reply(502,"event_provider_unavailable"); }
});
