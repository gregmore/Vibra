import 'package:flutter_test/flutter_test.dart';
import 'package:vibra/domain/entities/music_story.dart';

void main() {
  final row = {
    'id': 's1',
    'user_id': 'ana',
    'username': 'ana',
    'kind': 'album',
    'provider': 'spotify',
    'item_id': '2xLMifQCjDGFmkHkpNLD9h',
    'title': 'Homogenic',
    'subtitle': 'Björk · 1997',
    'external_url': 'https://open.spotify.com/album/2xLMifQCjDGFmkHkpNLD9h',
    'background': 'neon',
    'visibility': 'everyone',
    'allow_replies': false,
    'expires_at': '2026-11-09T10:00:00Z',
    'created_at': '2026-11-08T10:00:00Z',
    'reactions': {'fire': 2},
    'my_reactions': ['fire'],
    'seen': true,
  };

  test('parses a music story and falls back to a known background', () {
    final s = MusicStory.fromRow(row)!;
    expect(s.kind, StoryKind.album);
    expect(s.item!.subtitle, 'Björk · 1997');
    expect(s.background, 'aurora');
    expect(s.everyone, isTrue);
    expect(s.allowReplies, isFalse);
    expect(s.viewCount, isNull);
    final off = s.withReaction('fire', on: false);
    expect(off.reactions, {'fire': 1});
    expect(off.myReactions, isEmpty);
  });

  test('rejects unknown kinds and music stories without an item', () {
    expect(MusicStory.fromRow({...row, 'kind': 'podcast'}), isNull);
    expect(MusicStory.fromRow({...row, 'title': null}), isNull);
    final opinion = MusicStory.fromRow({
      ...row,
      'kind': 'opinion',
      'title': null,
      'body': 'Vinyl > streaming',
    })!;
    expect(opinion.item, isNull);
  });

  test('replies group into one thread per viewer', () {
    StoryReply r(String id, String from, String to) => StoryReply(
      id: id,
      senderId: from,
      recipientId: to,
      username: from,
      body: id,
      createdAt: DateTime(2026),
    );
    final threads = storyThreads([
      r('1', 'bo', 'ana'),
      r('2', 'ana', 'bo'),
      r('3', 'cy', 'ana'),
    ], 'ana');
    expect(threads.keys, ['bo', 'cy']);
    expect(threads['bo']!.map((x) => x.id), ['1', '2']);
  });
}
