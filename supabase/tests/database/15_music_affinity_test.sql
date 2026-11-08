BEGIN;
\ir ../pgtap_setup.inc
SELECT plan(16);

-- me (real), friendly (real), blocked (real), outsider (test segment),
-- optout (real, no consent).
INSERT INTO auth.users (id, email, raw_app_meta_data) VALUES
  ('f1500000-0000-4000-8000-000000000001', 'aff-me@example.invalid', '{"is_test_user":false}'),
  ('f1500000-0000-4000-8000-000000000002', 'aff-friendly@example.invalid', '{"is_test_user":false}'),
  ('f1500000-0000-4000-8000-000000000003', 'aff-blocked@example.invalid', '{"is_test_user":false}'),
  ('f1500000-0000-4000-8000-000000000004', 'aff-outsider@example.invalid', '{"is_test_user":true}'),
  ('f1500000-0000-4000-8000-000000000005', 'aff-optout@example.invalid', '{"is_test_user":false}');
INSERT INTO public.users (id, username) VALUES
  ('f1500000-0000-4000-8000-000000000001', 'aff_me'),
  ('f1500000-0000-4000-8000-000000000002', 'aff_friendly'),
  ('f1500000-0000-4000-8000-000000000003', 'aff_blocked'),
  ('f1500000-0000-4000-8000-000000000004', 'aff_outsider'),
  ('f1500000-0000-4000-8000-000000000005', 'aff_optout')
ON CONFLICT (id) DO UPDATE SET username = EXCLUDED.username;
INSERT INTO auth.sessions (id, user_id) SELECT id, id FROM auth.users WHERE id::text LIKE 'f15%' ON CONFLICT DO NOTHING;
UPDATE public.launch_features SET enabled = true WHERE feature = 'spotify';
INSERT INTO public.privacy_preferences (user_id, spotify_matching)
SELECT id, id::text NOT LIKE '%5' FROM public.users WHERE id::text LIKE 'f15%'
ON CONFLICT (user_id) DO UPDATE SET spotify_matching = EXCLUDED.spotify_matching;
-- Everyone picked genres by hand; nobody has Spotify.
INSERT INTO public.user_genre_preferences (user_id, genre_key, intensity)
SELECT id, 'trap', 90 FROM public.users WHERE id::text LIKE 'f15%';
INSERT INTO public.blocked_users (blocker_id, blocked_id)
VALUES ('f1500000-0000-4000-8000-000000000003', 'f1500000-0000-4000-8000-000000000001');

-- ── Candidates (service role) ─────────────────────────────────────────────
SET LOCAL ROLE service_role;
SET LOCAL request.jwt.claims = '{"role":"service_role"}';
SELECT results_eq(
  $$ SELECT user_id::text FROM public.find_affinity_candidates('f1500000-0000-4000-8000-000000000001') ORDER BY 1 $$,
  $$ VALUES ('f1500000-0000-4000-8000-000000000002'::text) $$,
  'Genre-only users are candidates; blocked, opted-out and other-segment users are not');
SELECT is(
  (SELECT manual_genres FROM public.get_affinity_input('f1500000-0000-4000-8000-000000000001')),
  '[{"genre_key": "trap", "intensity": 90}]'::jsonb,
  'The engine receives the picked genres without Spotify');
SELECT is(public.save_affinity_matches('f1500000-0000-4000-8000-000000000001',
  '[{"user_id_a":"f1500000-0000-4000-8000-000000000001","user_id_b":"f1500000-0000-4000-8000-000000000002",
     "compatibility":97,"shared_artists":0,"shared_genres":1,"algorithm_version":2,
     "details":{"v":2,"tier":"exceptional","reasons":[{"code":"shared_families","families":["hip-hop"]}]}}]'::jsonb,
  ARRAY['f1500000-0000-4000-8000-000000000002']::uuid[], true), 1, 'Pairs are written by the service role');
SELECT is((SELECT details->>'tier' FROM public.user_matches WHERE user_id_a = 'f1500000-0000-4000-8000-000000000001'),
  'exceptional', 'The explanation is cached with the pair');
-- A complete recompute without that pair invalidates it.
SELECT public.save_affinity_matches('f1500000-0000-4000-8000-000000000001', '[]'::jsonb, '{}', true);
SELECT is_empty($$ SELECT 1 FROM public.user_matches WHERE user_id_a = 'f1500000-0000-4000-8000-000000000001' $$,
  'Stale cached pairs are removed when the profile no longer supports them');
