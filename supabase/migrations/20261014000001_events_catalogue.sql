BEGIN;
-- Coarse areas of public event discovery, shared across callers. No identities,
-- device-location history, provider credentials or private profile data.
CREATE TABLE public.event_provider_search_cache (
  cache_key text PRIMARY KEY CHECK (char_length(cache_key) BETWEEN 5 AND 100),
  attempted_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  succeeded_at timestamptz
);
ALTER TABLE public.event_provider_search_cache ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.event_provider_search_cache FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.event_provider_search_cache TO service_role;
CREATE FUNCTION public.claim_event_provider_search(p_cache_key text)
RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  IF p_cache_key IS NULL OR p_cache_key !~ '^-?[0-9.]+:-?[0-9.]+:[0-9]+$' OR char_length(p_cache_key)>100 THEN
    RAISE invalid_parameter_value USING MESSAGE='Invalid event search area';
  END IF;
  INSERT INTO public.event_provider_search_cache AS c(cache_key) VALUES(p_cache_key)
  ON CONFLICT(cache_key) DO UPDATE SET attempted_at=clock_timestamp()
    WHERE c.attempted_at<clock_timestamp()-interval '1 minute'
      AND (c.succeeded_at IS NULL OR c.succeeded_at<clock_timestamp()-interval '15 minutes');
  RETURN FOUND;
END;
$$;
REVOKE ALL ON FUNCTION public.claim_event_provider_search(text) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.claim_event_provider_search(text) TO service_role;

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
    WHEN 'delete-account' THEN 3 ELSE NULL END;
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


CREATE FUNCTION vibra_private.enqueue_catalogue_sync()
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE endpoint text; credential text;
BEGIN
  DELETE FROM public.event_provider_search_cache WHERE attempted_at<clock_timestamp()-interval '2 days';
  SELECT decrypted_secret INTO endpoint FROM vault.decrypted_secrets WHERE name='vibra_functions_url';
  SELECT decrypted_secret INTO credential FROM vault.decrypted_secrets WHERE name='vibra_service_role_key';
  IF endpoint IS NULL OR credential IS NULL THEN RETURN; END IF;
  PERFORM net.http_post(url:=rtrim(endpoint,'/')||'/ticketmaster-sync',
    headers:=jsonb_build_object('Content-Type','application/json','Authorization','Bearer '||credential),
    body:='{"country_codes":["IT"]}'::jsonb, timeout_milliseconds:=120000);
END;
$$;
REVOKE ALL ON FUNCTION vibra_private.enqueue_catalogue_sync() FROM PUBLIC, anon, authenticated;
SELECT cron.schedule('invoke-ticketmaster-sync','25 */6 * * *',
  'SELECT vibra_private.enqueue_catalogue_sync();');
NOTIFY pgrst,'reload schema';
COMMIT;
