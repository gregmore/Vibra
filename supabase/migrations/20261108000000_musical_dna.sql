-- VIBRA Musical DNA (docs/musical-dna.md).
--
-- * musical_dna_snapshots: one computed DNA per user per day. The newest row
--   is the current DNA; older rows are the history ("evolution"). Written
--   only by the service role (Edge Functions), from the user's own Spotify
--   top artists/tracks and picked genres. Kept for 400 days.
-- * privacy_preferences.musical_dna_visibility: public | matches | private.
--   Private by default; the owner always sees their own DNA.
-- * get_musical_dna(user): the only way to read someone else's DNA. Applies
--   visibility, blocks and test-segment isolation.
-- * Spotify disconnect or account deletion removes the snapshots with the
--   music profile they were derived from.
BEGIN;

ALTER TABLE public.privacy_preferences
  ADD COLUMN IF NOT EXISTS musical_dna_visibility text NOT NULL DEFAULT 'private'
  CHECK (musical_dna_visibility IN ('public', 'matches', 'private'));

CREATE TABLE public.musical_dna_snapshots (
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  captured_on date NOT NULL DEFAULT current_date,
  dna jsonb NOT NULL CHECK (jsonb_typeof(dna) = 'object'),
  algorithm_version smallint NOT NULL DEFAULT 1,
  updated_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, captured_on)
);
ALTER TABLE public.musical_dna_snapshots ENABLE ROW LEVEL SECURITY;
CREATE POLICY musical_dna_snapshots_owner_select ON public.musical_dna_snapshots
  FOR SELECT TO authenticated USING (user_id = (SELECT auth.uid()));
REVOKE ALL ON TABLE public.musical_dna_snapshots FROM PUBLIC, anon, authenticated;
GRANT SELECT ON TABLE public.musical_dna_snapshots TO authenticated;
GRANT ALL ON TABLE public.musical_dna_snapshots TO service_role;

-- ── Engine input (service role) ───────────────────────────────────────────
CREATE FUNCTION public.get_musical_dna_input(p_user_id uuid)
RETURNS TABLE (top_artists jsonb, top_tracks jsonb, top_genres jsonb, manual_genres jsonb)
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  IF auth.role() IS DISTINCT FROM 'service_role' THEN
    RAISE insufficient_privilege USING MESSAGE = 'Service role required';
  END IF;
  RETURN QUERY
  SELECT
    COALESCE(mp.top_artists, '[]'::jsonb),
    COALESCE(mp.top_tracks, '[]'::jsonb),
    COALESCE(mp.top_genres, '[]'::jsonb),
    COALESCE((SELECT jsonb_agg(jsonb_build_object('genre_key', g.genre_key, 'intensity', g.intensity) ORDER BY g.genre_key)
      FROM public.user_genre_preferences g WHERE g.user_id = u.id), '[]'::jsonb)
  FROM public.users u
  LEFT JOIN public.music_profiles mp ON mp.user_id = u.id
  WHERE u.id = p_user_id;
END;
$$;
REVOKE ALL ON FUNCTION public.get_musical_dna_input(uuid) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_musical_dna_input(uuid) TO service_role;

