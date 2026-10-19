import {
  assert,
  assertEquals,
  assertRejects,
} from "https://deno.land/std@0.208.0/assert/mod.ts";
import {
  geohash,
  normalizeTicketmasterEvent,
  searchTicketmaster,
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
  assertEquals(params.get("classificationName"), "music");
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
