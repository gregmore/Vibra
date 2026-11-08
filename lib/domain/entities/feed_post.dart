import 'music_story.dart' show StoryItem;

/// VIBRA Feed (docs/vibra-feed.md). Metadata only: no audio is ever kept or
/// played in Vibra.
enum FeedKind {
  song('song'),
  album('album'),
  playlist('playlist'),
  recommendation('recommendation'),
  discovery('discovery'),
  review('review'),
  opinion('opinion'),
  concertPhoto('concert_photo'),
  share('share');

  const FeedKind(this.wire);
  final String wire;

  /// Item types each kind accepts (empty: no music item).
  List<FeedItemType> get itemTypes => switch (this) {
    FeedKind.song => const [FeedItemType.track],
    FeedKind.album => const [FeedItemType.album],
    FeedKind.playlist => const [FeedItemType.playlist],
    FeedKind.recommendation || FeedKind.discovery => FeedItemType.values,
    FeedKind.review => const [FeedItemType.album, FeedItemType.track],
    _ => const [],
  };

  bool get hasItem => itemTypes.isNotEmpty;

  /// Kinds a person picks in the composer (shares come from a post).
  static const composable = [
    FeedKind.recommendation,
    FeedKind.song,
    FeedKind.album,
    FeedKind.playlist,
    FeedKind.review,
    FeedKind.discovery,
    FeedKind.opinion,
    FeedKind.concertPhoto,
  ];

  static FeedKind? fromWire(Object? v) =>
      FeedKind.values.where((k) => k.wire == v).firstOrNull;
}

enum FeedItemType {
  track('track'),
  album('album'),
  artist('artist'),
  playlist('playlist');

  const FeedItemType(this.wire);
  final String wire;

  static FeedItemType? fromWire(Object? v) =>
      FeedItemType.values.where((k) => k.wire == v).firstOrNull;
}

/// Feed orderings: relevance, or strictly chronological.
enum FeedMode {
  forYou('for_you'),
  following('following'),
  latest('latest');

  const FeedMode(this.wire);
  final String wire;
}

/// Why a post is in "For you" (shown to the reader, never hidden).
enum FeedReason {
  following,
  connection,
  artists,
  genres,
  community,
  match,
  interaction,
  newPost,
  chronological,
  mine;

  static FeedReason from(Object? v) => switch (v) {
    'following' => FeedReason.following,
    'connection' => FeedReason.connection,
    'artists' => FeedReason.artists,
    'genres' => FeedReason.genres,
    'community' => FeedReason.community,
    'match' => FeedReason.match,
    'interaction' => FeedReason.interaction,
    'mine' => FeedReason.mine,
    'new' => FeedReason.newPost,
    _ => FeedReason.chronological,
  };
}

/// Like plus the VIBRA emoji reactions.
const feedLike = 'like';

class FeedPost {
  const FeedPost({
    required this.id,
    required this.userId,
    required this.username,
    required this.kind,
    required this.createdAt,
    this.displayName,
    this.avatarUrl,
    this.itemType,
    this.item,
    this.mediaPath,
    this.eventId,
    this.eventName,
    this.body,
    this.rating,
    this.everyone = true,
    this.commentsEnabled = true,
    this.likeCount = 0,
    this.reactions = const {},
    this.myReactions = const {},
    this.commentCount = 0,
    this.shareCount = 0,
    this.bookmarked = false,
    this.heldForReview = false,
    this.shared,
    this.reason = FeedReason.chronological,
    this.savedAt,
  });

  final String id;
  final String userId;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final FeedKind kind;
  final FeedItemType? itemType;
  final StoryItem? item;

  /// Path in the private feed-media bucket (concert photos).
  final String? mediaPath;
  final String? eventId;
  final String? eventName;
  final String? body;
  final int? rating;
  final bool everyone;
  final bool commentsEnabled;
  final DateTime createdAt;
  final int likeCount;
  final Map<String, int> reactions;
  final Set<String> myReactions;
  final int commentCount;
  final int shareCount;
  final bool bookmarked;
  final bool heldForReview;

  /// The original, for a share (null if it is gone or no longer visible).
  final FeedPost? shared;
  final FeedReason reason;

  /// When I bookmarked it (only on my saved list; its paging cursor).
  final DateTime? savedAt;

  String get name =>
      displayName?.trim().isNotEmpty == true ? displayName!.trim() : username;

  bool get liked => myReactions.contains(feedLike);

  /// The post whose content is shown (the original for a share).
  FeedPost get content => shared ?? this;

