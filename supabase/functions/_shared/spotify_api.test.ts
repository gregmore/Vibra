import { assert, assertEquals, assertRejects } from "https://deno.land/std@0.208.0/assert/mod.ts";
import { encryptToken } from "./token-crypto.ts";
import {
  type ConnectionRow, refreshAccessToken, retryAfterMs, SpotifyClient, SpotifyRequestError,
  SpotifyRevokedError,
} from "./spotify_api.ts";

Deno.env.set("SPOTIFY_TOKEN_ENCRYPTION_KEY", btoa(String.fromCharCode(...new Uint8Array(32).fill(7))));
Deno.env.set("SPOTIFY_CLIENT_ID", "fixture-client-id");

const json = (body: unknown, status = 200, headers: Record<string, string> = {}) =>
  new Response(JSON.stringify(body), { status, headers: { "Content-Type": "application/json", ...headers } });

async function connection(expiresInMs: number, now: number): Promise<ConnectionRow> {
  return {
    user_id: "user", spotify_user_id: "sp-user", connected_at: "2026-11-01T00:00:00Z",
    access_token_ciphertext: await encryptToken("old-access"),
    refresh_token_ciphertext: await encryptToken("refresh-1"),
    token_expires_at: new Date(now + expiresInMs).toISOString(),
  };
}

Deno.test("PKCE refresh sends client_id and no secret; invalid_grant means revoked", async () => {
  let body = "", auth: string | null = "";
  const fresh = await refreshAccessToken("refresh-1", async (_url, init) => {
    body = String(init?.body); auth = new Headers(init?.headers).get("Authorization");
    return json({ access_token: "new", expires_in: 3600 });
  });
  assertEquals(fresh.access_token, "new");
  assert(body.includes("grant_type=refresh_token") && body.includes("client_id=fixture-client-id"));
  assertEquals(auth, null);
  await assertRejects(
    () => refreshAccessToken("revoked", async () => json({ error: "invalid_grant" }, 400)),
    SpotifyRevokedError,
  );
});

Deno.test("a token about to expire is refreshed before the first request and persisted", async () => {
  const now = Date.parse("2026-11-05T10:00:00Z");
  const saved: unknown[] = [];
  const urls: string[] = [];
  const client = await SpotifyClient.fromConnection(await connection(60_000, now), async (t) => {
    saved.push(t); return true;
  }, {
    now: () => now,
    request: async (input, init) => {
      const url = String(input); urls.push(url);
      if (url.includes("/api/token")) return json({ access_token: "fresh", refresh_token: "refresh-2", expires_in: 3600 });
      assertEquals(new Headers(init?.headers).get("Authorization"), "Bearer fresh");
      return json({ items: [] });
    },
  });
  await client.get("/me/top/artists");
  assertEquals(urls[0], "https://accounts.spotify.com/api/token");
  assertEquals(saved.length, 1);
  assertEquals(client.tokenExpiresAt, now + 3600_000);
});

Deno.test("a valid token is used directly; a 401 refreshes once and retries", async () => {
  const now = Date.now();
  let apiCalls = 0, refreshes = 0;
  const client = await SpotifyClient.fromConnection(await connection(3600_000, now), async () => true, {
    request: async (input) => {
      if (String(input).includes("/api/token")) { refreshes++; return json({ access_token: "fresh", expires_in: 3600 }); }
      return ++apiCalls === 1 ? json({}, 401) : json({ ok: true });
    },
  });
  assertEquals(await client.get("/me"), { ok: true });
  assertEquals([apiCalls, refreshes], [2, 1]);
});

Deno.test("429 waits for Retry-After, then succeeds; long waits are not attempted", async () => {
  const waits: number[] = [];
  let calls = 0;
  const client = await SpotifyClient.fromConnection(await connection(3600_000, Date.now()), async () => true, {
    sleep: async (ms) => { waits.push(ms); },
    request: async () => ++calls < 3 ? json({}, 429, { "Retry-After": "2" }) : json({ ok: true }),
  });
  assertEquals(await client.get("/me"), { ok: true });
  assertEquals(waits, [2000, 2000]);

  const slow = await SpotifyClient.fromConnection(await connection(3600_000, Date.now()), async () => true, {
    sleep: async () => { throw new Error("must not sleep"); },
    request: async () => json({}, 429, { "Retry-After": "120" }),
  });
  const error = await assertRejects(() => slow.get("/me"), SpotifyRequestError);
  assertEquals(error.status, 429);
  assertEquals(retryAfterMs(new Response(null, { headers: {} })), 1000);
});

Deno.test("revoked access during a request surfaces as SpotifyRevokedError", async () => {
  const client = await SpotifyClient.fromConnection(await connection(3600_000, Date.now()), async () => true, {
    request: async (input) => String(input).includes("/api/token")
      ? json({ error: "invalid_grant" }, 400)
      : json({}, 401),
  });
  await assertRejects(() => client.get("/me"), SpotifyRevokedError);
});

Deno.test("a concurrent disconnect wins over a refreshed token", async () => {
  const client = await SpotifyClient.fromConnection(await connection(0, Date.now()), async () => false, {
    request: async () => json({ access_token: "fresh", expires_in: 3600 }),
  });
  const error = await assertRejects(() => client.get("/me"), SpotifyRequestError);
  assertEquals(error.status, 409);
});
