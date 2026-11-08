import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Social safety (docs/safety.md): checked against the migrations.
void main() {
  final sql = File(
    'supabase/migrations/20261124000000_social_safety.sql',
  ).readAsStringSync();
  String section(String from) =>
      sql.substring(sql.indexOf(from), sql.indexOf(r'$$;', sql.indexOf(from)));

  test('blocked pairs cannot connect through any alternative feature', () {
    for (final table in [
      'follows',
      'friendships',
      'circle_invitations',
      'saved_profiles',
    ]) {
      expect(
        sql,
        contains(
          'ON public.$table\nFOR EACH ROW EXECUTE FUNCTION vibra_private.reject_blocked_pair()',
        ),
        reason: table,
      );
    }
    // The refusal never says who blocked whom.
    expect(
      section('FUNCTION vibra_private.reject_blocked_pair()'),
      contains("'user_unavailable'"),
    );
  });

  test('blocking removes what connected the two people', () {
    final apply = section('FUNCTION vibra_private.apply_block()');
    expect(apply, contains('DELETE FROM public.follows'));
    expect(apply, contains('DELETE FROM public.friendships'));
    expect(apply, contains("SET status = 'revoked'"));
    expect(apply, contains('DELETE FROM public.saved_profiles'));
    expect(sql, contains('AFTER INSERT ON public.blocked_users'));
  });

  test('blocks go through a rate-limited server path; lists are own-only', () {
    expect(
      section('FUNCTION public.block_user('),
      contains("consume_action_limit('blocks')"),
    );
    expect(
      section('FUNCTION public.unblock_user('),
      contains('blocker_id = auth.uid()'),
    );
    final list = section('FUNCTION public.get_my_blocked_users()');
    expect(list, contains('WHERE b.blocker_id = auth.uid()'));
    expect(list, isNot(contains('blocked_id = auth.uid()')));
  });

  test('reports: no duplicates within a week, 30 a day', () {
    final limit = section('FUNCTION vibra_private.limit_reports()');
    expect(limit, contains("'duplicate_report'"));
    expect(limit, contains("interval '7 days'"));
    expect(limit, contains('>= 30'));
  });

  test('every surface checks blocks on the server', () {
    final all = Directory(
      'supabase/migrations',
    ).listSync().whereType<File>().map((f) => f.readAsStringSync()).join('\n');
    // Messages, live chat, circles, communities, vibes/stories/feed.
    expect(all, contains('CREATE POLICY "messages_select_without_blocks"'));
    expect(all, contains('live_messages_private_visibility'));
    expect(
      all,
      contains('public.may_access_message((SELECT auth.uid()), sender_id)'),
    );
    expect(all, contains('FUNCTION public.may_see_community_author'));
    expect(
      all,
      contains('AND public.may_access_message(auth.uid(), p_author)'),
    );
    // The app blocks through the server path.
    expect(
      File(
        'lib/data/datasources/supabase_social_datasource.dart',
      ).readAsStringSync(),
      contains("rpc('block_user'"),
    );
  });
}
