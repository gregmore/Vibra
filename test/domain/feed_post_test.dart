import 'package:flutter_test/flutter_test.dart';
import 'package:vibra/domain/entities/feed_post.dart';

void main() {
  final row = {
    'id': 'p1',
    'user_id': 'ana',
    'username': 'ana',
    'kind': 'review',
    'provider': 'spotify',
    'item_type': 'album',
    'item_id': '2xLMifQCjDGFmkHkpNLD9h',
    'title': 'Homogenic',
    'external_url': 'https://open.spotify.com/album/2xLMifQCjDGFmkHkpNLD9h',
    'body': 'A masterpiece',
    'rating': 5,
    'visibility': 'connections',
    'created_at': '2026-11-08T10:00:00Z',
    'like_count': 3,
    'reactions': {'fire': 2},
    'my_reactions': ['like'],
  };

  test('parses a review with its item, rating and my state', () {
    final p = FeedPost.fromRow(row)!;
    expect(p.kind, FeedKind.review);
    expect(p.itemType, FeedItemType.album);
    expect(p.rating, 5);
    expect(p.everyone, isFalse);
    expect(p.liked, isTrue);
  });

  test('likes and reactions toggle separately', () {
    final p = FeedPost.fromRow(row)!;
    final unliked = p.withReaction(feedLike, on: false);
    expect(unliked.likeCount, 2);
    expect(unliked.reactions, {'fire': 2});
    final fire = p.withReaction('fire', on: true);
    expect(fire.reactions['fire'], 3);
    expect(fire.likeCount, 3);
    // Toggling something already on changes nothing.
    expect(p.withReaction(feedLike, on: true).likeCount, 3);
  });

  test('a share needs its visible original; ranked order is kept', () {
    expect(
      FeedPost.fromRow({...row, 'kind': 'share', 'provider': null}),
      isNull,
    );
    final share = FeedPost.fromRow({
      'id': 's1',
      'user_id': 'bo',
      'kind': 'share',
      'created_at': '2026-11-08T11:00:00Z',
      'shared': row,
    })!;
    expect(share.content.id, 'p1');
    final ordered = orderedFeed(
      [
        (id: 's1', reason: FeedReason.genres),
        (id: 'p1', reason: FeedReason.following),
        (id: 'gone', reason: FeedReason.newPost),
      ],
      [FeedPost.fromRow(row)!, share],
    );
    expect(ordered.map((p) => p.id), ['s1', 'p1']);
    expect(ordered.first.reason, FeedReason.genres);
  });
}
