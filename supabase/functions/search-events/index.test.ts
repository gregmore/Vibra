import {
  assert,
  assertEquals,
} from "https://deno.land/std@0.208.0/assert/mod.ts";

type Handler = (request: Request) => Response | Promise<Response>;
const handlers: Record<string, Handler> = {};
const originalServe = Deno.serve;
let registering = "";
Deno.serve = ((handler: Handler) => {
  handlers[registering] = handler;
  return {};
}) as unknown as typeof Deno.serve;
try {
  registering = "search-events";
  await import("./index.ts");
  registering = "ticketmaster-sync";
  await import("../ticketmaster-sync/index.ts");
} finally {
  Deno.serve = originalServe;
}

const userToken = "fixture-user-token";
const serviceToken = "fixture-service-role";
const jobSecret = "fixture-catalogue-job-credential-000000000000000000";
const userId = "e1400000-0000-0000-0000-000000000001";
const envKeys = [
  "SUPABASE_URL",
  "SUPABASE_ANON_KEY",
  "SUPABASE_SERVICE_ROLE_KEY",
  "TICKETMASTER_API_KEY",
  "VIBRA_CATALOGUE_JOB_SECRET",
];
type Call = {
  url: URL;
  method: string;
  authorization: string | null;
  body: any;
};
type Options = {
  active?: boolean;
  rateLimited?: boolean;
  authUnavailable?: boolean;
  configured?: boolean;
  jobConfigured?: boolean;
  claimed?: boolean;
  claimFails?: boolean;
  writeFails?: boolean;
  cacheWriteFails?: boolean;
  readFails?: boolean;
  providerStatus?: number;
  providerCount?: number;
};

function providerEvent(id: string) {
  return {
    id,
    name: "Fixture concert",
    dates: { start: { dateTime: "2026-11-01T20:00:00Z" } },
    _embedded: {
      venues: [{
        name: "Fixture venue",
        location: { latitude: "45.46", longitude: "9.19" },
      }],
    },
  };
}

