# Performance and scalability

How VIBRA keeps the app fast and the backend bounded as users and
content grow (spec section 24). Migration:
`supabase/migrations/20261127000000_performance.sql` (not yet applied).
Checked by `test/core/performance_test.dart`,
`test/core/schema_audit_test.dart`,
`test/presentation/widgets/vibra_paged_list_test.dart` and the Deno tests
`_shared/user_batches.test.ts` and `_shared/music_affinity.test.ts`.

## Rules

1. **No unbounded reads.** Every list RPC caps `p_limit` on the server
   (`LEAST(GREATEST(COALESCE(p_limit, n), 1), max)`), and every client query
   has a `.limit()`. Nothing loads all users or all events into memory.
2. **Server-side filtering and pagination.** Lists page with a keyset
   cursor (`p_before` = the oldest timestamp shown, or `id > cursor`), never
   with `OFFSET` on large tables. RLS and visibility functions filter on the
   server; the app never filters private data locally.
3. **Index what is filtered and sorted.** Every foreign key is indexed
   (`schema_audit_test`), plus a `(user_id, time DESC)` index for each
   per-user list.
4. **Do not recompute unchanged results.** Derived data (matches, artist
   recommendations, DNA snapshots) is cached and rebuilt only when its
   inputs change or it expires.
5. **Background work runs in jobs**, in bounded batches that resume.

## Server

### Batch workers (keyset pages that resume)

`send-notifications` and `retention-notifications` used to read the first
500 or 1,000 users, so later users never got event alerts or digests. They
now use `_shared/user_batches.ts` (`forEachUserPage`):

- users are read in id order, 200 at a time (`id > cursor ORDER BY id`,
  `users_real_id_idx`);
- each page loads music profiles, preferences and distances in **one
  query per page** (`.in("user_id", ids)`, `nearby_event_distances_for_users`),
  not one per user;
- a run stops after a page limit or about 100 seconds and saves its cursor
  in `vibra_private.job_cursors` (`get_job_cursor` / `set_job_cursor`,
  service role only); the next run continues from there, and a NULL cursor
  starts a new pass;
- upcoming events are one bounded, shared set (`events_upcoming_real_idx`).

Other jobs were already bounded: `spotify-sync-worker` claims due
connections in batches, `event-reminders` reads due attendances by date,
`ticketmaster-sync` pages per query, and `media-purge` lists orphans with a
limit.

### Incremental affinity updates

The app calls `calculate-match` after profile and genre changes. It used to
re-score up to 500 candidates every time. Now `recomputeMatches(...,
{ onlyIfChanged: true })` hashes the user's affinity input with the
algorithm version and weights (SHA-256, `affinityFingerprint`). If the
fingerprint matches the last computation (`vibra_private.affinity_state`)
and that computation is under 6 hours old, the cached pairs are reused
(`affinity_cached_count`). Any change to the user's own data (a Spotify
sync, a genre picked or removed, a disconnect) changes the fingerprint and
forces a recompute. New users still meet existing ones because their own
recompute writes both sides of every pair. The Spotify sync worker always
recomputes after a full sync and records the fingerprint.

Artist discovery is cached for 12 hours (`artist_recommendations`), the
Musical DNA keeps one snapshot a day, and Ticketmaster results are cached
per query.

### Feed ranking

`get_feed('for_you')` scores up to 1,500 recent candidates. The social
signals used to be seven correlated subqueries per candidate. They are now
computed once per request as small sets and joined:

- the people I follow or am connected to (arrays);
- my matches;
- co-members among the candidates' authors;
- my interactions per author;
- engagers per candidate.

The scoring, reasons and diversity rules are unchanged (vibra-feed.md).
The `following` mode reads `feed_posts_author_idx` with a bounded author
set instead of scanning recent posts.

## App

- **Lazy lists.** Long lists use `ListView.builder`, so rows are built only
  when they scroll into view.
- **Pagination.** `VibraPagedList<T>`
  (`lib/presentation/widgets/common/vibra_paged_list.dart`) takes the first
  page from a provider, so refresh and invalidation keep working. It loads
  the next page 600 px before the end, removes duplicates, and stops after a
  short page. A failed page shows Retry instead of retrying in a loop. It is
  used for:
  - Discoveries (40 per page);
  - saved posts and a person's posts (20 per page; before this change only
    the first page was ever shown).

  The feed and the Notification Center (40 per page) page the same way
  through their controllers.
- **Narrow reads.** "Saved" marks on songs read only `external_url` from my
  Discoveries, not the whole collection with names (`discoveredUrls`).
- **Images.** `VibraNetworkImage` uses `cached_network_image` (disk and
  memory cache) and decodes at display size (`memCacheWidth`), so large
  artwork is not decoded at full resolution. Private concert photos
  (`StoryPhoto`) are read with the viewer's session and decoded at 1080 px.
  They stay in the memory image cache only, never on disk, because access is
  re-checked on every load.
- **Batched writes.** Feed impressions are flushed every 3 seconds in one
  call. Story views and notification reads are single RPCs.
- **Cached providers.** Riverpod `autoDispose` providers keep data while a
  screen is open and drop it afterwards. Expensive server results (matches,
  artist recommendations) are cached in the database, not recomputed per
  screen.

## Operating notes

- To see whether every user is reached, check `vibra_private.job_cursors`:
  `passes` counts completed passes per job.
- If a worker pass gets too long, raise its schedule frequency, not its page
  size. Each run stays bounded either way.
- Apply the migration on staging first and compare `EXPLAIN ANALYZE` for
  `get_feed` before and after on real data.
