BEGIN;
\ir ../pgtap_setup.inc
SELECT plan(30);

SELECT columns_are('public', 'event_provider_search_cache',
  ARRAY['cache_key', 'attempted_at', 'succeeded_at'],
  'The shared area cache contains only coarse keys and refresh timestamps');
SELECT ok(NOT has_table_privilege('anon', 'public.event_provider_search_cache', 'SELECT'),
  'Anonymous clients cannot enumerate searched public areas');
SELECT ok(NOT has_table_privilege('authenticated', 'public.event_provider_search_cache', 'SELECT'),
  'Authenticated clients cannot enumerate other map search areas');
SELECT ok(NOT has_table_privilege('authenticated', 'public.event_provider_search_cache', 'INSERT'),
  'A client cannot forge provider refresh timestamps');
SELECT ok(has_table_privilege('service_role', 'public.event_provider_search_cache', 'SELECT'),
  'The provider worker can read its shared area cache');
SELECT ok(has_table_privilege('service_role', 'public.event_provider_search_cache', 'INSERT'),
  'The provider worker can maintain its shared area cache');
SELECT ok(NOT has_function_privilege('authenticated', 'public.claim_event_provider_search(text)', 'EXECUTE'),
  'Authenticated clients cannot directly claim provider budget');
SELECT ok(NOT has_function_privilege('anon', 'public.claim_event_provider_search(text)', 'EXECUTE'),
  'Anonymous clients cannot directly claim provider budget');
SELECT ok(has_function_privilege('service_role', 'public.claim_event_provider_search(text)', 'EXECUTE'),
  'Only the trusted service can claim public provider searches');
SELECT ok(NOT has_function_privilege('anon', 'vibra_private.enqueue_catalogue_sync()', 'EXECUTE'),
  'Anonymous users cannot invoke the privileged cron enqueue helper');
SELECT ok(NOT has_function_privilege('authenticated', 'vibra_private.enqueue_catalogue_sync()', 'EXECUTE'),
  'Authenticated users cannot invoke the privileged cron enqueue helper');
SELECT is((SELECT command FROM cron.job WHERE jobname = 'invoke-ticketmaster-sync'),
  'SELECT vibra_private.enqueue_catalogue_sync();',
  'The cron command contains only the private enqueue call, without credentials');
SELECT ok(position('vault.decrypted_secrets' IN pg_get_functiondef('vibra_private.enqueue_catalogue_sync()'::regprocedure)) > 0,
  'Catalogue cron reads its credential from Vault at execution time');
SELECT ok(position('vibra_catalogue_job_secret' IN pg_get_functiondef('vibra_private.enqueue_catalogue_sync()'::regprocedure)) > 0,
  'Catalogue cron uses its dedicated named Vault job secret');

SET LOCAL ROLE service_role;
SELECT throws_like('SELECT public.claim_event_provider_search(NULL)', '%Invalid event search area%',
  'A missing cache key is rejected');
SELECT throws_like($$ SELECT public.claim_event_provider_search('exact-device-gps-history') $$,
  '%Invalid event search area%', 'Unstructured area keys are rejected');
SELECT is(public.claim_event_provider_search('45.46:9.19:102'), true,
  'A new public area can be claimed once');
SELECT is(public.claim_event_provider_search('45.46:9.19:102'), false,
  'An immediate concurrent claim does not duplicate provider work');
UPDATE public.event_provider_search_cache SET attempted_at = clock_timestamp() - interval '61 seconds'
WHERE cache_key = '45.46:9.19:102';
SELECT is(public.claim_event_provider_search('45.46:9.19:102'), true,
  'A failed area becomes retryable after its one-minute claim cooldown');
UPDATE public.event_provider_search_cache SET attempted_at = clock_timestamp() - interval '61 seconds',
  succeeded_at = clock_timestamp() WHERE cache_key = '45.46:9.19:102';
SELECT is(public.claim_event_provider_search('45.46:9.19:102'), false,
  'A successful shared refresh remains fresh for fifteen minutes');
UPDATE public.event_provider_search_cache SET attempted_at = clock_timestamp(),
  succeeded_at = clock_timestamp() - interval '16 minutes' WHERE cache_key = '45.46:9.19:102';
SELECT is(public.claim_event_provider_search('45.46:9.19:102'), false,
  'A stale area still respects the active one-minute claim cooldown');
UPDATE public.event_provider_search_cache SET attempted_at = clock_timestamp() - interval '61 seconds'
WHERE cache_key = '45.46:9.19:102';
SELECT is(public.claim_event_provider_search('45.46:9.19:102'), true,
  'An expired successful area is refreshed after the claim cooldown');
SELECT is(public.claim_event_provider_search('44.84:11.62:102'), true,
  'A different public map area has an independent shared refresh claim');

SET LOCAL ROLE postgres;
INSERT INTO auth.users (id, email)
VALUES ('e1400000-0000-0000-0000-000000000001', 'catalogue-fixture@example.invalid');
INSERT INTO public.users (id, username)
VALUES ('e1400000-0000-0000-0000-000000000001', 'catalogue-fixture');
INSERT INTO auth.sessions (id, user_id)
VALUES ('e1400000-0000-0000-0000-000000000001', 'e1400000-0000-0000-0000-000000000001');
SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'e1400000-0000-0000-0000-000000000001';
SET LOCAL request.jwt.claims = '{"role":"authenticated","sub":"e1400000-0000-0000-0000-000000000001","session_id":"e1400000-0000-0000-0000-000000000001"}';
SELECT lives_ok($$ SELECT public.consume_action_limit('search-events') $$,
  'Event discovery is registered as an authenticated rate-limited action');
SELECT lives_ok($$ DO $limit$ BEGIN FOR i IN 1..29 LOOP
  PERFORM public.consume_action_limit('search-events'); END LOOP; END $limit$ $$,
  'A caller can perform thirty map searches in a one-minute window');
SELECT throws_like($$ SELECT public.consume_action_limit('search-events') $$,
  '%Rate limit exceeded%', 'The thirty-first search is denied before provider work');
SELECT throws_like($$ SELECT public.claim_event_provider_search('45.46:9.19:102') $$,
  '%permission denied%', 'An authenticated caller cannot bypass the endpoint claim guard');
SELECT throws_like('SELECT * FROM public.event_provider_search_cache',
  '%permission denied%', 'Area refresh metadata remains unavailable to app callers');
SET LOCAL ROLE postgres;
UPDATE vibra_private.action_limits SET window_start = clock_timestamp() - interval '61 seconds'
WHERE user_id = 'e1400000-0000-0000-0000-000000000001' AND action = 'search-events';
SET LOCAL ROLE authenticated;
SELECT lives_ok($$ SELECT public.consume_action_limit('search-events') $$,
  'The event search quota resets after the one-minute window');
SET LOCAL ROLE postgres;
DELETE FROM auth.sessions WHERE user_id = 'e1400000-0000-0000-0000-000000000001';
SET LOCAL ROLE authenticated;
SELECT throws_like($$ SELECT public.consume_action_limit('search-events') $$,
  '%Session revoked%', 'A revoked session cannot consume provider search budget');

SELECT * FROM finish();
ROLLBACK;
