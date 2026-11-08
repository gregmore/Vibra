BEGIN;
\ir ../pgtap_setup.inc
SELECT no_plan();

INSERT INTO auth.users (id, email) VALUES
  ('f2000000-0000-0000-0000-000000000001', 'pause-alice@example.invalid'),
  ('f2000000-0000-0000-0000-000000000002', 'pause-bob@example.invalid');
INSERT INTO public.users (id, username, spotify_id, last_latitude, last_longitude) VALUES
  ('f2000000-0000-0000-0000-000000000001', 'pause-alice', 'pause-spotify-a', 45.46, 9.19),
  ('f2000000-0000-0000-0000-000000000002', 'pause-bob', 'pause-spotify-b', 45.46, 9.19);
INSERT INTO auth.sessions (id, user_id) SELECT id, id FROM auth.users WHERE id::text LIKE 'f2000000%';
INSERT INTO public.privacy_preferences (user_id, spotify_matching, location_processing)
SELECT id, true, true FROM public.users WHERE id::text LIKE 'f2000000%';
INSERT INTO public.spotify_connections (user_id, spotify_user_id, access_token_ciphertext, token_expires_at, connected_at)
VALUES ('f2000000-0000-0000-0000-000000000001', 'pause-spotify-a', 'v1.fixture.fixture', now(), '2026-10-13T10:00:00Z');
INSERT INTO public.music_profiles (user_id, top_artists, embedding) VALUES
  ('f2000000-0000-0000-0000-000000000001', '[{"id":"fixture-artist"}]', '[1,0,0,0,0,0,0,0,0,0]'),
  ('f2000000-0000-0000-0000-000000000002', '[{"id":"fixture-artist"}]', '[1,0,0,0,0,0,0,0,0,0]');
INSERT INTO public.user_matches (user_id_a, user_id_b, compatibility)
VALUES ('f2000000-0000-0000-0000-000000000001', 'f2000000-0000-0000-0000-000000000002', 90);
INSERT INTO public.notifications (user_id, type, title, body) VALUES
  ('f2000000-0000-0000-0000-000000000001', 'match', 'Fixture affinity', 'Fixture'),
  ('f2000000-0000-0000-0000-000000000001', 'chat_message', 'Fixture chat', 'Fixture');
INSERT INTO public.events (id, external_id, source, name, event_date)
VALUES ('f2000000-0000-0000-0000-000000000003', 'pause-event', 'ticketmaster', 'Pause fixture event', now() + interval '1 day');

UPDATE public.launch_features SET enabled = false WHERE feature = 'spotify';
SELECT is(public.spotify_feature_enabled(), false, 'Spotify is paused by the server flag');
SELECT is((SELECT count(*) FROM public.spotify_connections WHERE user_id::text LIKE 'f2000000%'), 1::bigint, 'Pausing keeps encrypted credentials for explicit disconnect');
SELECT is((SELECT count(*) FROM public.music_profiles WHERE user_id::text LIKE 'f2000000%'), 2::bigint, 'Pausing does not erase imported profiles');
SELECT is((SELECT count(*) FROM public.user_matches WHERE user_id_a::text LIKE 'f2000000%'), 1::bigint, 'Pausing does not erase stored matches');
SELECT is((SELECT bool_and(spotify_matching) FROM public.privacy_preferences WHERE user_id::text LIKE 'f2000000%'), true, 'Pausing preserves individual matching consent');
SELECT lives_ok($$ INSERT INTO auth.users (id, email) VALUES ('f2000000-0000-0000-0000-000000000004', 'fresh-signup@example.invalid') $$,
  'A fresh Auth signup remains possible while Spotify is paused');
SELECT lives_ok($$ INSERT INTO public.users (id, username) VALUES ('f2000000-0000-0000-0000-000000000004', 'fresh-signup') $$,
  'Ordinary profile bootstrap does not require a Spotify music profile');
SELECT is(has_table_privilege('authenticated', 'public.launch_features', 'SELECT'), false, 'Clients cannot inspect the private feature table');
SELECT is(has_table_privilege('authenticated', 'public.launch_features', 'UPDATE'), false, 'Clients cannot re-enable server features');
SELECT is(has_function_privilege('anon', 'public.spotify_feature_enabled()', 'EXECUTE'), false, 'Anonymous callers cannot invoke the flag helper');

SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'f2000000-0000-0000-0000-000000000001';
SET LOCAL request.jwt.claims = '{"role":"authenticated","sub":"f2000000-0000-0000-0000-000000000001","session_id":"f2000000-0000-0000-0000-000000000001"}';
SELECT is((SELECT count(*) FROM public.music_profiles), 1::bigint, 'Own imported data remains available for account export');
SELECT is((public.export_my_personal_data()->'music_profile'->'top_artists'->0->>'id'), 'fixture-artist',
  'The actual account export still contains the owner imported data during the pause');
SELECT is_empty('SELECT * FROM public.user_matches', 'Old clients cannot read cached musical matches while paused');
SELECT is_empty('SELECT * FROM public.music_profile_discovery', 'Old clients cannot read musical discovery while paused');
SELECT is_empty('SELECT * FROM public.music_profiles_public', 'The legacy public music view also obeys the pause');
SELECT is(public.may_discover_music('f2000000-0000-0000-0000-000000000002'), false, 'The public music-discovery helper also obeys the global pause');
SELECT is(public.may_access_music_match('f2000000-0000-0000-0000-000000000001', 'f2000000-0000-0000-0000-000000000002'), false,
  'The music-match permission helper cannot advertise a paused affinity');
