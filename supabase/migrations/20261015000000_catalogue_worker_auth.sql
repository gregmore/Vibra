BEGIN;

-- A dedicated job credential avoids depending on the legacy project JWT used
-- by service-role clients. The credential stays encrypted in Vault and is
-- resolved only when the existing catalogue cron job runs.
CREATE OR REPLACE FUNCTION vibra_private.enqueue_catalogue_sync()
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE endpoint text; credential text;
BEGIN
  DELETE FROM public.event_provider_search_cache WHERE attempted_at<clock_timestamp()-interval '2 days';
  SELECT decrypted_secret INTO endpoint FROM vault.decrypted_secrets WHERE name='vibra_functions_url';
  SELECT decrypted_secret INTO credential FROM vault.decrypted_secrets WHERE name='vibra_catalogue_job_secret';
  IF NULLIF(btrim(endpoint), '') IS NULL OR NULLIF(btrim(credential), '') IS NULL THEN RETURN; END IF;
  PERFORM net.http_post(url:=rtrim(endpoint,'/')||'/ticketmaster-sync',
    headers:=jsonb_build_object('Content-Type','application/json','x-vibra-job-secret',credential),
    body:='{"country_codes":["IT"]}'::jsonb, timeout_milliseconds:=120000);
END;
$$;

-- CREATE OR REPLACE preserves the helper's existing owner, private ACL and
-- cron schedule. No credential is embedded in the function or cron command.
COMMIT;
