import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vibra/domain/entities/music_reaction.dart';

/// Track reactions (docs/track-reactions.md): the server decides which
/// reaction set applies, and Discoveries accept songs from every share.
void main() {
  final sql = File(
    'supabase/migrations/20261119000000_track_reactions.sql',
  ).readAsStringSync();

  String section(String from) =>
      sql.substring(sql.indexOf(from), sql.indexOf(r'$$;', sql.indexOf(from)));

  test('the app and the server agree on both reaction sets', () {
    expect(
      sql,
      contains(
        "ARRAY['fire', 'obsessed', 'underrated', 'classic', 'new_discovery', 'on_repeat']",
      ),
    );
    expect(MusicReactions.track, [
      'fire',
      'obsessed',
      'underrated',
      'classic',
      'new_discovery',
      'on_repeat',
    ]);
    expect(
      sql,
      contains("ARRAY['fire', 'heart', 'headphones', 'clap', 'mind_blown']"),
    );
    for (final r in [...MusicReactions.track, ...MusicReactions.general]) {
      expect(MusicReactions.emoji[r], isNotNull, reason: r);
    }
  });

  test('every toggle validates the reaction against the content', () {
    expect(
      section('FUNCTION public.toggle_daily_vibe_reaction('),
      contains('require_reaction(true, p_reaction)'),
    );
    expect(
      section('FUNCTION public.toggle_music_story_reaction('),
      contains("require_reaction(s.kind = 'now_playing', p_reaction)"),
    );
    final feed = section('FUNCTION public.toggle_feed_reaction(');
    expect(feed, contains('feed_post_is_song(p)'));
    expect(feed, contains("IS DISTINCT FROM 'like'"));
    final community = section('FUNCTION public.toggle_community_reaction(');
    expect(community, contains('is_song_link'));
    expect(community, contains('community_post_access'));
  });

  test('discoveries: only songs, only visible content, attribution', () {
    final save = section('FUNCTION public.save_track_to_discoveries(');
    for (final check in [
      'require_visible_vibe(p_id)',
      'require_visible_story(p_id)',
      'require_visible_post(p_id)',
      'community_post_access(p_id, auth.uid())',
    ]) {
      expect(save, contains(check));
    }
    expect(save, contains("'not_a_song'"));
    expect(save, contains("'discovery_limit'"));
    final read = section('FUNCTION public.get_discoveries(');
    expect(read, contains('WHERE d.user_id = auth.uid()'));
    expect(read, contains('may_access_message(auth.uid(), d.found_via)'));
  });

  test('the song-link rule matches the server', () {
    expect(
      isSongLink('https://open.spotify.com/track/2xLMifQCjDGFmkHkpNLD9h'),
      isTrue,
    );
    expect(
      isSongLink('https://open.spotify.com/album/2xLMifQCjDGFmkHkpNLD9h'),
      isFalse,
    );
    expect(isSongLink('https://soundcloud.com/a/b'), isTrue);
    expect(isSongLink('https://example.com/song'), isFalse);
    expect(isSongLink(null), isFalse);
  });
}
