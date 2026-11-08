-- VIBRA "Discover my next artist" (docs/artist-discovery.md).
--
-- * artist_feedback: what the user said about a recommended artist: like,
--   not interested, already known, and/or saved for later. Not-interested
--   and known artists are never recommended again.
-- * artist_recommendations: the user's current recommendations, computed
--   by the discover-artists Edge Function from Spotify's catalogue (app
--   credentials), their Musical DNA, top artists, discoveries and feedback.
--   Cached so Spotify is not called on every visit; how often each was
--   shown is kept so the same artist does not keep coming back unanswered.
BEGIN;

CREATE TABLE public.artist_feedback (
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  artist_id text NOT NULL CHECK (artist_id ~ '^[A-Za-z0-9]{22}$'),
  artist_name text NOT NULL CHECK (char_length(artist_name) BETWEEN 1 AND 200),
  reaction text CHECK (reaction IN ('like', 'not_interested', 'known')),
  saved boolean NOT NULL DEFAULT false,
  genre_keys text[] NOT NULL DEFAULT '{}' CHECK (cardinality(genre_keys) <= 12),
  image_url text CHECK (image_url ~ '^https://(i\.scdn\.co|mosaic\.scdn\.co|image-cdn-[a-z0-9]+\.spotifycdn\.com)/'),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, artist_id),
  -- "Not interested" is never also saved.
  CHECK (NOT (saved AND reaction = 'not_interested'))
);
CREATE INDEX artist_feedback_saved_idx ON public.artist_feedback (user_id, updated_at DESC) WHERE saved;

CREATE TABLE public.artist_recommendations (
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  artist_id text NOT NULL CHECK (artist_id ~ '^[A-Za-z0-9]{22}$'),
  name text NOT NULL CHECK (char_length(name) BETWEEN 1 AND 200),
  image_url text CHECK (image_url ~ '^https://(i\.scdn\.co|mosaic\.scdn\.co|image-cdn-[a-z0-9]+\.spotifycdn\.com)/'),
  genres text[] NOT NULL DEFAULT '{}' CHECK (cardinality(genres) <= 10),
  genre_keys text[] NOT NULL DEFAULT '{}' CHECK (cardinality(genre_keys) <= 12),
  popularity smallint CHECK (popularity BETWEEN 0 AND 100),
  followers integer CHECK (followers >= 0),
  bucket text NOT NULL CHECK (bucket IN ('similar', 'collaboration', 'emerging', 'underground', 'exploration')),
  -- Why (facts only): seed_artist, shared_genres, explored_genre.
  reason jsonb NOT NULL DEFAULT '{}'::jsonb CHECK (jsonb_typeof(reason) = 'object'),
  score real NOT NULL DEFAULT 0,
  position smallint NOT NULL DEFAULT 0,
  shown_count integer NOT NULL DEFAULT 0 CHECK (shown_count >= 0),
  last_shown_at timestamptz,
  generated_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, artist_id)
);

ALTER TABLE public.artist_feedback ENABLE ROW LEVEL SECURITY;
CREATE POLICY artist_feedback_owner ON public.artist_feedback FOR SELECT TO authenticated
  USING (user_id = (SELECT auth.uid()));
ALTER TABLE public.artist_recommendations ENABLE ROW LEVEL SECURITY;
CREATE POLICY artist_recommendations_owner ON public.artist_recommendations FOR SELECT TO authenticated
  USING (user_id = (SELECT auth.uid()));
REVOKE ALL ON public.artist_feedback, public.artist_recommendations FROM PUBLIC, anon, authenticated;
GRANT SELECT ON public.artist_feedback, public.artist_recommendations TO authenticated;
GRANT ALL ON public.artist_feedback, public.artist_recommendations TO service_role;

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

