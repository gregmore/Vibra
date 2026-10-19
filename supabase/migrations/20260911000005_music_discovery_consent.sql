BEGIN;
CREATE FUNCTION public.may_discover_music(p_user_id uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
 SELECT auth.uid() = p_user_id OR (
   EXISTS (SELECT 1 FROM public.privacy_preferences p WHERE p.user_id=p_user_id AND p.spotify_matching)
   AND NOT EXISTS (SELECT 1 FROM public.blocked_users b WHERE
     (b.blocker_id=auth.uid() AND b.blocked_id=p_user_id) OR
     (b.blocked_id=auth.uid() AND b.blocker_id=p_user_id))
 );
$$;
REVOKE ALL ON FUNCTION public.may_discover_music(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.may_discover_music(uuid) TO authenticated;
CREATE POLICY music_discovery_requires_consent ON public.music_profile_discovery
AS RESTRICTIVE FOR SELECT TO authenticated
USING (public.may_discover_music(user_id));
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
  IF NOT EXISTS (SELECT 1 FROM public.users WHERE id = p_user_id) THEN
    RAISE EXCEPTION 'Unknown Vibra profile';
  END IF;
  IF COALESCE(auth.role(), '') <> 'service_role'
     AND auth.uid() IS DISTINCT FROM p_user_id THEN
    RAISE EXCEPTION 'A user can request compatibility candidates only for itself';
  END IF;

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


COMMIT;
