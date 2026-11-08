import {
  assert,
  assertEquals,
  assertRejects,
} from "https://deno.land/std@0.208.0/assert/mod.ts";
import {
  geohash,
  MUSIC_SEGMENT_ID,
  normalizeTicketmasterEvent,
  providerSearchArea,
  searchTicketmaster,
  searchTicketmasterAll,
} from "./ticketmaster.ts";

function event(id = "fixture-event"): any {
  return {
    id,
    name: "  Fixture live concert  ",
    test: false,
    url: "https://www.ticketmaster.it/event/fixture",
    dates: {
      start: { dateTime: "2026-11-01T20:00:00Z" },
      status: { code: "onsale" },
    },
    classifications: [{
      genre: { name: "Rock" },
      subGenre: { name: "Alternative" },
    }, { genre: { name: "Rock" }, subGenre: { name: "Undefined" } }],
    images: [{ url: "http://example.invalid/unsafe.jpg", width: 1024 }, {
      url: "https://images.example.invalid/small.jpg",
      width: 100,
    }, { url: "https://images.example.invalid/large.jpg", width: 1000 }],
    priceRanges: [{ min: 20, max: 70, currency: "EUR" }],
    _embedded: {
      venues: [{
        name: "Fixture venue",
        city: { name: "Milano" },
        country: { countryCode: "IT" },
        location: { latitude: "45.4642", longitude: "9.1900" },
      }],
      attractions: [{ name: "Fixture artist" }],
    },
  };
}

function response(data: unknown) {
  return new Response(JSON.stringify(data), {
    headers: { "Content-Type": "application/json" },
  });
}

Deno.test("provider normalization uses only supported canonical fields and safe links", () => {
  const raw = event();
  raw.user_id = "must-not-be-imported";
  raw.is_test_data = true;
  const row = normalizeTicketmasterEvent(raw)!;
  assertEquals(row.external_id, "fixture-event");
  assertEquals(row.source, "ticketmaster");
  assertEquals(row.name, "Fixture live concert");
  assertEquals(row.latitude, 45.4642);
  assertEquals(row.longitude, 9.19);
  assertEquals(row.artist_name, "Fixture artist");
  assertEquals(row.description, "Rock, Alternative");
  assertEquals(row.genres, ["Rock", "Alternative"]);
  assertEquals(row.event_date, "2026-11-01T20:00:00.000Z");
  assertEquals(row.image_url, "https://images.example.invalid/large.jpg");
  assertEquals(row.price_min, 20);
  assertEquals(row.price_max, 70);
  assertEquals("user_id" in row, false);
  assertEquals("is_test_data" in row, false);
});

Deno.test("unsafe event/image URLs are removed rather than copied to the app", () => {
  for (
    const url of [
      "javascript:alert(1)",
      "http://example.invalid/event",
      "https://user:password@example.invalid/event",
      "not a url",
    ]
  ) {
    const raw = event();
    raw.url = url;
    raw.images = [{ url, width: 1024 }];
    const row = normalizeTicketmasterEvent(raw)!;
    assertEquals(row.ticket_url, null);
    assertEquals(row.image_url, null);
  }
});

Deno.test("test events, invalid IDs, missing venue/name and invalid dates do not enter the catalogue", () => {
  const variants = [
    { ...event(), test: true },
    { ...event(), id: "path/forged" },
    { ...event(), id: "" },
    { ...event(), name: "  " },
    { ...event(), _embedded: {} },
    { ...event(), dates: { start: { dateTime: "invalid" } } },
    { ...event(), dates: { start: { localDate: "2026-02-31" } } },
    {
      ...event(),
      dates: {
        start: { dateTime: "2026-11-01T20:00:00Z" },
        status: { code: "unknown" },
      },
    },
  ];
  for (const raw of variants) {
    assertEquals(normalizeTicketmasterEvent(raw), null);
  }
});

Deno.test("malformed nested provider records cannot crash normalization", () => {
  for (
    const patch of [
      { _embedded: { venues: {} } },
      { _embedded: { venues: "venue" } },
      { classifications: {} },
      { classifications: [null, {}, { genre: null }] },
      { images: {} },
      { images: [null, {}] },
      { priceRanges: {} },
      { priceRanges: [null, {}] },
    ]
  ) {
    // Optional malformed sections may be discarded, whereas a missing real
    // venue drops the event. In either case one record must not break a batch.
    const row = normalizeTicketmasterEvent({ ...event(), ...patch });
    assert(row === null || row.external_id === "fixture-event");
  }
});

Deno.test("only finite geographic numeric values are accepted as venue coordinates", () => {
  for (
    const [latitude, longitude] of [
      [91, 9],
      [45, 181],
      [NaN, 9],
      [45, Infinity],
      [null, 9],
      [45, ""],
      [false, 9],
      [[], 9],
      ["   ", 9],
    ]
  ) {
    const raw = event();
    raw._embedded.venues[0].location = { latitude, longitude };
    assertEquals(normalizeTicketmasterEvent(raw), null);
  }
  const raw = event();
  raw._embedded.venues.unshift({ location: { latitude: 100, longitude: 0 } });
  assertEquals(normalizeTicketmasterEvent(raw)!.latitude, 45.4642);
});

