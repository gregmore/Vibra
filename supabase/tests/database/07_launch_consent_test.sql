BEGIN;
\ir ../pgtap_setup.inc
SELECT plan(34);
INSERT INTO auth.users (id, email) VALUES ('d1000000-0000-0000-0000-000000000001', 'consent@example.invalid');
INSERT INTO public.users (id, username, avatar_url)
VALUES ('d1000000-0000-0000-0000-000000000001', 'consent-fixture', 'https://example.invalid/vibra-avatar.jpg');
INSERT INTO auth.sessions (id, user_id) VALUES ('d1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000001');
INSERT INTO public.privacy_preferences (user_id, location_processing, spotify_matching)
VALUES ('d1000000-0000-0000-0000-000000000001', false, true);
UPDATE public.users SET spotify_id = 'consent-spotify' WHERE id = 'd1000000-0000-0000-0000-000000000001';
INSERT INTO public.spotify_connections (user_id, spotify_user_id, access_token_ciphertext, refresh_token_ciphertext, token_expires_at, connected_at)
VALUES ('d1000000-0000-0000-0000-000000000001', 'consent-spotify', 'v1.fixture.fixture', 'v1.refresh.fixture', now(), '2026-10-13T10:00:00Z');

SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'd1000000-0000-0000-0000-000000000001';
SET LOCAL request.jwt.claims = '{"role":"authenticated","sub":"d1000000-0000-0000-0000-000000000001","session_id":"d1000000-0000-0000-0000-000000000001"}';
SELECT throws_like('SELECT public.update_user_location(9.19, 45.46)', '%Location consent required%', 'Location RPC refuses absent consent');
SELECT throws_like($$ UPDATE public.users SET last_latitude = 45.46, last_longitude = 9.19
  WHERE id = 'd1000000-0000-0000-0000-000000000001' $$, '%Location consent required%', 'Direct profile writes cannot bypass location consent');
UPDATE public.privacy_preferences SET location_processing = true WHERE user_id = auth.uid();
SELECT lives_ok('SELECT public.update_user_location(9.19, 45.46)', 'Real location can be stored with consent');
SELECT is((SELECT last_latitude FROM public.users WHERE id = auth.uid()), 45.46::double precision, 'The server stores the actual coordinate');
SELECT throws_like('SELECT public.update_user_location(181, 45.46)', '%Invalid location%', 'Invalid coordinates are rejected');
UPDATE public.privacy_preferences SET location_processing = false WHERE user_id = auth.uid();
SELECT is((SELECT last_location IS NULL AND last_latitude IS NULL AND last_longitude IS NULL FROM public.users WHERE id = auth.uid()), true, 'Opt-out erases stored coordinates atomically');
SELECT throws_like('SELECT public.update_user_location(9.19, 45.46)', '%Location consent required%', 'A late GPS write cannot undo opt-out');
SELECT throws_like($$ SELECT public.disconnect_spotify_account('d1000000-0000-0000-0000-000000000001') $$,
  '%permission denied%', 'Clients cannot invoke the privileged disconnect routine');
SELECT throws_like($$ SELECT public.refresh_spotify_connection('d1000000-0000-0000-0000-000000000001', 'consent-spotify',
  '2026-10-13T10:00:00Z', 'v1.client.fixture', NULL, now()) $$,
  '%permission denied%', 'Clients cannot replace backend-managed Spotify tokens');
SELECT throws_like($$ SELECT public.save_connected_music_profile('d1000000-0000-0000-0000-000000000001', 'consent-spotify',
  '2026-10-13T10:00:00Z', '{}') $$,
  '%permission denied%', 'Clients cannot forge imported Spotify data');
SELECT throws_like($$ SELECT public.connect_spotify_account('d1000000-0000-0000-0000-000000000001', 'consent-spotify',
  '{}', 'v1.client.fixture', NULL, now()) $$,
  '%permission denied%', 'Clients cannot forge Spotify connection consent');

UPDATE public.privacy_preferences SET spotify_matching = false WHERE user_id = auth.uid();

SET LOCAL ROLE service_role;
SET LOCAL request.jwt.claims = '{"role":"service_role"}';
SELECT is(public.refresh_spotify_connection('d1000000-0000-0000-0000-000000000001', 'consent-spotify',
  '2026-10-13T10:00:00Z', 'v1.refreshed.fixture', NULL, now()), true, 'A current connection can refresh without granting consent');
SET LOCAL ROLE postgres;
SELECT is((SELECT access_token_ciphertext FROM public.spotify_connections WHERE user_id = 'd1000000-0000-0000-0000-000000000001'),
  'v1.refreshed.fixture', 'The refresh stores the new encrypted access token');
SELECT is((SELECT refresh_token_ciphertext FROM public.spotify_connections WHERE user_id = 'd1000000-0000-0000-0000-000000000001'),
  'v1.refresh.fixture', 'A refresh without rotation retains the stored encrypted refresh token');
SELECT is((SELECT spotify_matching FROM public.privacy_preferences WHERE user_id = 'd1000000-0000-0000-0000-000000000001'),
  false, 'Token refresh preserves matching opt-out');
