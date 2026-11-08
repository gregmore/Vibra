BEGIN;
\ir ../pgtap_setup.inc
SELECT plan(9);
INSERT INTO auth.users (id, email) VALUES
  ('e1000000-0000-0000-0000-000000000001', 'match-alice@example.invalid'),
  ('e1000000-0000-0000-0000-000000000002', 'match-bob@example.invalid');
INSERT INTO public.users (id, username) VALUES
  ('e1000000-0000-0000-0000-000000000001', 'match-alice'),
  ('e1000000-0000-0000-0000-000000000002', 'match-bob');
INSERT INTO auth.sessions (id, user_id) SELECT id, id FROM auth.users ON CONFLICT DO NOTHING;
INSERT INTO public.privacy_preferences (user_id, spotify_matching)
SELECT id, true FROM public.users WHERE id::text LIKE 'e1000000%';
INSERT INTO public.user_matches (user_id_a, user_id_b, compatibility)
VALUES ('e1000000-0000-0000-0000-000000000001', 'e1000000-0000-0000-0000-000000000002', 90);

SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'e1000000-0000-0000-0000-000000000001';
SET LOCAL request.jwt.claims = '{"role":"authenticated","sub":"e1000000-0000-0000-0000-000000000001","session_id":"e1000000-0000-0000-0000-000000000001"}';
SELECT is((SELECT count(*) FROM public.user_matches), 1::bigint, 'Mutually opted-in participants can view their match');
UPDATE public.privacy_preferences SET spotify_matching = false WHERE user_id = auth.uid();
SELECT is_empty('SELECT * FROM public.user_matches', 'Opt-out hides previously calculated matches immediately');
UPDATE public.privacy_preferences SET spotify_matching = true WHERE user_id = auth.uid();
SET LOCAL ROLE postgres;
UPDATE public.privacy_preferences SET spotify_matching = false WHERE user_id = 'e1000000-0000-0000-0000-000000000002';
SET LOCAL ROLE authenticated;
SELECT is_empty('SELECT * FROM public.user_matches', 'The other participant opt-out also hides cached music-derived data');
SET LOCAL ROLE postgres;
UPDATE public.privacy_preferences SET spotify_matching = true WHERE user_id = 'e1000000-0000-0000-0000-000000000002';
INSERT INTO public.blocked_users (blocker_id, blocked_id)
VALUES ('e1000000-0000-0000-0000-000000000002', 'e1000000-0000-0000-0000-000000000001');
SET LOCAL ROLE authenticated;
SELECT is_empty('SELECT * FROM public.user_matches', 'The blocked party cannot see a cached affinity');
SET LOCAL request.jwt.claim.sub = 'e1000000-0000-0000-0000-000000000002';
SET LOCAL request.jwt.claims = '{"role":"authenticated","sub":"e1000000-0000-0000-0000-000000000002","session_id":"e1000000-0000-0000-0000-000000000002"}';
SELECT is_empty('SELECT * FROM public.user_matches', 'The blocker no longer sees that affinity either');
SET LOCAL ROLE postgres;
DELETE FROM public.blocked_users WHERE blocker_id = 'e1000000-0000-0000-0000-000000000002';
SET LOCAL ROLE authenticated;
SELECT is((SELECT count(*) FROM public.user_matches), 1::bigint, 'An unblocked opted-in affinity is visible again');
SELECT is(public.may_access_music_match('e1000000-0000-0000-0000-000000000001',
  'e1000000-0000-0000-0000-000000000003'), false, 'The permission helper cannot reveal nonparticipant relationships');
SET LOCAL ROLE postgres;
DELETE FROM auth.sessions WHERE user_id = 'e1000000-0000-0000-0000-000000000002';
SET LOCAL ROLE authenticated;
SELECT is_empty('SELECT * FROM public.user_matches', 'Revoked sessions cannot read cached affinities');
SET LOCAL ROLE anon;
SELECT throws_like($$ SELECT public.may_access_music_match('e1000000-0000-0000-0000-000000000001',
  'e1000000-0000-0000-0000-000000000002') $$, '%permission denied%', 'Anonymous callers cannot inspect match permissions');
SELECT * FROM finish();
ROLLBACK;
