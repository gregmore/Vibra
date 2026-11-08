import { rejectRevokedSession } from "../_shared/session-guard.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";
import { corsHeaders, handleOptions } from "../_shared/cors.ts";
import { createSupabaseServiceClient } from "../_shared/supabase.ts";
import { clamp } from "../_shared/geo.ts";
import { rejectDisabledSpotify } from "../_shared/spotify-feature.ts";
import { computeMusicalDna, type DnaInput } from "../_shared/musical_dna.ts";
import {
  eventGenres, passesFilters, type RecEvent, scoreEvent, type UserTaste,
} from "../_shared/event_recommendation.ts";

// Concert Intelligence (docs/concert-intelligence.md): events ranked by the
// user's musical identity, previous interests, distance and date, each with
// the reasons it was recommended. Only published event data is returned;
// nothing about tickets is inferred.

type Body = {
  limit?: number;
  latitude?: number;
  longitude?: number;
  radius_km?: number;
  family?: string;
  artist?: string;
  date_from?: string;
  date_to?: string;
  /** Maximum "from" price in EUR; only events with a published EUR price. */
  price_max?: number;
};

const EVENT_COLUMNS =
  "id, external_id, source, name, artist_name, artist_spotify_id, venue_name, city, country, latitude, longitude, event_date, ticket_url, price_min, price_max, price_currency, image_url, description, status, genres";

const headers = { ...corsHeaders, "Content-Type": "application/json" };
const reply = (status: number, body: unknown) => new Response(JSON.stringify(body), { status, headers });
const validLat = (v: unknown): v is number => typeof v === "number" && Number.isFinite(v) && v >= -90 && v <= 90;
const validLon = (v: unknown): v is number => typeof v === "number" && Number.isFinite(v) && v >= -180 && v <= 180;
const isoOrNull = (v: unknown) => typeof v === "string" && Number.isFinite(Date.parse(v)) ? new Date(v) : null;

