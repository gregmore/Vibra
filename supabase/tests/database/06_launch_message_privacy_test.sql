BEGIN;
\ir ../pgtap_setup.inc
SELECT plan(22);

INSERT INTO auth.users (id, email) VALUES
  ('c1000000-0000-0000-0000-000000000001', 'message-alice@example.invalid'),
  ('c1000000-0000-0000-0000-000000000002', 'message-bob@example.invalid'),
  ('c1000000-0000-0000-0000-000000000003', 'message-eve@example.invalid');
INSERT INTO public.users (id, username) VALUES
  ('c1000000-0000-0000-0000-000000000001', 'message-alice'),
  ('c1000000-0000-0000-0000-000000000002', 'message-bob'),
  ('c1000000-0000-0000-0000-000000000003', 'message-eve');
INSERT INTO auth.sessions (id, user_id) SELECT id, id FROM auth.users ON CONFLICT DO NOTHING;
INSERT INTO public.privacy_preferences (user_id, location_processing)
SELECT id, true FROM public.users WHERE id::text LIKE 'c1000000%';
UPDATE public.users SET last_latitude = 45.4642, last_longitude = 9.1900
WHERE id::text LIKE 'c1000000%';
UPDATE public.users SET last_latitude = 41.9028, last_longitude = 12.4964
WHERE id = 'c1000000-0000-0000-0000-000000000003';

SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'c1000000-0000-0000-0000-000000000001';
SET LOCAL request.jwt.claims = '{"role":"authenticated","sub":"c1000000-0000-0000-0000-000000000001","session_id":"c1000000-0000-0000-0000-000000000001"}';
SELECT is((SELECT count(*) FROM public.users), 1::bigint, 'Nearby messaging does not expose the receiver private profile');
SELECT lives_ok($$ INSERT INTO public.messages (id, sender_id, receiver_id, content, media_path)
  VALUES ('c2000000-0000-0000-0000-000000000001', 'c1000000-0000-0000-0000-000000000001',
    'c1000000-0000-0000-0000-000000000002', 'Hello', 'c1000000-0000-0000-0000-000000000001/photo.png') $$,
  'Nearby nonfriends can send a genuine initial request');
SELECT throws_like($$ INSERT INTO public.messages (sender_id, receiver_id, content)
  VALUES ('c1000000-0000-0000-0000-000000000001', 'c1000000-0000-0000-0000-000000000003', 'Hello') $$,
  '%row-level security%', 'A remote stranger cannot be contacted');
SELECT lives_ok($$ INSERT INTO public.messages (sender_id, receiver_id, content)
  SELECT 'c1000000-0000-0000-0000-000000000001'::uuid, 'c1000000-0000-0000-0000-000000000002'::uuid,
    'Initial request ' || n FROM generate_series(2, 3) n $$, 'An unanswered nearby request allows three messages');
SELECT throws_like($$ INSERT INTO public.messages (sender_id, receiver_id, content)
  VALUES ('c1000000-0000-0000-0000-000000000001', 'c1000000-0000-0000-0000-000000000002', 'Fourth request') $$,
  '%more than 3 messages%', 'An unanswered stranger cannot send a fourth request');

SET LOCAL ROLE postgres;
INSERT INTO storage.objects (bucket_id, name) VALUES ('chat-media', 'c1000000-0000-0000-0000-000000000001/photo.png');
UPDATE public.users SET last_location = NULL, last_latitude = NULL, last_longitude = NULL
WHERE id = 'c1000000-0000-0000-0000-000000000002';
SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'c1000000-0000-0000-0000-000000000002';
SET LOCAL request.jwt.claims = '{"role":"authenticated","sub":"c1000000-0000-0000-0000-000000000002","session_id":"c1000000-0000-0000-0000-000000000002"}';
SELECT is((SELECT is_message_request FROM public.get_user_conversations()), true, 'An initial incoming contact is a request');
SELECT lives_ok($$ INSERT INTO public.messages (sender_id, receiver_id, content)
  VALUES ('c1000000-0000-0000-0000-000000000002', 'c1000000-0000-0000-0000-000000000001', 'Reply') $$,
  'The recipient can reply after moving or disabling location');
SELECT is((SELECT count(*) FROM storage.objects WHERE bucket_id = 'chat-media'), 1::bigint, 'A recipient can access a referenced private image');

