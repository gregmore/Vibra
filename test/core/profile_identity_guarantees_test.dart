import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Profile identity (docs/profile-identity.md): per-section visibility on
/// top of every existing privacy rule.
void main() {
  final sql = File(
    'supabase/migrations/20261123000000_profile_identity.sql',
  ).readAsStringSync();
  final read = sql.substring(
    sql.indexOf('FUNCTION public.get_profile_identity('),
  );

  test('blocks and test segments hide the whole profile', () {
    expect(read, contains('NOT public.may_access_message(me, p_user)'));
    expect(read, contains('a.is_test_user = b.is_test_user'));
  });

  test('every section is gated by its level', () {
    for (final s in [
      'genres',
      'artists',
      'stats',
      'saved_songs',
      'playlists',
      'events',
      'communities',
      'circles',
      'activity',
    ]) {
      expect(read, contains("WHERE section = '$s')"), reason: s);
    }
    expect(read, contains("(lv.level = 'connections' AND v_connection)"));
    expect(sql, contains("WHEN 'saved_songs' THEN 'private'"));
  });

  test('existing rules still apply inside sections', () {
    // Musical DNA: its own visibility.
    expect(read, contains('public.get_musical_dna(p_user)'));
    // Events: each attendance's Who's Going visibility.
    expect(
      read,
      contains("COALESCE(a.visibility, pp.attendance_visibility, 'private')"),
    );
    // Circles: only shared ones for others.
    expect(read, contains('v.user_id = me'));
    // Posts and vibes: their own audience.
    expect(read, contains('public.can_see_feed_post('));
    expect(read, contains('public.can_see_daily_vibe('));
    // Attendance counts only for the owner.
    expect(read, contains("'concerts', CASE WHEN v_is_me"));
    // Levels are shown to the owner only.
    expect(read, contains("'sections', CASE WHEN v_is_me"));
  });
}
