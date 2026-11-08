-- VIBRA music affinity engine (docs/music-affinity-engine.md).
--
-- * user_genre_preferences: genres a user picks by hand (works without
--   Spotify). Keys come from supabase/functions/_shared/genre_catalog.json;
--   unknown keys are ignored by the engine.
-- * user_matches gains the explanation (details) and algorithm version. The
--   score is still written only by the service role (Edge Functions).
-- * affinity_dismissals: "Ignore" in the affinity deck is remembered.
-- * find_affinity_candidates / get_affinity_input / save_affinity_matches:
--   service-role helpers for the engine.
-- * get_affinity_feed: the caller's discovery feed. SECURITY INVOKER, so the
--   existing user_matches consent/block policies and the test-segment
--   policies on users_public keep applying unchanged.
-- * Match push notifications only for strong new affinities (>= 80).
BEGIN;

-- ── Manual genre preferences ──────────────────────────────────────────────
CREATE TABLE public.user_genre_preferences (
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  genre_key text NOT NULL CHECK (genre_key ~ '^[a-z0-9]+(-[a-z0-9]+)*$' AND char_length(genre_key) <= 40),
  intensity smallint NOT NULL DEFAULT 70 CHECK (intensity BETWEEN 1 AND 100),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, genre_key)
);
ALTER TABLE public.user_genre_preferences ENABLE ROW LEVEL SECURITY;
CREATE POLICY user_genre_preferences_owner_select ON public.user_genre_preferences
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY user_genre_preferences_owner_insert ON public.user_genre_preferences
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY user_genre_preferences_owner_update ON public.user_genre_preferences
  FOR UPDATE TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY user_genre_preferences_owner_delete ON public.user_genre_preferences
  FOR DELETE TO authenticated USING (user_id = auth.uid());
REVOKE ALL ON TABLE public.user_genre_preferences FROM PUBLIC, anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.user_genre_preferences TO authenticated;
GRANT ALL ON TABLE public.user_genre_preferences TO service_role;

CREATE FUNCTION public.limit_user_genre_preferences()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  NEW.updated_at := now();
  IF TG_OP = 'INSERT' AND (SELECT count(*) FROM public.user_genre_preferences WHERE user_id = NEW.user_id) >= 30 THEN
    RAISE check_violation USING MESSAGE = 'genre_preferences_limit';
  END IF;
  RETURN NEW;
END;
$$;
REVOKE ALL ON FUNCTION public.limit_user_genre_preferences() FROM PUBLIC, anon, authenticated;
CREATE TRIGGER trg_limit_user_genre_preferences BEFORE INSERT OR UPDATE
ON public.user_genre_preferences FOR EACH ROW EXECUTE FUNCTION public.limit_user_genre_preferences();

-- ── Cached explanation on the pair ────────────────────────────────────────
ALTER TABLE public.user_matches
  ADD COLUMN IF NOT EXISTS details jsonb NOT NULL DEFAULT '{}'::jsonb,
  ADD COLUMN IF NOT EXISTS algorithm_version smallint NOT NULL DEFAULT 1;
ALTER TABLE public.user_matches
  ADD CONSTRAINT user_matches_details_object CHECK (jsonb_typeof(details) = 'object');

-- ── Ignored profiles ──────────────────────────────────────────────────────
CREATE TABLE public.affinity_dismissals (
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  dismissed_user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, dismissed_user_id),
  CHECK (user_id <> dismissed_user_id)
);
ALTER TABLE public.affinity_dismissals ENABLE ROW LEVEL SECURITY;
CREATE POLICY affinity_dismissals_owner_select ON public.affinity_dismissals
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY affinity_dismissals_owner_insert ON public.affinity_dismissals
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY affinity_dismissals_owner_delete ON public.affinity_dismissals
  FOR DELETE TO authenticated USING (user_id = auth.uid());