SET LOCAL ROLE service_role;
SELECT lives_ok($$ SELECT public.save_connected_music_profile('d1000000-0000-0000-0000-000000000001', 'consent-spotify',
  '2026-10-13T10:00:00Z', '{"top_artists":[{"id":"fixture-artist"}]}') $$,
  'A current Spotify connection can save a music profile');
SELECT lives_ok($$ SELECT public.disconnect_spotify_account('d1000000-0000-0000-0000-000000000001') $$, 'The trusted endpoint can disconnect atomically');
SET LOCAL ROLE postgres;
SELECT is_empty('SELECT * FROM public.spotify_connections WHERE user_id = ''d1000000-0000-0000-0000-000000000001''', 'Disconnect removes the encrypted credentials');
SELECT is((SELECT spotify_id FROM public.users WHERE id = 'd1000000-0000-0000-0000-000000000001'), NULL::text, 'Disconnect removes the provider identity');
SELECT is((SELECT spotify_matching FROM public.privacy_preferences WHERE user_id = 'd1000000-0000-0000-0000-000000000001'), false, 'Disconnect revokes matching consent');
SELECT is_empty('SELECT * FROM public.music_profiles WHERE user_id = ''d1000000-0000-0000-0000-000000000001''',
  'Disconnect removes the derived music profile');

SET LOCAL ROLE service_role;
SELECT is(public.refresh_spotify_connection('d1000000-0000-0000-0000-000000000001', 'consent-spotify',
  '2026-10-13T10:00:00Z', 'v1.late.fixture', NULL, now()), false, 'A late token refresh cannot recreate a disconnected account');
SELECT throws_like($$ SELECT public.save_connected_music_profile('d1000000-0000-0000-0000-000000000001', 'consent-spotify',
  '2026-10-13T10:00:00Z', '{}') $$,
  '%disconnected%', 'A late music sync cannot recreate data after disconnect');
SELECT lives_ok($$ SELECT public.connect_spotify_account('d1000000-0000-0000-0000-000000000001', 'consent-spotify',
  '{"username":"stale-oauth-name", "avatar_url":"https://example.invalid/stale-avatar.jpg"}',
  'v1.new.fixture', 'v1.newrefresh.fixture', now()) $$, 'A fresh explicit OAuth connection can reconnect');
SET LOCAL ROLE postgres;
SELECT is((SELECT username::text FROM public.users WHERE id = 'd1000000-0000-0000-0000-000000000001'),
  'consent-fixture', 'OAuth completion preserves the existing Vibra username');
SELECT is((SELECT avatar_url FROM public.users WHERE id = 'd1000000-0000-0000-0000-000000000001'),
  'https://example.invalid/vibra-avatar.jpg', 'OAuth completion does not replace an existing profile photo choice');
SELECT is((SELECT spotify_matching FROM public.privacy_preferences WHERE user_id = 'd1000000-0000-0000-0000-000000000001'),
  true, 'Only explicit OAuth connection records matching consent');
SELECT isnt((SELECT connected_at FROM public.spotify_connections WHERE user_id = 'd1000000-0000-0000-0000-000000000001'),
  '2026-10-13T10:00:00Z'::timestamptz, 'Reconnect changes the generation used by in-flight workers');
SET LOCAL ROLE service_role;
SELECT is(public.refresh_spotify_connection('d1000000-0000-0000-0000-000000000001', 'consent-spotify',
  '2026-10-13T10:00:00Z', 'v1.stale.fixture', NULL, now()), false, 'A refresh from an earlier connection cannot overwrite reconnect');
SELECT throws_like($$ SELECT public.save_connected_music_profile('d1000000-0000-0000-0000-000000000001', 'consent-spotify',
  '2026-10-13T10:00:00Z', '{}') $$,
  '%disconnected%', 'An earlier music sync cannot overwrite a new connection');
SELECT is(public.refresh_spotify_connection('d1000000-0000-0000-0000-000000000001', 'different-account',
  (SELECT connected_at FROM public.spotify_connections WHERE user_id = 'd1000000-0000-0000-0000-000000000001'),
  'v1.mismatch.fixture', NULL, now()), false, 'Refresh cannot change the linked Spotify identity');

SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'd1000000-0000-0000-0000-000000000001';
SET LOCAL request.jwt.claims = '{"role":"authenticated","sub":"d1000000-0000-0000-0000-000000000001","session_id":"d1000000-0000-0000-0000-000000000001"}';
UPDATE public.privacy_preferences SET location_processing = true WHERE user_id = auth.uid();
SELECT public.update_user_location(9.19, 45.46);
DELETE FROM public.privacy_preferences WHERE user_id = auth.uid();
SELECT is((SELECT last_location IS NULL AND last_latitude IS NULL AND last_longitude IS NULL
  FROM public.users WHERE id = auth.uid()), true, 'Removing the consent record erases coordinates too');
SELECT throws_like('SELECT public.update_user_location(9.19, 45.46)', '%Location consent required%',
  'A deleted consent record cannot be recreated by a late GPS request');
SET LOCAL ROLE postgres;
DELETE FROM auth.sessions WHERE user_id = 'd1000000-0000-0000-0000-000000000001';
SET LOCAL ROLE authenticated;
SELECT throws_like('SELECT public.update_user_location(9.19, 45.46)', '%Session revoked%',
  'Location persistence validates session revocation itself');
SELECT * FROM finish();
ROLLBACK;