  FeedPost copyWith({
    int? likeCount,
    Map<String, int>? reactions,
    Set<String>? myReactions,
    int? commentCount,
    int? shareCount,
    bool? bookmarked,
    bool? everyone,
    bool? commentsEnabled,
    FeedReason? reason,
    DateTime? savedAt,
  }) => FeedPost(
    id: id,
    userId: userId,
    username: username,
    displayName: displayName,
    avatarUrl: avatarUrl,
    kind: kind,
    itemType: itemType,
    item: item,
    mediaPath: mediaPath,
    eventId: eventId,
    eventName: eventName,
    body: body,
    rating: rating,
    everyone: everyone ?? this.everyone,
    commentsEnabled: commentsEnabled ?? this.commentsEnabled,
    createdAt: createdAt,
    likeCount: likeCount ?? this.likeCount,
    reactions: reactions ?? this.reactions,
    myReactions: myReactions ?? this.myReactions,
    commentCount: commentCount ?? this.commentCount,
    shareCount: shareCount ?? this.shareCount,
    bookmarked: bookmarked ?? this.bookmarked,
    heldForReview: heldForReview,
    savedAt: savedAt ?? this.savedAt,
    shared: shared,
    reason: reason ?? this.reason,
  );

  /// Toggles a like or a reaction locally (optimistic update).
  FeedPost withReaction(String r, {required bool on}) {
    final mine = Set<String>.from(myReactions);
    final changed = on ? mine.add(r) : mine.remove(r);
    if (!changed) return this;
    if (r == feedLike) {
      return copyWith(
        myReactions: mine,
        likeCount: (likeCount + (on ? 1 : -1)).clamp(0, 1 << 30),
      );
    }
    final counts = Map<String, int>.from(reactions);
    final n = (counts[r] ?? 0) + (on ? 1 : -1);
    n <= 0 ? counts.remove(r) : counts[r] = n;
    return copyWith(reactions: counts, myReactions: mine);
  }

  static FeedPost? fromRow(Map<String, dynamic> r, {bool nested = false}) {
    final kind = FeedKind.fromWire(r['kind']);
    if (r['id'] is! String || r['user_id'] is! String || kind == null) {
      return null;
    }
    final item = kind.hasItem ? StoryItem.fromJson(r) : null;
    if (kind.hasItem && item == null) return null;
    final shared = !nested && r['shared'] is Map
        ? FeedPost.fromRow(
            Map<String, dynamic>.from(r['shared'] as Map),
            nested: true,
          )
        : null;
    if (kind == FeedKind.share && !nested && shared == null) return null;
    final reactions = <String, int>{};
    if (r['reactions'] is Map) {
      (r['reactions'] as Map).forEach((k, v) {
        if (k is String && v is num) reactions[k] = v.toInt();
      });
    }
    return FeedPost(
      id: r['id'] as String,
      userId: r['user_id'] as String,
      username: r['username']?.toString() ?? 'user',
      displayName: r['display_name'] as String?,
      avatarUrl: r['avatar_url'] as String?,
      kind: kind,
      itemType: FeedItemType.fromWire(r['item_type']),
      item: item,
      mediaPath: r['media_path'] as String?,
      eventId: r['event_id'] as String?,
      eventName: r['event_name'] as String?,
      body: r['body'] as String?,
      rating: (r['rating'] as num?)?.toInt(),
      everyone: r['visibility'] != 'connections',
      commentsEnabled: r['comments_enabled'] != false,
      createdAt:
          DateTime.tryParse('${r['created_at']}') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      likeCount: (r['like_count'] as num?)?.toInt() ?? 0,
      reactions: reactions,
      myReactions: {
        if (r['my_reactions'] is List)
          ...(r['my_reactions'] as List).whereType<String>(),
      },
      commentCount: (r['comment_count'] as num?)?.toInt() ?? 0,
      shareCount: (r['share_count'] as num?)?.toInt() ?? 0,
      bookmarked: r['bookmarked'] == true,
      heldForReview: r['held_for_review'] == true,
      shared: shared,
    );
  }
}

class FeedComment {
  const FeedComment({
    required this.id,
    required this.authorId,
    required this.username,
    required this.body,
    required this.createdAt,
    this.parentId,
    this.displayName,
    this.avatarUrl,
  });

  final String id;
  final String? parentId;
  final String authorId;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final String body;
  final DateTime createdAt;

  String get name =>
      displayName?.trim().isNotEmpty == true ? displayName!.trim() : username;

  static FeedComment? fromRow(Map<String, dynamic> r) {
    if (r['id'] is! String || r['author_id'] is! String) return null;
    return FeedComment(
      id: r['id'] as String,
      parentId: r['parent_id'] as String?,
      authorId: r['author_id'] as String,
      username: r['username']?.toString() ?? 'user',
      displayName: r['display_name'] as String?,
      avatarUrl: r['avatar_url'] as String?,
      body: r['body']?.toString() ?? '',
      createdAt:
          DateTime.tryParse('${r['created_at']}') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

/// Orders rows returned by id lookups the way the ranked ids came back.
List<FeedPost> orderedFeed(
  List<({String id, FeedReason reason})> ranked,
  List<FeedPost> rows,
) {
  final byId = {for (final p in rows) p.id: p};
  return [
    for (final r in ranked)
      if (byId[r.id] case final p?) p.copyWith(reason: r.reason),
  ];
}