async function fixture(
  options: Options,
  run: (calls: Call[]) => Promise<void>,
) {
  const previous = new Map(envKeys.map((key) => [key, Deno.env.get(key)]));
  const previousFetch = globalThis.fetch;
  const calls: Call[] = [];
  Deno.env.set("SUPABASE_URL", "https://fixture.supabase.invalid");
  Deno.env.set("SUPABASE_ANON_KEY", "fixture-anon-key");
  Deno.env.set("SUPABASE_SERVICE_ROLE_KEY", serviceToken);
  if (options.jobConfigured === false) {
    Deno.env.delete("VIBRA_CATALOGUE_JOB_SECRET");
  } else Deno.env.set("VIBRA_CATALOGUE_JOB_SECRET", jobSecret);
  if (options.configured === false) Deno.env.delete("TICKETMASTER_API_KEY");
  else Deno.env.set("TICKETMASTER_API_KEY", "fixture-provider-key");
  const json = (body: unknown, status = 200) =>
    new Response(JSON.stringify(body), {
      status,
      headers: { "Content-Type": "application/json" },
    });
  globalThis.fetch = async (input, init) => {
    const request = new Request(input, init);
    const url = new URL(request.url);
    const raw = request.body ? await request.text() : null;
    const body = raw ? JSON.parse(raw) : null;
    calls.push({
      url,
      method: request.method,
      authorization: request.headers.get("Authorization"),
      body,
    });
    if (url.hostname === "app.ticketmaster.com") {
      if (options.providerStatus) {
        return json(
          { error: "DO_NOT_EXPOSE_PROVIDER_BODY" },
          options.providerStatus,
        );
      }
      const total = options.providerCount ?? 1;
      const page = Number(url.searchParams.get("page"));
      const size = Math.min(200, Math.max(0, total - page * 200));
      const country = url.searchParams.get("countryCode") ?? "viewport";
      return json({
        page: {
          number: page,
          totalElements: total,
          totalPages: Math.ceil(total / 200),
        },
        _embedded: {
          events: Array.from(
            { length: size },
            (_, i) => providerEvent(`${country}-${page}-${i}`),
          ),
        },
      });
    }
    if (url.hostname !== "fixture.supabase.invalid") {
      throw new Error("Unexpected external request");
    }
    const path = url.pathname;
    if (path === "/auth/v1/user") {
      return request.headers.get("Authorization") === `Bearer ${userToken}`
        ? json({ id: userId, email: "fixture@example.invalid" })
        : json({ message: "Invalid session", error_code: "bad_jwt" }, 401);
    }
    if (path === "/rest/v1/rpc/has_active_session") {
      if (options.authUnavailable) throw new Error("Auth unavailable");
      return json(options.active !== false);
    }
    if (path === "/rest/v1/rpc/consume_action_limit") {
      assertEquals(body, { p_action: "search-events" });
      return options.rateLimited
        ? json({ code: "PT429", message: "Rate limit exceeded" }, 429)
        : json(null);
    }
    if (path === "/rest/v1/rpc/claim_event_provider_search") {
      assertEquals(
        request.headers.get("Authorization"),
        `Bearer ${serviceToken}`,
      );
      return options.claimFails
        ? json({ code: "P0001", message: "DO_NOT_EXPOSE_CACHE_ERROR" }, 500)
        : json(options.claimed === true);
    }
    if (path === "/rest/v1/events") {
      assertEquals(
        request.headers.get("Authorization"),
        `Bearer ${serviceToken}`,
      );
      return options.writeFails
        ? json({ code: "P0001", message: "DO_NOT_EXPOSE_WRITE_ERROR" }, 500)
        : json(null, 201);
    }
    if (path === "/rest/v1/event_provider_search_cache") {
      assertEquals(
        request.headers.get("Authorization"),
        `Bearer ${serviceToken}`,
      );
      return options.cacheWriteFails
        ? json({ code: "P0001", message: "DO_NOT_EXPOSE_CACHE_ERROR" }, 500)
        : json(null);
    }
    if (path === "/rest/v1/rpc/find_events_in_radius") {
      assertEquals(request.headers.get("Authorization"), `Bearer ${userToken}`);
      return options.readFails
        ? json({ code: "P0001", message: "DO_NOT_EXPOSE_READ_ERROR" }, 500)
        : json([{ id: "public-visible-event", name: "Public fixture" }]);
    }
    throw new Error(`Unexpected Supabase endpoint: ${path}`);
  };
  try {
    await run(calls);
  } finally {
    globalThis.fetch = previousFetch;
    for (const [key, value] of previous) {
      if (value === undefined) Deno.env.delete(key);
      else Deno.env.set(key, value);
    }
  }
}

function request(name: string, token = userToken, body: unknown = {
  latitude: 45.4642,
  longitude: 9.1901,
  radius_km: 100,
}, method = "POST") {
  return new Request(`https://edge.example.invalid/${name}`, {
    method,
    headers: token
      ? {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
        ...(name === "ticketmaster-sync" && token === jobSecret
          ? { "x-vibra-job-secret": token }
          : {}),
      }
      : {},
    body: method === "POST" ? JSON.stringify(body) : undefined,
  });
}
const providerCalls = (calls: Call[]) =>
  calls.filter((call) => call.url.hostname === "app.ticketmaster.com");
const callsTo = (calls: Call[], path: string) =>
  calls.filter((call) => call.url.pathname === path);

Deno.test("event discovery preflight and unsupported methods avoid authentication/provider work", async () => {
  await fixture({}, async (calls) => {
    assertEquals(
      (await handlers["search-events"](
        request("search-events", "", {}, "OPTIONS"),
      )).status,
      200,
    );
    assertEquals(
      (await handlers["search-events"](request("search-events", "", {}, "GET")))
        .status,
      405,
    );
    assertEquals(calls, []);
  });
});

