BEGIN;
\ir ../pgtap_setup.inc
SELECT plan(30);

SELECT ok((SELECT prosecdef FROM pg_proc WHERE oid='vibra_private.enqueue_catalogue_sync()'::regprocedure),
  'The private cron helper retains its security-definer execution');
SELECT ok((SELECT proconfig=ARRAY['search_path=pg_catalog'] FROM pg_proc
  WHERE oid='vibra_private.enqueue_catalogue_sync()'::regprocedure),
  'The helper keeps its locked search path');
SELECT ok(NOT has_function_privilege('anon', 'vibra_private.enqueue_catalogue_sync()', 'EXECUTE'),
  'Anonymous callers cannot invoke the catalogue cron helper');
SELECT ok(NOT has_function_privilege('authenticated', 'vibra_private.enqueue_catalogue_sync()', 'EXECUTE'),
  'Authenticated callers cannot invoke the catalogue cron helper');
SELECT ok(NOT has_function_privilege('service_role', 'vibra_private.enqueue_catalogue_sync()', 'EXECUTE'),
  'The dedicated cron helper is not exposed to service-role API callers');
SELECT ok(position('vault.decrypted_secrets' IN pg_get_functiondef('vibra_private.enqueue_catalogue_sync()'::regprocedure))>0,
  'The job credential is read from Vault at execution time');
SELECT ok(position('vibra_catalogue_job_secret' IN pg_get_functiondef('vibra_private.enqueue_catalogue_sync()'::regprocedure))>0,
  'The helper reads the dedicated job secret');
SELECT ok(position('vibra_service_role_key' IN pg_get_functiondef('vibra_private.enqueue_catalogue_sync()'::regprocedure))=0,
  'The catalogue helper no longer depends on the legacy service-role key');
SELECT ok(position('x-vibra-job-secret' IN pg_get_functiondef('vibra_private.enqueue_catalogue_sync()'::regprocedure))>0,
  'The helper uses the explicit job authentication header');
SELECT ok(position('authorization' IN lower(pg_get_functiondef('vibra_private.enqueue_catalogue_sync()'::regprocedure)))=0,
  'The helper does not send the legacy Authorization credential');
SELECT is((SELECT command FROM cron.job WHERE jobname='invoke-ticketmaster-sync'),
  'SELECT vibra_private.enqueue_catalogue_sync();',
  'The existing cron command still contains only the private helper call');
SELECT is((SELECT schedule FROM cron.job WHERE jobname='invoke-ticketmaster-sync'),
  '25 */6 * * *', 'The existing catalogue refresh schedule is unchanged');

-- All Vault fixtures and HTTP queue entries are rolled back. pg_net only sees
-- committed requests, so these assertions never send a network request.
CREATE TEMP TABLE catalogue_job_fixture ON COMMIT DROP AS
SELECT replace(gen_random_uuid()::text, '-', '')||replace(gen_random_uuid()::text, '-', '') AS credential,
  'https://catalogue-worker.example.invalid/functions/v1'::text AS endpoint;
CREATE TEMP TABLE catalogue_queue_baseline ON COMMIT DROP AS
SELECT COALESCE(max(id),0)::bigint AS cutoff FROM net.http_request_queue;
DELETE FROM vault.secrets WHERE name IN ('vibra_functions_url','vibra_catalogue_job_secret');
INSERT INTO public.event_provider_search_cache(cache_key, attempted_at) VALUES
  ('14.01:14.02:14',clock_timestamp()-interval '3 days'),
  ('14.03:14.04:14',clock_timestamp());

SELECT lives_ok('SELECT vibra_private.enqueue_catalogue_sync()',
  'Missing Vault configuration fails closed without raising a cron error');
SELECT is((SELECT count(*) FROM net.http_request_queue WHERE id>(SELECT cutoff FROM catalogue_queue_baseline)),
  0::bigint, 'Missing configuration does not enqueue an unauthenticated request');
SELECT is((SELECT count(*) FROM public.event_provider_search_cache WHERE cache_key='14.01:14.02:14'),
  0::bigint, 'Expired coarse area cache entries are still removed when authentication is unavailable');
SELECT is((SELECT count(*) FROM public.event_provider_search_cache WHERE cache_key='14.03:14.04:14'),
  1::bigint, 'Recent shared cache entries are preserved');

DO $fixture$
BEGIN
  PERFORM vault.create_secret((SELECT endpoint FROM catalogue_job_fixture), 'vibra_functions_url');
  PERFORM vibra_private.enqueue_catalogue_sync();
