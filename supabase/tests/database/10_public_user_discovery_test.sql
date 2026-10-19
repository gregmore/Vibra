BEGIN;
\ir ../pgtap_setup.inc
SELECT no_plan();
INSERT INTO auth.users (id, email, raw_app_meta_data) VALUES
  ('f3000000-0000-0000-0000-000000000001', 'discovery-alice@example.invalid', '{}'),
  ('f3000000-0000-0000-0000-000000000002', 'discovery-bob@example.invalid', '{}'),
  ('f3000000-0000-0000-0000-000000000003', 'discovery-carol@example.invalid', '{}'),
  ('f3000000-0000-0000-0000-000000000004', 'discovery-outgoing-block@example.invalid', '{}'),
  ('f3000000-0000-0000-0000-000000000005', 'discovery-incoming-block@example.invalid', '{}'),
  ('f3000000-0000-0000-0000-000000000006', 'discovery-test@example.invalid', '{"is_test_user":true}');
INSERT INTO public.users (id, username, display_name, avatar_url, bio) VALUES
  ('f3000000-0000-0000-0000-000000000001', 'discover_alice', 'Alice', NULL, NULL),
  ('f3000000-0000-0000-0000-000000000002', 'discover_bob', 'Public Bob', 'https://example.invalid/avatar.jpg', 'Public bio'),
  ('f3000000-0000-0000-0000-000000000003', 'discover_carol', 'Carol % literal', NULL, NULL),
  ('f3000000-0000-0000-0000-000000000004', 'discover_outgoing', 'Hidden outgoing', NULL, NULL),
  ('f3000000-0000-0000-0000-000000000005', 'discover_incoming', 'Hidden incoming', NULL, NULL),
  ('f3000000-0000-0000-0000-000000000006', 'discover_test', 'Synthetic person', NULL, NULL);
INSERT INTO auth.sessions (id, user_id) SELECT id, id FROM auth.users WHERE id::text LIKE 'f3000000%';
INSERT INTO auth.users (id, email)
SELECT md5('discovery-boundary-' || n)::uuid, 'discovery-boundary-' || n || '@example.invalid' FROM generate_series(1, 60) AS n;
INSERT INTO public.users (id, username)
SELECT md5('discovery-boundary-' || n)::uuid, 'bounds_' || lpad(n::text, 2, '0') FROM generate_series(1, 60) AS n;
INSERT INTO public.blocked_users (blocker_id, blocked_id) VALUES
  ('f3000000-0000-0000-0000-000000000001', 'f3000000-0000-0000-0000-000000000004'),
  ('f3000000-0000-0000-0000-000000000005', 'f3000000-0000-0000-0000-000000000001');
UPDATE public.launch_features SET enabled = false WHERE feature = 'spotify';
SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'f3000000-0000-0000-0000-000000000001';
SET LOCAL request.jwt.claims = '{"role":"authenticated","sub":"f3000000-0000-0000-0000-000000000001","session_id":"f3000000-0000-0000-0000-000000000001"}';
SELECT results_eq($$ SELECT username FROM public.discover_public_users('discover_', 30) $$,
  $$ VALUES ('discover_bob'::text), ('discover_carol'::text) $$,
  'Ordinary community discovery works without Spotify, excludes self, both block directions and test profiles');
SELECT results_eq($$ SELECT id, username, display_name, avatar_url, bio FROM public.discover_public_users('PUBLIC BOB', 30) $$,
  $$ VALUES ('f3000000-0000-0000-0000-000000000002'::uuid, 'discover_bob'::text, 'Public Bob'::text, 'https://example.invalid/avatar.jpg'::text, 'Public bio'::text) $$,
  'Case-insensitive display-name search returns only the requested public fields');
SELECT results_eq($$ SELECT username FROM public.discover_public_users('%', 30) $$,
  $$ VALUES ('discover_carol'::text) $$, 'Percent is a literal character, not a wildcard');
SELECT is_empty($$ SELECT * FROM public.discover_public_users('bob OR 1=1', 30) $$,
  'Search input cannot inject predicates');
SELECT is((SELECT count(*) FROM public.discover_public_users('discover_', 0)), 1::bigint, 'The server clamps a zero limit');
SELECT is((SELECT count(*) FROM public.discover_public_users('discover_', NULL)), 2::bigint, 'A null limit uses the safe default');
SELECT is((SELECT count(*) FROM public.discover_public_users('bounds_', 500)), 50::bigint, 'The server prevents oversized discovery pages');
SELECT is((SELECT count(*) FROM public.discover_public_users('bounds_', NULL)), 30::bigint, 'The default discovery page contains at most thirty people');
SELECT lives_ok($$ SELECT * FROM public.discover_public_users(repeat('x', 100), 30) $$, 'A query at the documented length boundary is valid');
SELECT throws_like($$ SELECT * FROM public.discover_public_users(repeat('x', 101), 30) $$,
  '%100 characters%', 'The server rejects excessive search input');
SELECT is((SELECT prosecdef FROM pg_proc WHERE oid = 'public.discover_public_users(text,integer)'::regprocedure), false,
  'Community search runs as the caller and preserves existing view RLS');
SELECT is(has_function_privilege('service_role', 'public.discover_public_users(text,integer)', 'EXECUTE'), false,
  'The public community RPC is available only to authenticated user callers');
SELECT is((SELECT array_to_string(proargnames[3:7], ',') FROM pg_proc WHERE oid = 'public.discover_public_users(text,integer)'::regprocedure),
  'id,username,display_name,avatar_url,bio', 'The RPC exposes no email, coordinates or Spotify fields');

SET LOCAL request.jwt.claim.sub = 'f3000000-0000-0000-0000-000000000006';
SET LOCAL request.jwt.claims = '{"role":"authenticated","sub":"f3000000-0000-0000-0000-000000000006","session_id":"f3000000-0000-0000-0000-000000000006"}';
SELECT is_empty($$ SELECT * FROM public.discover_public_users('discover_', 30) $$,
  'A test identity cannot discover real users and its own row is excluded');
SET LOCAL ROLE postgres;
DELETE FROM auth.sessions WHERE user_id = 'f3000000-0000-0000-0000-000000000001';
SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'f3000000-0000-0000-0000-000000000001';
SET LOCAL request.jwt.claims = '{"role":"authenticated","sub":"f3000000-0000-0000-0000-000000000001","session_id":"f3000000-0000-0000-0000-000000000001"}';
SELECT throws_like($$ SELECT * FROM public.discover_public_users('', 30) $$, '%Session revoked%',
  'A revoked session cannot use community discovery');
SET LOCAL ROLE anon;
SELECT throws_like($$ SELECT * FROM public.discover_public_users('', 30) $$, '%permission denied%',
  'Anonymous callers cannot enumerate public user profiles');
SELECT * FROM finish();
ROLLBACK;