Deno.test("anonymous discovery cannot claim an area, call the provider or read the catalogue", async () => {
  await fixture({}, async (calls) => {
    assertEquals(
      (await handlers["search-events"](request("search-events", ""))).status,
      401,
    );
    assertEquals(providerCalls(calls), []);
    assertEquals(
      calls.every((call) => call.url.pathname === "/auth/v1/user"),
      true,
    );
  });
});

Deno.test("revoked or unavailable sessions fail closed before rate limits and provider requests", async (test) => {
  for (const options of [{ active: false }, { authUnavailable: true }]) {
    await test.step(JSON.stringify(options), async () => {
      await fixture(options, async (calls) => {
        assertEquals(
          (await handlers["search-events"](request("search-events"))).status,
          401,
        );
        assertEquals(providerCalls(calls), []);
        assertEquals(callsTo(calls, "/rest/v1/rpc/consume_action_limit"), []);
        assertEquals(
          callsTo(calls, "/rest/v1/rpc/claim_event_provider_search"),
          [],
        );
      });
    });
  }
});

Deno.test("discovery rate limits expose Retry-After and prevent service-role work", async () => {
  await fixture({ rateLimited: true }, async (calls) => {
    const result = await handlers["search-events"](request("search-events"));
    assertEquals(result.status, 429);
    assertEquals(result.headers.get("Retry-After"), "60");
    assertEquals(await result.json(), { error: "rate_limit_exceeded" });
    assertEquals(providerCalls(calls), []);
    assertEquals(
      calls.some((call) => call.authorization === `Bearer ${serviceToken}`),
      false,
    );
  });
});

Deno.test("invalid search bodies and impossible geographic areas never reach the provider", async () => {
  await fixture({}, async (calls) => {
    for (
      const body of [
        null,
        [],
        "invalid",
        { latitude: "45", longitude: 9, radius_km: 100 },
        { latitude: 91, longitude: 9, radius_km: 100 },
        { latitude: 45, longitude: 181, radius_km: 100 },
        { latitude: 45, longitude: 9, radius_km: 0 },
        { latitude: 45, longitude: 9, radius_km: 251 },
      ]
    ) {
      assertEquals(
        (await handlers["search-events"](
          request("search-events", userToken, body),
        )).status,
        400,
      );
    }
    const malformed = new Request(
      "https://edge.example.invalid/search-events",
      {
        method: "POST",
        headers: { Authorization: `Bearer ${userToken}` },
        body: "not JSON",
      },
    );
    assertEquals((await handlers["search-events"](malformed)).status, 400);
    assertEquals(providerCalls(calls), []);
    assertEquals(
      callsTo(calls, "/rest/v1/rpc/claim_event_provider_search"),
      [],
    );
  });
});

Deno.test("oversized authenticated request streams are rejected before provider work", async () => {
  await fixture({}, async (calls) => {
    const oversized = new Request(
      "https://edge.example.invalid/search-events",
      {
        method: "POST",
        headers: { Authorization: `Bearer ${userToken}` },
        body: JSON.stringify({
          latitude: 45,
          longitude: 9,
          radius_km: 100,
          unused: "x".repeat(5000),
        }),
      },
    );
    assertEquals((await handlers["search-events"](oversized)).status, 400);
    assertEquals(providerCalls(calls), []);
  });
});

Deno.test("missing provider configuration is explicit and cannot stamp a successful refresh", async () => {
  await fixture({ configured: false }, async (calls) => {
    const result = await handlers["search-events"](request("search-events"));
    assertEquals(result.status, 503);
    assertEquals(await result.json(), {
      error: "event_provider_not_configured",
    });
    assertEquals(
      callsTo(calls, "/rest/v1/rpc/claim_event_provider_search"),
      [],
    );
  });
});

