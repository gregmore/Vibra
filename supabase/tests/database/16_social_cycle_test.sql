BEGIN;
\ir ../pgtap_setup.inc
SELECT plan(68);

-- Features of the 2026-11 cycle (migrations 20261108–20261127): every
-- client read runs for a signed-in user (catches runtime SQL errors that
-- applying a migration cannot), server-only functions refuse clients,
-- internal state is unreachable, and blocks apply across features.
-- me, friend (follows each other), blocked (blocks me).
INSERT INTO auth.users (id, email, raw_app_meta_data) VALUES
  ('f1600000-0000-4000-8000-000000000001', 'cyc-me@example.invalid', '{"is_test_user":false}'),
  ('f1600000-0000-4000-8000-000000000002', 'cyc-friend@example.invalid', '{"is_test_user":false}'),
  ('f1600000-0000-4000-8000-000000000003', 'cyc-blocked@example.invalid', '{"is_test_user":false}');
INSERT INTO public.users (id, username) VALUES
  ('f1600000-0000-4000-8000-000000000001', 'cyc_me'),
  ('f1600000-0000-4000-8000-000000000002', 'cyc_friend'),
  ('f1600000-0000-4000-8000-000000000003', 'cyc_blocked')
ON CONFLICT (id) DO UPDATE SET username = EXCLUDED.username;
INSERT INTO auth.sessions (id, user_id) SELECT id, id FROM auth.users WHERE id::text LIKE 'f16%' ON CONFLICT DO NOTHING;
UPDATE public.launch_features SET enabled = true WHERE feature = 'spotify';
INSERT INTO public.privacy_preferences (user_id, spotify_matching)
SELECT id, true FROM public.users WHERE id::text LIKE 'f16%'
ON CONFLICT (user_id) DO UPDATE SET spotify_matching = true;
INSERT INTO public.user_genre_preferences (user_id, genre_key, intensity)
SELECT id, 'trap', 80 FROM public.users WHERE id::text LIKE 'f16%';
INSERT INTO public.follows (follower_id, following_id) VALUES
  ('f1600000-0000-4000-8000-000000000001', 'f1600000-0000-4000-8000-000000000002'),
  ('f1600000-0000-4000-8000-000000000002', 'f1600000-0000-4000-8000-000000000001');
INSERT INTO public.user_matches (user_id_a, user_id_b, compatibility, details)
VALUES ('f1600000-0000-4000-8000-000000000001', 'f1600000-0000-4000-8000-000000000002', 88, '{"v":2}');

-- ── Server-side writes (service role) ─────────────────────────────────────
SET LOCAL ROLE service_role;
SET LOCAL request.jwt.claims = '{"role":"service_role"}';
SELECT lives_ok($$ SELECT public.create_feed_post('f1600000-0000-4000-8000-000000000002',
  '{"kind":"opinion","body":"Friend post","genre_keys":["trap"]}'::jsonb) $$,
  'The service role publishes a feed post');
SELECT lives_ok($$ SELECT public.create_feed_post('f1600000-0000-4000-8000-000000000003',
  '{"kind":"opinion","body":"Blocked post"}'::jsonb) $$, 'Another author posts');
SELECT lives_ok($$ SELECT public.record_notification('f1600000-0000-4000-8000-000000000001',
  'friend_request', 'New request', 'cyc_friend wants to connect', '{}'::jsonb,
  'f1600000-0000-4000-8000-000000000002', 'follow:f16') $$,
  'The one notification policy stores a notification');
SELECT lives_ok($$ SELECT public.set_job_cursor('send-notifications', 'f1600000-0000-4000-8000-000000000002') $$,
  'Workers save their keyset cursor');
SELECT is(public.get_job_cursor('send-notifications')::text, 'f1600000-0000-4000-8000-000000000002',
  'The cursor resumes where the last run stopped');
