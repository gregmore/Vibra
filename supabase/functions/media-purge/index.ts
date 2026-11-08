import { catalogueJobAuthorized } from "../_shared/catalogue_auth.ts";
import { createSupabaseServiceClient } from "../_shared/supabase.ts";

// Hourly (pg_cron → vibra_private.enqueue_media_purge): deletes photos that
// no live story or post uses, i.e. expired, deleted, or uploaded and never
// posted (docs/music-stories.md, docs/vibra-feed.md). Storage's API
// removes the files.
const BUCKETS = [
  { bucket: "story-media", rpc: "list_orphan_story_media" },
  { bucket: "feed-media", rpc: "list_orphan_feed_media" },
] as const;

Deno.serve(async (req) => {
  if (req.method !== "POST" || !await catalogueJobAuthorized(req)) {
    return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401 });
  }
  const admin = createSupabaseServiceClient();
  const removed: Record<string, number> = {};
  for (const { bucket, rpc } of BUCKETS) {
    removed[bucket] = 0;
    for (let batch = 0; batch < 10; batch++) {
      const { data, error } = await admin.rpc(rpc, { p_limit: 200 });
      if (error) {
        console.error("media-purge list failed", bucket, error.message);
        return new Response(JSON.stringify({ error: "list_failed", removed }), { status: 500 });
      }
      const names = ((data ?? []) as { name: string }[]).map((r) => r.name);
      if (!names.length) break;
      const { error: removeError } = await admin.storage.from(bucket).remove(names);
      if (removeError) {
        console.error("media-purge remove failed", bucket, removeError.message);
        return new Response(JSON.stringify({ error: "remove_failed", removed }), { status: 500 });
      }
      removed[bucket] += names.length;
    }
  }
  return new Response(JSON.stringify({ ok: true, removed }), { headers: { "Content-Type": "application/json" } });
});