Deno.test("fresh shared coarse area skips provider and returns events through the caller's RLS", async () => {
  await fixture({}, async (calls) => {
    const result = await handlers["search-events"](
      request("search-events", userToken, {
        latitude: 45.4642,
        longitude: 9.1901,
        radius_km: 99.2,
        user_id: "untrusted-user",
        events: ["forged"],
      }),
    );
    assertEquals(result.status, 200);
    const body = await result.json();
    assertEquals(body.events, [{
      id: "public-visible-event",
      name: "Public fixture",
    }]);
    assertEquals(body.refreshed, false);
    assertEquals(body.provider_total, null);
    assertEquals(body.result_limit, 500);
    assertEquals(providerCalls(calls), []);
    assertEquals(
      callsTo(calls, "/rest/v1/rpc/claim_event_provider_search")[0].body,
      { p_cache_key: "45.46:9.19:102" },
    );
    assertEquals(callsTo(calls, "/rest/v1/rpc/find_events_in_radius")[0].body, {
      p_latitude: 45.4642,
      p_longitude: 9.1901,
      p_radius_meters: 99200,
      p_status: null,
      p_limit: 500,
    });
    assertEquals(callsTo(calls, "/rest/v1/events"), []);
  });
});

Deno.test("claimed area imports only normalized provider events in bounded batches before marking success", async () => {
  await fixture({ claimed: true, providerCount: 201 }, async (calls) => {
    const result = await handlers["search-events"](request("search-events"));
    assertEquals(result.status, 200);
    const body = await result.json();
    assertEquals(body.refreshed, true);
    assertEquals(body.provider_total, 201);
    assertEquals(body.provider_truncated, false);
    assertEquals(providerCalls(calls).length, 2);
    assertEquals(
      callsTo(calls, "/rest/v1/events").map((call) => call.body.length),
      [200, 1],
    );
    const cache = callsTo(calls, "/rest/v1/event_provider_search_cache");
    assertEquals(cache.length, 1);
    assertEquals(cache[0].method, "PATCH");
    assertEquals(Object.keys(cache[0].body), ["succeeded_at"]);
    assert(Number.isFinite(Date.parse(cache[0].body.succeeded_at)));
    assertEquals(
      cache[0].url.searchParams.get("cache_key"),
      "eq.45.46:9.19:102",
    );
    assertEquals(
      callsTo(calls, "/rest/v1/events")[0].url.searchParams.get("on_conflict"),
      "source,external_id",
    );
  });
});

Deno.test("provider failures return an actionable failure without leaking bodies or stamping success", async () => {
  await fixture({ claimed: true, providerStatus: 429 }, async (calls) => {
    const result = await handlers["search-events"](request("search-events"));
    assertEquals(result.status, 502);
    assertEquals(await result.json(), { error: "event_provider_unavailable" });
    assertEquals(callsTo(calls, "/rest/v1/event_provider_search_cache"), []);
    assertEquals(callsTo(calls, "/rest/v1/events"), []);
  });
});

Deno.test("cache claims, persistence and caller reads preserve their distinct failure boundaries", async (test) => {
  for (
    const [options, expected] of [
      [{ claimFails: true }, "event_cache_unavailable"],
      [{ claimed: true, writeFails: true }, "event_sync_failed"],
      [{ claimed: true, cacheWriteFails: true }, "event_cache_unavailable"],
      [{ readFails: true }, "event_read_failed"],
    ] as [Options, string][]
  ) {
    await test.step(expected + JSON.stringify(options), async () => {
      await fixture(options, async (calls) => {
        const result = await handlers["search-events"](
          request("search-events"),
        );
        assertEquals(result.status, 500);
        assertEquals(await result.json(), { error: expected });
        if (options.claimFails || options.writeFails) {
          assertEquals(
            callsTo(calls, "/rest/v1/event_provider_search_cache"),
            [],
          );
        }
      });
    });
  }
});