-- Records feedback on an artist. p_reaction: 'like' | 'not_interested' |
-- 'known' | NULL (clear); p_saved: save for later (NULL keeps it).
-- The artist must be one VIBRA recommended to this user (or already in
-- their feedback), so names and genres come from Spotify, not the client.
CREATE FUNCTION public.set_artist_feedback(p_artist text, p_reaction text, p_saved boolean DEFAULT NULL)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE r public.artist_recommendations%ROWTYPE; f public.artist_feedback%ROWTYPE;
  v_saved boolean;
BEGIN
  PERFORM public.require_active_session();
  PERFORM public.consume_action_limit('artist-feedback');
  IF p_reaction IS NOT NULL AND p_reaction NOT IN ('like', 'not_interested', 'known') THEN
    RAISE invalid_parameter_value USING MESSAGE = 'invalid_reaction';
  END IF;
  SELECT * INTO r FROM public.artist_recommendations WHERE user_id = auth.uid() AND artist_id = p_artist;
  SELECT * INTO f FROM public.artist_feedback WHERE user_id = auth.uid() AND artist_id = p_artist;
  IF r.artist_id IS NULL AND f.artist_id IS NULL THEN
    RAISE no_data_found USING MESSAGE = 'artist_not_recommended';
  END IF;
  v_saved := CASE WHEN p_reaction = 'not_interested' THEN false
    ELSE COALESCE(p_saved, f.saved, false) END;
  IF p_reaction IS NULL AND NOT v_saved THEN
    DELETE FROM public.artist_feedback WHERE user_id = auth.uid() AND artist_id = p_artist;
    RETURN;
  END IF;
  INSERT INTO public.artist_feedback (user_id, artist_id, artist_name, reaction, saved, genre_keys, image_url)
  VALUES (auth.uid(), p_artist, COALESCE(r.name, f.artist_name), p_reaction, v_saved,
    COALESCE(r.genre_keys, f.genre_keys, '{}'), COALESCE(r.image_url, f.image_url))
  ON CONFLICT (user_id, artist_id) DO UPDATE SET
    reaction = EXCLUDED.reaction, saved = EXCLUDED.saved, updated_at = now();
END;
$$;
REVOKE ALL ON FUNCTION public.set_artist_feedback(text, text, boolean) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.set_artist_feedback(text, text, boolean) TO authenticated;

-- The app showed these recommendations (an unanswered artist cools down).
CREATE FUNCTION public.mark_artist_recommendations_shown(p_artists text[])
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  PERFORM public.require_active_session();
  PERFORM public.consume_action_limit('artist-feedback');
  UPDATE public.artist_recommendations SET
    shown_count = shown_count + CASE WHEN last_shown_at IS NULL OR last_shown_at < now() - interval '6 hours' THEN 1 ELSE 0 END,
    last_shown_at = CASE WHEN last_shown_at IS NULL OR last_shown_at < now() - interval '6 hours' THEN now() ELSE last_shown_at END
  WHERE user_id = auth.uid() AND artist_id = ANY (p_artists[1:50]);
END;
$$;
REVOKE ALL ON FUNCTION public.mark_artist_recommendations_shown(text[]) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.mark_artist_recommendations_shown(text[]) TO authenticated;

