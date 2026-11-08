-- VIBRA profile: complete musical identity (docs/profile-identity.md).
--
-- One read, get_profile_identity(user), assembles a profile section by
-- section. Each section has its own visibility, chosen by the owner:
--   public       anyone signed in
--   connections  accepted connections and mutual musical matches
--   private      only me
-- On top of that, every item keeps its own existing rule: Musical DNA its
-- DNA visibility, events each attendance's visibility (Who's Going), posts
-- and vibes their audience, circles only those the viewer is also in.
-- Blocks and test segments always hide the whole profile.
BEGIN;

ALTER TABLE public.privacy_preferences
  ADD COLUMN IF NOT EXISTS profile_sections jsonb NOT NULL DEFAULT '{}'::jsonb
  CHECK (jsonb_typeof(profile_sections) = 'object');

-- The owner's level for one section (defaults when never chosen).
CREATE FUNCTION public.profile_section_level(p_owner uuid, p_section text)
RETURNS text LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
  SELECT COALESCE(
    (SELECT p.profile_sections->>p_section FROM public.privacy_preferences p WHERE p.user_id = p_owner),
    CASE p_section
      WHEN 'saved_songs' THEN 'private'
      WHEN 'events' THEN 'connections'
      WHEN 'circles' THEN 'connections'
      ELSE 'public' END);
