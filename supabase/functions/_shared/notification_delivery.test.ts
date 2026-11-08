import { assertEquals } from "https://deno.land/std@0.208.0/assert/mod.ts";
import { deliver } from "./notification_delivery.ts";

const fakeDb = (result: unknown) => {
  const calls: Record<string, unknown>[] = [];
  return {
    calls,
    rpc: (_fn: string, args: Record<string, unknown>) => {
      calls.push(args);
      return Promise.resolve({ data: result, error: null });
    },
  };
};

Deno.test("pushes only when the server policy allows it", async () => {
  const sent: string[] = [];
  const push = (token: string) => (sent.push(token), Promise.resolve(true));
  const allowed = fakeDb({ id: "n1", push: true, token: "tok", count: 3, grouped: true });
  const r = await deliver(allowed, { userId: "u", type: "feed_comment", title: "T", body: "B", groupKey: "g" }, push);
  assertEquals(r, { stored: true, pushed: true, grouped: true });
  assertEquals(sent, ["tok"]);
  assertEquals(allowed.calls[0].p_group_key, "g");

  const held = fakeDb({ id: "n2", push: false, token: null });
  assertEquals((await deliver(held, { userId: "u", type: "recommendation", title: "T", body: "B" }, push)).pushed, false);
  assertEquals(sent.length, 1);
});

Deno.test("blocked or self notifications are not stored", async () => {
  const r = await deliver(fakeDb({ skipped: "blocked" }), { userId: "u", type: "chat_message", title: "T", body: "B", actorId: "a" },
    () => Promise.resolve(true));
  assertEquals(r.stored, false);
  assertEquals(r.skipped, "blocked");
});
