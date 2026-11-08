-- VIBRA Notification Center (docs/notification-center.md).
--
-- * One delivery policy for every notification: record_notification()
--   (service role) stores the in-app notification and decides, server-side,
--   whether a push may be sent. All workers go through it.
-- * Ten categories, each with its own push switch (users.push_settings).
--   In-app notifications are always kept; push is the user's choice.
-- * Avoiding excessive notifications:
--     - repeated events are grouped ("3 new comments") instead of stacked;
--     - quiet hours (user time zone) hold pushes, except direct messages;
--     - a daily push cap (default 20), and low-priority categories
--       (communities, recommendations, discoveries, updates) push at most
--       once a day each;
--     - a grouped update does not push again within 30 minutes;
--     - never across a block.
-- * New sources: accepted requests, community comments and replies, people
--   saving a song you shared, recommendations from people you follow.
-- * Push only through the configured provider (FCM, with its service
--   account); without it notifications stay in-app.
BEGIN;

-- ── Notifications: categories, grouping, delivery state ───────────────────
ALTER TABLE public.notifications
  ADD COLUMN IF NOT EXISTS category text,
  ADD COLUMN IF NOT EXISTS group_key text CHECK (char_length(group_key) <= 120),
  ADD COLUMN IF NOT EXISTS group_count integer NOT NULL DEFAULT 1 CHECK (group_count >= 1),
  ADD COLUMN IF NOT EXISTS actor_id uuid REFERENCES public.users(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS push_sent boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS read_at timestamptz;
CREATE INDEX IF NOT EXISTS notifications_group_idx
  ON public.notifications (user_id, group_key, created_at DESC) WHERE group_key IS NOT NULL;
CREATE INDEX IF NOT EXISTS notifications_unread_idx
  ON public.notifications (user_id) WHERE NOT read;

ALTER TABLE public.notifications DROP CONSTRAINT IF EXISTS notifications_type_check;
ALTER TABLE public.notifications ADD CONSTRAINT notifications_type_check CHECK (type IN (
  'event_alert', 'match', 'friend_request', 'message_request', 'chat_message',
  'live_chat', 'ticket_low', 'retention', 'digest', 'artist_concert', 'event_update',
  'circle_invite', 'circle_message', 'circle_plan', 'vibe_comment', 'story_reply', 'feed_comment',
  'request_accepted', 'community_comment', 'community_reply', 'event_reminder',
  'recommendation', 'discovery'
));

-- Every type belongs to one category (the unit of user preference).
CREATE FUNCTION public.notification_category(p_type text)
RETURNS text LANGUAGE sql IMMUTABLE SET search_path = pg_catalog AS $$
  SELECT CASE
    WHEN p_type IN ('friend_request', 'request_accepted') THEN 'requests'
    WHEN p_type IN ('chat_message', 'message_request', 'live_chat') THEN 'messages'
    WHEN p_type IN ('community_comment', 'community_reply') THEN 'communities'
    WHEN p_type IN ('circle_invite', 'circle_message', 'circle_plan') THEN 'circles'
    WHEN p_type IN ('event_alert', 'artist_concert', 'event_update', 'ticket_low') THEN 'concerts'
    WHEN p_type = 'event_reminder' THEN 'reminders'
    WHEN p_type IN ('recommendation', 'match') THEN 'recommendations'
    WHEN p_type IN ('vibe_comment', 'story_reply', 'feed_comment') THEN 'social'
    WHEN p_type = 'discovery' THEN 'discoveries'
    ELSE 'updates' END;
$$;
GRANT EXECUTE ON FUNCTION public.notification_category(text) TO authenticated, service_role;

UPDATE public.notifications SET category = public.notification_category(type) WHERE category IS NULL;
ALTER TABLE public.notifications ALTER COLUMN category SET DEFAULT 'updates';

-- Old per-feature switches become category switches (off stays off).
UPDATE public.users u SET push_settings = u.push_settings || jsonb_strip_nulls(jsonb_build_object(
  'messages', CASE WHEN u.push_settings->>'chat' = 'false' OR u.push_settings->>'live_chat' = 'false' THEN false END,
  'requests', CASE WHEN u.push_settings->>'friend_request' = 'false' THEN false END,
  'recommendations', CASE WHEN u.push_settings->>'match' = 'false' THEN false END,
  'concerts', CASE WHEN u.push_settings->>'event_alert' = 'false' THEN false END,
  'reminders', CASE WHEN u.push_settings->>'event_alert' = 'false' THEN false END,
  'social', CASE WHEN u.push_settings->>'vibes' = 'false' OR u.push_settings->>'stories' = 'false'
    OR u.push_settings->>'feed' = 'false' THEN false END,
  'updates', CASE WHEN u.push_settings->>'retention' = 'false' THEN false END))
WHERE u.push_settings <> '{}'::jsonb;

ALTER TABLE public.notification_preferences
  ADD COLUMN IF NOT EXISTS push_daily_cap smallint NOT NULL DEFAULT 20 CHECK (push_daily_cap BETWEEN 1 AND 100);

-- ── The single delivery policy ────────────────────────────────────────────
-- Stores the notification (grouped with an unread one of the same group in
-- the last 12 hours) and returns whether a push may be sent now.
CREATE FUNCTION public.record_notification(
  p_user uuid, p_type text, p_title text, p_body text,
  p_data jsonb DEFAULT '{}'::jsonb, p_actor uuid DEFAULT NULL, p_group_key text DEFAULT NULL
)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE
  v_category text := public.notification_category(p_type);
  v_id uuid; v_grouped boolean := false; v_count integer := 1; v_last_push timestamptz;
  v_user record; v_pref record; v_push boolean; v_local_hour integer; v_pushed_today integer;
BEGIN
  IF auth.role() IS DISTINCT FROM 'service_role' THEN
    RAISE insufficient_privilege USING MESSAGE = 'Service role required';
  END IF;
  IF p_user IS NULL OR p_user = p_actor THEN RETURN jsonb_build_object('skipped', 'self'); END IF;
  -- Never across a block, whoever blocked.
  IF p_actor IS NOT NULL AND vibra_private.blocked_between(p_user, p_actor) THEN
    RETURN jsonb_build_object('skipped', 'blocked');
  END IF;
  SELECT u.fcm_token, u.push_enabled, COALESCE(u.push_settings, '{}'::jsonb) AS push_settings
  INTO v_user FROM public.users u WHERE u.id = p_user;
  IF NOT FOUND THEN RETURN jsonb_build_object('skipped', 'no_user'); END IF;

  IF p_group_key IS NOT NULL THEN
    SELECT n.id, n.group_count + 1,
      (SELECT max(x.created_at) FROM public.notifications x
        WHERE x.user_id = p_user AND x.group_key = p_group_key AND x.push_sent)
    INTO v_id, v_count, v_last_push
    FROM public.notifications n
    WHERE n.user_id = p_user AND n.group_key = p_group_key AND NOT n.read
      AND n.created_at > now() - interval '12 hours'
    ORDER BY n.created_at DESC LIMIT 1;
    IF v_id IS NOT NULL THEN
      v_grouped := true;
      UPDATE public.notifications SET title = left(p_title, 200), body = left(p_body, 500),
        data = COALESCE(p_data, '{}'::jsonb), group_count = v_count, actor_id = p_actor, created_at = now()
      WHERE id = v_id;
    END IF;
  END IF;
  IF v_id IS NULL THEN
    v_count := 1;
    INSERT INTO public.notifications (user_id, type, category, title, body, data, actor_id, group_key)
    VALUES (p_user, p_type, v_category, left(p_title, 200), left(p_body, 500),
      COALESCE(p_data, '{}'::jsonb), p_actor, p_group_key)
    RETURNING id INTO v_id;
  END IF;

  -- Push decision.
  SELECT COALESCE(p.timezone, 'Europe/Rome') AS tz, COALESCE(p.quiet_hours_start, 22) AS qs,
    COALESCE(p.quiet_hours_end, 8) AS qe, COALESCE(p.push_daily_cap, 20) AS cap
  INTO v_pref FROM (SELECT 1) one
  LEFT JOIN public.notification_preferences p ON p.user_id = p_user;
  v_push := v_user.fcm_token IS NOT NULL AND v_user.push_enabled IS DISTINCT FROM false
    AND (v_user.push_settings->>v_category) IS DISTINCT FROM 'false';
  IF v_push AND v_category <> 'messages' THEN
    BEGIN
      v_local_hour := extract(hour FROM now() AT TIME ZONE v_pref.tz)::integer;
    EXCEPTION WHEN OTHERS THEN
      v_local_hour := extract(hour FROM now() AT TIME ZONE 'Europe/Rome')::integer;
    END;
    IF (v_pref.qs > v_pref.qe AND (v_local_hour >= v_pref.qs OR v_local_hour < v_pref.qe))
       OR (v_pref.qs < v_pref.qe AND v_local_hour >= v_pref.qs AND v_local_hour < v_pref.qe) THEN
      v_push := false;
    END IF;
  END IF;
  IF v_push AND v_grouped AND v_last_push > now() - interval '30 minutes' THEN
    v_push := false;
  END IF;
  IF v_push THEN
    SELECT count(*) INTO v_pushed_today FROM public.notifications n
    WHERE n.user_id = p_user AND n.push_sent AND n.created_at > now() - interval '1 day';
    IF v_pushed_today >= v_pref.cap THEN v_push := false; END IF;
  END IF;
  IF v_push AND v_category IN ('communities', 'recommendations', 'discoveries', 'updates') AND EXISTS (
      SELECT 1 FROM public.notifications n WHERE n.user_id = p_user AND n.category = v_category
        AND n.push_sent AND n.id <> v_id AND n.created_at > now() - interval '1 day') THEN
    v_push := false;
  END IF;
  IF v_push THEN UPDATE public.notifications SET push_sent = true WHERE id = v_id; END IF;
  RETURN jsonb_build_object('id', v_id, 'push', v_push, 'grouped', v_grouped, 'count', v_count,
    'category', v_category, 'token', CASE WHEN v_push THEN v_user.fcm_token END);
END;
$$;
REVOKE ALL ON FUNCTION public.record_notification(uuid, text, text, text, jsonb, uuid, text) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.record_notification(uuid, text, text, text, jsonb, uuid, text) TO service_role;

-- ── Reading and settings (the user's own) ─────────────────────────────────
CREATE FUNCTION public.get_notifications(p_before timestamptz DEFAULT NULL, p_limit integer DEFAULT 50)
RETURNS TABLE (id uuid, type text, category text, title text, body text, data jsonb, read boolean,
  group_count integer, actor_id uuid, actor_name text, actor_avatar text, created_at timestamptz)
LANGUAGE sql STABLE SECURITY INVOKER SET search_path = pg_catalog AS $$
  SELECT n.id, n.type, COALESCE(n.category, public.notification_category(n.type)), n.title, n.body,
    n.data, n.read, n.group_count, n.actor_id,
    COALESCE(NULLIF(btrim(d.display_name), ''), d.username::text), d.avatar_url, n.created_at
  FROM public.notifications n
  LEFT JOIN public.profile_discovery d ON d.id = n.actor_id
  WHERE n.user_id = auth.uid()
    AND (p_before IS NULL OR n.created_at < p_before)
    -- Someone blocked after the notification was sent disappears from it.
    AND (n.actor_id IS NULL OR NOT EXISTS (SELECT 1 FROM public.blocked_users b
      WHERE b.blocker_id = auth.uid() AND b.blocked_id = n.actor_id))
  ORDER BY n.created_at DESC
  LIMIT LEAST(GREATEST(COALESCE(p_limit, 50), 1), 100);
$$;
REVOKE ALL ON FUNCTION public.get_notifications(timestamptz, integer) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_notifications(timestamptz, integer) TO authenticated;

CREATE FUNCTION public.get_unread_notification_count()
RETURNS integer LANGUAGE sql STABLE SECURITY INVOKER SET search_path = pg_catalog AS $$
  SELECT count(*)::integer FROM public.notifications n WHERE n.user_id = auth.uid() AND NOT n.read;
$$;
REVOKE ALL ON FUNCTION public.get_unread_notification_count() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_unread_notification_count() TO authenticated;

-- NULL marks everything read.
CREATE FUNCTION public.mark_notifications_read(p_ids uuid[] DEFAULT NULL)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  PERFORM public.require_active_session();
  UPDATE public.notifications SET read = true, read_at = now()
  WHERE user_id = auth.uid() AND NOT read AND (p_ids IS NULL OR id = ANY (p_ids[1:200]));
END;
$$;
REVOKE ALL ON FUNCTION public.mark_notifications_read(uuid[]) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.mark_notifications_read(uuid[]) TO authenticated;

CREATE FUNCTION public.get_notification_settings()
RETURNS jsonb LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
  SELECT jsonb_build_object(
    'push_enabled', COALESCE(u.push_enabled, true),
    'has_device', u.fcm_token IS NOT NULL,
    'categories', (SELECT jsonb_object_agg(c, (COALESCE(u.push_settings, '{}'::jsonb)->>c) IS DISTINCT FROM 'false')
      FROM unnest(ARRAY['requests', 'messages', 'communities', 'circles', 'concerts', 'reminders',
        'recommendations', 'social', 'discoveries', 'updates']) AS c),
    'quiet_start', COALESCE(p.quiet_hours_start, 22),
    'quiet_end', COALESCE(p.quiet_hours_end, 8),
    'timezone', COALESCE(p.timezone, 'Europe/Rome'),
    'daily_cap', COALESCE(p.push_daily_cap, 20))
  FROM public.users u
  LEFT JOIN public.notification_preferences p ON p.user_id = u.id
  WHERE u.id = auth.uid();
$$;
REVOKE ALL ON FUNCTION public.get_notification_settings() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_notification_settings() TO authenticated;

CREATE FUNCTION public.set_notification_category(p_category text, p_push boolean)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  PERFORM public.require_active_session();
  PERFORM public.consume_action_limit('profile-settings');
  IF p_category NOT IN ('requests', 'messages', 'communities', 'circles', 'concerts', 'reminders',
      'recommendations', 'social', 'discoveries', 'updates') THEN
    RAISE invalid_parameter_value USING MESSAGE = 'invalid_category';
  END IF;
  UPDATE public.users SET push_settings = COALESCE(push_settings, '{}'::jsonb)
    || jsonb_build_object(p_category, COALESCE(p_push, true))
  WHERE id = auth.uid();
END;
$$;
REVOKE ALL ON FUNCTION public.set_notification_category(text, boolean) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.set_notification_category(text, boolean) TO authenticated;

CREATE FUNCTION public.set_notification_schedule(p_quiet_start smallint, p_quiet_end smallint,
  p_timezone text, p_daily_cap smallint)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  PERFORM public.require_active_session();
  PERFORM public.consume_action_limit('profile-settings');
  IF p_timezone IS NOT NULL AND NOT EXISTS (SELECT 1 FROM pg_timezone_names WHERE name = p_timezone) THEN
    RAISE invalid_parameter_value USING MESSAGE = 'invalid_timezone';
  END IF;
  INSERT INTO public.notification_preferences (user_id, quiet_hours_start, quiet_hours_end, timezone, push_daily_cap)
  VALUES (auth.uid(), COALESCE(p_quiet_start, 22), COALESCE(p_quiet_end, 8),
    COALESCE(p_timezone, 'Europe/Rome'), COALESCE(p_daily_cap, 20))
  ON CONFLICT (user_id) DO UPDATE SET
    quiet_hours_start = COALESCE(p_quiet_start, public.notification_preferences.quiet_hours_start),
    quiet_hours_end = COALESCE(p_quiet_end, public.notification_preferences.quiet_hours_end),
    timezone = COALESCE(p_timezone, public.notification_preferences.timezone),
    push_daily_cap = COALESCE(p_daily_cap, public.notification_preferences.push_daily_cap),
    updated_at = now();
END;
$$;
REVOKE ALL ON FUNCTION public.set_notification_schedule(smallint, smallint, text, smallint) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.set_notification_schedule(smallint, smallint, text, smallint) TO authenticated;

-- ── New sources (handled by send-social-notification) ─────────────────────
-- A connection request was accepted: tell the requester.
CREATE FUNCTION public.notify_friendship_accepted()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  IF NEW.status = 'accepted' AND OLD.status IS DISTINCT FROM 'accepted' THEN
    PERFORM vibra_private.enqueue_notification('send-social-notification',
      jsonb_build_object('type', 'UPDATE', 'table', 'friendships', 'schema', 'public', 'record', to_jsonb(NEW)));
  END IF;
  RETURN NEW;
END;
$$;
REVOKE ALL ON FUNCTION public.notify_friendship_accepted() FROM PUBLIC, anon, authenticated;
CREATE TRIGGER friendships_accepted_notify AFTER UPDATE OF status ON public.friendships
FOR EACH ROW EXECUTE FUNCTION public.notify_friendship_accepted();

CREATE TRIGGER community_comments_notify AFTER INSERT ON public.community_comments
FOR EACH ROW EXECUTE FUNCTION public.notify_social_action();

-- Someone saved a song you shared.
CREATE TRIGGER discovery_collection_notify AFTER INSERT ON public.discovery_collection
FOR EACH ROW WHEN (NEW.found_via IS NOT NULL) EXECUTE FUNCTION public.notify_social_action();

-- A public recommendation or discovery from someone you follow.
CREATE TRIGGER feed_posts_recommendation_notify AFTER INSERT ON public.feed_posts
FOR EACH ROW WHEN (NEW.kind IN ('recommendation', 'discovery') AND NEW.visibility = 'everyone')
EXECUTE FUNCTION public.notify_social_action();

-- Followers of a recommender (worker, service role): only people who may see
-- the author, capped.
CREATE FUNCTION public.get_recommendation_audience(p_author uuid, p_limit integer DEFAULT 300)
RETURNS TABLE (user_id uuid)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
  SELECT f.follower_id FROM public.follows f
  JOIN public.users a ON a.id = p_author
  JOIN public.users b ON b.id = f.follower_id
  WHERE auth.role() = 'service_role' AND f.following_id = p_author
    AND a.is_test_user = b.is_test_user
    AND NOT vibra_private.blocked_between(p_author, f.follower_id)
  ORDER BY f.created_at DESC
  LIMIT LEAST(GREATEST(COALESCE(p_limit, 300), 1), 1000);
$$;
REVOKE ALL ON FUNCTION public.get_recommendation_audience(uuid, integer) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_recommendation_audience(uuid, integer) TO service_role;

-- ── Retention ─────────────────────────────────────────────────────────────
CREATE FUNCTION vibra_private.purge_old_notifications()
RETURNS void LANGUAGE sql SECURITY DEFINER SET search_path = pg_catalog AS $$
  DELETE FROM public.notifications WHERE (read AND created_at < now() - interval '90 days')
    OR created_at < now() - interval '180 days';
$$;
REVOKE ALL ON FUNCTION vibra_private.purge_old_notifications() FROM PUBLIC, anon, authenticated;
SELECT cron.schedule('purge-old-notifications', '23 4 * * *', 'SELECT vibra_private.purge_old_notifications();');

NOTIFY pgrst, 'reload schema';
COMMIT;