$$;
REVOKE ALL ON FUNCTION public.profile_section_level(uuid, text) FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION public.consume_action_limit(p_action text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE maximum integer; used integer;
BEGIN
  PERFORM public.require_active_session();
  IF auth.uid() IS NULL THEN RAISE SQLSTATE 'PT401' USING MESSAGE='Authentication required'; END IF;
  maximum := CASE p_action
    WHEN 'auth_errors_log' THEN 5 WHEN 'reactions' THEN 60 WHEN 'search-events' THEN 30 WHEN 'resolve-event' THEN 20 WHEN 'upload-image' THEN 10 WHEN 'messages' THEN 30 WHEN 'live_messages' THEN 20
    WHEN 'friendships' THEN 10 WHEN 'follows' THEN 20
    WHEN 'reports' THEN 5 WHEN 'support_reports' THEN 5
    WHEN 'spotify-token-exchange' THEN 10 WHEN 'sync-music-profile' THEN 5
    WHEN 'calculate-match' THEN 10 WHEN 'recommend-events' THEN 30
    WHEN 'track-ticket-click' THEN 30 WHEN 'spotify-disconnect' THEN 5
    WHEN 'delete-account' THEN 3 WHEN 'music-radar' THEN 6
    WHEN 'community-create' THEN 2 WHEN 'community-join' THEN 20 WHEN 'community-post' THEN 5
    WHEN 'community-comment' THEN 10 WHEN 'community-reaction' THEN 60 WHEN 'community-moderate' THEN 30
    WHEN 'circle-create' THEN 2 WHEN 'circle-invite' THEN 10 WHEN 'circle-message' THEN 20
    WHEN 'circle-update' THEN 20
    WHEN 'track-search' THEN 20 WHEN 'vibe-comment' THEN 10 WHEN 'vibe-reaction' THEN 60 WHEN 'discovery' THEN 30
    WHEN 'story-reaction' THEN 60 WHEN 'story-reply' THEN 20 WHEN 'story-view' THEN 120
    WHEN 'story-settings' THEN 30
    WHEN 'feed-reaction' THEN 60 WHEN 'feed-comment' THEN 10 WHEN 'feed-bookmark' THEN 30
    WHEN 'feed-seen' THEN 60 WHEN 'feed-read' THEN 60
    WHEN 'ai-assistant' THEN 6 WHEN 'ai-consent' THEN 10
    WHEN 'discover-artists' THEN 6 WHEN 'artist-feedback' THEN 60
    WHEN 'taste-history' THEN 10 WHEN 'profile-settings' THEN 30
    ELSE NULL END;
  IF maximum IS NULL THEN RAISE invalid_parameter_value USING MESSAGE='Unknown action'; END IF;
  INSERT INTO vibra_private.action_limits AS limits VALUES(auth.uid(),p_action,clock_timestamp(),1)
  ON CONFLICT(user_id,action) DO UPDATE SET
    count = CASE WHEN limits.window_start <= clock_timestamp()-interval '1 minute' THEN 1 ELSE limits.count+1 END,
    window_start = CASE WHEN limits.window_start <= clock_timestamp()-interval '1 minute' THEN clock_timestamp() ELSE limits.window_start END
  RETURNING count INTO used;
  IF used > maximum THEN RAISE SQLSTATE 'PT429' USING MESSAGE='Rate limit exceeded'; END IF;
END;
$$;
REVOKE ALL ON FUNCTION public.consume_action_limit(text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.consume_action_limit(text) TO authenticated;

CREATE FUNCTION public.set_profile_section_visibility(p_section text, p_level text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  PERFORM public.require_active_session();
  PERFORM public.consume_action_limit('profile-settings');
  IF p_section NOT IN ('genres', 'artists', 'stats', 'saved_songs', 'playlists', 'events',
      'communities', 'circles', 'activity') THEN
    RAISE invalid_parameter_value USING MESSAGE = 'invalid_section';
  END IF;
  IF p_level NOT IN ('public', 'connections', 'private') THEN
    RAISE invalid_parameter_value USING MESSAGE = 'invalid_level';
  END IF;
  INSERT INTO public.privacy_preferences (user_id, profile_sections)
  VALUES (auth.uid(), jsonb_build_object(p_section, p_level))
  ON CONFLICT (user_id) DO UPDATE SET
    profile_sections = public.privacy_preferences.profile_sections || jsonb_build_object(p_section, p_level),
    updated_at = now();
END;
$$;
REVOKE ALL ON FUNCTION public.set_profile_section_visibility(text, text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.set_profile_section_visibility(text, text) TO authenticated;

CREATE FUNCTION public.get_profile_identity(p_user uuid)
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE
  me uuid := auth.uid();
  v_is_me boolean := p_user = auth.uid();
  v_friend boolean := false;
  v_match boolean := false;
  v_connection boolean := false;
  v_dna jsonb;
  v_profile record;
  v_result jsonb;
BEGIN
  PERFORM public.require_active_session();
  IF me IS NULL THEN RAISE SQLSTATE 'PT401' USING MESSAGE = 'Authentication required'; END IF;
  -- Blocks and test segments hide everything.
  IF NOT v_is_me AND (NOT public.may_access_message(me, p_user) OR NOT EXISTS (
      SELECT 1 FROM public.users a JOIN public.users b ON b.id = p_user
      WHERE a.id = me AND a.is_test_user = b.is_test_user)) THEN
    RETURN NULL;
  END IF;
  SELECT d.username::text AS username, d.display_name, d.avatar_url, d.bio, d.created_at
  INTO v_profile FROM public.profile_discovery d WHERE d.id = p_user;
  IF NOT FOUND THEN RETURN NULL; END IF;

  IF NOT v_is_me THEN
    v_friend := EXISTS (SELECT 1 FROM public.friendships f WHERE f.status = 'accepted'
      AND ((f.requester_id = me AND f.receiver_id = p_user) OR (f.requester_id = p_user AND f.receiver_id = me)));
    v_match := EXISTS (SELECT 1 FROM public.user_matches m
      WHERE m.user_id_a = LEAST(me, p_user) AND m.user_id_b = GREATEST(me, p_user)
        AND public.may_access_music_match(LEAST(me, p_user), GREATEST(me, p_user)));
    v_connection := v_friend OR v_match;
  END IF;
  -- Musical DNA keeps its own visibility setting (get_musical_dna).
  v_dna := public.get_musical_dna(p_user)->'dna';

  WITH lv AS (
    SELECT s.section, public.profile_section_level(p_user, s.section) AS level
    FROM unnest(ARRAY['genres', 'artists', 'stats', 'saved_songs', 'playlists', 'events',
      'communities', 'circles', 'activity']) AS s(section)
  ), allowed AS (
    SELECT lv.section, lv.level,
      (v_is_me OR lv.level = 'public' OR (lv.level = 'connections' AND v_connection)) AS ok
    FROM lv
  )
  SELECT jsonb_build_object(
    'user_id', p_user,
    'is_me', v_is_me,
    'relation', CASE WHEN v_is_me THEN 'me' WHEN v_friend THEN 'connection' WHEN v_match THEN 'match' ELSE 'none' END,
    'username', v_profile.username,
    'display_name', v_profile.display_name,
    'avatar_url', v_profile.avatar_url,
    'bio', v_profile.bio,
    'member_since', v_profile.created_at,
    'dna', CASE WHEN v_dna IS NULL THEN NULL ELSE jsonb_build_object(
      'families', COALESCE(v_dna->'families', '[]'::jsonb),
      'subgenres', COALESCE((SELECT jsonb_agg(x) FROM (SELECT x FROM jsonb_array_elements(COALESCE(v_dna->'subgenres', '[]'::jsonb)) x LIMIT 8) y), '[]'::jsonb),
      'diversity', v_dna->'diversity') END,
    -- Only the owner sees the levels (to edit them).
    'sections', CASE WHEN v_is_me THEN (SELECT jsonb_object_agg(a.section, a.level) FROM allowed a) END,
    'hidden', (SELECT COALESCE(jsonb_agg(a.section), '[]'::jsonb) FROM allowed a WHERE NOT a.ok),

    'genres', CASE WHEN (SELECT ok FROM allowed WHERE section = 'genres') THEN COALESCE((
      SELECT jsonb_agg(g.genre_key ORDER BY g.intensity DESC, g.genre_key)
      FROM public.user_genre_preferences g WHERE g.user_id = p_user), '[]'::jsonb) END,

    'artists', CASE WHEN (SELECT ok FROM allowed WHERE section = 'artists') THEN COALESCE((
      SELECT jsonb_agg(jsonb_build_object('id', a->>'id', 'name', a->>'name') ORDER BY ord)
      FROM public.music_profiles mp, jsonb_array_elements(COALESCE(mp.top_artists, '[]'::jsonb)) WITH ORDINALITY AS t(a, ord)
      WHERE mp.user_id = p_user AND ord <= 10 AND a->>'name' IS NOT NULL), '[]'::jsonb) END,

    'stats', CASE WHEN (SELECT ok FROM allowed WHERE section = 'stats') THEN jsonb_build_object(
      'followers', (SELECT count(*) FROM public.follows f WHERE f.following_id = p_user),
      'following', (SELECT count(*) FROM public.follows f WHERE f.follower_id = p_user),
      'discoveries', (SELECT count(*) FROM public.discovery_collection d WHERE d.user_id = p_user),
      'posts', (SELECT count(*) FROM public.feed_posts p WHERE p.user_id = p_user AND NOT p.held_for_review),
      'communities', (SELECT count(*) FROM public.community_members m WHERE m.user_id = p_user),
      'genres', (SELECT jsonb_array_length(COALESCE(v_dna->'subgenres', '[]'::jsonb))),
      'diversity', (v_dna #>> '{diversity,score}')::integer,
      -- Concerts only for the owner: counting others' attendance could
      -- reveal events they keep private.
      'concerts', CASE WHEN v_is_me THEN (SELECT count(*) FROM public.event_attendees a
        JOIN public.events e ON e.id = a.event_id WHERE a.user_id = p_user AND a.status = 'going' AND e.event_date < now()) END
    ) END,

    'saved_songs', CASE WHEN (SELECT ok FROM allowed WHERE section = 'saved_songs') THEN COALESCE((
      SELECT jsonb_agg(jsonb_build_object('title', d.title, 'artist', d.artist, 'artwork_url', d.artwork_url,
          'external_url', d.external_url, 'provider', d.provider) ORDER BY d.saved_at DESC)
      FROM (SELECT * FROM public.discovery_collection d WHERE d.user_id = p_user ORDER BY d.saved_at DESC LIMIT 8) d), '[]'::jsonb) END,

    -- Playlists they shared in the feed (each post keeps its own audience).
    'playlists', CASE WHEN (SELECT ok FROM allowed WHERE section = 'playlists') THEN COALESCE((
      SELECT jsonb_agg(jsonb_build_object('post_id', p.id, 'title', p.title, 'subtitle', p.subtitle,
          'artwork_url', p.artwork_url, 'external_url', p.external_url, 'provider', p.provider) ORDER BY p.created_at DESC)
      FROM (SELECT * FROM public.feed_posts p WHERE p.user_id = p_user AND p.item_type = 'playlist'
            AND (v_is_me OR public.can_see_feed_post(p.user_id, p.visibility, p.held_for_review))
            ORDER BY p.created_at DESC LIMIT 6) p), '[]'::jsonb) END,

    -- Upcoming events: each attendance's own visibility (Who's Going) applies.
    'events', CASE WHEN (SELECT ok FROM allowed WHERE section = 'events') THEN COALESCE((
      SELECT jsonb_agg(jsonb_build_object('id', e.id, 'name', e.name, 'artist_name', e.artist_name,
          'venue_name', e.venue_name, 'city', e.city, 'event_date', e.event_date, 'image_url', e.image_url,
          'status', a.status) ORDER BY e.event_date)
      FROM public.event_attendees a
      JOIN public.events e ON e.id = a.event_id
      LEFT JOIN public.privacy_preferences pp ON pp.user_id = a.user_id
      WHERE a.user_id = p_user AND a.status IN ('interested', 'maybe', 'going')
        AND e.event_date >= now() AND e.status IS DISTINCT FROM 'canceled'
        AND (v_is_me OR CASE COALESCE(a.visibility, pp.attendance_visibility, 'private')
          WHEN 'public' THEN true WHEN 'friends' THEN v_friend WHEN 'matches' THEN v_connection ELSE false END)
      ), '[]'::jsonb) END,

    'communities', CASE WHEN (SELECT ok FROM allowed WHERE section = 'communities') THEN COALESCE((
      SELECT jsonb_agg(jsonb_build_object('id', c.id, 'name', c.name, 'kind', c.kind, 'role', m.role,
          'member_count', c.member_count) ORDER BY m.joined_at DESC)
      FROM public.community_members m JOIN public.communities c ON c.id = m.community_id
      WHERE m.user_id = p_user AND c.archived_at IS NULL), '[]'::jsonb) END,

    -- Circles are private groups: others only see circles they are in too.
    'circles', CASE WHEN (SELECT ok FROM allowed WHERE section = 'circles') THEN COALESCE((
      SELECT jsonb_agg(jsonb_build_object('id', c.id, 'name', c.name, 'basis', c.basis,
          'members', (SELECT count(*) FROM public.circle_members x WHERE x.circle_id = c.id)) ORDER BY m.joined_at DESC)
      FROM public.circle_members m JOIN public.circles c ON c.id = m.circle_id
      WHERE m.user_id = p_user
        AND (v_is_me OR EXISTS (SELECT 1 FROM public.circle_members v WHERE v.circle_id = c.id AND v.user_id = me))
      ), '[]'::jsonb) END,

    -- Recent musical activity, each item under its own audience rule.
    'activity', CASE WHEN (SELECT ok FROM allowed WHERE section = 'activity') THEN COALESCE((
      SELECT jsonb_agg(x ORDER BY (x->>'at') DESC) FROM (
        (SELECT jsonb_build_object('type', 'post', 'id', p.id, 'kind', p.kind,
            'title', COALESCE(p.title, left(p.body, 80)), 'at', p.created_at) AS x
         FROM public.feed_posts p WHERE p.user_id = p_user
           AND (v_is_me OR public.can_see_feed_post(p.user_id, p.visibility, p.held_for_review))
         ORDER BY p.created_at DESC LIMIT 5)
        UNION ALL
        (SELECT jsonb_build_object('type', 'vibe', 'id', v.id, 'title', v.title, 'subtitle', v.artist, 'at', v.created_at)
         FROM public.daily_vibes v WHERE v.user_id = p_user
           AND (v_is_me OR public.can_see_daily_vibe(v.user_id, v.visibility, v.expires_at, v.held_for_review))
         ORDER BY v.created_at DESC LIMIT 2)
        UNION ALL
        (SELECT jsonb_build_object('type', 'community', 'id', c.id, 'title', c.name, 'at', m.joined_at)
         FROM public.community_members m JOIN public.communities c ON c.id = m.community_id
         WHERE m.user_id = p_user AND c.archived_at IS NULL
           AND (SELECT ok FROM allowed WHERE section = 'communities')
         ORDER BY m.joined_at DESC LIMIT 3)
      ) items
    ), '[]'::jsonb) END
  ) INTO v_result;
  RETURN v_result;
END;
$$;
REVOKE ALL ON FUNCTION public.get_profile_identity(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_profile_identity(uuid) TO authenticated;

NOTIFY pgrst, 'reload schema';
COMMIT;