-- Stores today's snapshot (replacing an earlier one from the same day), or
-- removes every snapshot when the user no longer has any musical data.
CREATE FUNCTION public.save_musical_dna(p_user_id uuid, p_dna jsonb)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  IF auth.role() IS DISTINCT FROM 'service_role' THEN
    RAISE insufficient_privilege USING MESSAGE = 'Service role required';
  END IF;
  -- Same lock as Spotify disconnect/sync: a concurrent disconnect wins.
  PERFORM 1 FROM public.users WHERE id = p_user_id FOR UPDATE;
  IF NOT FOUND THEN RETURN; END IF;
  IF p_dna IS NULL OR jsonb_typeof(p_dna) = 'null' THEN
    DELETE FROM public.musical_dna_snapshots WHERE user_id = p_user_id;
    RETURN;
  END IF;
  IF jsonb_typeof(p_dna) <> 'object' OR jsonb_typeof(p_dna->'families') <> 'array' THEN
    RAISE invalid_parameter_value USING MESSAGE = 'dna must be an object with families';
  END IF;
  -- Spotify-derived DNA without a music profile means a disconnect won the
  -- race: do not write it back.
  IF COALESCE((p_dna #>> '{sources,spotify}')::boolean, false)
     AND NOT EXISTS (SELECT 1 FROM public.music_profiles WHERE user_id = p_user_id) THEN
    RETURN;
  END IF;
  INSERT INTO public.musical_dna_snapshots AS s (user_id, captured_on, dna, algorithm_version, updated_at)
  VALUES (p_user_id, current_date, p_dna, COALESCE((p_dna->>'version')::smallint, 1), now())
  ON CONFLICT (user_id, captured_on) DO UPDATE
    SET dna = EXCLUDED.dna, algorithm_version = EXCLUDED.algorithm_version, updated_at = now();
  DELETE FROM public.musical_dna_snapshots
  WHERE user_id = p_user_id AND captured_on < current_date - 400;
END;
$$;
REVOKE ALL ON FUNCTION public.save_musical_dna(uuid, jsonb) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.save_musical_dna(uuid, jsonb) TO service_role;

-- Snapshots are derived from the music profile: when it goes (Spotify
-- disconnect or revocation), they go too. A user with picked genres gets a
-- fresh genre-only DNA on the next calculate-match.
CREATE FUNCTION public.clear_musical_dna_on_profile_delete()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  DELETE FROM public.musical_dna_snapshots WHERE user_id = OLD.user_id;
  RETURN NULL;
END;
$$;
REVOKE ALL ON FUNCTION public.clear_musical_dna_on_profile_delete() FROM PUBLIC, anon, authenticated;
CREATE TRIGGER trg_clear_musical_dna_on_profile_delete AFTER DELETE
ON public.music_profiles FOR EACH ROW EXECUTE FUNCTION public.clear_musical_dna_on_profile_delete();

-- ── Reading someone's DNA ─────────────────────────────────────────────────
-- Returns the newest snapshot, or NULL when the caller may not see it.
--   owner     → always
--   'public'  → any signed-in user
--   'matches' → users with a cached affinity pair (both consented to musical
--               matching) or an accepted connection
--   'private' → nobody else
-- Blocks in either direction and different test segments always hide it.
CREATE FUNCTION public.get_musical_dna(p_user_id uuid)
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE
  v_viewer uuid := auth.uid();
  v_visibility text;
  v_row public.musical_dna_snapshots%ROWTYPE;
BEGIN
  IF v_viewer IS NULL THEN
    RAISE insufficient_privilege USING MESSAGE = 'Authentication required';
  END IF;
  IF v_viewer <> p_user_id THEN
    SELECT COALESCE(p.musical_dna_visibility, 'private') INTO v_visibility
    FROM public.privacy_preferences p WHERE p.user_id = p_user_id;
    v_visibility := COALESCE(v_visibility, 'private');
    IF v_visibility = 'private' THEN RETURN NULL; END IF;
    IF EXISTS (SELECT 1 FROM public.blocked_users b WHERE
        (b.blocker_id = v_viewer AND b.blocked_id = p_user_id) OR
        (b.blocker_id = p_user_id AND b.blocked_id = v_viewer)) THEN
      RETURN NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM public.users owner_user
        JOIN public.users viewer_user ON viewer_user.id = v_viewer
        WHERE owner_user.id = p_user_id AND owner_user.is_test_user = viewer_user.is_test_user) THEN
      RETURN NULL;
    END IF;
    IF v_visibility = 'matches' AND NOT EXISTS (
        SELECT 1 FROM public.user_matches m
        WHERE m.user_id_a = LEAST(v_viewer, p_user_id) AND m.user_id_b = GREATEST(v_viewer, p_user_id)
      ) AND NOT EXISTS (
        SELECT 1 FROM public.friendships f WHERE f.status = 'accepted'
          AND ((f.requester_id = v_viewer AND f.receiver_id = p_user_id)
            OR (f.requester_id = p_user_id AND f.receiver_id = v_viewer))
      ) THEN
      RETURN NULL;
    END IF;
  END IF;
  SELECT * INTO v_row FROM public.musical_dna_snapshots s
  WHERE s.user_id = p_user_id ORDER BY s.captured_on DESC LIMIT 1;
  IF NOT FOUND THEN RETURN NULL; END IF;
  RETURN jsonb_build_object(
    'user_id', p_user_id,
    'captured_on', v_row.captured_on,
    'updated_at', v_row.updated_at,
    -- The ranked artist list is only for the owner and for server-side
    -- "recently discovered" comparisons; other viewers get the distribution.
    'dna', CASE WHEN v_viewer = p_user_id THEN v_row.dna ELSE v_row.dna - 'artists' END
  );
END;
$$;
REVOKE ALL ON FUNCTION public.get_musical_dna(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_musical_dna(uuid) TO authenticated;

-- ── Personal data export includes the DNA history ─────────────────────────
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
    'musical_dna', COALESCE((SELECT jsonb_agg(to_jsonb(s) ORDER BY s.captured_on) FROM public.musical_dna_snapshots s WHERE s.user_id = uid), '[]'::jsonb)
  );
END;
$$;
REVOKE ALL ON FUNCTION public.export_my_personal_data() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.export_my_personal_data() TO authenticated;

NOTIFY pgrst, 'reload schema';
COMMIT;
