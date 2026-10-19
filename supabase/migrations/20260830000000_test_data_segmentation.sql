-- Keep automated/manual QA identities and their synthetic events isolated from
-- real beta users. The seed itself remains opt-in and lives outside migrations.

BEGIN;

ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS is_test_user boolean NOT NULL DEFAULT false;

ALTER TABLE public.events
  ADD COLUMN IF NOT EXISTS is_test_data boolean NOT NULL DEFAULT false;

CREATE INDEX IF NOT EXISTS idx_users_test_segment
  ON public.users (is_test_user, id);
CREATE INDEX IF NOT EXISTS idx_events_test_segment_date
  ON public.events (is_test_data, event_date);

-- Auth app_metadata is the source of truth. This also protects an auth-only
-- fixture: when the app bootstraps its public profile, the test flag cannot be
-- lost or forged by a client write.
CREATE OR REPLACE FUNCTION public.auth_user_is_test(p_user_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
  SELECT COALESCE(
    lower(COALESCE(u.raw_app_meta_data ->> 'is_test_user', 'false')) = 'true',
    false
  )
  FROM auth.users AS u
  WHERE u.id = p_user_id;
$$;

REVOKE ALL ON FUNCTION public.auth_user_is_test(uuid) FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION public.current_user_is_test()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
  SELECT COALESCE(public.auth_user_is_test(auth.uid()), false);
$$;

REVOKE ALL ON FUNCTION public.current_user_is_test() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.current_user_is_test() TO anon, authenticated;

CREATE OR REPLACE FUNCTION public.user_is_in_current_test_segment(p_user_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
  SELECT COALESCE(public.auth_user_is_test(p_user_id), false)
       = COALESCE(public.auth_user_is_test(auth.uid()), false);
$$;

REVOKE ALL ON FUNCTION public.user_is_in_current_test_segment(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.user_is_in_current_test_segment(uuid)
  TO authenticated;

CREATE OR REPLACE FUNCTION public.enforce_profile_test_segment()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
BEGIN
  NEW.is_test_user := COALESCE(public.auth_user_is_test(NEW.id), false);
  RETURN NEW;
END;
$$;

REVOKE ALL ON FUNCTION public.enforce_profile_test_segment() FROM PUBLIC, anon, authenticated;

DROP TRIGGER IF EXISTS trg_users_enforce_test_segment ON public.users;
CREATE TRIGGER trg_users_enforce_test_segment
BEFORE INSERT OR UPDATE OF is_test_user ON public.users
FOR EACH ROW EXECUTE FUNCTION public.enforce_profile_test_segment();

UPDATE public.users AS profile
SET is_test_user = COALESCE(public.auth_user_is_test(profile.id), false)
WHERE profile.is_test_user IS DISTINCT FROM
      COALESCE(public.auth_user_is_test(profile.id), false);

-- Discovery projections contain only safe public fields, but test and real
-- profiles must never share the same discovery segment.
ALTER TABLE public.profile_discovery
  ADD COLUMN IF NOT EXISTS is_test_user boolean NOT NULL DEFAULT false;

UPDATE public.profile_discovery AS discovery
SET is_test_user = profile.is_test_user
FROM public.users AS profile
WHERE profile.id = discovery.id
  AND discovery.is_test_user IS DISTINCT FROM profile.is_test_user;

CREATE OR REPLACE FUNCTION public.sync_profile_discovery()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  INSERT INTO public.profile_discovery (
    id, username, display_name, avatar_url, bio, spotify_id,
    onboarding_completed, onboarding_step, created_at, updated_at,
    is_test_user
  ) VALUES (
    NEW.id, NEW.username, NEW.display_name, NEW.avatar_url, NEW.bio,
    NEW.spotify_id, NEW.onboarding_completed, NEW.onboarding_step,
    NEW.created_at, NEW.updated_at, NEW.is_test_user
  )
  ON CONFLICT (id) DO UPDATE SET
    username = EXCLUDED.username,
    display_name = EXCLUDED.display_name,
    avatar_url = EXCLUDED.avatar_url,
    bio = EXCLUDED.bio,
    spotify_id = EXCLUDED.spotify_id,
    onboarding_completed = EXCLUDED.onboarding_completed,
    onboarding_step = EXCLUDED.onboarding_step,
    updated_at = EXCLUDED.updated_at,
    is_test_user = EXCLUDED.is_test_user;
  RETURN NEW;
END;
$$;

REVOKE ALL ON FUNCTION public.sync_profile_discovery() FROM PUBLIC, anon, authenticated;

DROP TRIGGER IF EXISTS trg_users_sync_profile_discovery ON public.users;
CREATE TRIGGER trg_users_sync_profile_discovery
AFTER INSERT OR UPDATE OF username, display_name, avatar_url, bio, spotify_id,
  onboarding_completed, onboarding_step, is_test_user
ON public.users
FOR EACH ROW EXECUTE FUNCTION public.sync_profile_discovery();

CREATE OR REPLACE VIEW public.users_public
WITH (security_invoker = true)
AS SELECT * FROM public.profile_discovery;
REVOKE ALL ON TABLE public.users_public FROM PUBLIC;
GRANT SELECT ON TABLE public.users_public TO authenticated;

DROP POLICY IF EXISTS "profile_discovery_authenticated_read" ON public.profile_discovery;
DROP POLICY IF EXISTS "profile_discovery_same_segment_read" ON public.profile_discovery;
CREATE POLICY "profile_discovery_same_segment_read"
ON public.profile_discovery FOR SELECT TO authenticated
USING (is_test_user = public.current_user_is_test());

DROP POLICY IF EXISTS "music_profile_discovery_authenticated_read" ON public.music_profile_discovery;
DROP POLICY IF EXISTS "music_profile_discovery_same_segment_read" ON public.music_profile_discovery;
CREATE POLICY "music_profile_discovery_same_segment_read"
ON public.music_profile_discovery FOR SELECT TO authenticated
USING (public.user_is_in_current_test_segment(user_id));

-- Synthetic events are hidden from anonymous/real users. Authenticated test
-- users may still see real staging events so mixed-feed behavior can be tested.
DROP POLICY IF EXISTS "events_select_all" ON public.events;
DROP POLICY IF EXISTS "events_select_without_test_data" ON public.events;
CREATE POLICY "events_select_without_test_data"
ON public.events FOR SELECT TO anon, authenticated
USING (NOT is_test_data OR public.current_user_is_test());

DROP POLICY IF EXISTS "events_insert_authenticated" ON public.events;
CREATE POLICY "events_insert_authenticated"
ON public.events FOR INSERT TO authenticated
WITH CHECK (NOT is_test_data);

-- Saved-event rows are private state. This closes the historical data-isolation
-- hole where every authenticated account could enumerate every attendee row.
DROP POLICY IF EXISTS "event_attendees_select_authenticated" ON public.event_attendees;
DROP POLICY IF EXISTS "event_attendees_select_own" ON public.event_attendees;
CREATE POLICY "event_attendees_select_own"
ON public.event_attendees FOR SELECT TO authenticated
USING (user_id = auth.uid());

-- Reject accidental real<->test social edges even when a service job bypasses
-- client-side discovery filters.
CREATE OR REPLACE FUNCTION public.enforce_same_test_segment_edge()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  left_id uuid;
  right_id uuid;
  left_is_test boolean;
  right_is_test boolean;
BEGIN
  CASE TG_TABLE_NAME
    WHEN 'user_matches' THEN
      left_id := NEW.user_id_a; right_id := NEW.user_id_b;
    WHEN 'friendships' THEN
      left_id := NEW.requester_id; right_id := NEW.receiver_id;
    WHEN 'messages' THEN
      left_id := NEW.sender_id; right_id := NEW.receiver_id;
    WHEN 'follows' THEN
      left_id := NEW.follower_id; right_id := NEW.following_id;
    WHEN 'blocked_users' THEN
      left_id := NEW.blocker_id; right_id := NEW.blocked_id;
    ELSE
      RAISE EXCEPTION 'Unsupported segmented edge table: %', TG_TABLE_NAME;
  END CASE;

  -- GDPR erasure may null one side of a historic message.
  IF left_id IS NULL OR right_id IS NULL THEN
    RETURN NEW;
  END IF;

  SELECT is_test_user INTO left_is_test FROM public.users WHERE id = left_id;
  SELECT is_test_user INTO right_is_test FROM public.users WHERE id = right_id;

  IF left_is_test IS NULL OR right_is_test IS NULL THEN
    RAISE EXCEPTION 'Social edge references a missing Vibra profile';
  END IF;

  IF left_is_test IS DISTINCT FROM right_is_test THEN
    RAISE EXCEPTION 'Real and test users cannot share social edges';
  END IF;

  RETURN NEW;
END;
$$;

REVOKE ALL ON FUNCTION public.enforce_same_test_segment_edge() FROM PUBLIC, anon, authenticated;

DROP TRIGGER IF EXISTS trg_user_matches_same_test_segment ON public.user_matches;
CREATE TRIGGER trg_user_matches_same_test_segment
BEFORE INSERT OR UPDATE OF user_id_a, user_id_b ON public.user_matches
FOR EACH ROW EXECUTE FUNCTION public.enforce_same_test_segment_edge();

DROP TRIGGER IF EXISTS trg_friendships_same_test_segment ON public.friendships;
CREATE TRIGGER trg_friendships_same_test_segment
BEFORE INSERT OR UPDATE OF requester_id, receiver_id ON public.friendships
FOR EACH ROW EXECUTE FUNCTION public.enforce_same_test_segment_edge();

DROP TRIGGER IF EXISTS trg_messages_same_test_segment ON public.messages;
CREATE TRIGGER trg_messages_same_test_segment
BEFORE INSERT OR UPDATE OF sender_id, receiver_id ON public.messages
FOR EACH ROW EXECUTE FUNCTION public.enforce_same_test_segment_edge();

DROP TRIGGER IF EXISTS trg_follows_same_test_segment ON public.follows;
CREATE TRIGGER trg_follows_same_test_segment
BEFORE INSERT OR UPDATE OF follower_id, following_id ON public.follows
FOR EACH ROW EXECUTE FUNCTION public.enforce_same_test_segment_edge();

DROP TRIGGER IF EXISTS trg_blocked_users_same_test_segment ON public.blocked_users;
CREATE TRIGGER trg_blocked_users_same_test_segment
BEFORE INSERT OR UPDATE OF blocker_id, blocked_id ON public.blocked_users
FOR EACH ROW EXECUTE FUNCTION public.enforce_same_test_segment_edge();

-- Candidate generation is segmented at the source. The write trigger above is
-- a second line of defence for direct/service-role upserts.
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
    AND candidate_user.is_test_user = target_user.is_test_user
  ORDER BY candidate.embedding <-> p_embedding
  LIMIT LEAST(GREATEST(COALESCE(p_limit, 50), 1), 200);
END;
$$;

REVOKE ALL ON FUNCTION public.find_compatible_users(uuid, vector, int) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.find_compatible_users(uuid, vector, int)
  TO authenticated, service_role;

COMMIT;
