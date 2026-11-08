// Keyset batching for workers that visit every user (docs/performance.md).
//
// A run reads users in id order, one page at a time (`id > cursor ORDER BY
// id LIMIT pageSize`), handles each page, and stops after `maxPages` or when
// its time budget is spent. The cursor is saved in vibra_private.job_cursors
// (get_job_cursor / set_job_cursor), so the next run resumes where this one
// stopped and every user is reached, however many there are, without ever
// holding more than one page in memory.

// deno-lint-ignore no-explicit-any
type Admin = any;

export type BatchOptions<T extends { id: string }> = {
  job: string;
  pageSize: number;
  maxPages: number;
  /** Stop starting new pages after this many milliseconds. */
  budgetMs: number;
  /** Load one page of users with id > cursor, ordered by id, at most `limit`. */
  loadPage: (cursor: string | null, limit: number) => Promise<T[]>;
  handlePage: (rows: T[]) => Promise<void>;
  now?: () => number;
};

export type BatchResult = { pages: number; users: number; completedPass: boolean };

export async function forEachUserPage<T extends { id: string }>(
  admin: Admin,
  options: BatchOptions<T>,
): Promise<BatchResult> {
  const now = options.now ?? Date.now;
  const started = now();
  const { data: saved, error } = await admin.rpc("get_job_cursor", { p_job: options.job });
  if (error) throw new Error("job_cursor_unavailable");
  let cursor: string | null = typeof saved === "string" ? saved : null;
  let pages = 0, users = 0;
  while (true) {
    const rows = await options.loadPage(cursor, options.pageSize);
    if (rows.length > 0) {
      await options.handlePage(rows);
      pages++;
      users += rows.length;
      cursor = rows[rows.length - 1].id;
    }
    if (rows.length < options.pageSize) {
      await saveCursor(admin, options.job, null);
      return { pages, users, completedPass: true };
    }
    if (pages >= options.maxPages || now() - started >= options.budgetMs) {
      await saveCursor(admin, options.job, cursor);
      return { pages, users, completedPass: false };
    }
  }
}

async function saveCursor(admin: Admin, job: string, cursor: string | null) {
  const { error } = await admin.rpc("set_job_cursor", { p_job: job, p_last_user_id: cursor });
  if (error) throw new Error("job_cursor_write_failed");
}

/** Apply the keyset condition to a PostgREST users query. */
// deno-lint-ignore no-explicit-any
export function keyset(query: any, cursor: string | null, limit: number) {
  const q = cursor ? query.gt("id", cursor) : query;
  return q.order("id", { ascending: true }).limit(limit);
}