SELECT lives_ok($$ SELECT public.set_job_cursor('send-notifications', NULL) $$, 'A finished pass resets it');
SELECT lives_ok($$ SELECT public.record_affinity_fingerprint('f1600000-0000-4000-8000-000000000001', repeat('a', 64)) $$,
  'The affinity fingerprint is recorded');
SELECT is(public.affinity_cached_count('f1600000-0000-4000-8000-000000000001', repeat('a', 64)), 1,
  'Unchanged inputs reuse the cached pairs');
SELECT is(public.affinity_cached_count('f1600000-0000-4000-8000-000000000001', repeat('b', 64)), NULL,
  'Changed inputs force a recompute');

-- The blocked user blocks me (the cascade removes our links).
SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'f1600000-0000-4000-8000-000000000003';
SET LOCAL request.jwt.claims = '{"role":"authenticated","sub":"f1600000-0000-4000-8000-000000000003","session_id":"f1600000-0000-4000-8000-000000000003"}';
SELECT lives_ok($$ SELECT public.block_user('f1600000-0000-4000-8000-000000000001') $$, 'A user blocks me');

-- ── Me ────────────────────────────────────────────────────────────────────
SET LOCAL request.jwt.claim.sub = 'f1600000-0000-4000-8000-000000000001';
SET LOCAL request.jwt.claims = '{"role":"authenticated","sub":"f1600000-0000-4000-8000-000000000001","session_id":"f1600000-0000-4000-8000-000000000001"}';

-- Every read of the cycle runs for a signed-in user.
SELECT lives_ok($$ SELECT * FROM public.get_musical_dna('f1600000-0000-4000-8000-000000000001') $$, 'get_musical_dna');
SELECT lives_ok($$ SELECT * FROM public.get_same_frequency(20) $$, 'get_same_frequency');
SELECT lives_ok($$ SELECT * FROM public.get_saved_profiles() $$, 'get_saved_profiles');
SELECT lives_ok($$ SELECT * FROM public.get_music_radar() $$, 'get_music_radar');
SELECT lives_ok($$ SELECT * FROM public.get_communities(NULL, 50) $$, 'get_communities');
SELECT lives_ok($$ SELECT * FROM public.get_my_circles() $$, 'get_my_circles');
SELECT lives_ok($$ SELECT * FROM public.get_my_circle_invitations() $$, 'get_my_circle_invitations');
SELECT lives_ok($$ SELECT * FROM public.get_daily_vibes(60) $$, 'get_daily_vibes');
SELECT lives_ok($$ SELECT * FROM public.get_discoveries(40, NULL) $$, 'get_discoveries');
SELECT lives_ok($$ SELECT * FROM public.get_story_ring() $$, 'get_story_ring');
SELECT lives_ok($$ SELECT * FROM public.get_user_music_stories('f1600000-0000-4000-8000-000000000002') $$, 'get_user_music_stories');
SELECT lives_ok($$ SELECT * FROM public.get_story_audience_candidates() $$, 'get_story_audience_candidates');
SELECT lives_ok($$ SELECT * FROM public.get_story_hidden_viewers() $$, 'get_story_hidden_viewers');
SELECT lives_ok($$ SELECT * FROM public.get_feed('latest', NULL, '{}', 20) $$, 'get_feed latest');
SELECT lives_ok($$ SELECT * FROM public.get_feed_bookmarks(NULL, 30) $$, 'get_feed_bookmarks');
SELECT lives_ok($$ SELECT * FROM public.get_user_feed_posts('f1600000-0000-4000-8000-000000000002', NULL, 20) $$, 'get_user_feed_posts');
SELECT lives_ok($$ SELECT * FROM public.get_artist_recommendations() $$, 'get_artist_recommendations');
SELECT lives_ok($$ SELECT * FROM public.get_taste_evolution(90) $$, 'get_taste_evolution');
SELECT lives_ok($$ SELECT * FROM public.get_profile_identity('f1600000-0000-4000-8000-000000000002') $$, 'get_profile_identity');
SELECT lives_ok($$ SELECT * FROM public.get_my_blocked_users() $$, 'get_my_blocked_users');
SELECT lives_ok($$ SELECT * FROM public.get_my_safety_overview() $$, 'get_my_safety_overview');
SELECT lives_ok($$ SELECT * FROM public.get_notifications(NULL, 40) $$, 'get_notifications');
SELECT lives_ok($$ SELECT public.get_unread_notification_count() $$, 'get_unread_notification_count');
SELECT lives_ok($$ SELECT * FROM public.get_notification_settings() $$, 'get_notification_settings');

