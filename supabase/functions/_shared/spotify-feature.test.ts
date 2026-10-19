import { assertEquals } from "https://deno.land/std@0.208.0/assert/mod.ts";
import { isSpotifyEnabled } from "./spotify-feature.ts";
import { fetchSpotifyArtistsByIds, getSpotifyAppAccessToken } from "./spotify_app_token.ts";

type Handler = (request: Request) => Response | Promise<Response>;
const handlers: Record<string, Handler> = {};
const functionNames = ["spotify-token-exchange", "sync-music-profile", "calculate-match",
  "recommend-events", "compute-event-embeddings", "send-notifications",
  "retention-notifications", "send-social-notification", "spotify-disconnect"];

// Capture the actual deployed entrypoints, without starting HTTP servers or
// duplicating their authorization/feature-guard logic in test-only handlers.
const originalServe = Deno.serve;
let registering = "";
Deno.serve = ((handler: Handler) => {
  handlers[registering] = handler;
  return {};
}) as unknown as typeof Deno.serve;
try {
  for (const name of functionNames) {
    registering = name;
    await import(`../${name}/index.ts`);
  }
} finally {
  Deno.serve = originalServe;
}

const fixtureUserId = "f1000000-0000-0000-0000-000000000001";
const userToken = "fixture-user-token";
const serviceToken = "fixture-service-key-with-at-least-32-characters";
const envKeys = ["SPOTIFY_ENABLED", "SPOTIFY_CLIENT_ID", "SPOTIFY_CLIENT_SECRET",
  "SUPABASE_URL", "SUPABASE_ANON_KEY", "SUPABASE_SERVICE_ROLE_KEY", "VIBRA_NOTIFICATION_WORKER_KEY"];

async function fixture(run: (calls: string[]) => Promise<void>) {
  const previous = new Map(envKeys.map((key) => [key, Deno.env.get(key)]));
  const previousFetch = globalThis.fetch;
  const calls: string[] = [];
  Deno.env.set("SPOTIFY_ENABLED", "false");
  Deno.env.set("SUPABASE_URL", "https://fixture.supabase.invalid");
  Deno.env.set("SUPABASE_ANON_KEY", "fixture-anon-key");
  Deno.env.set("SUPABASE_SERVICE_ROLE_KEY", serviceToken);
  Deno.env.delete("VIBRA_NOTIFICATION_WORKER_KEY");
  // Deliberately omit Spotify credentials: a disabled feature must not need them.
  Deno.env.delete("SPOTIFY_CLIENT_ID");
  Deno.env.delete("SPOTIFY_CLIENT_SECRET");
  globalThis.fetch = (input, init) => {
    const url = new URL(input instanceof Request ? input.url : String(input));
    calls.push(url.pathname);
    const headers = new Headers(init?.headers ?? (input instanceof Request ? input.headers : undefined));
    if (url.hostname !== "fixture.supabase.invalid") throw new Error("Unexpected provider request while paused");
    const json = (body: unknown, status = 200) => Promise.resolve(new Response(JSON.stringify(body), {
      status, headers: { "Content-Type": "application/json" },
    }));
    if (url.pathname === "/auth/v1/user") {
      return headers.get("Authorization") === `Bearer ${userToken}`
        ? json({ id: fixtureUserId, email: "fixture@example.invalid" })
        : json({ message: "Invalid session", error_code: "bad_jwt" }, 401);
    }
    if (url.pathname === "/rest/v1/rpc/has_active_session") return json(true);
    if (url.pathname === "/rest/v1/rpc/consume_action_limit") return json(null);
    if (url.pathname === "/rest/v1/rpc/disconnect_spotify_account") return json(null);
    throw new Error(`Unexpected application read/write while paused: ${url.pathname}`);
  };
  try { await run(calls); }
  finally {
    globalThis.fetch = previousFetch;
    for (const [key, value] of previous) {
      if (value === undefined) Deno.env.delete(key); else Deno.env.set(key, value);
    }
  }
}

function request(name: string, token = userToken, body: unknown = {}) {
  return new Request(`https://edge.example.invalid/${name}`, {
    method: "POST", headers: token ? { Authorization: `Bearer ${token}`, "Content-Type": "application/json" } : {},
    body: JSON.stringify(body),
  });
}

Deno.test("Spotify flag requires an explicit true and fails closed for unknown values", async () => {
  await fixture(async () => {
    for (const value of ["false", "FALSE", "0", "1", "enabled", "", "truthy"]) assertEquals(isSpotifyEnabled(value), false);
    for (const value of ["true", "TRUE", "  True  "]) assertEquals(isSpotifyEnabled(value), true);
    Deno.env.delete("SPOTIFY_ENABLED");
    assertEquals(isSpotifyEnabled(), false);
  });
});