-- Replaces the user's recommendations (service role: discover-artists).
-- Times shown carry over for artists that stay, so repetition is tracked
-- across refreshes. Artists with "not interested" or "known" are refused.
CREATE FUNCTION public.save_artist_recommendations(p_user_id uuid, p_rows jsonb)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  IF auth.role() IS DISTINCT FROM 'service_role' THEN
    RAISE insufficient_privilege USING MESSAGE = 'Service role required';
  END IF;
  IF jsonb_typeof(p_rows) <> 'array' OR jsonb_array_length(p_rows) > 60 THEN
    RAISE invalid_parameter_value USING MESSAGE = 'invalid_rows';
  END IF;
  WITH incoming AS (
    SELECT x.artist_id, x.name, x.image_url, COALESCE(x.genres, '{}') AS genres,
      COALESCE(x.genre_keys, '{}') AS genre_keys, x.popularity, x.followers, x.bucket,
      COALESCE(x.reason, '{}'::jsonb) AS reason, COALESCE(x.score, 0) AS score, (x.ord - 1)::smallint AS position
    FROM jsonb_to_recordset(p_rows) WITH ORDINALITY AS x(artist_id text, name text, image_url text, genres text[],
      genre_keys text[], popularity smallint, followers integer, bucket text, reason jsonb, score real, ord bigint)
    WHERE NOT EXISTS (SELECT 1 FROM public.artist_feedback f WHERE f.user_id = p_user_id
      AND f.artist_id = x.artist_id AND f.reaction IN ('not_interested', 'known'))
  ), removed AS (
    DELETE FROM public.artist_recommendations r WHERE r.user_id = p_user_id
      AND NOT EXISTS (SELECT 1 FROM incoming i WHERE i.artist_id = r.artist_id)
  )
  INSERT INTO public.artist_recommendations (user_id, artist_id, name, image_url, genres, genre_keys,
    popularity, followers, bucket, reason, score, position, generated_at)
  SELECT p_user_id, i.artist_id, i.name, i.image_url, i.genres[1:10], i.genre_keys[1:12], i.popularity,
    i.followers, i.bucket, i.reason, i.score, i.position, now()
  FROM incoming i
  ON CONFLICT (user_id, artist_id) DO UPDATE SET
    name = EXCLUDED.name, image_url = EXCLUDED.image_url, genres = EXCLUDED.genres,
    genre_keys = EXCLUDED.genre_keys, popularity = EXCLUDED.popularity, followers = EXCLUDED.followers,
    bucket = EXCLUDED.bucket, reason = EXCLUDED.reason, score = EXCLUDED.score,
    position = EXCLUDED.position, generated_at = now();
END;
$$;
REVOKE ALL ON FUNCTION public.save_artist_recommendations(uuid, jsonb) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.save_artist_recommendations(uuid, jsonb) TO service_role;

-- Engine input (service role): everything the engine may use, for one user.
CREATE FUNCTION public.get_artist_discovery_input(p_user_id uuid)
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  IF auth.role() IS DISTINCT FROM 'service_role' THEN
    RAISE insufficient_privilege USING MESSAGE = 'Service role required';
  END IF;
  RETURN jsonb_build_object(
    'top_artists', COALESCE((SELECT mp.top_artists FROM public.music_profiles mp WHERE mp.user_id = p_user_id), '[]'::jsonb),
    'dna', (SELECT s.dna - 'sources' FROM public.musical_dna_snapshots s WHERE s.user_id = p_user_id ORDER BY s.captured_on DESC LIMIT 1),
    'picked_genres', COALESCE((SELECT jsonb_agg(g.genre_key) FROM public.user_genre_preferences g WHERE g.user_id = p_user_id), '[]'::jsonb),
    'discovered_artists', COALESCE((SELECT jsonb_agg(DISTINCT lower(d.artist)) FROM public.discovery_collection d WHERE d.user_id = p_user_id), '[]'::jsonb),
    'feedback', COALESCE((SELECT jsonb_agg(jsonb_build_object('artist_id', f.artist_id, 'name', f.artist_name,
        'reaction', f.reaction, 'saved', f.saved, 'genre_keys', f.genre_keys)) FROM public.artist_feedback f WHERE f.user_id = p_user_id), '[]'::jsonb),
    'shown', COALESCE((SELECT jsonb_object_agg(r.artist_id, r.shown_count) FROM public.artist_recommendations r WHERE r.user_id = p_user_id), '{}'::jsonb),
    'generated_at', (SELECT max(r.generated_at) FROM public.artist_recommendations r WHERE r.user_id = p_user_id)
  );
END;
$$;
REVOKE ALL ON FUNCTION public.get_artist_discovery_input(uuid) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_artist_discovery_input(uuid) TO service_role;

