BEGIN;

-- Reversible launch control: keep existing imports and individual consents,
-- but stop their use while the provider does not permit public access.
CREATE TABLE public.launch_features (
  feature text PRIMARY KEY CHECK (feature = 'spotify'),
  enabled boolean NOT NULL DEFAULT false
);
ALTER TABLE public.launch_features ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.launch_features FROM PUBLIC, anon, authenticated;
GRANT SELECT, UPDATE ON public.launch_features TO service_role;
INSERT INTO public.launch_features (feature, enabled) VALUES ('spotify', false);

CREATE FUNCTION public.spotify_feature_enabled()
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
  SELECT COALESCE((SELECT enabled FROM public.launch_features WHERE feature = 'spotify'), false);
$$;
REVOKE ALL ON FUNCTION public.spotify_feature_enabled() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.spotify_feature_enabled() TO authenticated, service_role;

CREATE POLICY user_matches_launch_feature ON public.user_matches
AS RESTRICTIVE FOR SELECT TO authenticated USING (public.spotify_feature_enabled());
CREATE POLICY music_discovery_launch_feature ON public.music_profile_discovery
AS RESTRICTIVE FOR SELECT TO authenticated USING (public.spotify_feature_enabled());
CREATE POLICY notifications_launch_music_feature ON public.notifications
AS RESTRICTIVE FOR SELECT TO authenticated USING (
  type NOT IN ('match', 'event_alert', 'artist_concert', 'retention', 'digest')
  OR public.spotify_feature_enabled()
);

