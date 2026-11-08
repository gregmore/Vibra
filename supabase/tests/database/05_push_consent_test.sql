BEGIN;
\ir ../pgtap_setup.inc
SELECT plan(6);
INSERT INTO auth.users (id, email) VALUES ('b2000000-0000-0000-0000-000000000001', 'push-test@example.invalid');
INSERT INTO public.users (id, username) VALUES ('b2000000-0000-0000-0000-000000000001', 'push-consent-fixture');
UPDATE public.users SET push_enabled = false, fcm_token = 'fixture-token'
WHERE id = 'b2000000-0000-0000-0000-000000000001';
SELECT is((SELECT fcm_token FROM public.users WHERE id = 'b2000000-0000-0000-0000-000000000001'), NULL::text, 'Opt-out clears the token atomically');
UPDATE public.users SET fcm_token = 'late-refresh'
WHERE id = 'b2000000-0000-0000-0000-000000000001';
SELECT is((SELECT fcm_token FROM public.users WHERE id = 'b2000000-0000-0000-0000-000000000001'), NULL::text, 'A late refresh cannot bypass opt-out');
UPDATE public.users SET push_enabled = true, fcm_token = 'enabled-token'
WHERE id = 'b2000000-0000-0000-0000-000000000001';
SELECT is((SELECT fcm_token FROM public.users WHERE id = 'b2000000-0000-0000-0000-000000000001'), 'enabled-token', 'Opt-in accepts a device token');
SELECT is(has_function_privilege('authenticated', 'vibra_private.enforce_push_consent()', 'EXECUTE'), false, 'Clients cannot call the consent trigger directly');
INSERT INTO public.notifications (user_id, type, title, body, data) VALUES
('b2000000-0000-0000-0000-000000000001', 'event_alert', 'Test', 'Test', '{"event_id":"fixture-event","reminder":true,"reminder_days":1}');
SELECT throws_like(
  $$ INSERT INTO public.notifications (user_id, type, title, body, data) VALUES
  ('b2000000-0000-0000-0000-000000000001', 'event_alert', 'Test', 'Test', '{"event_id":"fixture-event","reminder":true,"reminder_days":1}') $$,
  '%duplicate key%', 'The same event milestone cannot be enqueued twice'
);
SELECT lives_ok(
  $$ INSERT INTO public.notifications (user_id, type, title, body, data) VALUES
  ('b2000000-0000-0000-0000-000000000001', 'event_alert', 'Test', 'Test', '{"event_id":"fixture-event","reminder":true,"reminder_days":0}') $$,
  'Different milestones for the same event remain allowed'
);
SELECT * FROM finish();
ROLLBACK;