-- What the app shows: current recommendations without any the user
-- answered "not interested" or "known".
CREATE FUNCTION public.get_artist_recommendations()
RETURNS TABLE (artist_id text, name text, image_url text, genres text[], genre_keys text[],
  popularity smallint, followers integer, bucket text, reason jsonb, reaction text, saved boolean,
  generated_at timestamptz)
LANGUAGE sql STABLE SECURITY INVOKER SET search_path = pg_catalog AS $$
  SELECT r.artist_id, r.name, r.image_url, r.genres, r.genre_keys, r.popularity, r.followers,
    r.bucket, r.reason, f.reaction, COALESCE(f.saved, false), r.generated_at
  FROM public.artist_recommendations r
  LEFT JOIN public.artist_feedback f ON f.user_id = r.user_id AND f.artist_id = r.artist_id
  WHERE r.user_id = auth.uid()
    AND f.reaction IS DISTINCT FROM 'not_interested' AND f.reaction IS DISTINCT FROM 'known'
  ORDER BY r.position
  LIMIT 60;
$$;
REVOKE ALL ON FUNCTION public.get_artist_recommendations() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_artist_recommendations() TO authenticated;

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
    'same_frequency_views', COALESCE((SELECT jsonb_agg(to_jsonb(v) ORDER BY v.last_shown_at) FROM public.same_frequency_views v WHERE v.user_id = uid), '[]'::jsonb),
    'music_radar_position', (SELECT jsonb_build_object(
        'cell_center_latitude', public.ST_Y(r.center::public.geometry),
        'cell_center_longitude', public.ST_X(r.center::public.geometry),
        'precision', r.precision, 'anchored_at', r.anchored_at, 'located_at', r.located_at)
      FROM vibra_private.radar_presence r WHERE r.user_id = uid),
    'community_memberships', COALESCE((SELECT jsonb_agg(to_jsonb(m) ORDER BY m.joined_at) FROM public.community_members m WHERE m.user_id = uid), '[]'::jsonb),
    'community_posts', COALESCE((SELECT jsonb_agg(to_jsonb(p) ORDER BY p.created_at) FROM public.community_posts p WHERE p.author_id = uid), '[]'::jsonb),
    'community_comments', COALESCE((SELECT jsonb_agg(to_jsonb(c) ORDER BY c.created_at) FROM public.community_comments c WHERE c.author_id = uid), '[]'::jsonb),
    'community_reactions', COALESCE((SELECT jsonb_agg(to_jsonb(r) ORDER BY r.created_at) FROM public.community_reactions r WHERE r.user_id = uid), '[]'::jsonb),
    'circle_memberships', COALESCE((SELECT jsonb_agg(to_jsonb(m) ORDER BY m.joined_at) FROM public.circle_members m WHERE m.user_id = uid), '[]'::jsonb),
    'circle_invitations', COALESCE((SELECT jsonb_agg(to_jsonb(i) ORDER BY i.created_at) FROM public.circle_invitations i WHERE i.inviter_id = uid OR i.invitee_id = uid), '[]'::jsonb),
    'circle_messages', COALESCE((SELECT jsonb_agg(to_jsonb(x) ORDER BY x.created_at) FROM public.circle_messages x WHERE x.sender_id = uid), '[]'::jsonb),
    'circle_playlist_items', COALESCE((SELECT jsonb_agg(to_jsonb(p) ORDER BY p.created_at) FROM public.circle_playlist_items p WHERE p.added_by = uid), '[]'::jsonb),
    'circle_plans', COALESCE((SELECT jsonb_agg(to_jsonb(p) ORDER BY p.created_at) FROM public.circle_plans p WHERE p.created_by = uid), '[]'::jsonb),
    'circle_plan_participation', COALESCE((SELECT jsonb_agg(to_jsonb(x) ORDER BY x.created_at) FROM public.circle_plan_participants x WHERE x.user_id = uid), '[]'::jsonb),
    'daily_vibes', COALESCE((SELECT jsonb_agg(to_jsonb(v) ORDER BY v.created_at) FROM public.daily_vibes v WHERE v.user_id = uid), '[]'::jsonb),
    'daily_vibe_comments', COALESCE((SELECT jsonb_agg(to_jsonb(c) ORDER BY c.created_at) FROM public.daily_vibe_comments c WHERE c.author_id = uid), '[]'::jsonb),
    'daily_vibe_reactions', COALESCE((SELECT jsonb_agg(to_jsonb(r) ORDER BY r.created_at) FROM public.daily_vibe_reactions r WHERE r.user_id = uid), '[]'::jsonb),
    'discovery_collection', COALESCE((SELECT jsonb_agg(to_jsonb(d) ORDER BY d.saved_at) FROM public.discovery_collection d WHERE d.user_id = uid), '[]'::jsonb),
    'music_stories', COALESCE((SELECT jsonb_agg(to_jsonb(s) ORDER BY s.created_at) FROM public.music_stories s WHERE s.user_id = uid), '[]'::jsonb),
    'music_story_reactions', COALESCE((SELECT jsonb_agg(to_jsonb(r) ORDER BY r.created_at) FROM public.music_story_reactions r WHERE r.user_id = uid), '[]'::jsonb),
    'music_story_replies', COALESCE((SELECT jsonb_agg(to_jsonb(r) ORDER BY r.created_at) FROM public.music_story_replies r WHERE r.sender_id = uid OR r.recipient_id = uid), '[]'::jsonb),
    'music_story_views', COALESCE((SELECT jsonb_agg(to_jsonb(v) ORDER BY v.viewed_at) FROM public.music_story_views v WHERE v.viewer_id = uid), '[]'::jsonb),
    'story_settings', (SELECT to_jsonb(s) FROM public.story_settings s WHERE s.user_id = uid),
    'story_hidden_viewers', COALESCE((SELECT jsonb_agg(to_jsonb(h) ORDER BY h.created_at) FROM public.story_hidden_viewers h WHERE h.owner_id = uid), '[]'::jsonb),
    'story_mutes', COALESCE((SELECT jsonb_agg(to_jsonb(m) ORDER BY m.created_at) FROM public.story_mutes m WHERE m.user_id = uid), '[]'::jsonb),
    'feed_posts', COALESCE((SELECT jsonb_agg(to_jsonb(p) ORDER BY p.created_at) FROM public.feed_posts p WHERE p.user_id = uid), '[]'::jsonb),
    'feed_comments', COALESCE((SELECT jsonb_agg(to_jsonb(c) ORDER BY c.created_at) FROM public.feed_comments c WHERE c.author_id = uid), '[]'::jsonb),
    'feed_reactions', COALESCE((SELECT jsonb_agg(to_jsonb(r) ORDER BY r.created_at) FROM public.feed_post_reactions r WHERE r.user_id = uid), '[]'::jsonb),
    'feed_bookmarks', COALESCE((SELECT jsonb_agg(to_jsonb(b) ORDER BY b.created_at) FROM public.feed_bookmarks b WHERE b.user_id = uid), '[]'::jsonb),
    'feed_impressions', COALESCE((SELECT jsonb_agg(to_jsonb(i) ORDER BY i.last_shown_at) FROM public.feed_impressions i WHERE i.user_id = uid), '[]'::jsonb),
    'artist_feedback', COALESCE((SELECT jsonb_agg(to_jsonb(f) ORDER BY f.updated_at) FROM public.artist_feedback f WHERE f.user_id = uid), '[]'::jsonb),
    'artist_recommendations', COALESCE((SELECT jsonb_agg(to_jsonb(r) ORDER BY r.position) FROM public.artist_recommendations r WHERE r.user_id = uid), '[]'::jsonb)
  );
END;
$$;
REVOKE ALL ON FUNCTION public.export_my_personal_data() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.export_my_personal_data() TO authenticated;

NOTIFY pgrst, 'reload schema';
COMMIT;
