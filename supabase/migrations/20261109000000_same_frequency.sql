-- VIBRA Same Frequency (docs/same-frequency.md).
--
-- People with a meaningful musical connection, from several signals:
--   * the cached affinity pair (genres, related genres, artists in common);
--   * artists both recently started listening to (Musical DNA snapshots);
--   * families both are moving toward (Musical DNA evolution);
--   * upcoming events both saved (only when BOTH opted in).
-- Candidates come from get_affinity_feed (SECURITY INVOKER), so consent,
-- blocks, test segments, dismissals and existing connections keep applying.
-- The extra signals are read by a SECURITY DEFINER helper that re-checks the
-- pair and each person's visibility settings before reading anything.
--
-- * saved_profiles: "Save" on a person (private to the saver).
-- * same_frequency_views: how often and when a person was shown, so the list
--   rotates instead of repeating the same people.
-- * privacy_preferences.same_frequency_events: opt-in, default off. Saved
--   events are private (20260830000000), so they are compared only between
--   two people who both turned this on.
BEGIN;

ALTER TABLE public.privacy_preferences
  ADD COLUMN IF NOT EXISTS same_frequency_events boolean NOT NULL DEFAULT false;

-- ── Saved profiles ────────────────────────────────────────────────────────
CREATE TABLE public.saved_profiles (
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  saved_user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, saved_user_id),
  CHECK (user_id <> saved_user_id)
);
ALTER TABLE public.saved_profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY saved_profiles_owner_select ON public.saved_profiles
  FOR SELECT TO authenticated USING (user_id = (SELECT auth.uid()));
CREATE POLICY saved_profiles_owner_insert ON public.saved_profiles
  FOR INSERT TO authenticated WITH CHECK (user_id = (SELECT auth.uid()));
CREATE POLICY saved_profiles_owner_delete ON public.saved_profiles
  FOR DELETE TO authenticated USING (user_id = (SELECT auth.uid()));
REVOKE ALL ON TABLE public.saved_profiles FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT, DELETE ON TABLE public.saved_profiles TO authenticated;
GRANT ALL ON TABLE public.saved_profiles TO service_role;

CREATE FUNCTION public.limit_saved_profiles()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  IF (SELECT count(*) FROM public.saved_profiles WHERE user_id = NEW.user_id) >= 200 THEN
    RAISE check_violation USING MESSAGE = 'saved_profiles_limit';
  END IF;
  -- Only people the saver may interact with (blocks, test segments).
  IF NOT public.may_access_message(NEW.user_id, NEW.saved_user_id) THEN
    RAISE insufficient_privilege USING MESSAGE = 'profile_not_available';
  END IF;
  RETURN NEW;
END;
$$;
REVOKE ALL ON FUNCTION public.limit_saved_profiles() FROM PUBLIC, anon, authenticated;
CREATE TRIGGER trg_limit_saved_profiles BEFORE INSERT
ON public.saved_profiles FOR EACH ROW EXECUTE FUNCTION public.limit_saved_profiles();

-- The caller's saved people that are still visible to them, newest first.
CREATE FUNCTION public.get_saved_profiles()
RETURNS TABLE (
  user_id uuid, username text, display_name text, avatar_url text, bio text,
  compatibility integer, details jsonb, saved_at timestamptz
)
LANGUAGE sql STABLE SECURITY INVOKER SET search_path = pg_catalog AS $$
  SELECT u.id, u.username::text, u.display_name, u.avatar_url, u.bio,
    round(m.compatibility)::integer, m.details, s.created_at
  FROM public.saved_profiles s
  JOIN public.users_public u ON u.id = s.saved_user_id
  LEFT JOIN public.user_matches m
    ON m.user_id_a = LEAST(s.user_id, s.saved_user_id)
   AND m.user_id_b = GREATEST(s.user_id, s.saved_user_id)
  WHERE s.user_id = auth.uid()
  ORDER BY s.created_at DESC
  LIMIT 200;
$$;
REVOKE ALL ON FUNCTION public.get_saved_profiles() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_saved_profiles() TO authenticated;

-- ── Impressions (rotation) ────────────────────────────────────────────────
CREATE TABLE public.same_frequency_views (
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  shown_user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  times_shown integer NOT NULL DEFAULT 1 CHECK (times_shown >= 0),
  last_shown_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, shown_user_id)
);
ALTER TABLE public.same_frequency_views ENABLE ROW LEVEL SECURITY;
CREATE POLICY same_frequency_views_owner_select ON public.same_frequency_views
  FOR SELECT TO authenticated USING (user_id = (SELECT auth.uid()));