-- The ranked feed: the people I follow come first, with their reason.
SELECT results_eq(
  $$ SELECT reason FROM public.get_feed('for_you', NULL, '{}', 20) $$,
  $$ VALUES ('following'::text) $$,
  'For you ranks the followed author and hides the user who blocked me');
SELECT results_eq(
  $$ SELECT count(*)::int FROM public.get_feed('following', NULL, '{}', 20) $$,
  $$ VALUES (1) $$, 'Following shows only people I follow or am connected to');
SELECT results_eq(
  $$ SELECT count(*)::int FROM public.get_feed('latest', NULL, '{}', 20) $$,
  $$ VALUES (1) $$, 'Latest is chronological and still hides blocked authors');
SELECT is((SELECT count(*)::int FROM public.get_notifications(NULL, 40)), 1, 'My notification is in my inbox');
SELECT is(public.get_unread_notification_count(), 1, 'and counted as unread');
SELECT lives_ok($$ SELECT public.mark_notifications_read(NULL) $$, 'Marking everything read works');
SELECT is(public.get_unread_notification_count(), 0, 'Nothing unread afterwards');

-- Server-only functions refuse clients.
SELECT throws_like($$ SELECT public.create_feed_post('f1600000-0000-4000-8000-000000000001', '{"kind":"opinion","body":"x"}') $$,
  '%permission denied%', 'Clients cannot publish feed posts directly');
SELECT throws_like($$ SELECT public.record_notification('f1600000-0000-4000-8000-000000000002', 'follow', 't', 'b', '{}', NULL, NULL) $$,
  '%permission denied%', 'Clients cannot send notifications');
SELECT throws_like($$ SELECT public.get_job_cursor('send-notifications') $$,
  '%permission denied%', 'Clients cannot read job cursors');
SELECT throws_like($$ SELECT public.set_job_cursor('send-notifications', NULL) $$,
  '%permission denied%', 'Clients cannot move job cursors');
SELECT throws_like($$ SELECT public.affinity_cached_count('f1600000-0000-4000-8000-000000000001', repeat('a', 64)) $$,
  '%permission denied%', 'Clients cannot probe the affinity cache');
SELECT throws_like($$ SELECT public.record_affinity_fingerprint('f1600000-0000-4000-8000-000000000001', repeat('a', 64)) $$,
  '%permission denied%', 'Clients cannot write affinity state');
SELECT throws_like($$ SELECT public.save_musical_dna('f1600000-0000-4000-8000-000000000001', '{}') $$,
  '%permission denied%', 'Clients cannot write their Musical DNA');
SELECT throws_like($$ SELECT public.create_music_story('f1600000-0000-4000-8000-000000000001', '{}') $$,
  '%permission denied%', 'Clients cannot create stories without the server checks');

-- Internal state is unreachable.
SELECT throws_like($$ SELECT * FROM vibra_private.job_cursors $$, '%permission denied%', 'job_cursors is private');
SELECT throws_like($$ SELECT * FROM vibra_private.affinity_state $$, '%permission denied%', 'affinity_state is private');
SELECT throws_like($$ SELECT * FROM vibra_private.feed_post_log $$, '%permission denied%', 'feed_post_log is private');
SELECT throws_like($$ SELECT * FROM vibra_private.action_limits $$, '%permission denied%', 'action_limits is private');