Deno.test("paused user endpoints preserve authentication and avoid Spotify/profile reads and writes", async (test) => {
  for (const name of ["spotify-token-exchange", "sync-music-profile", "calculate-match", "recommend-events"]) {
    await test.step(name, async () => {
      await fixture(async (calls) => {
        const anonymous = await handlers[name](request(name, ""));
        assertEquals(anonymous.status, 401);
        const authenticated = await handlers[name](request(name));
        assertEquals(authenticated.status, 503);
        assertEquals(await authenticated.json(), { error: "spotify_temporarily_unavailable" });
        assertEquals(authenticated.headers.get("Access-Control-Allow-Origin"), "*");
        assertEquals(authenticated.headers.get("Cache-Control"), "no-store");
        assertEquals(calls.every((path) => ["/auth/v1/user", "/rest/v1/rpc/has_active_session",
          "/rest/v1/rpc/consume_action_limit"].includes(path)), true);
      });
    });
  }
});

Deno.test("paused internal workers authenticate then skip without provider calls, database queries or pushes", async (test) => {
  for (const name of ["compute-event-embeddings", "send-notifications", "retention-notifications"]) {
    await test.step(name, async () => {
      await fixture(async (calls) => {
        assertEquals((await handlers[name](request(name, ""))).status, 401);
        const paused = await handlers[name](request(name, serviceToken));
        assertEquals(paused.status, 200);
        assertEquals(await paused.json(), { ok: true, skipped: "spotify_temporarily_unavailable" });
        assertEquals(calls, []);
      });
    });
  }
});

Deno.test("paused match webhook produces no musical affinity notification", async () => {
  await fixture(async (calls) => {
    const response = await handlers["send-social-notification"](request("send-social-notification", serviceToken, {
      type: "INSERT", table: "user_matches", schema: "public",
      record: { user_id_a: fixtureUserId, user_id_b: "f1000000-0000-0000-0000-000000000002", compatibility: 90 },
    }));
    assertEquals(response.status, 200);
    assertEquals(await response.json(), { ok: true, skipped: "spotify_temporarily_unavailable" });
    assertEquals(calls, []);
  });
});

Deno.test("friend and message webhooks are not rejected by the Spotify pause", async () => {
  await fixture(async () => {
    const fixtureFetch = globalThis.fetch;
    let created = 0;
    globalThis.fetch = (input, init) => {
      const path = new URL(input instanceof Request ? input.url : String(input)).pathname;
      const json = (body: unknown, status = 200) => Promise.resolve(new Response(JSON.stringify(body), {
        status, headers: { "Content-Type": "application/json" },
      }));
      if (path === "/rest/v1/users") return json({ fcm_token: null, push_enabled: true, display_name: "Fixture user" });
      if (path === "/rest/v1/friendships") return json([{ id: "fixture-friendship" }]);
      if (path === "/rest/v1/notifications") { created++; return json(null, 201); }
      return fixtureFetch(input, init);
    };
    for (const table of ["messages", "friendships"]) {
      const response = await handlers["send-social-notification"](request("send-social-notification", serviceToken, {
        type: "INSERT", table, schema: "public", record: {
          sender_id: fixtureUserId, requester_id: fixtureUserId,
          receiver_id: "f1000000-0000-0000-0000-000000000002", content: "Fixture message",
        },
      }));
      const body = await response.json();
      assertEquals(response.status, 200);
      assertEquals(body.ok, true);
      assertEquals(body.in_app_created, 1);
      assertEquals(body.skipped === "spotify_temporarily_unavailable", false);
    }
    assertEquals(created, 2);
  });
});

Deno.test("disconnect remains usable with Spotify paused and no provider credentials", async () => {
  await fixture(async (calls) => {
    const response = await handlers["spotify-disconnect"](request("spotify-disconnect"));
    assertEquals(response.status, 200);
    assertEquals(await response.json(), { success: true });
    assertEquals(calls.filter((path) => path === "/rest/v1/rpc/disconnect_spotify_account").length, 1);
  });
});

Deno.test("pausing clears a cached app token and enrichment does not call Spotify", async () => {
  await fixture(async () => {
    Deno.env.set("SPOTIFY_ENABLED", "true");
    Deno.env.set("SPOTIFY_CLIENT_ID", "fixture-client");
    Deno.env.set("SPOTIFY_CLIENT_SECRET", "fixture-secret");
    let providerCalls = 0;
    globalThis.fetch = () => {
      providerCalls++;
      return Promise.resolve(new Response(JSON.stringify({ access_token: `fixture-token-${providerCalls}`, expires_in: 3600 }), {
        headers: { "Content-Type": "application/json" },
      }));
    };
    assertEquals(await getSpotifyAppAccessToken(), "fixture-token-1");
    Deno.env.set("SPOTIFY_ENABLED", "false");
    assertEquals(await getSpotifyAppAccessToken(), null);
    assertEquals(await fetchSpotifyArtistsByIds(["fixture-artist"]), []);
    assertEquals(providerCalls, 1);
    Deno.env.set("SPOTIFY_ENABLED", "true");
    assertEquals(await getSpotifyAppAccessToken(), "fixture-token-2");
    // Do not leave a token cached across tests.
    Deno.env.set("SPOTIFY_ENABLED", "false");
    await getSpotifyAppAccessToken();
  });
});
