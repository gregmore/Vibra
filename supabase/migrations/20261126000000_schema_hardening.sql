-- VIBRA schema hardening (docs/architecture.md, spec section 23).
--
-- Review of every table added in 20261105–20261125: all public tables have
-- RLS, every foreign key has an explicit ON DELETE rule. Missing were
-- indexes on foreign-key columns that are not the leading column of an
-- existing index. Without them, deleting a user, post, story, circle or
-- event (all cascade or set null) scans the referencing table, and joins
-- in RLS policies and RPCs on those columns are slower. This migration
-- only adds indexes; it changes no data, policy or behaviour.
BEGIN;

-- Users referenced by social features (account erasure cascades here).
CREATE INDEX IF NOT EXISTS affinity_dismissals_dismissed_idx ON public.affinity_dismissals (dismissed_user_id);
CREATE INDEX IF NOT EXISTS saved_profiles_saved_user_idx ON public.saved_profiles (saved_user_id);
CREATE INDEX IF NOT EXISTS same_frequency_views_shown_idx ON public.same_frequency_views (shown_user_id);
CREATE INDEX IF NOT EXISTS communities_created_by_idx ON public.communities (created_by) WHERE created_by IS NOT NULL;
CREATE INDEX IF NOT EXISTS community_bans_user_idx ON public.community_bans (user_id);
CREATE INDEX IF NOT EXISTS community_bans_banned_by_idx ON public.community_bans (banned_by) WHERE banned_by IS NOT NULL;
CREATE INDEX IF NOT EXISTS community_posts_removed_by_idx ON public.community_posts (removed_by) WHERE removed_by IS NOT NULL;
CREATE INDEX IF NOT EXISTS community_comments_removed_by_idx ON public.community_comments (removed_by) WHERE removed_by IS NOT NULL;
CREATE INDEX IF NOT EXISTS community_reactions_user_idx ON public.community_reactions (user_id);
CREATE INDEX IF NOT EXISTS circles_created_by_idx ON public.circles (created_by) WHERE created_by IS NOT NULL;
CREATE INDEX IF NOT EXISTS circle_bans_user_idx ON public.circle_bans (user_id);
CREATE INDEX IF NOT EXISTS circle_bans_banned_by_idx ON public.circle_bans (banned_by) WHERE banned_by IS NOT NULL;
CREATE INDEX IF NOT EXISTS circle_invitations_inviter_idx ON public.circle_invitations (inviter_id);
CREATE INDEX IF NOT EXISTS circle_messages_sender_idx ON public.circle_messages (sender_id);
CREATE INDEX IF NOT EXISTS circle_messages_removed_by_idx ON public.circle_messages (removed_by) WHERE removed_by IS NOT NULL;
CREATE INDEX IF NOT EXISTS circle_playlist_items_added_by_idx ON public.circle_playlist_items (added_by) WHERE added_by IS NOT NULL;
CREATE INDEX IF NOT EXISTS circle_events_added_by_idx ON public.circle_events (added_by) WHERE added_by IS NOT NULL;
CREATE INDEX IF NOT EXISTS circle_plans_created_by_idx ON public.circle_plans (created_by) WHERE created_by IS NOT NULL;
CREATE INDEX IF NOT EXISTS circle_plan_participants_user_idx ON public.circle_plan_participants (user_id);
CREATE INDEX IF NOT EXISTS daily_vibe_reactions_user_idx ON public.daily_vibe_reactions (user_id);
CREATE INDEX IF NOT EXISTS daily_vibe_comments_author_idx ON public.daily_vibe_comments (author_id);
CREATE INDEX IF NOT EXISTS music_story_reactions_user_idx ON public.music_story_reactions (user_id);
CREATE INDEX IF NOT EXISTS music_story_replies_sender_idx ON public.music_story_replies (sender_id);
CREATE INDEX IF NOT EXISTS music_story_replies_recipient_idx ON public.music_story_replies (recipient_id);
CREATE INDEX IF NOT EXISTS story_hidden_viewers_viewer_idx ON public.story_hidden_viewers (viewer_id);
CREATE INDEX IF NOT EXISTS story_mutes_muted_idx ON public.story_mutes (muted_id);
CREATE INDEX IF NOT EXISTS discovery_collection_found_via_idx ON public.discovery_collection (found_via) WHERE found_via IS NOT NULL;
CREATE INDEX IF NOT EXISTS notifications_actor_idx ON public.notifications (actor_id) WHERE actor_id IS NOT NULL;

-- Content referenced by other content (deleting a post/story/vibe/event).
CREATE INDEX IF NOT EXISTS community_posts_event_idx ON public.community_posts (event_id) WHERE event_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS circles_event_idx ON public.circles (event_id) WHERE event_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS circle_events_event_idx ON public.circle_events (event_id);
CREATE INDEX IF NOT EXISTS circle_plans_event_idx ON public.circle_plans (event_id) WHERE event_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS daily_vibe_comments_parent_idx ON public.daily_vibe_comments (parent_id) WHERE parent_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS discovery_collection_from_vibe_idx ON public.discovery_collection (from_vibe_id) WHERE from_vibe_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS discovery_collection_from_story_idx ON public.discovery_collection (from_story_id) WHERE from_story_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS discovery_collection_from_post_idx ON public.discovery_collection (from_post_id) WHERE from_post_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS discovery_collection_from_cpost_idx ON public.discovery_collection (from_community_post_id) WHERE from_community_post_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS music_stories_event_idx ON public.music_stories (event_id) WHERE event_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS feed_posts_event_idx ON public.feed_posts (event_id) WHERE event_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS feed_comments_parent_idx ON public.feed_comments (parent_id) WHERE parent_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS feed_bookmarks_post_idx ON public.feed_bookmarks (post_id);
CREATE INDEX IF NOT EXISTS feed_impressions_post_idx ON public.feed_impressions (post_id);

-- Reports point at many kinds of content (each cascades on delete), and the
-- hold-for-review triggers count reports per content.
CREATE INDEX IF NOT EXISTS reports_community_post_idx ON public.reports (community_post_id) WHERE community_post_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS reports_community_comment_idx ON public.reports (community_comment_id) WHERE community_comment_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS reports_circle_message_idx ON public.reports (circle_message_id) WHERE circle_message_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS reports_circle_idx ON public.reports (circle_id) WHERE circle_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS reports_daily_vibe_idx ON public.reports (daily_vibe_id) WHERE daily_vibe_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS reports_daily_vibe_comment_idx ON public.reports (daily_vibe_comment_id) WHERE daily_vibe_comment_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS reports_music_story_idx ON public.reports (music_story_id) WHERE music_story_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS reports_music_story_reply_idx ON public.reports (music_story_reply_id) WHERE music_story_reply_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS reports_feed_post_idx ON public.reports (feed_post_id) WHERE feed_post_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS reports_feed_comment_idx ON public.reports (feed_comment_id) WHERE feed_comment_id IS NOT NULL;
-- Duplicate and daily-cap checks (limit_reports) read by reporter and time.
CREATE INDEX IF NOT EXISTS reports_reporter_recent_idx ON public.reports (reporter_id, created_at DESC);

COMMIT;
