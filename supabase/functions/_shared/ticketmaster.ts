export type TicketmasterQuery = {
  latitude?: number; longitude?: number; radiusKm?: number; countryCode?: string;
  start?: Date; maximumPages?: number;
};
export type EventRow = Record<string, unknown> & { external_id: string };

function text(value: unknown, limit: number): string | null {
  return typeof value === "string" && value.trim() ? Array.from(value.trim()).slice(0, limit).map((c) => {
    const cp = c.codePointAt(0)!; return cp >= 0xD800 && cp <= 0xDFFF ? "\uFFFD" : c;
  }).join("") : null;
}
function https(value: unknown): string | null {
  try {
    const url = new URL(String(value));
    return url.protocol === "https:" && !url.username && !url.password ? url.href : null;
  } catch { return null; }
}
function coordinate(value: unknown, maximum: number): number | null {
  if (typeof value !== "number" && typeof value !== "string") return null;
  if (typeof value === "string" && !/^[+-]?(?:\d+(?:\.\d*)?|\.\d+)$/.test(value.trim())) return null;
  const n = Number(value);
  return Number.isFinite(n) && Math.abs(n) <= maximum ? n : null;
}

// Provider data only: requests never accept client-written event records.
export function normalizeTicketmasterEvent(raw: any): EventRow | null {
  if (!raw || raw.test === true || typeof raw.id !== "string" ||
      !/^[a-zA-Z0-9_-]{1,200}$/.test(raw.id)) return null;
  const name = text(raw.name, 500);
  const venues = raw._embedded?.venues;
  if (!Array.isArray(venues)) return null;
  const venue = venues.find((v: any) =>
    coordinate(v?.location?.latitude, 90) !== null && coordinate(v?.location?.longitude, 180) !== null);
  if (!name || !venue) return null;
  const date = raw.dates?.start?.dateTime ??
    (/^\d{4}-\d{2}-\d{2}$/.test(raw.dates?.start?.localDate ?? "") ? `${raw.dates.start.localDate}T00:00:00Z` : null);
  if (typeof date !== "string" || !/^\d{4}-\d{2}-\d{2}T/.test(date) || !Number.isFinite(Date.parse(date))) return null;
  const day = date.slice(0, 10), dayValue = Date.parse(`${day}T00:00:00Z`);
  if (!Number.isFinite(dayValue) || new Date(dayValue).toISOString().slice(0, 10) !== day) return null;
  const codes = new Set(["onsale", "offsale", "canceled", "postponed", "rescheduled"]);
  const status = raw.dates?.status?.code ?? "onsale";
  if (!codes.has(status)) return null;
  const classifications = Array.isArray(raw.classifications) ? raw.classifications : [];
  const genres = [...new Set(classifications.flatMap((c: any) =>
    [c?.genre?.name, c?.subGenre?.name]).filter((s: unknown) => typeof s === "string" && s !== "Undefined"))];
  const image = (Array.isArray(raw.images) ? [...raw.images].filter((i: any) => i && typeof i === "object") : []).sort((a, b) =>
    Math.abs((a.width ?? 0) - 1024) - Math.abs((b.width ?? 0) - 1024)).find((i) => https(i.url));
  const prices = (Array.isArray(raw.priceRanges) ? raw.priceRanges : []).find((p: any) =>
    p && Number.isFinite(p.min) && Number.isFinite(p.max) && p.min >= 0 && p.max >= p.min);
  return {
    external_id: raw.id, source: "ticketmaster", name,
    artist_name: text(raw._embedded?.attractions?.[0]?.name, 300),
    venue_name: text(venue.name, 300), city: text(venue.city?.name, 150),
    country: typeof venue.country?.countryCode === "string" && /^[A-Z]{2}$/.test(venue.country.countryCode) ? venue.country.countryCode : null,
    latitude: coordinate(venue.location.latitude, 90), longitude: coordinate(venue.location.longitude, 180),
    event_date: new Date(date).toISOString(), status,
    ticket_url: https(raw.url), image_url: https(image?.url),
    price_min: prices?.min ?? null, price_max: prices?.max ?? null,
    description: text([text(raw.info, 3000), text(raw.description, 3000), genres.join(", ")].filter(Boolean).join("\n"), 6000),
  };
}

