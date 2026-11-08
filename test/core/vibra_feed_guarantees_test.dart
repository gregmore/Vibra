import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Ranking, anti-manipulation, privacy and moderation guarantees of the
/// VIBRA Feed (docs/vibra-feed.md), checked against the migration.
void main() {
  final sql = File(
    'supabase/migrations/20261118000000_vibra_feed.sql',
  ).readAsStringSync();
  final fn = File('supabase/functions/feed-posts/index.ts').readAsStringSync();

  String section(String from, String to) =>
      sql.substring(sql.indexOf(from), sql.indexOf(to, sql.indexOf(from)));

  final feed = section('FUNCTION public.get_feed(', r'$$;');

  test('relevance uses the five requested signals, with bounded weights', () {
    expect(feed, contains('public.follows f WHERE f.follower_id = me'));
    expect(feed, contains('my_genres'));
    expect(feed, contains('my_artists'));
    expect(
      feed,
      contains('community_members a JOIN public.community_members b'),
    );
    expect(feed, contains('my_community_genres'));
    expect(feed, contains("x.created_at > now() - interval '30 days'"));
    // Every signal is capped (LEAST) so none can dominate.
    expect(feed, contains('LEAST(s.genre_hits, 3)'));
    expect(feed, contains('LEAST(ln(1 + s.my_interactions) / ln(11), 1)'));
  });

  test('popularity is a small capped signal, never raw counts', () {
    expect(feed, contains('0.5 * LEAST(ln(1 + s.engagers) / ln(51), 1)'));
    // Engagement by the author themself does not count.
    expect(feed, contains('r.user_id <> c.user_id'));
    expect(feed, isNot(contains('ORDER BY like_count')));
    expect(sql, contains('Likes and reactions deliberately do not notify'));
  });

  test('repetition is pushed down: seen, same author, same item', () {
    expect(feed, contains('power(0.6, s.shown)'));
    expect(feed, contains('COALESCE(i.shown_count, 0) < 4'));
    expect(feed, contains('PARTITION BY s.user_id'));
    expect(feed, contains('PARTITION BY s.item_key'));
    expect(feed, contains('NOT COALESCE(i.dismissed, false)'));
    final create = section('FUNCTION public.create_feed_post(', r'$$;');
    expect(create, contains("'duplicate_post'"));
    expect(
      section('FUNCTION public.add_feed_comment(', r'$$;'),
      contains("'duplicate_comment'"),
    );
  });

  test('chronological options are strictly by time', () {
    expect(feed, contains("IF p_mode = 'following' OR p_mode = 'latest' THEN"));
    expect(feed, contains('ORDER BY p.created_at DESC'));
  });

  test('visibility, blocks and shares respect the original', () {
    expect(
      section('FUNCTION public.can_see_feed_post(', r'$$;'),
      contains('can_see_daily_vibe'),
    );
    expect(feed, contains('SECURITY INVOKER'));
    final rows = section('FUNCTION public.feed_post_rows(', r'$$;');
    expect(
      rows,
      contains(
        'EXISTS (SELECT 1 FROM public.feed_posts o WHERE o.id = p.shared_post_id)',
      ),
    );
    final create = section('FUNCTION public.create_feed_post(', r'$$;');
    expect(create, contains("'invalid_share'"));
    expect(create, contains('public.blocked_users b'));
    for (final f in [
      'toggle_feed_reaction',
      'add_feed_comment',
      'set_feed_bookmark',
    ]) {
      expect(
        section('FUNCTION public.$f(', r'$$;'),
        contains('require_visible_post(p_post)'),
        reason: f,
      );
    }
  });

  test('reports, holds, rate limits, bookmarks private, export', () {
    expect(
      section('FUNCTION public.protect_report_submission()', r'$$;'),
      contains('NEW.feed_post_id'),
    );
    expect(
      section('FUNCTION vibra_private.hold_reported_feed_content()', r'$$;'),
      contains('>= 3'),
    );
    for (final a in [
      'feed-reaction',
      'feed-comment',
      'feed-bookmark',
      'feed-seen',
    ]) {
      expect(sql, contains("WHEN '$a'"));
    }
    expect(sql, contains("'feed_rate_limit'"));
    expect(
      section('CREATE POLICY feed_bookmarks_owner', ';'),
      contains('user_id = (SELECT auth.uid())'),
    );
    expect(sql, contains("'feed_posts', COALESCE("));
  });

  test('music metadata comes from Spotify; photos private; no audio', () {
    expect(fn, contains(r'spotifyApi(`/${type}s/${body.item_id}`, token)'));
    expect(
      section('FUNCTION public.create_feed_post(', r'$$;'),
      contains("'Service role required'"),
    );
    final table = section(
      'CREATE TABLE public.feed_posts',
      'CREATE INDEX feed_posts_recent_idx',
    );
    for (final audio in ['preview', 'audio', 'mp3']) {
      expect(table, isNot(contains(audio)));
      expect(fn, isNot(contains(audio)));
    }
    expect(sql, contains("VALUES ('feed-media', 'feed-media', false"));
    expect(
      section('CREATE POLICY feed_media_select_visible', ';'),
      contains('public.feed_posts p'),
    );
  });
}