Deno.test("catalogue worker authenticates only its dedicated secret before input, provider or database work", async () => {
  await fixture({}, async (calls) => {
    for (const token of ["", userToken, serviceToken, "forged-service"]) {
      assertEquals(
        (await handlers["ticketmaster-sync"](
          request("ticketmaster-sync", token, {}),
        )).status,
        401,
      );
    }
    assertEquals(
      (await handlers["ticketmaster-sync"](
        request("ticketmaster-sync", jobSecret, {}, "GET"),
      )).status,
      401,
    );
    assertEquals(
      (await handlers["ticketmaster-sync"](
        request("ticketmaster-sync", "", {}, "OPTIONS"),
      )).status,
      200,
    );
    assertEquals(calls, []);
  });
});

Deno.test("catalogue worker rejects malformed country requests without provider calls", async () => {
  await fixture({}, async (calls) => {
    for (
      const body of [
        null,
        [],
        "invalid",
        { country_codes: [] },
        { country_codes: "IT" },
        { country_codes: ["it"] },
        { country_codes: ["ITALY"] },
        { country_codes: [null] },
        { country_codes: ["IT", "FR", "DE", "ES", "GB", "US"] },
      ]
    ) {
      assertEquals(
        (await handlers["ticketmaster-sync"](
          request("ticketmaster-sync", jobSecret, body),
        )).status,
        400,
      );
    }
    assertEquals(providerCalls(calls), []);
    assertEquals(callsTo(calls, "/rest/v1/events"), []);
  });
});

Deno.test("catalogue worker imports future public music events, deduplicates countries and caps each batch", async () => {
  await fixture({ providerCount: 201 }, async (calls) => {
    const result = await handlers["ticketmaster-sync"](
      request("ticketmaster-sync", jobSecret, {
        country_codes: ["IT", "IT", "DE"],
      }),
    );
    assertEquals(result.status, 200);
    const body = await result.json();
    assertEquals(body.imported, 402);
    assertEquals(body.countries.map((country: any) => country.country), [
      "IT",
      "DE",
    ]);
    assertEquals(providerCalls(calls).length, 4);
    assertEquals(
      callsTo(calls, "/rest/v1/events").map((call) => call.body.length),
      [200, 1, 200, 1],
    );
    assertEquals(
      calls.some((call) => call.url.pathname.startsWith("/auth/")),
      false,
    );
    assertEquals(callsTo(calls, "/rest/v1/rpc/find_events_in_radius"), []);
  });
});

Deno.test("catalogue worker failures do not claim a completed import or expose provider/server bodies", async (test) => {
  for (const options of [{ providerStatus: 503 }, { writeFails: true }]) {
    await test.step(JSON.stringify(options), async () => {
      await fixture(options, async () => {
        const result = await handlers["ticketmaster-sync"](
          request("ticketmaster-sync", jobSecret, {}),
        );
        assertEquals(result.status, 502);
        assertEquals(await result.json(), {
          error: "catalogue_sync_failed",
          completed_countries: [],
        });
      });
    });
  }
});

Deno.test("catalogue worker rejects missing configuration and incorrect job header without work", async () => {
  await fixture({ jobConfigured: false }, async (calls) => {
    assertEquals(
      (await handlers["ticketmaster-sync"](
        request("ticketmaster-sync", jobSecret, {}),
      )).status,
      401,
    );
    assertEquals(calls, []);
  });
  await fixture({}, async (calls) => {
    for (const secret of ["incorrect", jobSecret + "x", "x".repeat(257)]) {
      const req = new Request(
        "https://edge.example.invalid/ticketmaster-sync",
        {
          method: "POST",
          headers: { "x-vibra-job-secret": secret },
          body: "{}",
        },
      );
      assertEquals((await handlers["ticketmaster-sync"](req)).status, 401);
    }
    assertEquals(calls, []);
    const req = new Request("https://edge.example.invalid/ticketmaster-sync", {
      method: "POST",
      headers: { "x-vibra-job-secret": jobSecret },
      body: '{"country_codes":[]}',
    });
    assertEquals((await handlers["ticketmaster-sync"](req)).status, 400);
    assertEquals(calls, []);
  });
});