SELECT is_empty($$ SELECT * FROM public.find_compatible_users('f2000000-0000-0000-0000-000000000001', '[1,0,0,0,0,0,0,0,0,0]'::vector, 50) $$,
  'Direct authenticated compatibility RPC returns no candidates while paused');
SELECT throws_like($$ SELECT * FROM public.find_compatible_users('f2000000-0000-0000-0000-000000000002', '[1,0,0,0,0,0,0,0,0,0]'::vector, 50) $$,
  '%only for itself%', 'Pausing does not bypass compatibility identity checks');
SELECT results_eq('SELECT type FROM public.notifications ORDER BY type', $$ VALUES ('chat_message'::text) $$,
  'Music notification history is hidden while ordinary chat history remains available');
SELECT throws_like('UPDATE public.launch_features SET enabled = true', '%permission denied%', 'A client cannot alter the operational flag');

SET LOCAL ROLE service_role;
SET LOCAL request.jwt.claims = '{"role":"service_role"}';
SELECT is_empty($$ SELECT * FROM public.find_compatible_users('f2000000-0000-0000-0000-000000000001', '[1,0,0,0,0,0,0,0,0,0]'::vector, 50) $$,
  'Privileged compatibility worker cannot obtain paused candidates');
SELECT is_empty($$ SELECT * FROM public.nearby_recent_match_for_user('f2000000-0000-0000-0000-000000000001', 25000) $$,
  'Privileged retention RPC cannot obtain paused affinities');
SELECT throws_ok($$ SELECT public.connect_spotify_account('f2000000-0000-0000-0000-000000000001', 'different-spotify', '{}', 'v1.late.fixture', NULL, now()) $$,
  'PT503', 'spotify_temporarily_unavailable', 'A late OAuth exchange cannot save a connection during the pause');
SELECT throws_ok($$ SELECT public.refresh_spotify_connection('f2000000-0000-0000-0000-000000000001', 'pause-spotify-a', '2026-10-13T10:00:00Z', 'v1.late.fixture', NULL, now()) $$,
  'PT503', 'spotify_temporarily_unavailable', 'A late refresh cannot replace encrypted tokens during the pause');
SELECT throws_ok($$ SELECT public.save_connected_music_profile('f2000000-0000-0000-0000-000000000001', 'pause-spotify-a', '2026-10-13T10:00:00Z', '{}') $$,
  'PT503', 'spotify_temporarily_unavailable', 'A late sync cannot overwrite imported data during the pause');
SELECT throws_ok($$ UPDATE public.user_matches SET compatibility = 95 WHERE user_id_a = 'f2000000-0000-0000-0000-000000000001' $$,
  'PT503', 'spotify_temporarily_unavailable', 'A direct privileged match update cannot bypass the pause');
SELECT throws_ok($$ INSERT INTO public.notifications (user_id, type, title, body) VALUES ('f2000000-0000-0000-0000-000000000001', 'match', 'Late affinity', 'Fixture') $$,
  'PT503', 'spotify_temporarily_unavailable', 'An old notification worker cannot publish a paused affinity');
SELECT throws_ok($$ UPDATE public.events SET embedding = '[1,0,0,0,0,0,0,0,0,0]'::vector WHERE id = 'f2000000-0000-0000-0000-000000000003' $$,
  'PT503', 'spotify_temporarily_unavailable', 'An old enrichment worker cannot store a Spotify event embedding');
SELECT lives_ok($$ UPDATE public.events SET name = 'Updated ordinary event' WHERE id = 'f2000000-0000-0000-0000-000000000003' $$,
  'Ordinary event catalog updates remain usable');
SELECT lives_ok($$ INSERT INTO public.notifications (user_id, type, title, body) VALUES ('f2000000-0000-0000-0000-000000000001', 'friend_request', 'Fixture friend', 'Fixture') $$,
  'Friendship notifications can still be created while Spotify is paused');
SELECT lives_ok('UPDATE public.launch_features SET enabled = true WHERE feature = ''spotify''', 'The authorized operator can reversibly re-enable the feature');

SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claims = '{"role":"authenticated","sub":"f2000000-0000-0000-0000-000000000001","session_id":"f2000000-0000-0000-0000-000000000001"}';
SELECT is((SELECT count(*) FROM public.user_matches), 1::bigint, 'Re-enabling restores existing consented matches without recreating data');
SELECT is((SELECT count(*) FROM public.music_profile_discovery), 2::bigint, 'Re-enabling restores existing consented discovery data');
SET LOCAL ROLE service_role;
SET LOCAL request.jwt.claims = '{"role":"service_role"}';
UPDATE public.launch_features SET enabled = false WHERE feature = 'spotify';
SELECT lives_ok($$ SELECT public.disconnect_spotify_account('f2000000-0000-0000-0000-000000000001') $$,
  'Explicit disconnect and erasure remain available during the pause');
SELECT is_empty($$ SELECT * FROM public.spotify_connections WHERE user_id = 'f2000000-0000-0000-0000-000000000001' $$,
  'Explicit disconnect still removes encrypted credentials');
SELECT is((SELECT spotify_id FROM public.users WHERE id = 'f2000000-0000-0000-0000-000000000001'), NULL::text,
  'A rejected late OAuth exchange cannot leave a provider identity after disconnect');

SELECT * FROM finish();
ROLLBACK;