Deno.test("price ranges must be finite, nonnegative and ordered", () => {
  for (
    const range of [{ min: -1, max: 20 }, { min: 30, max: 20 }, {
      min: "1",
      max: 20,
    }]
  ) {
    const raw = event();
    raw.priceRanges = [range];
    const row = normalizeTicketmasterEvent(raw)!;
    assertEquals(row.price_min, null);
    assertEquals(row.price_max, null);
  }
});

Deno.test("text limits preserve complete Unicode scalars for PostgreSQL JSON input", () => {
  const raw = event();
  raw.name = "a" + "😀".repeat(1000);
  const row = normalizeTicketmasterEvent(raw)!;
  const name = row.name as string;
  assertEquals([...name].length, 500);
  assertEquals(name.endsWith("😀"), true);
  assertEquals(name, "a" + "😀".repeat(499));
});

Deno.test("local-date fallback is deterministic and future cancellation status is retained", () => {
  const raw = event();
  raw.dates = {
    start: { localDate: "2026-11-01" },
    status: { code: "canceled" },
  };
  const row = normalizeTicketmasterEvent(raw)!;
  assertEquals(row.event_date, "2026-11-01T00:00:00.000Z");
  assertEquals(row.status, "canceled");
});

Deno.test("geohash follows the standard interleaved WGS84 cell encoding", () => {
  assertEquals(geohash(42.6, -5.6, 5), "ezs42");
  assertEquals(geohash(57.64911, 10.40744, 11), "u4pruydqqvj");
  assertEquals(geohash(0, 0, 9), "s00000000");
  assertEquals(geohash(45.4642, 9.19).length, 9);
});

Deno.test("discovery fetches at most five 200-result pages and reports provider truncation", async () => {
  const urls: URL[] = [];
  const result = await searchTicketmaster("fixture-key", {
    latitude: 45.4642,
    longitude: 9.19,
    radiusKm: 100,
    start: new Date("2026-10-14T00:00:00Z"),
    maximumPages: 500,
    pauseMs: 0,
  }, async (input, options) => {
    const url = new URL(String(input));
    urls.push(url);
    const page = Number(url.searchParams.get("page"));
    assertEquals(options?.redirect, "error");
    assert(options?.signal instanceof AbortSignal);
    return response({
      page: { number: page, totalPages: 20, totalElements: 4000 },
      _embedded: {
        events: Array.from(
          { length: 200 },
          (_, i) => event(`event-${page}-${i}`),
        ),
      },
    });
  });
  assertEquals(urls.length, 5);
  assertEquals(result.rows.length, 1000);
  assertEquals(result.total, 4000);
  assertEquals(result.pages, 5);
  assertEquals(result.truncated, true);
  assertEquals(urls.map((u) => u.searchParams.get("page")), [
    "0",
    "1",
    "2",
    "3",
    "4",
  ]);
  const params = urls[0].searchParams;
  assertEquals(params.get("size"), "200");
  // Exact Music segment, applied by the provider (no sport/arts/family).
  assertEquals(params.get("segmentId"), MUSIC_SEGMENT_ID);
  assertEquals(params.get("classificationName"), null);
  assertEquals(params.get("includeTest"), "no");
  assertEquals(params.get("includeTBA"), "no");
  assertEquals(params.get("includeTBD"), "no");
  assertEquals(params.get("geoPoint"), geohash(45.4642, 9.19));
  assertEquals(params.get("unit"), "km");
  assertEquals(params.get("radius"), "100");
  assertEquals(params.get("startDateTime"), "2026-10-14T00:00:00Z");
  assertEquals(params.get("sort"), "distance,asc");
});

Deno.test("short final pages stop paging and duplicate provider IDs do not multiply map events", async () => {
  let calls = 0;
  const result = await searchTicketmaster(
    "fixture-key",
    { countryCode: "IT" },
    async (input) => {
      const url = new URL(String(input));
      assertEquals(url.searchParams.get("countryCode"), "IT");
      assertEquals(url.searchParams.get("sort"), "date,asc");
      calls++;
      return calls === 1
        ? response({
          page: { totalPages: 2, totalElements: 201 },
          _embedded: {
            events: Array.from({ length: 200 }, (_, i) => event(`event-${i}`)),
          },
        })
        : response({
          page: { totalPages: 2, totalElements: 201 },
          _embedded: { events: [event("event-0")] },
        });
    },
  );
  assertEquals(calls, 2);
  assertEquals(result.rows.length, 200);
  assertEquals(result.pages, 2);
  assertEquals(result.truncated, false);
});

