import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Privacy guarantees of Who's Going? (docs/whos-going.md).
void main() {
  final sql = File(
    'supabase/migrations/20261114000000_whos_going.sql',
  ).readAsStringSync();
  final social = sql.substring(
    sql.indexOf('CREATE FUNCTION public.get_event_social('),
    sql.indexOf(
      r'$$;',
      sql.indexOf('CREATE FUNCTION public.get_event_social('),
    ),
  );

  test('attendance stays private unless the attendee chooses otherwise', () {
    expect(
      sql,
      contains("attendance_visibility text NOT NULL DEFAULT 'private'"),
    );
    expect(
      social,
      contains("COALESCE(a.visibility, pp.attendance_visibility, 'private')"),
    );
  });

  test('a person appears only if their visibility includes the viewer', () {
    expect(social, contains("WHERE v.vis = 'public'"));
    expect(social, contains("OR (v.vis = 'friends' AND v.is_friend)"));
    expect(
      social,
      contains(
        "OR (v.vis = 'matches' AND (v.is_friend OR v.compatibility IS NOT NULL))",
      ),
    );
    // Blocks and test segments; never the caller; never 'not_going'.
    expect(social, contains('may_access_message(v_me, a.user_id)'));
    expect(social, contains('a.user_id <> v_me'));
    expect(social, contains("a.status IN ('interested', 'maybe', 'going')"));
  });

  test('counts cover only visible people and no timestamps leak', () {
    expect(social, contains("FROM people WHERE status = 'going'"));
    expect(social, isNot(contains('created_at')));
    expect(social, isNot(contains("'private'))")));
  });

  test('the event attendance table itself stays owner-only', () {
    expect(sql, isNot(contains('CREATE POLICY')));
    expect(sql, isNot(contains('GRANT SELECT')));
  });
}