REVOKE ALL ON TABLE public.same_frequency_views FROM PUBLIC, anon, authenticated;
GRANT SELECT ON TABLE public.same_frequency_views TO authenticated;
GRANT ALL ON TABLE public.same_frequency_views TO service_role;

-- Counts at most one view per person every 6 hours, so reopening the screen
-- does not inflate the count. Views older than 60 days are forgotten.
CREATE FUNCTION public.record_same_frequency_views(p_user_ids uuid[])
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v_me uuid := auth.uid();
BEGIN
  IF v_me IS NULL THEN RAISE insufficient_privilege USING MESSAGE = 'Authentication required'; END IF;
  IF cardinality(COALESCE(p_user_ids, '{}')) > 30 THEN
    RAISE invalid_parameter_value USING MESSAGE = 'too_many_views';
  END IF;
  INSERT INTO public.same_frequency_views AS v (user_id, shown_user_id)
  SELECT v_me, id FROM (SELECT DISTINCT unnest(p_user_ids) AS id) ids
  WHERE id <> v_me AND EXISTS (SELECT 1 FROM public.users WHERE users.id = ids.id)
  ON CONFLICT (user_id, shown_user_id) DO UPDATE
    SET times_shown = v.times_shown + 1, last_shown_at = now()
    WHERE v.last_shown_at < now() - interval '6 hours';
  DELETE FROM public.same_frequency_views
  WHERE user_id = v_me AND last_shown_at < now() - interval '60 days';
END;
$$;
REVOKE ALL ON FUNCTION public.record_same_frequency_views(uuid[]) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.record_same_frequency_views(uuid[]) TO authenticated;

-- ── DNA comparisons (internal) ────────────────────────────────────────────
-- Latest snapshot and the latest one at least 28 days older.
CREATE FUNCTION public.dna_snapshot_pair(p_user uuid)
RETURNS TABLE (now_dna jsonb, past_dna jsonb)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
  WITH latest AS (
    SELECT s.dna, s.captured_on FROM public.musical_dna_snapshots s
    WHERE s.user_id = p_user ORDER BY s.captured_on DESC LIMIT 1
  )
  SELECT l.dna, (
    SELECT p.dna FROM public.musical_dna_snapshots p
    WHERE p.user_id = p_user AND p.captured_on <= l.captured_on - 28
    ORDER BY p.captured_on DESC LIMIT 1
  ) FROM latest l;
$$;
REVOKE ALL ON FUNCTION public.dna_snapshot_pair(uuid) FROM PUBLIC, anon, authenticated;

-- Families whose share grew by >= 5 points, and artists that entered the
-- top list, between the two snapshots.
CREATE FUNCTION public.dna_rising_families(p_user uuid)
RETURNS TABLE (family text, delta integer)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
  WITH pair AS (SELECT * FROM public.dna_snapshot_pair(p_user) WHERE past_dna IS NOT NULL),
  now_f AS (SELECT f.key, f.percent FROM pair, jsonb_to_recordset(pair.now_dna->'families') AS f(key text, percent integer)),
  past_f AS (SELECT f.key, f.percent FROM pair, jsonb_to_recordset(pair.past_dna->'families') AS f(key text, percent integer))
  SELECT n.key, n.percent - COALESCE(p.percent, 0)
  FROM now_f n LEFT JOIN past_f p ON p.key = n.key
  WHERE n.percent - COALESCE(p.percent, 0) >= 5;
$$;
REVOKE ALL ON FUNCTION public.dna_rising_families(uuid) FROM PUBLIC, anon, authenticated;

CREATE FUNCTION public.dna_new_artists(p_user uuid)
RETURNS TABLE (key text, name text)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
  WITH pair AS (SELECT * FROM public.dna_snapshot_pair(p_user) WHERE past_dna IS NOT NULL
    AND jsonb_typeof(past_dna->'artists') = 'array' AND jsonb_array_length(past_dna->'artists') > 0)
  SELECT a.key, a.name
  FROM pair, jsonb_to_recordset(pair.now_dna->'artists') AS a(key text, name text)
  WHERE a.key IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM jsonb_to_recordset(pair.past_dna->'artists') AS p(key text) WHERE p.key = a.key
  );
$$;
REVOKE ALL ON FUNCTION public.dna_new_artists(uuid) FROM PUBLIC, anon, authenticated;

