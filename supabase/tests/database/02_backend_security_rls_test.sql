BEGIN;
\ir ../pgtap_setup.inc
SELECT plan(5);

INSERT INTO auth.users (id, email) VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'alice@vibra.test'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'bob@vibra.test');
INSERT INTO public.users (id, username) VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'alice-vibra'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'bob-vibra')
ON CONFLICT (id) DO UPDATE SET username = EXCLUDED.username;

INSERT INTO public.spotify_connections (user_id, spotify_user_id, access_token_ciphertext, token_expires_at)
VALUES ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'spotify-alice', 'v1.a.b', now());
INSERT INTO public.blocked_users (blocker_id, blocked_id)
VALUES ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb');

INSERT INTO auth.sessions (id,user_id) SELECT id,id FROM auth.users ON CONFLICT DO NOTHING;
SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claim.sub TO 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
SET LOCAL request.jwt.claims TO '{"role":"authenticated","sub":"bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb","session_id":"bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"}';

SELECT is_empty('SELECT * FROM public.spotify_connections', 'Client roles cannot read encrypted Spotify credentials');
SELECT is_empty('SELECT * FROM public.blocked_users', 'Blocked user cannot enumerate blockers');
SELECT throws_like(
  $$ INSERT INTO public.blocked_users (blocker_id, blocked_id) VALUES ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb') $$,
  '%check constraint%', 'Users cannot block themselves');
SELECT throws_like(
  $$ INSERT INTO public.messages (sender_id, receiver_id, content) VALUES ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'hello') $$,
  '%block exists%', 'A blocked user cannot message the blocker');

SET LOCAL request.jwt.claim.sub TO 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
SET LOCAL request.jwt.claims TO '{"role":"authenticated","sub":"aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa","session_id":"aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"}';
SELECT results_eq('SELECT blocker_id FROM public.blocked_users', $$ VALUES ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid) $$, 'Block owner can list own blocks');
SELECT * FROM finish();
ROLLBACK;
