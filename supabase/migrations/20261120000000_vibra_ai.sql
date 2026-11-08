-- VIBRA AI (docs/vibra-ai.md): the optional personal music assistant.
--
-- * Off by default. It runs only after the user explicitly allows it, because
--   their music profile is sent to an external AI provider to answer. The
--   choice is stored here and can be withdrawn at any time.
-- * Conversations are not stored: the app keeps them on the device and
--   sends the recent turns with each question.
-- * 6 questions a minute and 40 a day per user.
-- * Nothing in VIBRA depends on this: with no AI provider configured, the
--   vibra-ai function reports itself unavailable and every other feature
--   works as before.
BEGIN;

ALTER TABLE public.privacy_preferences
  ADD COLUMN IF NOT EXISTS ai_assistant boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS ai_assistant_consented_at timestamptz;

CREATE FUNCTION public.set_ai_assistant_consent(p_enabled boolean)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  PERFORM public.require_active_session();
  PERFORM public.consume_action_limit('ai-consent');
  INSERT INTO public.privacy_preferences (user_id, ai_assistant, ai_assistant_consented_at)
  VALUES (auth.uid(), COALESCE(p_enabled, false), CASE WHEN p_enabled THEN now() END)
  ON CONFLICT (user_id) DO UPDATE SET
    ai_assistant = EXCLUDED.ai_assistant,
    ai_assistant_consented_at = EXCLUDED.ai_assistant_consented_at,
    updated_at = now();
END;
$$;
REVOKE ALL ON FUNCTION public.set_ai_assistant_consent(boolean) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.set_ai_assistant_consent(boolean) TO authenticated;

CREATE TABLE vibra_private.ai_assistant_usage (
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  used_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ai_assistant_usage_idx ON vibra_private.ai_assistant_usage (user_id, used_at);
REVOKE ALL ON vibra_private.ai_assistant_usage FROM PUBLIC, anon, authenticated;

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

-- Called (as the user) by the vibra-ai Edge Function before every question:
-- requires consent, applies the limits, records only the time of use.
CREATE FUNCTION public.begin_ai_assistant_request()
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  PERFORM public.require_active_session();
  IF NOT COALESCE((SELECT p.ai_assistant FROM public.privacy_preferences p WHERE p.user_id = auth.uid()), false) THEN
    RAISE insufficient_privilege USING MESSAGE = 'ai_consent_required';
  END IF;
  PERFORM public.consume_action_limit('ai-assistant');
  PERFORM 1 FROM public.users WHERE id = auth.uid() FOR UPDATE;
  IF (SELECT count(*) FROM vibra_private.ai_assistant_usage
      WHERE user_id = auth.uid() AND used_at > now() - interval '1 day') >= 40 THEN
    RAISE SQLSTATE 'PT429' USING MESSAGE = 'ai_daily_limit';
  END IF;
  INSERT INTO vibra_private.ai_assistant_usage (user_id) VALUES (auth.uid());
END;
$$;
REVOKE ALL ON FUNCTION public.begin_ai_assistant_request() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.begin_ai_assistant_request() TO authenticated;

CREATE FUNCTION vibra_private.purge_ai_assistant_usage()
RETURNS void LANGUAGE sql SECURITY DEFINER SET search_path = pg_catalog AS $$
  DELETE FROM vibra_private.ai_assistant_usage WHERE used_at < now() - interval '2 days';
$$;
REVOKE ALL ON FUNCTION vibra_private.purge_ai_assistant_usage() FROM PUBLIC, anon, authenticated;
SELECT cron.schedule('purge-ai-assistant-usage', '51 4 * * *', 'SELECT vibra_private.purge_ai_assistant_usage();');

NOTIFY pgrst, 'reload schema';
COMMIT;
