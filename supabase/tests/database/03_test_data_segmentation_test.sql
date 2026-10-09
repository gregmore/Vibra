BEGIN;
\ir ../pgtap_setup.inc
SELECT plan(10);

INSERT INTO auth.users (id, email, raw_app_meta_data) VALUES
  ('71000000-0000-4000-8000-000000000001', 'segment-real@example.com', '{"is_test_user":false}'::jsonb),
  ('71000000-0000-4000-8000-000000000002', 'segment-test-a@example.com', '{"is_test_user":true}'::jsonb),
  ('71000000-0000-4000-8000-000000000003', 'segment-test-b@example.com', '{"is_test_user":true}'::jsonb);

INSERT INTO public.users (id, username) VALUES
  ('71000000-0000-4000-8000-000000000001', 'segment_real'),
  ('71000000-0000-4000-8000-000000000002', 'segment_test_a'),
  ('71000000-0000-4000-8000-000000000003', 'segment_test_b')
ON CONFLICT (id) DO UPDATE SET username = EXCLUDED.username;

SELECT results_eq(
  $$
    SELECT username::text, is_test_user
    FROM public.users
    WHERE id::text LIKE '71000000-%'
    ORDER BY username
  $$,
  $$ VALUES
    ('segment_real'::text, false),
    ('segment_test_a'::text, true),
    ('segment_test_b'::text, true)
  $$,
  'The public profile test flag is derived from auth app_metadata'
);

INSERT INTO public.events (
  id, external_id, source, name, event_date, latitude, longitude, is_test_data
) VALUES
  ('72000000-0000-4000-8000-000000000001', 'segment-real-event', 'ticketmaster', 'Segment Real Event', now() + interval '1 day', 45.46, 9.19, false),
  ('72000000-0000-4000-8000-000000000002', 'segment-test-event', 'ticketmaster', 'Segment Test Event', now() + interval '1 day', 45.46, 9.19, true);

INSERT INTO public.event_attendees (id, user_id, event_id, status) VALUES
  ('73000000-0000-4000-8000-000000000001', '71000000-0000-4000-8000-000000000002', '72000000-0000-4000-8000-000000000002', 'going'),
  ('73000000-0000-4000-8000-000000000002', '71000000-0000-4000-8000-000000000003', '72000000-0000-4000-8000-000000000002', 'going');

INSERT INTO public.music_profiles (user_id, top_artists, top_genres, embedding) VALUES
  ('71000000-0000-4000-8000-000000000001', '[]', '[]', '[0.9,0.8,0.7,0.6,0.5,0.4,0.3,0.2,0.1,0.0]'),
  ('71000000-0000-4000-8000-000000000002', '[]', '[]', '[0.9,0.8,0.7,0.6,0.5,0.4,0.3,0.2,0.1,0.0]'),
  ('71000000-0000-4000-8000-000000000003', '[]', '[]', '[0.8,0.7,0.6,0.5,0.4,0.3,0.2,0.1,0.0,0.1]');

INSERT INTO public.privacy_preferences (user_id,spotify_matching) SELECT id,true FROM public.users ON CONFLICT (user_id) DO UPDATE SET spotify_matching=true;

INSERT INTO auth.sessions (id,user_id) SELECT id,id FROM auth.users ON CONFLICT DO NOTHING;
SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claim.sub TO '71000000-0000-4000-8000-000000000002';
SET LOCAL request.jwt.claims TO '{"role":"authenticated","sub":"71000000-0000-4000-8000-000000000002","session_id":"71000000-0000-4000-8000-000000000002"}';
SET LOCAL request.jwt.claim.role TO 'authenticated';

SELECT is(
  (SELECT count(*) FROM public.users_public WHERE id::text LIKE '71000000-%'),
  2::bigint,
  'A test identity discovers only test profiles'
);

SELECT is(
  (SELECT count(*) FROM public.events WHERE id::text LIKE '72000000-%'),
  2::bigint,
  'A test identity can exercise real and synthetic staging events'
);

SELECT is(
  (SELECT count(*) FROM public.event_attendees WHERE id::text LIKE '73000000-%'),
  1::bigint,
  'Saved events remain private even inside the test segment'
);

SELECT results_eq(
  $$
    SELECT user_id
    FROM public.find_compatible_users(
      '71000000-0000-4000-8000-000000000002',
      '[0.9,0.8,0.7,0.6,0.5,0.4,0.3,0.2,0.1,0.0]'::vector,
      50
    )
  $$,
  $$ VALUES ('71000000-0000-4000-8000-000000000003'::uuid) $$,
  'Compatibility candidate generation stays in the test segment'
);

SET LOCAL request.jwt.claim.sub TO '71000000-0000-4000-8000-000000000001';
SET LOCAL request.jwt.claims TO '{"role":"authenticated","sub":"71000000-0000-4000-8000-000000000001","session_id":"71000000-0000-4000-8000-000000000001"}';

SELECT is(
  (SELECT count(*) FROM public.users_public WHERE id::text LIKE '71000000-%'),
  1::bigint,
  'A real identity discovers only real profiles'
);

SELECT is(
  (SELECT count(*) FROM public.events WHERE id::text LIKE '72000000-%'),
  1::bigint,
  'A real identity cannot read synthetic events'
);

SET LOCAL ROLE anon;
RESET request.jwt.claim.sub;
SET LOCAL request.jwt.claim.role TO 'anon';

SELECT is(
  (SELECT count(*) FROM public.events WHERE id::text LIKE '72000000-%'),
  1::bigint,
  'Anonymous event discovery excludes synthetic events'
);

SET LOCAL ROLE postgres;
SELECT throws_like(
  $$
    INSERT INTO public.user_matches (
      user_id_a, user_id_b, compatibility, shared_artists, shared_genres
    ) VALUES (
      '71000000-0000-4000-8000-000000000001',
      '71000000-0000-4000-8000-000000000002',
      50, 0, 0
    )
  $$,
  '%Real and test users cannot share social edges%',
  'Even a privileged job cannot create a cross-segment match'
);

SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claim.sub TO '71000000-0000-4000-8000-000000000002';
SET LOCAL request.jwt.claims TO '{"role":"authenticated","sub":"71000000-0000-4000-8000-000000000002","session_id":"71000000-0000-4000-8000-000000000002"}';
SET LOCAL request.jwt.claim.role TO 'authenticated';
SELECT throws_like(
  $$
    SELECT * FROM public.find_compatible_users(
      '71000000-0000-4000-8000-000000000001',
      '[0.9,0.8,0.7,0.6,0.5,0.4,0.3,0.2,0.1,0.0]'::vector,
      50
    )
  $$,
  '%only for itself%',
  'A client cannot request candidates for another identity'
);

SELECT * FROM finish();
ROLLBACK;