-- Direct writes are refused; writes go through the checked functions.
SELECT throws_like($$ INSERT INTO public.feed_posts (user_id, kind, body)
  VALUES ('f1600000-0000-4000-8000-000000000001', 'opinion', 'direct') $$,
  '%permission denied%', 'feed_posts cannot be written directly');
SELECT throws_ok($$ UPDATE public.notifications SET user_id = 'f1600000-0000-4000-8000-000000000002' $$,
  NULL, 'A notification cannot be moved to someone else''s inbox');
SELECT throws_like($$ INSERT INTO public.user_matches (user_id_a, user_id_b, compatibility)
  VALUES ('f1600000-0000-4000-8000-000000000001', 'f1600000-0000-4000-8000-000000000003', 100) $$,
  '%permission denied%', 'Scores cannot be forged');
SELECT throws_like($$ INSERT INTO public.artist_recommendations (user_id, artist_id, name)
  VALUES ('f1600000-0000-4000-8000-000000000001', '0OdUWJ0sBjDrqHygGUXeCF', 'x') $$,
  '%permission denied%', 'Artist recommendations are written by the server only');

-- Blocks apply across features.
SELECT is_empty($$ SELECT 1 FROM public.follows
  WHERE (follower_id, following_id) IN (('f1600000-0000-4000-8000-000000000003','f1600000-0000-4000-8000-000000000001'),
                                        ('f1600000-0000-4000-8000-000000000001','f1600000-0000-4000-8000-000000000003')) $$,
  'Blocking removes follows both ways');
SELECT throws_like($$ INSERT INTO public.follows (follower_id, following_id)
  VALUES ('f1600000-0000-4000-8000-000000000001', 'f1600000-0000-4000-8000-000000000003') $$,
  '%user_unavailable%', 'A blocked pair cannot follow again (without revealing the block)');
SELECT is_empty($$ SELECT 1 FROM public.feed_posts WHERE user_id = 'f1600000-0000-4000-8000-000000000003' $$,
  'Posts of someone who blocked me are invisible under RLS');
SELECT is_empty($$ SELECT 1 FROM public.get_user_feed_posts('f1600000-0000-4000-8000-000000000003', NULL, 20) $$,
  'and through their profile');
SELECT ok(NOT EXISTS (SELECT 1 FROM public.get_same_frequency(50) WHERE user_id = 'f1600000-0000-4000-8000-000000000003'),
  'Same Frequency never suggests someone who blocked me');
SELECT is((SELECT count(*)::int FROM public.get_my_blocked_users()), 0,
  'Being blocked is not shown to me as a block of mine');

-- Pagination caps are enforced on the server.
SELECT lives_ok($$ SELECT * FROM public.get_discoveries(100000, now()) $$, 'Oversized pages are clamped, not rejected');
SELECT lives_ok($$ SELECT * FROM public.get_notifications(now(), 100000) $$, 'Notifications page is clamped');

-- Reports: one per target per week.
SELECT lives_ok($$ INSERT INTO public.reports (reporter_id, reported_id, reason)
  VALUES ('f1600000-0000-4000-8000-000000000001', 'f1600000-0000-4000-8000-000000000002', 'spam') $$,
  'A report is accepted');
SELECT throws_like($$ INSERT INTO public.reports (reporter_id, reported_id, reason)
  VALUES ('f1600000-0000-4000-8000-000000000001', 'f1600000-0000-4000-8000-000000000002', 'spam') $$,
  '%report%', 'The same report twice in a week is refused');
SELECT throws_like($$ INSERT INTO public.reports (reporter_id, reported_id, reason)
  VALUES ('f1600000-0000-4000-8000-000000000002', 'f1600000-0000-4000-8000-000000000003', 'spam') $$,
  '%row-level security%', 'Nobody can report in someone else''s name');

SELECT * FROM finish();
ROLLBACK;