REVOKE ALL ON TABLE public.affinity_dismissals FROM PUBLIC, anon;
GRANT SELECT, INSERT, DELETE ON TABLE public.affinity_dismissals TO authenticated;
GRANT ALL ON TABLE public.affinity_dismissals TO service_role;

-- ── Engine inputs (service role) ──────────────────────────────────────────
CREATE FUNCTION public.get_affinity_input(p_user_id uuid)
RETURNS TABLE (user_id uuid, top_artists jsonb, top_genres jsonb, manual_genres jsonb)
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  IF auth.role() IS DISTINCT FROM 'service_role' THEN
    RAISE insufficient_privilege USING MESSAGE = 'Service role required';
  END IF;
  RETURN QUERY
  SELECT u.id,
    COALESCE(mp.top_artists, '[]'::jsonb),
    COALESCE(mp.top_genres, '[]'::jsonb),
    COALESCE((SELECT jsonb_agg(jsonb_build_object('genre_key', g.genre_key, 'intensity', g.intensity) ORDER BY g.genre_key)
      FROM public.user_genre_preferences g WHERE g.user_id = u.id), '[]'::jsonb)
  FROM public.users u
  LEFT JOIN public.music_profiles mp ON mp.user_id = u.id
  WHERE u.id = p_user_id;
END;
$$;
REVOKE ALL ON FUNCTION public.get_affinity_input(uuid) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_affinity_input(uuid) TO service_role;

-- Everyone with musical data (Spotify profile or picked genres), with the
-- same consent, block and test-segment rules as find_music_match_candidates.
CREATE FUNCTION public.find_affinity_candidates(p_user_id uuid, p_limit integer DEFAULT 500)
RETURNS TABLE (user_id uuid, top_artists jsonb, top_genres jsonb, manual_genres jsonb)
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  IF auth.role() IS DISTINCT FROM 'service_role' THEN
    RAISE insufficient_privilege USING MESSAGE = 'Service role required';
  END IF;
  IF NOT public.spotify_feature_enabled() THEN RETURN; END IF;
  RETURN QUERY
  WITH pool AS (
    SELECT mp.user_id, mp.last_synced_at AS freshness FROM public.music_profiles mp
    UNION
    SELECT g.user_id, max(g.updated_at) FROM public.user_genre_preferences g GROUP BY g.user_id
  ), ranked AS (
    SELECT p.user_id, max(p.freshness) AS freshness FROM pool p GROUP BY p.user_id
  )
  SELECT r.user_id,
    COALESCE(mp.top_artists, '[]'::jsonb),
    COALESCE(mp.top_genres, '[]'::jsonb),
    COALESCE((SELECT jsonb_agg(jsonb_build_object('genre_key', g.genre_key, 'intensity', g.intensity) ORDER BY g.genre_key)
      FROM public.user_genre_preferences g WHERE g.user_id = r.user_id), '[]'::jsonb)
  FROM ranked r
  JOIN public.users candidate_user ON candidate_user.id = r.user_id
  JOIN public.users target_user ON target_user.id = p_user_id
  LEFT JOIN public.music_profiles mp ON mp.user_id = r.user_id
  WHERE r.user_id <> p_user_id
    AND EXISTS (SELECT 1 FROM public.privacy_preferences p WHERE p.user_id = r.user_id AND p.spotify_matching)
    AND EXISTS (SELECT 1 FROM public.privacy_preferences p WHERE p.user_id = p_user_id AND p.spotify_matching)
    AND NOT EXISTS (SELECT 1 FROM public.blocked_users b WHERE
      (b.blocker_id = p_user_id AND b.blocked_id = r.user_id) OR
      (b.blocked_id = p_user_id AND b.blocker_id = r.user_id))
    AND candidate_user.is_test_user = target_user.is_test_user
  ORDER BY r.freshness DESC NULLS LAST, r.user_id
  LIMIT LEAST(GREATEST(COALESCE(p_limit, 500), 1), 1000);