SELECT public.save_affinity_matches('f1500000-0000-4000-8000-000000000001',
  '[{"user_id_a":"f1500000-0000-4000-8000-000000000001","user_id_b":"f1500000-0000-4000-8000-000000000002","compatibility":97,"details":{"v":2}}]'::jsonb,
  ARRAY['f1500000-0000-4000-8000-000000000002']::uuid[], true);
-- A cached pair with a blocked user (computed before the block) must not leak.
INSERT INTO public.user_matches (user_id_a, user_id_b, compatibility, details)
VALUES ('f1500000-0000-4000-8000-000000000001', 'f1500000-0000-4000-8000-000000000003', 99, '{"v":2}');

-- ── Caller ────────────────────────────────────────────────────────────────
SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'f1500000-0000-4000-8000-000000000001';
SET LOCAL request.jwt.claims = '{"role":"authenticated","sub":"f1500000-0000-4000-8000-000000000001","session_id":"f1500000-0000-4000-8000-000000000001"}';
SELECT throws_like($$ SELECT * FROM public.find_affinity_candidates('f1500000-0000-4000-8000-000000000001') $$,
  '%permission denied%', 'Clients cannot list candidates');
SELECT throws_like($$ SELECT public.save_affinity_matches('f1500000-0000-4000-8000-000000000001', '[]', '{}', true) $$,
  '%permission denied%', 'Clients cannot write or manipulate scores');
SELECT throws_like($$ UPDATE public.user_matches SET compatibility = 100 $$,
  '%permission denied%', 'Clients cannot edit cached scores');
SELECT results_eq($$ SELECT user_id::text, compatibility FROM public.get_affinity_feed() $$,
  $$ VALUES ('f1500000-0000-4000-8000-000000000002'::text, 97) $$,
  'The feed shows the eligible affinity and hides the blocked user');
INSERT INTO public.affinity_dismissals (user_id, dismissed_user_id)
VALUES ('f1500000-0000-4000-8000-000000000001', 'f1500000-0000-4000-8000-000000000002');
SELECT is_empty($$ SELECT * FROM public.get_affinity_feed() $$, 'An ignored profile does not come back');
DELETE FROM public.affinity_dismissals WHERE dismissed_user_id = 'f1500000-0000-4000-8000-000000000002';
SELECT throws_like($$ INSERT INTO public.affinity_dismissals (user_id, dismissed_user_id)
  VALUES ('f1500000-0000-4000-8000-000000000002', 'f1500000-0000-4000-8000-000000000001') $$,
  '%row-level security%', 'Dismissals can only be written for oneself');
SELECT throws_like($$ INSERT INTO public.user_genre_preferences (user_id, genre_key)
  VALUES ('f1500000-0000-4000-8000-000000000002', 'house') $$,
  '%row-level security%', 'Genre preferences can only be written for oneself');
SELECT is((SELECT count(*) FROM public.user_genre_preferences), 1::bigint, 'Other users'' genre picks are private');
SELECT throws_like($$ INSERT INTO public.user_genre_preferences (user_id, genre_key)
  VALUES ('f1500000-0000-4000-8000-000000000001', 'Not A Key!') $$,
  '%check constraint%', 'Genre keys are validated');
-- Accepted friends are no longer "discovery".
SET LOCAL ROLE postgres;
INSERT INTO public.friendships (requester_id, receiver_id, status)
VALUES ('f1500000-0000-4000-8000-000000000001', 'f1500000-0000-4000-8000-000000000002', 'accepted');
SET LOCAL ROLE authenticated;
SELECT is_empty($$ SELECT * FROM public.get_affinity_feed() $$, 'Existing connections are not rediscovered');
-- Removing every picked genre clears a genre-only user's cached pairs.
DELETE FROM public.user_genre_preferences WHERE user_id = auth.uid();
SET LOCAL ROLE postgres;
SELECT is_empty($$ SELECT 1 FROM public.user_matches WHERE user_id_a = 'f1500000-0000-4000-8000-000000000001' OR user_id_b = 'f1500000-0000-4000-8000-000000000001' $$,
  'A user without any musical data keeps no affinity score');

SELECT * FROM finish();
ROLLBACK;