CREATE OR REPLACE FUNCTION public.may_discover_music(p_user_id uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
  SELECT public.spotify_feature_enabled() AND (auth.uid() = p_user_id OR (
    EXISTS (SELECT 1 FROM public.privacy_preferences p WHERE p.user_id = p_user_id AND p.spotify_matching)
    AND NOT EXISTS (SELECT 1 FROM public.blocked_users b WHERE
      (b.blocker_id = auth.uid() AND b.blocked_id = p_user_id)
      OR (b.blocked_id = auth.uid() AND b.blocker_id = p_user_id))
  ));
$$;
CREATE OR REPLACE FUNCTION public.may_access_music_match(p_user_id_a uuid, p_user_id_b uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
  SELECT public.spotify_feature_enabled() AND public.may_access_message(p_user_id_a, p_user_id_b)
    AND EXISTS (SELECT 1 FROM public.privacy_preferences WHERE user_id = p_user_id_a AND spotify_matching)
    AND EXISTS (SELECT 1 FROM public.privacy_preferences WHERE user_id = p_user_id_b AND spotify_matching);
$$;

-- Hold a shared lock until the write transaction finishes. Pausing the flag
-- waits for earlier writes, then prevents a late worker from reviving data.
CREATE FUNCTION public.require_spotify_feature_enabled()
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  PERFORM 1 FROM public.launch_features WHERE feature = 'spotify' AND enabled FOR SHARE;
  IF NOT FOUND THEN RAISE SQLSTATE 'PT503' USING MESSAGE = 'spotify_temporarily_unavailable'; END IF;
END;
$$;
REVOKE ALL ON FUNCTION public.require_spotify_feature_enabled() FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.require_spotify_feature_enabled() TO service_role;

CREATE FUNCTION public.protect_paused_spotify_write()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  PERFORM public.require_spotify_feature_enabled();
  RETURN NEW;
END;
$$;
REVOKE ALL ON FUNCTION public.protect_paused_spotify_write() FROM PUBLIC, anon, authenticated;
CREATE TRIGGER trg_spotify_connections_launch_feature BEFORE INSERT OR UPDATE
ON public.spotify_connections FOR EACH ROW EXECUTE FUNCTION public.protect_paused_spotify_write();
CREATE TRIGGER trg_music_profiles_launch_feature BEFORE INSERT OR UPDATE
ON public.music_profiles FOR EACH ROW EXECUTE FUNCTION public.protect_paused_spotify_write();
CREATE TRIGGER trg_user_matches_launch_feature BEFORE INSERT OR UPDATE
ON public.user_matches FOR EACH ROW EXECUTE FUNCTION public.protect_paused_spotify_write();

CREATE FUNCTION public.protect_paused_music_notification()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  IF NEW.type IN ('match', 'event_alert', 'artist_concert', 'retention', 'digest') THEN
    PERFORM public.require_spotify_feature_enabled();
  END IF;
  RETURN NEW;
END;
$$;
REVOKE ALL ON FUNCTION public.protect_paused_music_notification() FROM PUBLIC, anon, authenticated;
CREATE TRIGGER trg_notifications_launch_music_feature BEFORE INSERT
ON public.notifications FOR EACH ROW EXECUTE FUNCTION public.protect_paused_music_notification();

CREATE FUNCTION public.protect_paused_event_embedding()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  IF NEW.embedding IS NOT NULL AND NEW.embedding::text IS DISTINCT FROM OLD.embedding::text THEN
    PERFORM public.require_spotify_feature_enabled();
  END IF;
  RETURN NEW;
END;
$$;
REVOKE ALL ON FUNCTION public.protect_paused_event_embedding() FROM PUBLIC, anon, authenticated;
CREATE TRIGGER trg_event_embedding_launch_feature BEFORE UPDATE OF embedding
ON public.events FOR EACH ROW EXECUTE FUNCTION public.protect_paused_event_embedding();

-- Basic community discovery does not depend on Spotify or musical affinity.
-- SECURITY INVOKER keeps users_public's current segment and session policies.
CREATE FUNCTION public.discover_public_users(p_query text DEFAULT '', p_limit integer DEFAULT 30)
RETURNS TABLE (id uuid, username text, display_name text, avatar_url text, bio text)
LANGUAGE plpgsql STABLE SECURITY INVOKER SET search_path = pg_catalog AS $$
DECLARE v_query text := lower(btrim(COALESCE(p_query, '')));
BEGIN
  IF auth.uid() IS NULL OR auth.role() IS DISTINCT FROM 'authenticated' THEN
    RAISE insufficient_privilege USING MESSAGE = 'Authentication required';
  END IF;
  PERFORM public.require_active_session();
  IF char_length(COALESCE(p_query, '')) > 100 THEN
    RAISE invalid_parameter_value USING MESSAGE = 'Search query must not exceed 100 characters';
  END IF;
  RETURN QUERY
  SELECT u.id, u.username::text, u.display_name, u.avatar_url, u.bio
  FROM public.users_public u
  WHERE u.id <> auth.uid()
    AND public.may_access_message(auth.uid(), u.id)
    AND (v_query = '' OR strpos(lower(COALESCE(u.username::text, '')), v_query) > 0
      OR strpos(lower(COALESCE(u.display_name, '')), v_query) > 0)
  ORDER BY lower(u.username::text) NULLS LAST, u.id
  LIMIT LEAST(GREATEST(COALESCE(p_limit, 30), 1), 50);
END;
$$;
REVOKE ALL ON FUNCTION public.discover_public_users(text, integer) FROM PUBLIC, anon, service_role;
GRANT EXECUTE ON FUNCTION public.discover_public_users(text, integer) TO authenticated;

-- Existing algorithm, permissions and segment/consent filters are retained.
CREATE OR REPLACE FUNCTION public.find_compatible_users(
  p_user_id uuid,
  p_embedding vector(10),
  p_limit int DEFAULT 50
)
RETURNS TABLE (
  user_id uuid,
  distance float,
  top_artists jsonb,
  top_genres jsonb
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  PERFORM public.require_active_session();
  IF NOT EXISTS (SELECT 1 FROM public.users WHERE id = p_user_id) THEN
    RAISE EXCEPTION 'Unknown Vibra profile';
  END IF;
  IF COALESCE(auth.role(), '') <> 'service_role'
     AND auth.uid() IS DISTINCT FROM p_user_id THEN
    RAISE EXCEPTION 'A user can request compatibility candidates only for itself';
  END IF;

  IF NOT public.spotify_feature_enabled() THEN RETURN; END IF;

  RETURN QUERY
  SELECT
    candidate.user_id,
    (candidate.embedding <-> p_embedding)::float AS distance,
    candidate.top_artists,
    candidate.top_genres
  FROM public.music_profiles AS candidate
  JOIN public.users AS candidate_user ON candidate_user.id = candidate.user_id
  JOIN public.users AS target_user ON target_user.id = p_user_id
  WHERE candidate.user_id <> p_user_id
    AND candidate.embedding IS NOT NULL
    AND EXISTS (SELECT 1 FROM public.privacy_preferences p WHERE p.user_id = candidate.user_id AND p.spotify_matching)
    AND EXISTS (SELECT 1 FROM public.privacy_preferences p WHERE p.user_id = p_user_id AND p.spotify_matching)
    AND NOT EXISTS (SELECT 1 FROM public.blocked_users b WHERE
      (b.blocker_id = p_user_id AND b.blocked_id = candidate.user_id) OR
      (b.blocked_id = p_user_id AND b.blocker_id = candidate.user_id))
    AND candidate_user.is_test_user = target_user.is_test_user
  ORDER BY candidate.embedding <-> p_embedding
  LIMIT LEAST(GREATEST(COALESCE(p_limit, 50), 1), 200);
END;
$$;

-- Existing algorithm, permissions and segment/consent filters are retained.
CREATE OR REPLACE FUNCTION public.nearby_recent_match_for_user(
  p_user_id uuid,
  p_radius_meters double precision DEFAULT 25000
)
RETURNS TABLE (
  match_id uuid,
  compatibility double precision,
  display_name text
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  IF auth.role() <> 'service_role' THEN
    RAISE EXCEPTION 'service role required';
  END IF;

  IF p_user_id IS NULL
     OR p_radius_meters IS NULL OR p_radius_meters NOT BETWEEN 100 AND 250000 THEN
    RAISE EXCEPTION 'Invalid nearby-match query parameters';
  END IF;

  IF NOT public.spotify_feature_enabled() THEN RETURN; END IF;

  RETURN QUERY
  WITH recent_matches AS (
    SELECT
      m.id,
      m.compatibility,
      m.created_at,
      CASE
        WHEN m.user_id_a = p_user_id THEN m.user_id_b
        ELSE m.user_id_a
      END AS other_user_id
    FROM public.user_matches AS m
    WHERE (m.user_id_a = p_user_id OR m.user_id_b = p_user_id)
      AND m.compatibility >= 75
      AND m.created_at >= now() - interval '7 days'
    ORDER BY m.created_at DESC
    LIMIT 5
  )
  SELECT
    rm.id,
    rm.compatibility,
    COALESCE(other_user.display_name, other_user.username::text, 'Una nuova persona')
  FROM recent_matches AS rm
  JOIN public.users AS viewer_user
    ON viewer_user.id = p_user_id
  JOIN public.users AS other_user
    ON other_user.id = rm.other_user_id
  WHERE viewer_user.last_location IS NOT NULL
    AND other_user.last_location IS NOT NULL
    AND public.ST_DWithin(
      viewer_user.last_location,
      other_user.last_location,
      p_radius_meters
    )
  ORDER BY rm.created_at DESC
  LIMIT 1;
END;
$$;

NOTIFY pgrst, 'reload schema';
COMMIT;