SET LOCAL request.jwt.claim.sub = 'c1000000-0000-0000-0000-000000000001';
SET LOCAL request.jwt.claims = '{"role":"authenticated","sub":"c1000000-0000-0000-0000-000000000001","session_id":"c1000000-0000-0000-0000-000000000001"}';
SELECT lives_ok($$ INSERT INTO public.messages (sender_id, receiver_id, content)
  VALUES ('c1000000-0000-0000-0000-000000000001', 'c1000000-0000-0000-0000-000000000002', 'Following reply') $$,
  'An established conversation continues without current proximity');
SET LOCAL request.jwt.claim.sub = 'c1000000-0000-0000-0000-000000000002';
SET LOCAL request.jwt.claims = '{"role":"authenticated","sub":"c1000000-0000-0000-0000-000000000002","session_id":"c1000000-0000-0000-0000-000000000002"}';
SELECT is((SELECT is_message_request FROM public.get_user_conversations()), false, 'The next incoming reply does not reset acceptance');

SET LOCAL ROLE postgres;
INSERT INTO public.blocked_users (blocker_id, blocked_id)
VALUES ('c1000000-0000-0000-0000-000000000001', 'c1000000-0000-0000-0000-000000000002');
SET LOCAL ROLE authenticated;
SELECT is_empty('SELECT * FROM public.blocked_users', 'The blocked party cannot enumerate who blocked them');
SELECT is_empty('SELECT * FROM public.messages', 'The blocked party cannot read message history');
SELECT is_empty('SELECT * FROM public.get_user_conversations()', 'The summary RPC does not bypass blocking');
SELECT is_empty('SELECT * FROM storage.objects WHERE bucket_id = ''chat-media''', 'The blocked party cannot retrieve referenced private media');
SELECT lives_ok($$ SELECT public.react_to_message('c2000000-0000-0000-0000-000000000001', 'c1000000-0000-0000-0000-000000000002', 'heart') $$,
  'An inaccessible reaction is harmless');
SET LOCAL ROLE postgres;
SELECT is((SELECT reactions FROM public.messages WHERE id = 'c2000000-0000-0000-0000-000000000001'), NULL::jsonb,
  'A blocked reaction does not modify the private message');
DELETE FROM public.blocked_users WHERE blocker_id = 'c1000000-0000-0000-0000-000000000001';
INSERT INTO public.friendships (requester_id, receiver_id, status)
VALUES ('c1000000-0000-0000-0000-000000000001', 'c1000000-0000-0000-0000-000000000003', 'accepted');
SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'c1000000-0000-0000-0000-000000000001';
SET LOCAL request.jwt.claims = '{"role":"authenticated","sub":"c1000000-0000-0000-0000-000000000001","session_id":"c1000000-0000-0000-0000-000000000001"}';
SELECT lives_ok($$ INSERT INTO public.messages (sender_id, receiver_id, content)
  SELECT 'c1000000-0000-0000-0000-000000000001'::uuid, 'c1000000-0000-0000-0000-000000000003'::uuid,
    'Friend message ' || n FROM generate_series(1, 4) n $$, 'Accepted friends can send more than three messages without a reply');
SELECT is((SELECT is_message_request FROM public.get_user_conversations()
  WHERE other_user_id = 'c1000000-0000-0000-0000-000000000003'), false, 'Accepted friendship is an ordinary conversation');
SET LOCAL request.jwt.claim.sub = 'c1000000-0000-0000-0000-000000000002';
SET LOCAL request.jwt.claims = '{"role":"authenticated","sub":"c1000000-0000-0000-0000-000000000002","session_id":"c1000000-0000-0000-0000-000000000002"}';
SELECT public.soft_delete_chat('c1000000-0000-0000-0000-000000000002', 'c1000000-0000-0000-0000-000000000001');
SELECT is_empty('SELECT * FROM public.messages', 'A locally deleted conversation is hidden in direct reads');
SELECT is_empty('SELECT * FROM storage.objects WHERE bucket_id = ''chat-media''', 'Deleted conversations no longer authorize media access');
SELECT throws_like($$ SELECT public.soft_delete_chat('c1000000-0000-0000-0000-000000000001', 'c1000000-0000-0000-0000-000000000002') $$,
  '%own chats%', 'A participant cannot delete the other user history');
SET LOCAL ROLE postgres;
DELETE FROM auth.sessions WHERE user_id = 'c1000000-0000-0000-0000-000000000002';
SET LOCAL ROLE authenticated;
SELECT throws_like('SELECT * FROM public.get_user_conversations()', '%Session revoked%', 'The summary RPC rejects a revoked session independently of the HTTP hook');

SELECT * FROM finish();
ROLLBACK;