END;
$fixture$;
SELECT is((SELECT count(*) FROM net.http_request_queue WHERE id>(SELECT cutoff FROM catalogue_queue_baseline)),
  0::bigint, 'An endpoint without the dedicated secret does not enqueue a job');

DO $fixture$
BEGIN
  PERFORM vault.create_secret('   ', 'vibra_catalogue_job_secret');
  PERFORM vibra_private.enqueue_catalogue_sync();
END;
$fixture$;
SELECT is((SELECT count(*) FROM net.http_request_queue WHERE id>(SELECT cutoff FROM catalogue_queue_baseline)),
  0::bigint, 'A blank dedicated secret also fails closed');

DO $fixture$
BEGIN
  DELETE FROM vault.secrets WHERE name='vibra_functions_url';
  PERFORM vault.update_secret((SELECT id FROM vault.secrets WHERE name='vibra_catalogue_job_secret'),
    (SELECT credential FROM catalogue_job_fixture));
  PERFORM vibra_private.enqueue_catalogue_sync();
END;
$fixture$;
SELECT is((SELECT count(*) FROM net.http_request_queue WHERE id>(SELECT cutoff FROM catalogue_queue_baseline)),
  0::bigint, 'A credential without the functions endpoint does not enqueue a job');

DO $fixture$
BEGIN
  PERFORM vault.create_secret('   ', 'vibra_functions_url');
  PERFORM vibra_private.enqueue_catalogue_sync();
END;
$fixture$;
SELECT is((SELECT count(*) FROM net.http_request_queue WHERE id>(SELECT cutoff FROM catalogue_queue_baseline)),
  0::bigint, 'A blank functions endpoint also fails closed');

DO $fixture$
BEGIN
  PERFORM vault.update_secret((SELECT id FROM vault.secrets WHERE name='vibra_functions_url'),
    (SELECT endpoint||'/' FROM catalogue_job_fixture));
END;
$fixture$;
SELECT lives_ok('SELECT vibra_private.enqueue_catalogue_sync()',
  'Valid dedicated job configuration enqueues the catalogue worker');
SELECT is((SELECT count(*) FROM net.http_request_queue WHERE id>(SELECT cutoff FROM catalogue_queue_baseline)),
  1::bigint, 'Exactly one configured catalogue request is queued');
SELECT is((SELECT method FROM net.http_request_queue WHERE id>(SELECT cutoff FROM catalogue_queue_baseline)),
  'POST', 'The catalogue job keeps its POST method');
SELECT ok((SELECT url=(SELECT endpoint||'/ticketmaster-sync' FROM catalogue_job_fixture)
  FROM net.http_request_queue WHERE id>(SELECT cutoff FROM catalogue_queue_baseline)),
  'The worker URL joins the configured endpoint without duplicate slashes');
SELECT ok((SELECT headers->>'x-vibra-job-secret'=(SELECT credential FROM catalogue_job_fixture)
  FROM net.http_request_queue WHERE id>(SELECT cutoff FROM catalogue_queue_baseline)),
  'The dedicated authentication header contains the runtime Vault credential');
SELECT ok((SELECT NOT EXISTS(SELECT 1 FROM jsonb_object_keys(headers) k WHERE lower(k)='authorization')
  FROM net.http_request_queue WHERE id>(SELECT cutoff FROM catalogue_queue_baseline)),
  'No Authorization header or legacy service credential is sent');
SELECT is((SELECT headers->>'Content-Type' FROM net.http_request_queue
  WHERE id>(SELECT cutoff FROM catalogue_queue_baseline)),
  'application/json', 'The catalogue job retains its JSON content type');
SELECT is((SELECT convert_from(body,'UTF8')::jsonb FROM net.http_request_queue
  WHERE id>(SELECT cutoff FROM catalogue_queue_baseline)),
  '{"country_codes":["IT"]}'::jsonb, 'The catalogue job preserves its Italy synchronization scope');
SELECT is((SELECT timeout_milliseconds FROM net.http_request_queue
  WHERE id>(SELECT cutoff FROM catalogue_queue_baseline)),
  120000, 'The catalogue job retains its worker timeout');
SELECT ok((SELECT position((SELECT credential FROM catalogue_job_fixture) IN command)=0
  FROM cron.job WHERE jobname='invoke-ticketmaster-sync'),
  'The cron command never contains the decrypted dedicated credential');

SELECT * FROM finish();
ROLLBACK;
