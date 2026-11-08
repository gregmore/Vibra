import { assertEquals } from "https://deno.land/std@0.208.0/assert/mod.ts";
import { forEachUserPage } from "./user_batches.ts";

function fakeAdmin(initial: string | null) {
  const state = { cursor: initial, writes: [] as Array<string | null> };
  return {
    state,
    rpc(name: string, args: Record<string, unknown>) {
      if (name === "get_job_cursor") return Promise.resolve({ data: state.cursor, error: null });
      if (name === "set_job_cursor") {
        state.cursor = args.p_last_user_id as string | null;
        state.writes.push(state.cursor);
        return Promise.resolve({ data: null, error: null });
      }
      throw new Error(name);
    },
  };
}

const ids = Array.from({ length: 25 }, (_, i) => ({ id: `u${String(i).padStart(3, "0")}` }));
const loadPage = (cursor: string | null, limit: number) =>
  Promise.resolve(ids.filter((u) => cursor === null || u.id > cursor).slice(0, limit));

Deno.test("pages resume from the saved cursor and wrap after a full pass", async () => {
  const admin = fakeAdmin(null);
  const seen: string[] = [];
  const run = () => forEachUserPage(admin, {
    job: "t", pageSize: 10, maxPages: 1, budgetMs: 60_000, loadPage,
    handlePage: (rows) => { seen.push(...rows.map((r) => r.id)); return Promise.resolve(); },
  });
  assertEquals((await run()).completedPass, false);
  assertEquals(admin.state.cursor, "u009");
  await run();
  const third = await run();
  assertEquals(third, { pages: 1, users: 5, completedPass: true });
  assertEquals(admin.state.cursor, null);
  assertEquals(seen, ids.map((u) => u.id));
});

Deno.test("never holds more than one page and stops on the time budget", async () => {
  const admin = fakeAdmin(null);
  let clock = 0, largest = 0;
  const result = await forEachUserPage(admin, {
    job: "t", pageSize: 5, maxPages: 100, budgetMs: 10, now: () => clock, loadPage,
    handlePage: (rows) => { largest = Math.max(largest, rows.length); clock += 6; return Promise.resolve(); },
  });
  assertEquals(result, { pages: 2, users: 10, completedPass: false });
  assertEquals(largest, 5);
  assertEquals(admin.state.cursor, "u009");
});

Deno.test("an exact multiple of the page size ends with an empty page", async () => {
  const admin = fakeAdmin("u014");
  const result = await forEachUserPage(admin, {
    job: "t", pageSize: 10, maxPages: 5, budgetMs: 60_000, loadPage,
    handlePage: () => Promise.resolve(),
  });
  assertEquals(result, { pages: 1, users: 10, completedPass: true });
  assertEquals(admin.state.writes, [null]);
});
