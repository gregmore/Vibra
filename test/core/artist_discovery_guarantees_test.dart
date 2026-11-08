import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// "Discover my next artist" (docs/artist-discovery.md).
void main() {
  final sql = File(
    'supabase/migrations/20261121000000_artist_discovery.sql',
  ).readAsStringSync();
  final fn = File(
    'supabase/functions/discover-artists/index.ts',
  ).readAsStringSync();

  String section(String from) =>
      sql.substring(sql.indexOf(from), sql.indexOf(r'$$;', sql.indexOf(from)));

  test('dismissed and known artists never come back', () {
    final save = section('FUNCTION public.save_artist_recommendations(');
    expect(save, contains("f.reaction IN ('not_interested', 'known')"));
    final read = section('FUNCTION public.get_artist_recommendations()');
    expect(read, contains("IS DISTINCT FROM 'not_interested'"));
    expect(read, contains("IS DISTINCT FROM 'known'"));
    expect(
      sql,
      contains("CHECK (NOT (saved AND reaction = 'not_interested'))"),
    );
  });

  test('feedback only on artists VIBRA recommended; facts from Spotify', () {
    final set = section('FUNCTION public.set_artist_feedback(');
    expect(set, contains("'artist_not_recommended'"));
    expect(set, contains('COALESCE(r.name, f.artist_name)'));
    expect(set, contains("consume_action_limit('artist-feedback')"));
  });

  test('repetition is tracked across refreshes', () {
    expect(
      section('FUNCTION public.mark_artist_recommendations_shown('),
      contains("interval '6 hours'"),
    );
    // shown_count is not overwritten by a refresh.
    final save = section('FUNCTION public.save_artist_recommendations(');
    expect(save, isNot(contains('shown_count = EXCLUDED')));
  });

  test('engine input uses all requested signals; only service role', () {
    final input = section('FUNCTION public.get_artist_discovery_input(');
    for (final signal in [
      "'top_artists'",
      "'dna'",
      "'picked_genres'",
      "'discovered_artists'",
      "'feedback'",
      "'shown'",
    ]) {
      expect(input, contains(signal));
    }
    expect(input, contains("'Service role required'"));
  });

  test('Spotify is read with app credentials, never a user token', () {
    expect(fn, contains('getSpotifyAppAccessToken'));
    for (final forbidden in [
      'spotify_connections',
      'refresh_token',
      'decryptSpotifyToken',
    ]) {
      expect(fn, isNot(contains(forbidden)));
    }
    expect(sql, contains("'artist_feedback', COALESCE("));
  });
}
