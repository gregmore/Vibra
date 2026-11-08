BEGIN;
\ir ../pgtap_setup.inc
SELECT plan(21);

-- Production derives this flag from trusted auth metadata, never profile input.
INSERT INTO auth.users (id, email, raw_app_meta_data) VALUES
  ('f3000000-0000-0000-0000-000000000001', 'permission-alice@example.invalid', '{"is_test_user":false}'::jsonb),
  ('f3000000-0000-0000-0000-000000000002', 'permission-bob@example.invalid', '{"is_test_user":false}'::jsonb),
  ('f3000000-0000-0000-0000-000000000003', 'permission-carol@example.invalid', '{"is_test_user":false}'::jsonb),
  ('f3000000-0000-0000-0000-000000000004', 'permission-test@example.invalid', '{"is_test_user":true}'::jsonb);
INSERT INTO public.users (id, username) VALUES
  ('f3000000-0000-0000-0000-000000000001', 'permission-alice'),
  ('f3000000-0000-0000-0000-000000000002', 'permission-bob'),
  ('f3000000-0000-0000-0000-000000000003', 'permission-carol'),
  ('f3000000-0000-0000-0000-000000000004', 'permission-test');
INSERT INTO auth.sessions (id, user_id)
SELECT id, id FROM auth.users WHERE id::text LIKE 'f3000000%';
INSERT INTO public.privacy_preferences (user_id, location_processing)
SELECT id, true FROM public.users WHERE id::text LIKE 'f3000000%';
UPDATE public.users SET last_latitude = 45.4642, last_longitude = 9.1900
WHERE id IN ('f3000000-0000-0000-0000-000000000001', 'f3000000-0000-0000-0000-000000000002');

SELECT is(has_function_privilege('anon', 'public.message_send_permission(uuid)', 'execute'), false, 'Anonymous callers cannot inspect messaging permission');
SELECT is(has_function_privilege('authenticated', 'public.message_send_permission(uuid)', 'execute'), true, 'Signed-in callers can inspect their own messaging permission');
SELECT is(has_function_privilege('service_role', 'public.message_send_permission(uuid)', 'execute'), false, 'Service role cannot act as a caller');
SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'f3000000-0000-0000-0000-000000000001';
SET LOCAL request.jwt.claims = '{"role":"authenticated","sub":"f3000000-0000-0000-0000-000000000001","session_id":"f3000000-0000-0000-0000-000000000001"}';
SELECT is(public.message_send_permission('f3000000-0000-0000-0000-000000000001'), 'unavailable', 'Self messages remain unavailable');
SELECT is(public.message_send_permission(NULL), 'unavailable', 'A missing target is unavailable');
SELECT is(public.message_send_permission('f3000000-0000-0000-0000-000000000099'), 'unavailable', 'A nonexistent profile is unavailable');
SELECT is(public.message_send_permission('f3000000-0000-0000-0000-000000000003'), 'friendship_required', 'No GPS or friendship explains why distant first contact is unavailable');
INSERT INTO public.friendships (requester_id, receiver_id, status) VALUES
  ('f3000000-0000-0000-0000-000000000001', 'f3000000-0000-0000-0000-000000000003', 'pending');
SELECT is(public.message_send_permission('f3000000-0000-0000-0000-000000000003'), 'friendship_required', 'A pending request does not prematurely authorize messages');
SELECT is(public.message_send_permission('f3000000-0000-0000-0000-000000000002'), 'allowed', 'Nearby first contact is allowed without revealing location');
INSERT INTO public.messages (sender_id, receiver_id, content)
SELECT 'f3000000-0000-0000-0000-000000000001'::uuid, 'f3000000-0000-0000-0000-000000000002'::uuid, 'Initial request ' || n
FROM generate_series(1, 3) n;
SELECT is(public.message_send_permission('f3000000-0000-0000-0000-000000000002'), 'awaiting_reply', 'Three unanswered messages explain the first-contact cap');

SET LOCAL ROLE postgres;
INSERT INTO public.blocked_users (blocker_id, blocked_id) VALUES
  ('f3000000-0000-0000-0000-000000000001', 'f3000000-0000-0000-0000-000000000002');
