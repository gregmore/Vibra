-- Performance and scalability (spec section 24, docs/performance.md).
--
-- 1. Job cursors: batch workers (send-notifications, retention-notifications)
--    page through users with keyset pagination (id > cursor ORDER BY id) and
--    resume from the saved cursor on their next run, so no run ever loads
--    every user into memory and every user is eventually processed.
-- 2. Affinity freshness: calculate-match skips the pairwise recompute when
--    the user's inputs (fingerprint of the affinity input + algorithm
--    version) are unchanged and the last full computation is recent. New
--    users still meet existing ones: their own recompute writes both sides
--    of every pair.
-- 3. Indexes for the keyset scans and the feed's hot paths.

BEGIN;

-- ── Job cursors ──────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS vibra_private.job_cursors (
  job text PRIMARY KEY CHECK (char_length(job) BETWEEN 1 AND 64),
  last_user_id uuid,
  passes integer NOT NULL DEFAULT 0 CHECK (passes >= 0),
  updated_at timestamptz NOT NULL DEFAULT now()
);
REVOKE ALL ON vibra_private.job_cursors FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION public.get_job_cursor(p_job text)
RETURNS uuid LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  IF auth.role() IS DISTINCT FROM 'service_role' THEN
    RAISE insufficient_privilege USING MESSAGE = 'Service role required';
  END IF;
  RETURN (SELECT last_user_id FROM vibra_private.job_cursors WHERE job = p_job);
END;
$$;
REVOKE ALL ON FUNCTION public.get_job_cursor(text) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_job_cursor(text) TO service_role;

-- A NULL cursor means the pass reached the end: the next run starts over.
CREATE OR REPLACE FUNCTION public.set_job_cursor(p_job text, p_last_user_id uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  IF auth.role() IS DISTINCT FROM 'service_role' THEN
    RAISE insufficient_privilege USING MESSAGE = 'Service role required';
  END IF;
  INSERT INTO vibra_private.job_cursors AS c (job, last_user_id, passes, updated_at)
  VALUES (p_job, p_last_user_id, CASE WHEN p_last_user_id IS NULL THEN 1 ELSE 0 END, now())
  ON CONFLICT (job) DO UPDATE SET
    last_user_id = EXCLUDED.last_user_id,
    passes = c.passes + CASE WHEN EXCLUDED.last_user_id IS NULL THEN 1 ELSE 0 END,
    updated_at = now();
END;
$$;
REVOKE ALL ON FUNCTION public.set_job_cursor(text, uuid) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.set_job_cursor(text, uuid) TO service_role;

-- ── Affinity freshness ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS vibra_private.affinity_state (
  user_id uuid PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  input_fingerprint text NOT NULL CHECK (char_length(input_fingerprint) BETWEEN 16 AND 128),
  computed_at timestamptz NOT NULL DEFAULT now()
);
REVOKE ALL ON vibra_private.affinity_state FROM PUBLIC, anon, authenticated;

-- Returns the number of cached pairs when the inputs are unchanged and the
-- last computation is younger than p_max_age_seconds; NULL when a
-- recompute is needed.
CREATE OR REPLACE FUNCTION public.affinity_cached_count(
  p_user_id uuid, p_fingerprint text, p_max_age_seconds integer DEFAULT 21600
)
RETURNS integer LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  IF auth.role() IS DISTINCT FROM 'service_role' THEN
    RAISE insufficient_privilege USING MESSAGE = 'Service role required';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM vibra_private.affinity_state s
    WHERE s.user_id = p_user_id AND s.input_fingerprint = p_fingerprint
      AND s.computed_at > now() - make_interval(secs => LEAST(GREATEST(COALESCE(p_max_age_seconds, 0), 0), 604800))
  ) THEN
    RETURN NULL;
  END IF;
  RETURN (SELECT count(*)::integer FROM public.user_matches m
    WHERE m.user_id_a = p_user_id OR m.user_id_b = p_user_id);
END;
$$;
REVOKE ALL ON FUNCTION public.affinity_cached_count(uuid, text, integer) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.affinity_cached_count(uuid, text, integer) TO service_role;

