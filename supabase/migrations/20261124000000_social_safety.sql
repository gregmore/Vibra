-- VIBRA Social safety (docs/safety.md): one set of rules everywhere.
--
-- Closes the gaps found in the safety audit:
--  * a blocked person could still follow, send a connection request, be
--    invited to a circle or be saved by the person they blocked (or who
--    blocked them): every one of those writes now refuses a blocked pair;
--  * blocking now removes what connected the two people (follows,
--    connections, pending circle invitations, saved profiles), so nothing
--    keeps them in each other's lists;
--  * reports: no duplicates of the same report within a week, at most 30 a
--    day (on top of the existing 5 a minute).
-- Who blocked whom is never revealed: refusals use one generic message.
BEGIN;

-- True when either of the two blocked the other. Only a yes/no, never who.
CREATE FUNCTION vibra_private.blocked_between(p_a uuid, p_b uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
  SELECT p_a IS NOT NULL AND p_b IS NOT NULL AND EXISTS (
    SELECT 1 FROM public.blocked_users b
    WHERE (b.blocker_id = p_a AND b.blocked_id = p_b) OR (b.blocker_id = p_b AND b.blocked_id = p_a));
$$;
REVOKE ALL ON FUNCTION vibra_private.blocked_between(uuid, uuid) FROM PUBLIC, anon, authenticated;

-- ── Writes that connect two people refuse a blocked pair ──────────────────
CREATE FUNCTION vibra_private.reject_blocked_pair()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE a uuid; b uuid;
BEGIN
  CASE TG_TABLE_NAME
    WHEN 'follows' THEN a := NEW.follower_id; b := NEW.following_id;
    WHEN 'friendships' THEN a := NEW.requester_id; b := NEW.receiver_id;
    WHEN 'circle_invitations' THEN a := NEW.inviter_id; b := NEW.invitee_id;
    WHEN 'saved_profiles' THEN a := NEW.user_id; b := NEW.saved_user_id;
    ELSE RETURN NEW;
  END CASE;
  IF vibra_private.blocked_between(a, b) THEN
    -- Same message whoever blocked: the block itself stays private.
    RAISE insufficient_privilege USING MESSAGE = 'user_unavailable';
  END IF;
  RETURN NEW;
END;
$$;
REVOKE ALL ON FUNCTION vibra_private.reject_blocked_pair() FROM PUBLIC, anon, authenticated;

CREATE TRIGGER trg_follows_reject_blocked BEFORE INSERT ON public.follows
FOR EACH ROW EXECUTE FUNCTION vibra_private.reject_blocked_pair();
CREATE TRIGGER trg_friendships_reject_blocked BEFORE INSERT OR UPDATE OF status ON public.friendships
FOR EACH ROW EXECUTE FUNCTION vibra_private.reject_blocked_pair();
CREATE TRIGGER trg_circle_invitations_reject_blocked BEFORE INSERT ON public.circle_invitations
FOR EACH ROW EXECUTE FUNCTION vibra_private.reject_blocked_pair();
CREATE TRIGGER trg_saved_profiles_reject_blocked BEFORE INSERT ON public.saved_profiles
FOR EACH ROW EXECUTE FUNCTION vibra_private.reject_blocked_pair();

-- ── Blocking removes what connected the two people ────────────────────────
CREATE FUNCTION vibra_private.apply_block()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE a uuid := NEW.blocker_id; b uuid := NEW.blocked_id;
BEGIN
  DELETE FROM public.follows
  WHERE (follower_id = a AND following_id = b) OR (follower_id = b AND following_id = a);
  DELETE FROM public.friendships
  WHERE (requester_id = a AND receiver_id = b) OR (requester_id = b AND receiver_id = a);
  UPDATE public.circle_invitations SET status = 'revoked', responded_at = now()
  WHERE status = 'pending'
    AND ((inviter_id = a AND invitee_id = b) OR (inviter_id = b AND invitee_id = a));
  DELETE FROM public.saved_profiles
  WHERE (user_id = a AND saved_user_id = b) OR (user_id = b AND saved_user_id = a);
  -- Stories: the blocker's stories are hidden by the block itself; nothing
  -- else to clean. Messages, comments and posts stay but are filtered.
  RETURN NULL;
END;
$$;
REVOKE ALL ON FUNCTION vibra_private.apply_block() FROM PUBLIC, anon, authenticated;
CREATE TRIGGER trg_apply_block AFTER INSERT ON public.blocked_users
FOR EACH ROW EXECUTE FUNCTION vibra_private.apply_block();

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
    WHEN 'blocks' THEN 20
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

-- Block and unblock through one server path (rate-limited). The blocked
-- person is not told.
CREATE FUNCTION public.block_user(p_user uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  PERFORM public.require_active_session();
  PERFORM public.consume_action_limit('blocks');
  IF p_user IS NULL OR p_user = auth.uid() THEN
    RAISE invalid_parameter_value USING MESSAGE = 'invalid_user';
  END IF;
  IF (SELECT count(*) FROM public.blocked_users WHERE blocker_id = auth.uid()) >= 5000 THEN
    RAISE check_violation USING MESSAGE = 'block_limit';
  END IF;
  INSERT INTO public.blocked_users (blocker_id, blocked_id) VALUES (auth.uid(), p_user)
  ON CONFLICT DO NOTHING;
END;
$$;
REVOKE ALL ON FUNCTION public.block_user(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.block_user(uuid) TO authenticated;

CREATE FUNCTION public.unblock_user(p_user uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  PERFORM public.require_active_session();
  PERFORM public.consume_action_limit('blocks');
  -- Connections removed by the block are not restored.
  DELETE FROM public.blocked_users WHERE blocker_id = auth.uid() AND blocked_id = p_user;
END;
$$;
REVOKE ALL ON FUNCTION public.unblock_user(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.unblock_user(uuid) TO authenticated;

-- People I blocked (only my own blocks; never who blocked me).
CREATE FUNCTION public.get_my_blocked_users()
RETURNS TABLE (user_id uuid, username text, display_name text, avatar_url text, blocked_at timestamptz)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
  SELECT b.blocked_id, d.username::text, d.display_name, d.avatar_url, b.created_at
  FROM public.blocked_users b
  LEFT JOIN public.profile_discovery d ON d.id = b.blocked_id
  WHERE b.blocker_id = auth.uid()
  ORDER BY b.created_at DESC
  LIMIT 1000;
$$;
REVOKE ALL ON FUNCTION public.get_my_blocked_users() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_my_blocked_users() TO authenticated;

-- ── Reports: no duplicates, a daily cap ───────────────────────────────────
CREATE FUNCTION vibra_private.limit_reports()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v_target text;
BEGIN
  -- SECURITY DEFINER runs as the owner, so the caller is
  -- identified from the request (service role and direct admin writes pass).
  IF COALESCE(auth.role(), '') NOT IN ('authenticated', 'anon') THEN RETURN NEW; END IF;
  -- The reported content (or the person) this report is about.
  v_target := COALESCE(NEW.message_id::text, NEW.community_post_id::text, NEW.community_comment_id::text,
    NEW.circle_message_id::text, NEW.daily_vibe_id::text, NEW.daily_vibe_comment_id::text,
    NEW.music_story_id::text, NEW.music_story_reply_id::text, NEW.feed_post_id::text,
    NEW.feed_comment_id::text, NEW.circle_id::text, 'user');
  IF EXISTS (SELECT 1 FROM public.reports r
      WHERE r.reporter_id = NEW.reporter_id AND r.reported_id = NEW.reported_id
        AND r.created_at > now() - interval '7 days'
        AND COALESCE(r.message_id::text, r.community_post_id::text, r.community_comment_id::text,
          r.circle_message_id::text, r.daily_vibe_id::text, r.daily_vibe_comment_id::text,
          r.music_story_id::text, r.music_story_reply_id::text, r.feed_post_id::text,
          r.feed_comment_id::text, r.circle_id::text, 'user') = v_target) THEN
    RAISE unique_violation USING MESSAGE = 'duplicate_report';
  END IF;
  IF (SELECT count(*) FROM public.reports r
      WHERE r.reporter_id = NEW.reporter_id AND r.created_at > now() - interval '1 day') >= 30 THEN
    RAISE SQLSTATE 'PT429' USING MESSAGE = 'report_daily_limit';
  END IF;
  RETURN NEW;
END;
$$;
REVOKE ALL ON FUNCTION vibra_private.limit_reports() FROM PUBLIC, anon, authenticated;
CREATE TRIGGER trg_limit_reports BEFORE INSERT ON public.reports
FOR EACH ROW EXECUTE FUNCTION vibra_private.limit_reports();

-- ── Safety overview: my own settings in one read ──────────────────────────
CREATE FUNCTION public.get_my_safety_overview()
RETURNS jsonb LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
  SELECT jsonb_build_object(
    'blocked_count', (SELECT count(*) FROM public.blocked_users b WHERE b.blocker_id = auth.uid()),
    'reports_made', (SELECT count(*) FROM public.reports r WHERE r.reporter_id = auth.uid()),
    'location_processing', COALESCE(p.location_processing, false),
    'radar_enabled', COALESCE(p.radar_enabled, false),
    'radar_visible', COALESCE(p.radar_visible, true),
    'musical_dna_visibility', COALESCE(p.musical_dna_visibility, 'private'),
    'attendance_visibility', COALESCE(p.attendance_visibility, 'private'),
    'spotify_matching', COALESCE(p.spotify_matching, false),
    'ai_assistant', COALESCE(p.ai_assistant, false),
    'taste_history', COALESCE(p.taste_history, true),
    'story_default_visibility', COALESCE((SELECT s.default_visibility FROM public.story_settings s WHERE s.user_id = auth.uid()), 'connections'),
    'hidden_story_viewers', (SELECT count(*) FROM public.story_hidden_viewers h WHERE h.owner_id = auth.uid())
  )
  FROM (SELECT auth.uid() AS uid) me
  LEFT JOIN public.privacy_preferences p ON p.user_id = me.uid;
$$;
REVOKE ALL ON FUNCTION public.get_my_safety_overview() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_my_safety_overview() TO authenticated;

NOTIFY pgrst, 'reload schema';
COMMIT;
