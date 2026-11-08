import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Performance and scalability rules (docs/performance.md), checked against
/// the sources so a regression shows up in CI.
void main() {
  final sql = File(
    'supabase/migrations/20261127000000_performance.sql',
  ).readAsStringSync();
  String fn(String name) {
    final start = sql.indexOf('FUNCTION public.$name(');
    expect(start, greaterThanOrEqualTo(0), reason: name);
    return sql.substring(start, sql.indexOf(r'$$;', start));
  }

  String read(String path) => File(path).readAsStringSync();

  test('batch workers page through users and never load them all', () {
    for (final worker in [
      'supabase/functions/send-notifications/index.ts',
      'supabase/functions/retention-notifications/index.ts',
    ]) {
      final src = read(worker);
      expect(src, contains('forEachUserPage'), reason: worker);
      expect(src, contains('keyset('), reason: worker);
      // No single query for the whole user table any more.
      expect(
        RegExp(r'from\("users"\)[^;]*\.limit\(\d+\)').hasMatch(src),
        isFalse,
        reason: worker,
      );
      // Per-page queries instead of one per user.
      expect(src, contains('.in("user_id", ids)'), reason: worker);
    }
  });

  test('job cursors and affinity state are server-only', () {
    for (final name in [
      'get_job_cursor',
      'set_job_cursor',
      'affinity_cached_count',
      'record_affinity_fingerprint',
    ]) {
      expect(fn(name), contains("IS DISTINCT FROM 'service_role'"));
      expect(
        RegExp(
          'GRANT EXECUTE ON FUNCTION public.$name\\([^)]*\\) TO authenticated',
        ).hasMatch(sql),
        isFalse,
        reason: name,
      );
      expect(
        RegExp(
          'GRANT EXECUTE ON FUNCTION public.$name\\([^)]*\\) TO service_role;',
        ).hasMatch(sql),
        isTrue,
        reason: name,
      );
    }
    expect(
      sql,
      contains('CREATE TABLE IF NOT EXISTS vibra_private.job_cursors'),
    );
    expect(
      sql,
      contains('CREATE TABLE IF NOT EXISTS vibra_private.affinity_state'),
    );
  });

  test('calculate-match skips unchanged inputs', () {
    expect(
      read('supabase/functions/calculate-match/index.ts'),
      contains('onlyIfChanged: true'),
    );
    final sync = read('supabase/functions/_shared/music_sync.ts');
    expect(sync, contains('affinity_cached_count'));
    expect(sync, contains('record_affinity_fingerprint'));
  });

  test('the feed ranks with set joins, not per-candidate subqueries', () {
    final feed = fn('get_feed');
    final ranked = feed.substring(feed.indexOf('WITH candidates'));
    expect(ranked, isNot(contains('EXISTS (SELECT 1 FROM public.follows')));
    expect(ranked, isNot(contains('EXISTS (SELECT 1 FROM public.friendships')));
    expect(ranked, isNot(contains('(SELECT m.compatibility')));
    expect(ranked, contains('LIMIT 1500'));
    // Same safety rules as before.
    expect(feed, contains('SECURITY INVOKER'));
    expect(feed, contains("RAISE SQLSTATE 'PT401'"));
    expect(feed, contains('LEAST(GREATEST(COALESCE(p_limit, 20), 1), 50)'));
  });

  test('lists are paged with a cursor and a server-side cap', () {
    final discoveries = fn('get_discoveries');
    expect(discoveries, contains('p_before'));
    expect(
      discoveries,
      contains('LEAST(GREATEST(COALESCE(p_limit, 40), 1), 100)'),
    );
    expect(discoveries, contains('d.user_id = auth.uid()'));
    expect(
      discoveries,
      contains('may_access_message(auth.uid(), d.found_via)'),
    );
    expect(
      read('lib/data/datasources/supabase_notification_center_datasource.dart'),
      contains("'p_before'"),
    );
    expect(
      read('lib/data/datasources/supabase_feed_datasource.dart'),
      contains(
        "'get_feed_bookmarks',\n          params: {\n            'p_before'",
      ),
    );
  });
}