CREATE OR REPLACE FUNCTION public.record_affinity_fingerprint(p_user_id uuid, p_fingerprint text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  IF auth.role() IS DISTINCT FROM 'service_role' THEN
    RAISE insufficient_privilege USING MESSAGE = 'Service role required';
  END IF;
  INSERT INTO vibra_private.affinity_state (user_id, input_fingerprint, computed_at)
  VALUES (p_user_id, p_fingerprint, now())
  ON CONFLICT (user_id) DO UPDATE SET input_fingerprint = EXCLUDED.input_fingerprint, computed_at = now();
END;
$$;
REVOKE ALL ON FUNCTION public.record_affinity_fingerprint(uuid, text) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.record_affinity_fingerprint(uuid, text) TO service_role;

-- No reset triggers are needed: the fingerprint is computed from the same
-- get_affinity_input the engine scores, so a genre pick, a Spotify sync or a
-- disconnect changes it and forces the next recompute. Changes on the other
-- side (a candidate's privacy or profile) are bounded by p_max_age_seconds.

-- ── Indexes for keyset scans ─────────────────────────────────────────────
-- Batch workers scan real users in id order.
CREATE INDEX IF NOT EXISTS users_real_id_idx ON public.users (id) WHERE is_test_user = false;
-- Upcoming real events, read in date order by the notification workers.
CREATE INDEX IF NOT EXISTS events_upcoming_real_idx ON public.events (event_date) WHERE is_test_data = false;

-- ── Feed ranking without per-candidate subqueries ────────────────────────
-- Same scoring, reasons and diversity rules as 20261118000000_vibra_feed.sql
-- (docs/vibra-feed.md). The social signals are computed once per request as
-- small sets (the people I follow or am connected to, my matches, my
-- co-members among the candidates' authors, my interactions per author,
-- engagers per candidate) and joined, instead of seven correlated
-- subqueries for each of up to 1,500 candidates. The chronological modes
-- read the author index with a bounded author set.
CREATE OR REPLACE FUNCTION public.get_feed(
  p_mode text DEFAULT 'for_you', p_before timestamptz DEFAULT NULL,
  p_exclude uuid[] DEFAULT '{}', p_limit integer DEFAULT 20
)
RETURNS TABLE (post_id uuid, score double precision, reason text)
LANGUAGE plpgsql STABLE SECURITY INVOKER SET search_path = pg_catalog AS $$
#variable_conflict use_column
DECLARE
  me uuid := auth.uid();
  lim integer := LEAST(GREATEST(COALESCE(p_limit, 20), 1), 50);
  my_genres text[]; my_artists text[]; my_community_genres text[];
  v_followed uuid[]; v_connected uuid[];
BEGIN
  IF me IS NULL THEN RAISE SQLSTATE 'PT401' USING MESSAGE = 'Authentication required'; END IF;

  v_followed := ARRAY(SELECT f.following_id FROM public.follows f WHERE f.follower_id = me);
  v_connected := ARRAY(
    SELECT CASE WHEN f.requester_id = me THEN f.receiver_id ELSE f.requester_id END
    FROM public.friendships f
    WHERE f.status = 'accepted' AND (f.requester_id = me OR f.receiver_id = me));

  IF p_mode = 'latest' THEN
    RETURN QUERY
    SELECT p.id, 0::double precision, CASE WHEN p.user_id = me THEN 'mine' ELSE 'chronological' END
    FROM public.feed_posts p
    WHERE (p_before IS NULL OR p.created_at < p_before)
      AND NOT EXISTS (SELECT 1 FROM public.feed_impressions i WHERE i.user_id = me AND i.post_id = p.id AND i.dismissed)
    ORDER BY p.created_at DESC
    LIMIT lim;
    RETURN;
  ELSIF p_mode = 'following' THEN
    RETURN QUERY
    SELECT p.id, 0::double precision, CASE WHEN p.user_id = me THEN 'mine' ELSE 'chronological' END
    FROM public.feed_posts p
    WHERE p.user_id = ANY (v_followed || v_connected || me)
      AND (p_before IS NULL OR p.created_at < p_before)
      AND NOT EXISTS (SELECT 1 FROM public.feed_impressions i WHERE i.user_id = me AND i.post_id = p.id AND i.dismissed)
    ORDER BY p.created_at DESC
    LIMIT lim;
    RETURN;
  END IF;

  -- My musical interests: the latest Musical DNA (families, subgenres,
  -- artists), the genres I picked, and the genres of communities I joined.
  SELECT
    ARRAY(SELECT f.key FROM jsonb_to_recordset(COALESCE(s.dna->'families', '[]')) AS f(key text)
      UNION SELECT g.key FROM jsonb_to_recordset(COALESCE(s.dna->'subgenres', '[]')) AS g(key text)),
    ARRAY(SELECT lower(a.name) FROM jsonb_to_recordset(COALESCE(s.dna->'artists', '[]')) AS a(name text))
  INTO my_genres, my_artists
  FROM public.musical_dna_snapshots s WHERE s.user_id = me ORDER BY s.captured_on DESC LIMIT 1;
  my_genres := COALESCE(my_genres, '{}') || ARRAY(SELECT g.genre_key FROM public.user_genre_preferences g WHERE g.user_id = me);
  my_community_genres := ARRAY(
    SELECT DISTINCT x
    FROM public.community_members m
    JOIN public.communities c ON c.id = m.community_id
    CROSS JOIN LATERAL unnest(ARRAY[c.genre_key, c.genre_family]) AS x
    WHERE m.user_id = me AND c.archived_at IS NULL AND x IS NOT NULL);
  my_artists := COALESCE(my_artists, '{}');

  RETURN QUERY
  WITH candidates AS MATERIALIZED (
    SELECT p.id, p.user_id, p.created_at, p.genre_keys, p.artist_keys,
      COALESCE(p.item_id, p.external_url, p.shared_post_id::text, p.id::text) AS item_key,
      COALESCE(i.shown_count, 0) AS shown
    FROM public.feed_posts p
    LEFT JOIN public.feed_impressions i ON i.user_id = me AND i.post_id = p.id
    WHERE p.created_at > now() - interval '14 days'
      AND p.user_id <> me
      AND NOT (p.id = ANY (COALESCE(p_exclude, '{}')))
      AND NOT COALESCE(i.dismissed, false)
      AND COALESCE(i.shown_count, 0) < 4
    ORDER BY p.created_at DESC
    LIMIT 1500
  ), authors AS MATERIALIZED (
    SELECT DISTINCT c.user_id FROM candidates c
  ), compat AS (
    SELECT CASE WHEN m.user_id_a = me THEN m.user_id_b ELSE m.user_id_a END AS other, m.compatibility AS score
    FROM public.user_matches m
    WHERE m.user_id_a = me OR m.user_id_b = me
  ), co_members AS (
    SELECT DISTINCT b.user_id
    FROM public.community_members a
    JOIN public.community_members b ON b.community_id = a.community_id
    JOIN authors au ON au.user_id = b.user_id
    WHERE a.user_id = me
  ), my_interactions AS (
    SELECT q.user_id AS author, count(*)::double precision AS n
    FROM (
      SELECT r.post_id FROM public.feed_post_reactions r
      WHERE r.user_id = me AND r.created_at > now() - interval '30 days'
      UNION ALL
      SELECT x.post_id FROM public.feed_comments x
      WHERE x.author_id = me AND x.created_at > now() - interval '30 days'
    ) mine
    JOIN public.feed_posts q ON q.id = mine.post_id
    GROUP BY q.user_id
  ), engagers AS (
    -- Distinct people (not the author) who engaged: a small, capped
    -- quality signal, never raw counts.
    SELECT e.post_id, count(DISTINCT e.u)::double precision AS n
    FROM (
      SELECT r.post_id, r.user_id AS u FROM public.feed_post_reactions r
      JOIN candidates c ON c.id = r.post_id WHERE r.user_id <> c.user_id
      UNION ALL
      SELECT x.post_id, x.author_id FROM public.feed_comments x
      JOIN candidates c ON c.id = x.post_id WHERE x.author_id <> c.user_id
    ) e
    GROUP BY e.post_id
  ), signals AS (
    SELECT c.*,
      c.user_id = ANY (v_followed) AS followed,
      c.user_id = ANY (v_connected) AS connected,
      COALESCE(cm.score, 0)::double precision AS compat,
      (co.user_id IS NOT NULL) AS co_member,
      cardinality(ARRAY(SELECT unnest(c.genre_keys) INTERSECT SELECT unnest(my_genres))) AS genre_hits,
      cardinality(ARRAY(SELECT unnest(c.genre_keys) INTERSECT SELECT unnest(my_community_genres))) AS community_genre_hits,
      cardinality(ARRAY(SELECT unnest(c.artist_keys) INTERSECT SELECT unnest(my_artists))) AS artist_hits,
      COALESCE(mi.n, 0) AS my_interactions,
      COALESCE(en.n, 0) AS engagers
    FROM candidates c
    LEFT JOIN compat cm ON cm.other = c.user_id
    LEFT JOIN co_members co ON co.user_id = c.user_id
    LEFT JOIN my_interactions mi ON mi.author = c.user_id
    LEFT JOIN engagers en ON en.post_id = c.id
  ), scored AS (
    SELECT s.*,
      (CASE WHEN s.followed THEN 3.0 ELSE 0 END
       + CASE WHEN s.connected THEN 2.5 ELSE 0 END
       + 1.5 * LEAST(s.compat, 100) / 100
       + CASE WHEN s.co_member THEN 1.0 ELSE 0 END
       + 2.0 * LEAST(s.genre_hits, 3) / 3.0
       + 0.8 * LEAST(s.community_genre_hits, 2) / 2.0
       + 1.0 * LEAST(s.artist_hits, 1)
       + 1.5 * LEAST(ln(1 + s.my_interactions) / ln(11), 1)
       + 0.5 * LEAST(ln(1 + s.engagers) / ln(51), 1)
       + 0.2) -- every visible post can surface, so new people are reachable
      -- Freshness: half the weight after ~33 hours.
      * exp(-extract(epoch FROM now() - s.created_at) / 3600.0 / 48.0)
      -- Already shown: less each time (hidden after 4 showings).
      * power(0.6, s.shown) AS base,
      CASE
        WHEN s.followed THEN 'following'
        WHEN s.connected THEN 'connection'
        WHEN s.artist_hits > 0 THEN 'artists'
        WHEN s.genre_hits > 0 THEN 'genres'
        WHEN s.co_member OR s.community_genre_hits > 0 THEN 'community'
        WHEN s.compat > 0 THEN 'match'
        WHEN s.my_interactions > 0 THEN 'interaction'
        ELSE 'new'
      END AS why
    FROM signals s
  ), diversified AS (
    SELECT s.id, s.why,
      -- The same author or the same song/album again in one feed: halved
      -- for each repeat, so one person or one release cannot fill it.
      s.base * power(0.5, (row_number() OVER (PARTITION BY s.user_id ORDER BY s.base DESC)) - 1)
             * power(0.35, (row_number() OVER (PARTITION BY s.item_key ORDER BY s.base DESC)) - 1) AS final
    FROM scored s
  )
  SELECT d.id, d.final, d.why FROM diversified d
  ORDER BY d.final DESC, d.id
  LIMIT lim;
END;
$$;
REVOKE ALL ON FUNCTION public.get_feed(text, timestamptz, uuid[], integer) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_feed(text, timestamptz, uuid[], integer) TO authenticated;
-- Engagers per candidate use the reactions primary key (post_id, …) and
-- feed_comments_post_idx; my interactions use feed_post_reactions_user_idx
-- and feed_comments_author_idx.

-- ── Paged lists ─────────────────────────────────────────────────────────
-- Discoveries were read 500 at a time; now one page at a time with a
-- saved_at cursor (the app's "load more"). The app's "saved" marks read
-- only external_url under the owner-only policy.
DROP FUNCTION IF EXISTS public.get_discoveries(integer);
CREATE FUNCTION public.get_discoveries(p_limit integer DEFAULT 40, p_before timestamptz DEFAULT NULL)
RETURNS TABLE (id uuid, provider text, track_id text, title text, artist text, album text,
  artwork_url text, external_url text, source text, saved_at timestamptz,
  via_user_id uuid, via_name text)
LANGUAGE sql STABLE SECURITY INVOKER SET search_path = pg_catalog AS $$
  SELECT d.id, d.provider, d.track_id, d.title, d.artist, d.album, d.artwork_url, d.external_url,
    d.source, d.saved_at,
    CASE WHEN ok.visible THEN d.found_via END,
    CASE WHEN ok.visible THEN COALESCE(NULLIF(btrim(p.display_name), ''), p.username::text) END
  FROM (
    SELECT * FROM public.discovery_collection d
    WHERE d.user_id = auth.uid() AND (p_before IS NULL OR d.saved_at < p_before)
    ORDER BY d.saved_at DESC
    LIMIT LEAST(GREATEST(COALESCE(p_limit, 40), 1), 100)
  ) d
  LEFT JOIN public.profile_discovery p ON p.id = d.found_via
  CROSS JOIN LATERAL (SELECT d.found_via IS NOT NULL
    AND public.may_access_message(auth.uid(), d.found_via) AS visible) ok
  ORDER BY d.saved_at DESC;
$$;
REVOKE ALL ON FUNCTION public.get_discoveries(integer, timestamptz) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_discoveries(integer, timestamptz) TO authenticated;

CREATE INDEX IF NOT EXISTS discovery_collection_user_saved_idx
  ON public.discovery_collection (user_id, saved_at DESC);
CREATE INDEX IF NOT EXISTS feed_bookmarks_user_saved_idx
  ON public.feed_bookmarks (user_id, created_at DESC);

NOTIFY pgrst, 'reload schema';
COMMIT;