export function geohash(latitude: number, longitude: number, precision = 9): string {
  const alphabet = "0123456789bcdefghjkmnpqrstuvwxyz";
  const lat = [-90, 90], lon = [-180, 180];
  let hash = "", value = 0, bits = 0, even = true;
  while (hash.length < precision) {
    const range = even ? lon : lat, coordinate = even ? longitude : latitude;
    const middle = (range[0] + range[1]) / 2;
    value = (value << 1) | (coordinate >= middle ? 1 : 0);
    range[coordinate >= middle ? 0 : 1] = middle;
    even = !even;
    if (++bits === 5) { hash += alphabet[value]; bits = 0; value = 0; }
  }
  return hash;
}

export async function limitedJson(response: Response, maximum = 4 * 1024 * 1024): Promise<any> {
  const reader = response.body?.getReader();
  if (!reader) throw new Error("empty_provider_response");
  const chunks: Uint8Array[] = []; let size = 0;
  while (true) {
    const part = await reader.read(); if (part.done) break;
    size += part.value.length;
    if (size > maximum) { await reader.cancel(); throw new Error("provider_response_too_large"); }
    chunks.push(part.value);
  }
  const bytes = new Uint8Array(size); let offset = 0;
  for (const chunk of chunks) { bytes.set(chunk, offset); offset += chunk.length; }
  return JSON.parse(new TextDecoder().decode(bytes));
}

export async function searchTicketmaster(
  key: string, query: TicketmasterQuery, request: typeof fetch = fetch,
): Promise<{ rows: EventRow[]; total: number; pages: number; truncated: boolean }> {
  const rows = new Map<string, EventRow>();
  let total = 0, pages = 0;
  // Discovery deep paging permits at most the first 1000 matches, not 10k.
  const maximumPages = Math.min(5, Math.max(1, query.maximumPages ?? 5));
  for (let page = 0; page < maximumPages; page++) {
    const url = new URL("https://app.ticketmaster.com/discovery/v2/events.json");
    const params: Record<string, string> = {
      apikey: key, classificationName: "music", size: "200", page: String(page),
      sort: query.latitude === undefined ? "date,asc" : "distance,asc",
      startDateTime: (query.start ?? new Date()).toISOString().replace(/\.\d{3}Z$/, "Z"),
      includeTBA: "no", includeTBD: "no", includeTest: "no",
    };
    if (query.countryCode) params.countryCode = query.countryCode;
    if (query.latitude !== undefined && query.longitude !== undefined) {
      params.geoPoint = geohash(query.latitude, query.longitude);
      params.radius = String(query.radiusKm ?? 25); params.unit = "km";
    }
    for (const [name, value] of Object.entries(params)) url.searchParams.set(name, value);
    const response = await request(url, { redirect: "error", signal: AbortSignal.timeout(12000) });
    if (!response.ok) throw new Error(`event_provider_http_${response.status}`);
    const body = await limitedJson(response);
    if (!body || typeof body !== "object" || !body.page || typeof body.page !== "object") throw new Error("invalid_provider_response");
    const data = body?._embedded?.events ?? [];
    if (!Array.isArray(data) || data.length > 200) throw new Error("invalid_provider_response");
    total = Number(body.page?.totalElements ?? data.length);
    const totalPages = Number(body.page?.totalPages ?? 0);
    if (!Number.isSafeInteger(total) || total < 0 || !Number.isSafeInteger(totalPages) || totalPages < 0)
      throw new Error("invalid_provider_total");
    for (const raw of data) { const row = normalizeTicketmasterEvent(raw); if (row) rows.set(row.external_id, row); }
    pages++;
    if (data.length < 200 || pages >= totalPages) break;
  }
  return { rows: [...rows.values()], total, pages, truncated: total > pages * 200 };
}
