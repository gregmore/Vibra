import { assertEquals } from "https://deno.land/std@0.208.0/assert/mod.ts";
import { notificationWorkerAuthorized } from "./notification_worker_auth.ts";

Deno.test("notification workers authenticate the Vault credential even when runtime service keys differ", async () => {
  const names = ["VIBRA_NOTIFICATION_WORKER_KEY", "SUPABASE_SERVICE_ROLE_KEY"];
  const previous = names.map((name) => Deno.env.get(name));
  const stable = "fixture-vault-service-role-key-at-least-32";
  const runtime = "fixture-runtime-service-role-key-at-least-32";
  const request = (key?: string) => new Request("https://example.invalid", {
    headers: key === undefined ? {} : { Authorization: `Bearer ${key}` },
  });
  try {
    for (const name of names) Deno.env.delete(name);
    assertEquals(await notificationWorkerAuthorized(request(stable)), false);
    Deno.env.set("SUPABASE_SERVICE_ROLE_KEY", runtime);
    assertEquals(await notificationWorkerAuthorized(request(runtime)), true);
    assertEquals(await notificationWorkerAuthorized(request(stable)), false);
    Deno.env.set("VIBRA_NOTIFICATION_WORKER_KEY", stable);
    assertEquals(await notificationWorkerAuthorized(request(stable)), true);
    assertEquals(await notificationWorkerAuthorized(request(runtime)), false);
    assertEquals(await notificationWorkerAuthorized(request()), false);
    assertEquals(await notificationWorkerAuthorized(new Request("https://example.invalid", {
      headers: { Authorization: stable },
    })), false);
    Deno.env.set("VIBRA_NOTIFICATION_WORKER_KEY", "");
    assertEquals(await notificationWorkerAuthorized(request(runtime)), false);
    Deno.env.set("VIBRA_NOTIFICATION_WORKER_KEY", "too-short");
    assertEquals(await notificationWorkerAuthorized(request("too-short")), false);
  } finally {
    names.forEach((name, index) => {
      const value = previous[index];
      if (value === undefined) Deno.env.delete(name);
      else Deno.env.set(name, value);
    });
  }
});