Deno.serve(async (req) => {
  const rejected = await rejectRevokedSession(req, "recommend-events");
  if (rejected) return rejected;
  const preflight = handleOptions(req);
  if (preflight) return preflight;
  if (req.method.toUpperCase() !== "POST") return reply(405, { error: "Method not allowed" });

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) return reply(401, { error: "Unauthorized" });
    const userClient = createClient(Deno.env.get("SUPABASE_URL") ?? "", Deno.env.get("SUPABASE_ANON_KEY") ?? "", {
      auth: { persistSession: false, autoRefreshToken: false },
      global: { headers: { Authorization: authHeader } },
    });
    const { data: { user }, error: authError } = await userClient.auth.getUser();
    if (authError || !user) return reply(401, { error: "Unauthorized" });
    // Shared limiter: 30 requests a minute per user.
    const { error: limitError } = await userClient.rpc("consume_action_limit", { p_action: "recommend-events" });
    if (limitError?.code === "PT429") return reply(429, { error: "rate_limited" });

    const unavailable = rejectDisabledSpotify();
    if (unavailable) return unavailable;

    let body: Body = {};
    try {
      body = (await req.json()) as Body;
    } catch {
      body = {};
    }
    const limit = clamp(Math.trunc(Number(body.limit ?? 20)) || 20, 1, 50);
    const radiusKm = typeof body.radius_km === "number" ? clamp(body.radius_km, 5, 500) : null;
    const now = new Date();
    const admin = createSupabaseServiceClient();

    // ── Musical identity (Spotify and/or picked genres) ─────────────────
    const { data: inputRows, error: inputError } = await admin.rpc("get_musical_dna_input", { p_user_id: user.id });
    if (inputError) throw inputError;
    const input = (Array.isArray(inputRows) ? inputRows[0] : inputRows) as DnaInput | undefined;
    const dna = input ? computeMusicalDna(input) : null;
    if (!dna) {
      return reply(404, {
        error: "music_profile_not_found",
        message: "Connect Spotify or pick genres to get recommendations.",
      });
    }

    // ── Previous interests: saved/going events and ticket clicks ────────
    const [{ data: saved }, { data: clicks }] = await Promise.all([
      admin.from("event_attendees").select("event_id").eq("user_id", user.id)
        .in("status", ["interested", "going", "maybe"]).order("created_at", { ascending: false }).limit(100),
      admin.from("ticket_clicks").select("event_id").eq("user_id", user.id)
        .order("clicked_at", { ascending: false }).limit(100),
    ]);
    const interestIds = [...new Set([...(saved ?? []), ...(clicks ?? [])].map((r: { event_id: string }) => r.event_id))];
    const savedIds = new Set((saved ?? []).map((r: { event_id: string }) => r.event_id));
    const interestArtists: string[] = [];
    const interestFamilies: string[] = [];
    if (interestIds.length) {
      const { data: past } = await admin.from("events").select("artist_name, genres").in("id", interestIds.slice(0, 200));
      for (const e of past ?? []) {
        if (e.artist_name) interestArtists.push(e.artist_name);
        interestFamilies.push(...eventGenres(e.genres).families);
      }
    }

    const taste: UserTaste = {
      dna,
      topArtists: (input?.top_artists ?? []).map((a) => ({ id: a?.id ?? null, name: a?.name ?? null })),
      trackArtists: (input?.top_tracks ?? []).map((t) => t?.artist).filter((a): a is string => typeof a === "string"),
      interestArtists: [...new Set(interestArtists)],
      interestFamilies,
    };

    // ── Location: the request's (device) position, else the user's own
    // consented server location. Never anyone else's.
    const [{ data: me }, { data: prefs }] = await Promise.all([
      admin.from("users").select("last_latitude, last_longitude, is_test_user").eq("id", user.id).maybeSingle(),
      admin.from("privacy_preferences").select("location_processing").eq("user_id", user.id).maybeSingle(),
    ]);
    let origin: { lat: number; lon: number } | null = null;
    let locationSource: "request" | "saved" | "none" = "none";
    if (validLat(body.latitude) && validLon(body.longitude)) {
      origin = { lat: body.latitude, lon: body.longitude };
      locationSource = "request";
    } else if (prefs?.location_processing && validLat(me?.last_latitude) && validLon(me?.last_longitude)) {
      origin = { lat: me.last_latitude, lon: me.last_longitude };
      locationSource = "saved";
    }

    // ── Candidate events (published data only) ──────────────────────────
    const from = isoOrNull(body.date_from);
    const to = isoOrNull(body.date_to);
    const start = from && from > now ? from : now;
    const end = to ?? new Date(now.getTime() + 365 * 86_400_000);
    let query = admin.from("events").select(EVENT_COLUMNS)
      .gte("event_date", start.toISOString())
      .lte("event_date", end.toISOString())
      .not("status", "eq", "canceled");
    if (me?.is_test_user !== true) query = query.eq("is_test_data", false);
    if (origin && radiusKm) {
      const dLat = radiusKm / 111;
      const dLon = radiusKm / (111 * Math.max(Math.cos((origin.lat * Math.PI) / 180), 0.05));
      query = query
        .gte("latitude", origin.lat - dLat).lte("latitude", origin.lat + dLat)
        .gte("longitude", origin.lon - dLon).lte("longitude", origin.lon + dLon);
    }
    const priceMax = typeof body.price_max === "number" && body.price_max > 0 ? body.price_max : null;
    if (priceMax !== null) {
      query = query.eq("price_currency", "EUR").not("price_min", "is", null).lte("price_min", priceMax);
    }
    const { data: events, error: eventsError } = await query.order("event_date", { ascending: true }).limit(800);
    if (eventsError) throw eventsError;

    const filters = {
      family: typeof body.family === "string" && /^[a-z0-9-]{2,40}$/.test(body.family) ? body.family : null,
      artist: typeof body.artist === "string" ? body.artist.slice(0, 80) : null,
      radiusKm,
    };
    const ranked = (events ?? [])
      .map((event) => ({ event, rec: scoreEvent(event as RecEvent, taste, { now, origin }) }))
      .filter(({ event, rec }) => rec.relevance > 0 && passesFilters(rec, event as RecEvent, filters))
      .sort((a, b) => b.rec.total - a.rec.total || a.event.event_date.localeCompare(b.event.event_date))
      .slice(0, limit);

    return reply(200, {
      user_id: user.id,
      limit,
      location_source: locationSource,
      data: ranked.map(({ event, rec }) => ({
        event,
        saved: savedIds.has(event.id),
        distance_km: rec.distanceKm,
        families: rec.families,
        reasons: rec.reasons,
        score: {
          total: rec.total,
          compatibility: rec.relevance,
          artist_match_score: rec.artist,
          genre_match_score: rec.genre,
          interest_score: rec.interest,
          proximity_score: rec.proximity,
          time_score: rec.soonness,
        },
      })),
    });
  } catch (e) {
    console.error("recommend-events failed", e instanceof Error ? e.message : e);
    return reply(500, { error: "internal_error" });
  }
});
