import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Privacy guarantees of Concert Match (docs/concert-match.md).
void main() {
  final sql = File(
    'supabase/migrations/20261115000000_concert_match.sql',
  ).readAsStringSync();
  final fn = sql.substring(
    sql.indexOf('CREATE FUNCTION public.get_concert_matches('),
    sql.indexOf(
      r'$$;',
      sql.indexOf('CREATE FUNCTION public.get_concert_matches('),
    ),
  );

  test('attendance shows only under the attendee visibility rules', () {
    expect(
      fn,
      contains("COALESCE(a.visibility, pp.attendance_visibility, 'private')"),
    );
    expect(fn, contains("WHERE a.vis = 'public'"));
    expect(
      fn,
      contains(
        "(a.vis = 'friends' AND a.user_id IN (SELECT user_id FROM friends))",
      ),
    );
    expect(fn, contains('may_access_message(v_me, c.user_id)'));
  });

  test('artist fans come from consented pairs and reveal no attendance', () {
    expect(fn, contains('may_access_music_match(m.user_id_a, m.user_id_b)'));
    expect(fn, contains("SELECT p.user_id, NULL, true"));
  });

  test('no location, distance, travel or timestamps are returned', () {
    for (final leak in [
      'latitude',
      'longitude',
      'last_location',
      'radar_presence',
      'ST_',
      'city',
      'created_at',
    ]) {
      expect(fn, isNot(contains(leak)), reason: leak);
    }
  });

  test('circle plans are members-only and written through checks', () {
    expect(sql, contains('USING (public.is_circle_member(circle_id))'));
    expect(sql, isNot(contains('GRANT INSERT')));
    final add = sql.substring(sql.indexOf('FUNCTION public.add_circle_plan('));
    expect(add, contains('require_circle_role(p_circle, false)'));
    expect(add, contains("consume_action_limit('circle-update')"));
  });
}
