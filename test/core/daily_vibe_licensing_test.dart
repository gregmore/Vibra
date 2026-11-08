import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Licensing and privacy guarantees of Daily Vibe (docs/daily-vibe.md).
void main() {
  final sql = File(
    'supabase/migrations/20261116000000_daily_vibe.sql',
  ).readAsStringSync();
  final fn = File('supabase/functions/daily-vibe/index.ts').readAsStringSync();
  final mapping = File(
    'supabase/functions/_shared/spotify_tracks.ts',
  ).readAsStringSync();

  test('no audio is stored, returned or proxied', () {
    final table = sql.substring(
      sql.indexOf('CREATE TABLE public.daily_vibes'),
      sql.indexOf('CREATE INDEX daily_vibes_feed_idx'),
    );
    for (final audio in ['preview', 'audio', 'mp3', 'stream_url']) {
      expect(table, isNot(contains(audio)));
      expect(fn, isNot(contains(audio)));
    }
    expect(mapping, isNot(contains('preview_url:')));
  });

  test('artwork is only referenced from the provider CDN, never copied', () {
    expect(
      sql,
      contains(
        r"artwork_url text CHECK (artwork_url ~ '^https://i\.scdn\.co/')",
      ),
    );
    expect(fn, isNot(contains('storage')));
  });

  test('Spotify metadata comes from Spotify, not from the client', () {
    expect(fn, contains('spotify(`/tracks/'));
    expect(
      sql,
      contains(
        "RAISE insufficient_privilege USING MESSAGE = 'Service role required'",
      ),
    );
  });

  test('expiry, visibility, one per day and blocks are enforced', () {
    expect(sql, contains('UNIQUE (user_id, vibe_day)'));
    expect(sql, contains("now() + interval '24 hours'"));
    final can = sql.substring(
      sql.indexOf('FUNCTION public.can_see_daily_vibe('),
    );
    expect(can, contains('p_expires IS NULL OR p_expires > now()'));
    expect(can, contains('may_access_message(auth.uid(), p_author)'));
    expect(sql, contains("cron.schedule('purge-expired-daily-vibes'"));
  });
}