Deno.test("empty provider results are a successful empty catalogue search", async () => {
  const result = await searchTicketmaster(
    "fixture-key",
    {},
    async () => response({ page: { totalElements: 0, totalPages: 0 } }),
  );
  assertEquals(result, { rows: [], total: 0, pages: 1, truncated: false });
});

Deno.test("provider HTTP failures, malformed bodies and oversized streams fail closed", async () => {
  for (
    const request of [
      async () => new Response("provider private error", { status: 429 }),
      async () => new Response("not JSON"),
      async () => response({ _embedded: { events: {} } }),
      async () =>
        response({ page: { totalElements: -1 }, _embedded: { events: [] } }),
      async () => new Response(" ".repeat(4 * 1024 * 1024 + 1)),
      async () =>
        response({
          page: { totalElements: 201, totalPages: 1 },
          _embedded: {
            events: Array.from({ length: 201 }, (_, i) => event(`event-${i}`)),
          },
        }),
    ]
  ) {
    await assertRejects(() => searchTicketmaster("fixture-key", {}, request));
  }
});

Deno.test("network/abort failures cannot produce partial successful results", async () => {
  let calls = 0;
  await assertRejects(
    () =>
      searchTicketmaster("fixture-key", {}, async () => {
        if (++calls === 2) throw new DOMException("Timed out", "TimeoutError");
        return response({
          page: { totalElements: 400, totalPages: 2 },
          _embedded: {
            events: Array.from({ length: 200 }, (_, i) => event(`event-${i}`)),
          },
        });
      }),
    DOMException,
    "Timed out",
  );
  assertEquals(calls, 2);
});

Deno.test("windowed search splits date ranges beyond the paging ceiling and keeps every event", async () => {
  // 1500 events in January (too many for one query), 300 in February.
  const january = Array.from({ length: 1500 }, (_, i) => `jan-${i}`);
  const february = Array.from({ length: 300 }, (_, i) => `feb-${i}`);
  const all = [
    ...january.map((id, i) => ({ id, at: Date.UTC(2027, 0, 1 + (i % 31)) })),
    ...february.map((id, i) => ({ id, at: Date.UTC(2027, 1, 1 + (i % 28)) })),
  ];
  const urls: URL[] = [];
  const result = await searchTicketmasterAll("fixture-key", {
    countryCode: "IT",
    start: new Date(Date.UTC(2027, 0, 1)),
    end: new Date(Date.UTC(2027, 2, 1)),
    pauseMs: 0,
  }, async (input) => {
    const url = new URL(String(input));
    urls.push(url);
    const from = Date.parse(url.searchParams.get("startDateTime")!);
    const to = Date.parse(url.searchParams.get("endDateTime")!);
    const page = Number(url.searchParams.get("page"));
    const matches = all.filter((e) => e.at >= from && e.at < to);
    const slice = matches.slice(page * 200, page * 200 + 200);
    return response({
      page: { totalElements: matches.length, totalPages: Math.ceil(matches.length / 200) },
      _embedded: {
        events: slice.map((e) => {
          const raw = event(e.id);
          raw.dates.start.dateTime = new Date(e.at + 20 * 3600_000).toISOString();
          return raw;
        }),
      },
    });
  }, 200);
  assertEquals(result.rows.length, 1800);
  assertEquals(result.truncated, false);
  assert(urls.every((u) => u.searchParams.get("segmentId") === MUSIC_SEGMENT_ID));
  assert(result.windows > 1);
});

Deno.test("windowed search reports truncation instead of silently stopping at its budget", async () => {
  let calls = 0;
  const result = await searchTicketmasterAll("fixture-key", {
    countryCode: "IT",
    start: new Date(Date.UTC(2027, 0, 1)),
    end: new Date(Date.UTC(2027, 6, 1)),
    pauseMs: 0,
  }, async (input) => {
    const page = Number(new URL(String(input)).searchParams.get("page"));
    calls++;
    return response({
      page: { totalElements: 5000, totalPages: 25 },
      _embedded: {
        events: Array.from({ length: 200 }, (_, i) => event(`e-${calls}-${page}-${i}`)),
      },
    });
  }, 3);
  assertEquals(result.requests, 3);
  assertEquals(result.truncated, true);
});

Deno.test("map areas snap to a radius-proportional grid that still covers the view", () => {
  const a = providerSearchArea(45.4642, 9.19, 100);
  const b = providerSearchArea(45.47, 9.2, 100);
  assertEquals(a.cacheKey, b.cacheKey);
  assert(a.radiusKm >= 100 + 25 * 0.75);
  assert(/^-?[0-9.]+:-?[0-9.]+:[0-9]+$/.test(a.cacheKey));
  const small = providerSearchArea(45.4642, 9.19, 2);
  assert(small.radiusKm >= 2);
  assert(/^-?[0-9.]+:-?[0-9.]+:[0-9]+$/.test(providerSearchArea(-33.9, -179.99, 250).cacheKey));
});