END;
$$;
REVOKE ALL ON FUNCTION public.find_affinity_candidates(uuid, integer) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.find_affinity_candidates(uuid, integer) TO service_role;

-- Writes one user's freshly computed pairs and invalidates stale ones in a
-- single transaction. p_considered: every candidate that was scored (or
-- found insufficient) this run; p_complete: the candidate list was not
-- truncated, so any other cached pair of this user is no longer eligible.
CREATE FUNCTION public.save_affinity_matches(
  p_user_id uuid, p_rows jsonb, p_considered uuid[], p_complete boolean
)
RETURNS integer LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v_kept uuid[];
BEGIN
  IF auth.role() IS DISTINCT FROM 'service_role' THEN
    RAISE insufficient_privilege USING MESSAGE = 'Service role required';
  END IF;
  IF jsonb_typeof(COALESCE(p_rows, '[]'::jsonb)) <> 'array' THEN
    RAISE invalid_parameter_value USING MESSAGE = 'rows must be an array';
  END IF;
  -- Same lock as Spotify disconnect/sync: a concurrent disconnect wins.
  PERFORM 1 FROM public.users WHERE id = p_user_id FOR UPDATE;

  SELECT COALESCE(array_agg(CASE WHEN (r->>'user_id_a')::uuid = p_user_id
      THEN (r->>'user_id_b')::uuid ELSE (r->>'user_id_a')::uuid END), '{}')
  INTO v_kept FROM jsonb_array_elements(COALESCE(p_rows, '[]'::jsonb)) r;

  DELETE FROM public.user_matches m
  WHERE (m.user_id_a = p_user_id OR m.user_id_b = p_user_id)
    AND NOT (CASE WHEN m.user_id_a = p_user_id THEN m.user_id_b ELSE m.user_id_a END = ANY (v_kept))
    AND (p_complete OR CASE WHEN m.user_id_a = p_user_id THEN m.user_id_b ELSE m.user_id_a END = ANY (COALESCE(p_considered, '{}')));

  INSERT INTO public.user_matches AS existing
    (user_id_a, user_id_b, compatibility, shared_artists, shared_genres, details, algorithm_version)
  SELECT (r->>'user_id_a')::uuid, (r->>'user_id_b')::uuid,
    LEAST(GREATEST((r->>'compatibility')::double precision, 0), 100),
    GREATEST(COALESCE((r->>'shared_artists')::int, 0), 0),
    GREATEST(COALESCE((r->>'shared_genres')::int, 0), 0),
    COALESCE(r->'details', '{}'::jsonb),
    COALESCE((r->>'algorithm_version')::smallint, 2)
  FROM jsonb_array_elements(COALESCE(p_rows, '[]'::jsonb)) r
  WHERE (r->>'user_id_a')::uuid < (r->>'user_id_b')::uuid
    AND p_user_id IN ((r->>'user_id_a')::uuid, (r->>'user_id_b')::uuid)
  ON CONFLICT (user_id_a, user_id_b) DO UPDATE SET
    compatibility = EXCLUDED.compatibility,
    shared_artists = EXCLUDED.shared_artists,
    shared_genres = EXCLUDED.shared_genres,
    details = EXCLUDED.details,
    algorithm_version = EXCLUDED.algorithm_version;
  RETURN cardinality(v_kept);
END;
$$;
REVOKE ALL ON FUNCTION public.save_affinity_matches(uuid, jsonb, uuid[], boolean) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.save_affinity_matches(uuid, jsonb, uuid[], boolean) TO service_role;