-- ── Extra signals for one person (caller's view) ──────────────────────────
CREATE FUNCTION public.same_frequency_signals(p_other uuid)
RETURNS TABLE (
  shared_discoveries text[], rising_families text[],
  shared_events integer, shared_event jsonb,
  times_shown integer, last_shown_at timestamptz, saved boolean
)
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE
  v_me uuid := auth.uid();
  v_dna_visible boolean;
  v_events boolean;
BEGIN
  IF v_me IS NULL THEN RAISE insufficient_privilege USING MESSAGE = 'Authentication required'; END IF;
  -- Only for a pair the caller may see: a cached affinity with mutual
  -- consent, no block and the same test segment.
  IF v_me = p_other OR NOT EXISTS (
      SELECT 1 FROM public.user_matches m
      WHERE m.user_id_a = LEAST(v_me, p_other) AND m.user_id_b = GREATEST(v_me, p_other))
     OR NOT public.may_access_music_match(LEAST(v_me, p_other), GREATEST(v_me, p_other)) THEN
    RETURN;
  END IF;
  -- Their DNA history is used only if they share their DNA with matches.
  SELECT COALESCE(p.musical_dna_visibility IN ('public', 'matches'), false) INTO v_dna_visible
  FROM public.privacy_preferences p WHERE p.user_id = p_other;
  -- Saved events are compared only when both opted in.
  SELECT count(*) = 2 INTO v_events FROM public.privacy_preferences p
  WHERE p.user_id IN (v_me, p_other) AND p.same_frequency_events;

  RETURN QUERY
  SELECT
    CASE WHEN COALESCE(v_dna_visible, false) THEN ARRAY(
      SELECT o.name FROM public.dna_new_artists(p_other) o
      JOIN public.dna_new_artists(v_me) m ON m.key = o.key
      WHERE NULLIF(o.name, '') IS NOT NULL ORDER BY o.name LIMIT 3
    ) ELSE '{}'::text[] END,
    CASE WHEN COALESCE(v_dna_visible, false) THEN ARRAY(
      SELECT o.family FROM public.dna_rising_families(p_other) o
      JOIN public.dna_rising_families(v_me) m ON m.family = o.family
      ORDER BY LEAST(o.delta, m.delta) DESC, o.family LIMIT 2
    ) ELSE '{}'::text[] END,
    CASE WHEN COALESCE(v_events, false) THEN (
      SELECT count(*)::integer FROM public.events e
      WHERE e.event_date >= now()
        AND EXISTS (SELECT 1 FROM public.event_attendees a WHERE a.event_id = e.id AND a.user_id = v_me AND a.status IN ('going', 'maybe'))
        AND EXISTS (SELECT 1 FROM public.event_attendees a WHERE a.event_id = e.id AND a.user_id = p_other AND a.status IN ('going', 'maybe'))
    ) ELSE 0 END,
    CASE WHEN COALESCE(v_events, false) THEN (
      SELECT jsonb_build_object('id', e.id, 'name', e.name, 'artist', e.artist_name, 'date', e.event_date, 'city', e.city)
      FROM public.events e
      WHERE e.event_date >= now()
        AND EXISTS (SELECT 1 FROM public.event_attendees a WHERE a.event_id = e.id AND a.user_id = v_me AND a.status IN ('going', 'maybe'))
        AND EXISTS (SELECT 1 FROM public.event_attendees a WHERE a.event_id = e.id AND a.user_id = p_other AND a.status IN ('going', 'maybe'))
      ORDER BY e.event_date LIMIT 1
    ) ELSE NULL END,
    COALESCE((SELECT v.times_shown FROM public.same_frequency_views v WHERE v.user_id = v_me AND v.shown_user_id = p_other), 0),
    (SELECT v.last_shown_at FROM public.same_frequency_views v WHERE v.user_id = v_me AND v.shown_user_id = p_other),
    EXISTS (SELECT 1 FROM public.saved_profiles s WHERE s.user_id = v_me AND s.saved_user_id = p_other);
END;
$$;
REVOKE ALL ON FUNCTION public.same_frequency_signals(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.same_frequency_signals(uuid) TO authenticated;

-- ── The caller's Same Frequency candidates ────────────────────────────────
-- Moderate affinity or above, with every signal. Final ranking, diversity
-- and rotation happen in the app (lib/domain/usecases/same_frequency.dart).
CREATE FUNCTION public.get_same_frequency(p_limit integer DEFAULT 80)
RETURNS TABLE (
  user_id uuid, username text, display_name text, avatar_url text, bio text,
  compatibility integer, details jsonb,
  shared_discoveries text[], rising_families text[],
  shared_events integer, shared_event jsonb,
  times_shown integer, last_shown_at timestamptz, saved boolean
)
LANGUAGE sql STABLE SECURITY INVOKER SET search_path = pg_catalog AS $$
  SELECT f.user_id, f.username, f.display_name, f.avatar_url, f.bio,
    f.compatibility, f.details,
    COALESCE(x.shared_discoveries, '{}'), COALESCE(x.rising_families, '{}'),
    COALESCE(x.shared_events, 0), x.shared_event,
    COALESCE(x.times_shown, 0), x.last_shown_at, COALESCE(x.saved, false)
  FROM public.get_affinity_feed(LEAST(GREATEST(COALESCE(p_limit, 80), 1), 100), 0) f
  LEFT JOIN LATERAL public.same_frequency_signals(f.user_id) x ON true
  WHERE f.compatibility >= 45;
$$;
REVOKE ALL ON FUNCTION public.get_same_frequency(integer) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_same_frequency(integer) TO authenticated;

-- ── Personal data export ──────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.export_my_personal_data()
RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
DECLARE
  uid uuid := auth.uid();
BEGIN
  IF uid IS NULL THEN RAISE EXCEPTION 'Authentication required'; END IF;
  RETURN jsonb_build_object(
    'format', 'vibra-personal-data-export/v1',
    'generated_at', now(),
    'response_target', 'Immediate automated export (well within 30 days)',
    'profile', (SELECT to_jsonb(u) - 'fcm_token' FROM public.users u WHERE u.id = uid),
    'privacy_preferences', (SELECT to_jsonb(p) FROM public.privacy_preferences p WHERE p.user_id = uid),
    'spotify_connection', (SELECT jsonb_build_object('spotify_user_id', s.spotify_user_id, 'connected_at', s.connected_at, 'token_expires_at', s.token_expires_at) FROM public.spotify_connections s WHERE s.user_id = uid),
    'music_profile', (SELECT to_jsonb(m) - 'embedding' FROM public.music_profiles m WHERE m.user_id = uid),
    'saved_events', COALESCE((SELECT jsonb_agg(to_jsonb(ea) ORDER BY ea.created_at) FROM public.event_attendees ea WHERE ea.user_id = uid), '[]'::jsonb),
    'messages', COALESCE((SELECT jsonb_agg(to_jsonb(m) ORDER BY m.created_at) FROM public.messages m WHERE m.sender_id = uid OR m.receiver_id = uid), '[]'::jsonb),
    'live_messages', COALESCE((SELECT jsonb_agg(to_jsonb(l) ORDER BY l.created_at) FROM public.live_messages l WHERE l.user_id = uid), '[]'::jsonb),
    'matches', COALESCE((SELECT jsonb_agg(to_jsonb(um) ORDER BY um.created_at) FROM public.user_matches um WHERE um.user_id_a = uid OR um.user_id_b = uid), '[]'::jsonb),
    'social_interactions', COALESCE((SELECT jsonb_agg(to_jsonb(i) ORDER BY i.created_at) FROM public.user_interactions_log i WHERE i.user_id = uid), '[]'::jsonb),
    'ticket_clicks', COALESCE((SELECT jsonb_agg(to_jsonb(t) ORDER BY t.clicked_at) FROM public.ticket_clicks t WHERE t.user_id = uid), '[]'::jsonb),
    'genre_preferences', COALESCE((SELECT jsonb_agg(to_jsonb(g) ORDER BY g.genre_key) FROM public.user_genre_preferences g WHERE g.user_id = uid), '[]'::jsonb),
    'affinity_dismissals', COALESCE((SELECT jsonb_agg(to_jsonb(d) ORDER BY d.created_at) FROM public.affinity_dismissals d WHERE d.user_id = uid), '[]'::jsonb),
    'musical_dna', COALESCE((SELECT jsonb_agg(to_jsonb(s) ORDER BY s.captured_on) FROM public.musical_dna_snapshots s WHERE s.user_id = uid), '[]'::jsonb),
    'saved_profiles', COALESCE((SELECT jsonb_agg(to_jsonb(s) ORDER BY s.created_at) FROM public.saved_profiles s WHERE s.user_id = uid), '[]'::jsonb),
    'same_frequency_views', COALESCE((SELECT jsonb_agg(to_jsonb(v) ORDER BY v.last_shown_at) FROM public.same_frequency_views v WHERE v.user_id = uid), '[]'::jsonb)
  );
END;
$$;
REVOKE ALL ON FUNCTION public.export_my_personal_data() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.export_my_personal_data() TO authenticated;

NOTIFY pgrst, 'reload schema';
COMMIT;
