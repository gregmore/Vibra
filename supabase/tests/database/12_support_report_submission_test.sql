BEGIN;
\ir ../pgtap_setup.inc
SELECT plan(9);

INSERT INTO auth.users (id, email) VALUES
  ('a1400000-0000-0000-0000-000000000001', 'support-alice@example.invalid'),
  ('a1400000-0000-0000-0000-000000000002', 'support-bob@example.invalid');
INSERT INTO public.users (id, username) VALUES
  ('a1400000-0000-0000-0000-000000000001', 'support-alice'),
  ('a1400000-0000-0000-0000-000000000002', 'support-bob');
INSERT INTO auth.sessions (id, user_id) SELECT id, id FROM auth.users
WHERE id::text LIKE 'a1400000%' ON CONFLICT DO NOTHING;

SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'a1400000-0000-0000-0000-000000000001';
SET LOCAL request.jwt.claims = '{"role":"authenticated","sub":"a1400000-0000-0000-0000-000000000001","session_id":"a1400000-0000-0000-0000-000000000001"}';
SELECT lives_ok($$ INSERT INTO public.support_reports (user_id, description, diagnostics)
  VALUES ('a1400000-0000-0000-0000-000000000001', 'The map does not open',
    jsonb_build_object('platform', 'ios', 'recent_logs', '[]'::jsonb)) $$,
  'A support report succeeds without native metadata or a returned row');
SELECT lives_ok($$ INSERT INTO public.support_reports (user_id, description, screenshot_path, diagnostics)
  VALUES ('a1400000-0000-0000-0000-000000000001', repeat('😀', 4000),
    'a1400000-0000-0000-0000-000000000001/screenshot.png',
    jsonb_build_object('recent_logs', jsonb_build_array(repeat('😀', 512)))) $$,
  'The server accepts 4000 Unicode characters and a bounded private attachment report');
SELECT throws_like($$ INSERT INTO public.support_reports (user_id, description)
  VALUES ('a1400000-0000-0000-0000-000000000001', '😀😀😀😀') $$,
  '%check constraint%', 'Four emoji remain fewer than eight database characters');
SELECT throws_like($$ INSERT INTO public.support_reports (user_id, description, diagnostics)
  VALUES ('a1400000-0000-0000-0000-000000000001', 'The map does not open',
    jsonb_build_object('recent_logs', repeat('😀', 9000))) $$,
  '%support_diagnostics_limit%', 'The original unbounded logs reproduce a backend rejection');
SELECT throws_like($$ INSERT INTO public.support_reports (user_id, description)
  VALUES ('a1400000-0000-0000-0000-000000000002', 'The map does not open') $$,
  '%row-level security%', 'A report cannot be submitted on behalf of another account');
SELECT throws_like($$ INSERT INTO public.support_reports (user_id, description, screenshot_path)
  VALUES ('a1400000-0000-0000-0000-000000000001', 'The map does not open',
    'a1400000-0000-0000-0000-000000000002/screenshot.png') $$,
  '%belong to the sender%', 'A private screenshot must belong to the sender');
SELECT throws_like($$ INSERT INTO public.support_reports (user_id, description, status)
  VALUES ('a1400000-0000-0000-0000-000000000001', 'The map does not open', 'resolved') $$,
  '%backend-managed%', 'The app cannot forge a resolved support status');
SELECT throws_like('SELECT * FROM public.support_reports', '%permission denied%',
  'A successful submission does not grant access to the private support queue');

SET LOCAL ROLE postgres;
DELETE FROM auth.sessions WHERE user_id = 'a1400000-0000-0000-0000-000000000001';
SET LOCAL ROLE authenticated;
SELECT throws_like($$ INSERT INTO public.support_reports (user_id, description)
  VALUES ('a1400000-0000-0000-0000-000000000001', 'The map does not open') $$,
  '%Session revoked%', 'A revoked session cannot submit a report');

SELECT * FROM finish();
ROLLBACK;