-- Picking or removing genres invalidates the cached pairs at once; the app
-- then asks calculate-match to rebuild them.
CREATE FUNCTION public.invalidate_affinity_on_genre_change()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v_user uuid := COALESCE(NEW.user_id, OLD.user_id);
BEGIN
  -- Spotify-backed users keep their pairs until the recompute replaces them;
  -- genre-only users have nothing else supporting a cached score.
  IF NOT EXISTS (SELECT 1 FROM public.music_profiles WHERE user_id = v_user)
     AND NOT EXISTS (SELECT 1 FROM public.user_genre_preferences WHERE user_id = v_user) THEN
    DELETE FROM public.user_matches WHERE user_id_a = v_user OR user_id_b = v_user;
  END IF;
  RETURN NULL;
END;
$$;
REVOKE ALL ON FUNCTION public.invalidate_affinity_on_genre_change() FROM PUBLIC, anon, authenticated;
CREATE TRIGGER trg_invalidate_affinity_on_genre_change AFTER DELETE
ON public.user_genre_preferences FOR EACH ROW EXECUTE FUNCTION public.invalidate_affinity_on_genre_change();

-- ── Discovery feed (caller) ───────────────────────────────────────────────
CREATE FUNCTION public.get_affinity_feed(p_limit integer DEFAULT 30, p_offset integer DEFAULT 0)
RETURNS TABLE (
  user_id uuid, username text, display_name text, avatar_url text, bio text,
  compatibility integer, details jsonb, algorithm_version smallint, profile_complete boolean
)
LANGUAGE sql STABLE SECURITY INVOKER SET search_path = pg_catalog AS $$
  SELECT other.id, other.username::text, other.display_name, other.avatar_url, other.bio,
    round(m.compatibility)::integer, m.details, m.algorithm_version,
    (other.avatar_url IS NOT NULL AND NULLIF(btrim(other.bio), '') IS NOT NULL)
  FROM public.user_matches m
  JOIN public.users_public other
    ON other.id = CASE WHEN m.user_id_a = auth.uid() THEN m.user_id_b ELSE m.user_id_a END
  WHERE (m.user_id_a = auth.uid() OR m.user_id_b = auth.uid())
    AND NOT EXISTS (SELECT 1 FROM public.affinity_dismissals d
      WHERE d.user_id = auth.uid() AND d.dismissed_user_id = other.id)
    AND NOT EXISTS (SELECT 1 FROM public.friendships f
      WHERE f.status IN ('accepted', 'pending')
        AND ((f.requester_id = auth.uid() AND f.receiver_id = other.id)
          OR (f.receiver_id = auth.uid() AND f.requester_id = other.id)))
  ORDER BY m.compatibility DESC,
    (other.avatar_url IS NOT NULL AND NULLIF(btrim(other.bio), '') IS NOT NULL) DESC,
    m.updated_at DESC, other.id
  LIMIT LEAST(GREATEST(COALESCE(p_limit, 30), 1), 100)
  OFFSET GREATEST(COALESCE(p_offset, 0), 0);
$$;
REVOKE ALL ON FUNCTION public.get_affinity_feed(integer, integer) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_affinity_feed(integer, integer) TO authenticated;

-- ── Personal data export includes the new tables ──────────────────────────
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
    'affinity_dismissals', COALESCE((SELECT jsonb_agg(to_jsonb(d) ORDER BY d.created_at) FROM public.affinity_dismissals d WHERE d.user_id = uid), '[]'::jsonb)
  );
END;
$$;
REVOKE ALL ON FUNCTION public.export_my_personal_data() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.export_my_personal_data() TO authenticated;

-- ── Notify only strong new affinities ─────────────────────────────────────
-- Pairs are now cached for every eligible candidate, not only the top 50, so
-- a push per inserted row would be noise.
DROP TRIGGER IF EXISTS user_matches_notify_trigger ON public.user_matches;
CREATE TRIGGER user_matches_notify_trigger
AFTER INSERT ON public.user_matches
FOR EACH ROW WHEN (NEW.compatibility >= 80)
EXECUTE FUNCTION public.notify_social_action();

NOTIFY pgrst, 'reload schema';
COMMIT;
