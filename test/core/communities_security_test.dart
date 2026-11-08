import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Static guarantees of the communities migration (docs/communities.md).
void main() {
  final sql = File(
    'supabase/migrations/20261111000000_communities.sql',
  ).readAsStringSync();

  String body(String function) {
    final start = sql.indexOf('FUNCTION $function(');
    expect(start, isNonNegative, reason: '$function not found');
    return sql.substring(start, sql.indexOf(r'$$;', start));
  }

  test('clients can only read; every write is a checked server function', () {
    expect(
      sql,
      contains(
        'GRANT SELECT ON public.communities, public.community_members, public.community_bans,\n'
        '  public.community_posts, public.community_comments, public.community_reactions TO authenticated;',
      ),
    );
    expect(sql, isNot(contains('GRANT INSERT')));
    expect(sql, isNot(contains('GRANT UPDATE')));
    for (final table in [
      'communities',
      'community_members',
      'community_bans',
      'community_posts',
      'community_comments',
      'community_reactions',
    ]) {
      expect(
        sql,
        contains('ALTER TABLE public.$table ENABLE ROW LEVEL SECURITY'),
      );
    }
  });

  test('posting checks session, membership, bans, rate limit and spam', () {
    final post = body('public.create_community_post');
    expect(post, contains('require_active_session'));
    expect(post, contains('community_membership_required'));
    expect(post, contains('community_banned'));
    expect(post, contains("consume_action_limit('community-post')"));
    expect(post, contains('community_post_daily_limit'));
    expect(post, contains('community_text_guard'));
    expect(post, contains('duplicate_content'));
    expect(post, contains('invalid_music_link'));
    final comment = body('public.create_community_comment');
    expect(comment, contains('community_post_access'));
    expect(comment, contains("consume_action_limit('community-comment')"));
    // Interacting with a blocked author's post is refused.
    expect(
      body('vibra_private.community_post_access'),
      contains('may_access_message(p_me, v_post.author_id)'),
    );
  });

  test('blocked authors and held/removed content are hidden by RLS', () {
    final policy = sql.substring(
      sql.indexOf('CREATE POLICY community_posts_read'),
      sql.indexOf('ALTER TABLE public.community_comments ENABLE'),
    );
    expect(policy, contains('may_see_community_author(author_id)'));
    expect(policy, contains('removed_at IS NULL AND NOT held_for_review'));
    expect(
      body('public.may_see_community_author'),
      contains('may_access_message(auth.uid(), p_author)'),
    );
  });

  test('moderation is role-gated and reports hold content after three', () {
    expect(
      body('public.moderate_community_content'),
      contains('moderator_required'),
    );
    final ban = body('public.set_community_ban');
    expect(ban, contains("v_their_role = 'owner'"));
    expect(ban, contains("v_my_role <> 'owner'"));
    expect(body('public.set_community_role'), contains('owner_required'));
    expect(
      body('vibra_private.hold_reported_community_content'),
      contains('>= 3'),
    );
    final report = body('public.protect_report_submission');
    expect(report, contains('Only visible posts may be reported'));
    expect(report, contains('You cannot report yourself'));
  });
}
