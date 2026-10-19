import { assert, assertEquals } from "https://deno.land/std@0.208.0/assert/mod.ts";
import { sendFcm } from "./fcm.ts";

Deno.test("FCM v1 authorization, caching, renewal and delivery failures", async (t) => {
  const originalFetch = globalThis.fetch;
  const originalCredentials = Deno.env.get("FCM_SERVICE_ACCOUNT_JSON");
  const originalFirebaseCredentials = Deno.env.get("FIREBASE_SERVICE_ACCOUNT_JSON");
  const originalWarn = console.warn;
  const warnings: string[] = [];
  console.warn = (...values: unknown[]) => warnings.push(values.join(" "));
  const pair = await crypto.subtle.generateKey({
    name: "RSASSA-PKCS1-v1_5", modulusLength: 2048,
    publicExponent: new Uint8Array([1, 0, 1]), hash: "SHA-256",
  }, true, ["sign", "verify"]);
  const bytes = new Uint8Array(await crypto.subtle.exportKey("pkcs8", pair.privateKey));
  const account = {
    project_id: "vibra-fixture", client_email: "fixture@vibra-fixture.iam.gserviceaccount.com",
    private_key: `-----BEGIN PRIVATE KEY-----\n${btoa(String.fromCharCode(...bytes))}\n-----END PRIVATE KEY-----`,
  };
  const decode = (part: string) => Uint8Array.from(
    atob(part.replace(/-/g, "+").replace(/_/g, "/")), (c) => c.charCodeAt(0),
  );
  try {
    await t.step("unconfigured push makes no outbound request", async () => {
      Deno.env.delete("FCM_SERVICE_ACCOUNT_JSON");
      Deno.env.delete("FIREBASE_SERVICE_ACCOUNT_JSON");
      globalThis.fetch = () => { throw new Error("Unexpected network request"); };
      assertEquals(await sendFcm("device", "Title", "Body"), false);
    });
    Deno.env.set("FCM_SERVICE_ACCOUNT_JSON", JSON.stringify(account));
    await t.step("RSA assertion and v1 payload are valid; token is reused", async () => {
      let authorizations = 0;
      let sends = 0;
      globalThis.fetch = async (url, init) => {
        if (String(url) === "https://oauth2.googleapis.com/token") {
          authorizations++;
          const params = init?.body as URLSearchParams;
          assertEquals(params.get("grant_type"), "urn:ietf:params:oauth:grant-type:jwt-bearer");
          const assertion = params.get("assertion")!;
          const [header, payload, signature] = assertion.split(".");
          const claims = JSON.parse(new TextDecoder().decode(decode(payload)));
          assertEquals(claims.iss, account.client_email);
          assertEquals(claims.scope, "https://www.googleapis.com/auth/firebase.messaging");
          assertEquals(claims.aud, String(url));
          assertEquals(claims.exp - claims.iat, 3600);
          assert(await crypto.subtle.verify("RSASSA-PKCS1-v1_5", pair.publicKey,
            decode(signature), new TextEncoder().encode(`${header}.${payload}`)));
          return Response.json({ access_token: "fixture-access-token", expires_in: 3600 });
        }
        sends++;
        assertEquals(String(url), "https://fcm.googleapis.com/v1/projects/vibra-fixture/messages:send");
        assertEquals(new Headers(init?.headers).get("Authorization"), "Bearer fixture-access-token");
        assertEquals(JSON.parse(init?.body as string), { message: {
          token: "device", notification: { title: "Title", body: "Body" }, data: { type: "event" },
          android: { priority: 'HIGH', notification: { sound: 'default' } },
          apns: { headers: { 'apns-priority': '10' }, payload: { aps: { sound: 'default' } } },
        } });
        return Response.json({ name: "projects/vibra-fixture/messages/1" });
      };
      assertEquals(await sendFcm("device", "Title", "Body", { type: "event" }), true);
      assertEquals(await sendFcm("device", "Title", "Body", { type: "event" }), true);
      assertEquals(authorizations, 1);
      assertEquals(sends, 2);
    });
    await t.step("401 renews authorization once and retries", async () => {
      let requests = 0;
      globalThis.fetch = (url) => {
        requests++;
        if (requests === 1) return Promise.resolve(new Response("expired", { status: 401 }));
        if (requests === 2) {
          assertEquals(String(url), "https://oauth2.googleapis.com/token");
          return Promise.resolve(Response.json({ access_token: "renewed-token", expires_in: 3600 }));
        }
        return Promise.resolve(Response.json({ name: "delivered" }));
      };
      assertEquals(await sendFcm("device", "Title", "Body"), true);
      assertEquals(requests, 3);
    });
    await t.step("provider and network failures are not reported as delivery", async () => {
      globalThis.fetch = () => Promise.resolve(new Response("unavailable", { status: 503 }));
      assertEquals(await sendFcm("device", "Title", "Body"), false);
      globalThis.fetch = () => Promise.reject(new Error("network offline"));
      assertEquals(await sendFcm("device", "Title", "Body"), false);
    });
    await t.step("existing Firebase secret supports delivery", async () => {
      Deno.env.delete("FCM_SERVICE_ACCOUNT_JSON");
      Deno.env.set("FIREBASE_SERVICE_ACCOUNT_JSON", JSON.stringify(account));
      globalThis.fetch = () => Promise.resolve(Response.json({ name: "delivered" }));
      assertEquals(await sendFcm("device", "Title", "Body"), true);
      Deno.env.delete("FIREBASE_SERVICE_ACCOUNT_JSON");
    });
    await t.step("malformed secrets fail without leaking credentials", async () => {
      Deno.env.set("FCM_SERVICE_ACCOUNT_JSON", "private-secret-invalid-json");
      assertEquals(await sendFcm("device", "Title", "Body"), false);
      assert(warnings.every((warning) => !warning.includes("private-secret") && !warning.includes("PRIVATE KEY") && !warning.includes("device")));
    });
  } finally {
    globalThis.fetch = originalFetch;
    console.warn = originalWarn;
    if (originalCredentials === undefined) Deno.env.delete("FCM_SERVICE_ACCOUNT_JSON");
    else Deno.env.set("FCM_SERVICE_ACCOUNT_JSON", originalCredentials);
    if (originalFirebaseCredentials === undefined) Deno.env.delete("FIREBASE_SERVICE_ACCOUNT_JSON");
    else Deno.env.set("FIREBASE_SERVICE_ACCOUNT_JSON", originalFirebaseCredentials);
  }
});
