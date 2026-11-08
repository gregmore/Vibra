import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Static guarantees of the Music Radar migration (docs/music-radar.md).
/// They fail loudly if a later edit starts returning location data.
void main() {
  final sql = File(
    'supabase/migrations/20261110000000_music_radar.sql',
  ).readAsStringSync();

  String body(String function) {
    final start = sql.indexOf('CREATE FUNCTION $function(');
    expect(start, isNonNegative, reason: '$function not found');
    final end = sql.indexOf(r'$$;', start);
    return sql.substring(start, end);
  }

  test('the radar returns no coordinates, distances, cells or timestamps', () {
    final radar = body('public.get_music_radar');
    for (final leak in [
      'last_latitude',
      'last_longitude',
      'last_location',
      'ST_Distance',
      'ST_X',
      'ST_Y',
      'ST_AsText',
      'ST_AsGeoJSON',
      "'center'",
      "'anchor'",
      'anchored_at\'',
      'located_at\'',
      "'distance'",
    ]) {
      expect(radar, isNot(contains(leak)), reason: 'radar exposes $leak');
    }
    // People are never ordered by distance.
    expect(radar, isNot(contains('ORDER BY public.ST_')));
    // Events are serialised without the geography column.
    expect(radar, contains("- 'location'"));
  });

  test('positions are private, snapped to cells and anchored for 6 hours', () {
    expect(sql, contains('CREATE TABLE vibra_private.radar_presence'));
    expect(
      sql,
      contains(
        'REVOKE ALL ON vibra_private.radar_presence FROM PUBLIC, anon, authenticated',
      ),
    );
    final refresh = body('vibra_private.radar_refresh');
    expect(refresh, contains("interval '6 hours'"));
    expect(refresh, contains('vibra_private.radar_snap'));
    // Radius membership compares snapped cell centres only.
    expect(
      body('public.get_music_radar'),
      contains('ST_DWithin(r.center, v_center'),
    );
  });

  test('opt-in, consent, hiding, fixed radii and rate limit are enforced', () {
    expect(sql, contains('radar_enabled boolean NOT NULL DEFAULT false'));
    expect(sql, contains('CHECK (radar_distance_km IN (5, 10, 25, 50))'));
    final radar = body('public.get_music_radar');
    expect(radar, contains("consume_action_limit('music-radar')"));
    expect(
      radar,
      contains(
        'pp.radar_enabled AND pp.radar_visible AND pp.location_processing',
      ),
    );
    expect(radar, contains('may_access_message(v_me, r.user_id)'));
    // Area statistics need at least five contributors.
    expect(radar, contains('FROM contributors) >= 5'));
  });
}