SET LOCAL ROLE authenticated;
SELECT is(public.message_send_permission('f3000000-0000-0000-0000-000000000002'), 'unavailable', 'Blocking never presents a misleading friendship action');
SET LOCAL request.jwt.claim.sub = 'f3000000-0000-0000-0000-000000000002';
SET LOCAL request.jwt.claims = '{"role":"authenticated","sub":"f3000000-0000-0000-0000-000000000002","session_id":"f3000000-0000-0000-0000-000000000002"}';
SELECT is(public.message_send_permission('f3000000-0000-0000-0000-000000000001'), 'unavailable', 'The blocked party sees the same generic unavailable result');
SET LOCAL ROLE postgres;
DELETE FROM public.blocked_users WHERE blocker_id = 'f3000000-0000-0000-0000-000000000001';
UPDATE public.friendships SET status = 'accepted' WHERE requester_id = 'f3000000-0000-0000-0000-000000000001';
SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'f3000000-0000-0000-0000-000000000001';
SET LOCAL request.jwt.claims = '{"role":"authenticated","sub":"f3000000-0000-0000-0000-000000000001","session_id":"f3000000-0000-0000-0000-000000000001"}';
SELECT is(public.message_send_permission('f3000000-0000-0000-0000-000000000003'), 'allowed_friend', 'Acceptance immediately authorizes the distant conversation');
SET LOCAL ROLE postgres;
UPDATE public.users SET last_latitude = NULL, last_longitude = NULL, last_location = NULL
WHERE id::text LIKE 'f3000000%';
SET LOCAL ROLE authenticated;
SELECT is(public.message_send_permission('f3000000-0000-0000-0000-000000000003'), 'allowed_friend', 'Accepted friends do not need GPS');
SET LOCAL request.jwt.claim.sub = 'f3000000-0000-0000-0000-000000000002';
SET LOCAL request.jwt.claims = '{"role":"authenticated","sub":"f3000000-0000-0000-0000-000000000002","session_id":"f3000000-0000-0000-0000-000000000002"}';
SELECT is(public.message_send_permission('f3000000-0000-0000-0000-000000000001'), 'allowed', 'A recipient may reply after removing GPS');
INSERT INTO public.messages (sender_id, receiver_id, content) VALUES
  ('f3000000-0000-0000-0000-000000000002', 'f3000000-0000-0000-0000-000000000001', 'A reply');
SET LOCAL request.jwt.claim.sub = 'f3000000-0000-0000-0000-000000000001';
SET LOCAL request.jwt.claims = '{"role":"authenticated","sub":"f3000000-0000-0000-0000-000000000001","session_id":"f3000000-0000-0000-0000-000000000001"}';
SELECT is(public.message_send_permission('f3000000-0000-0000-0000-000000000002'), 'allowed', 'A reply reopens the composer without GPS');
SET LOCAL ROLE postgres;
INSERT INTO vibra_private.action_limits (user_id, action, window_start, count)
VALUES ('f3000000-0000-0000-0000-000000000001', 'messages', clock_timestamp(), 30)
ON CONFLICT (user_id, action) DO UPDATE SET count = 30, window_start = clock_timestamp();
SET LOCAL ROLE authenticated;
SELECT is(public.message_send_permission('f3000000-0000-0000-0000-000000000003'), 'rate_limited', 'The minute rate limit has an actionable explanation');
SET LOCAL ROLE postgres;
UPDATE vibra_private.action_limits SET window_start = clock_timestamp() - interval '2 minutes'
WHERE user_id = 'f3000000-0000-0000-0000-000000000001' AND action = 'messages';
SET LOCAL ROLE authenticated;
SELECT is(public.message_send_permission('f3000000-0000-0000-0000-000000000003'), 'allowed_friend', 'An expired rate limit permits a retry');
SELECT is(public.message_send_permission('f3000000-0000-0000-0000-000000000004'), 'unavailable', 'Test and production segments remain isolated');
SELECT throws_like($$ INSERT INTO public.messages (sender_id, receiver_id, content)
  VALUES ('f3000000-0000-0000-0000-000000000001', 'f3000000-0000-0000-0000-000000000004', 'Unauthorized') $$,
  '%cannot share social edges%', 'The explanation RPC does not weaken actual insert controls');
SET LOCAL ROLE postgres;
DELETE FROM auth.sessions WHERE user_id = 'f3000000-0000-0000-0000-000000000001';
SET LOCAL ROLE authenticated;
SELECT throws_like($$ SELECT public.message_send_permission('f3000000-0000-0000-0000-000000000003') $$,
  '%Session revoked%', 'Revoked sessions cannot inspect permission');

SELECT * FROM finish();
ROLLBACK;
