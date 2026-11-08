/// Daily Vibe (docs/daily-vibe.md). Metadata only: no audio is ever kept or
/// played in Vibra; listening happens on the provider.
class VibeTrack {
  const VibeTrack({
    required this.provider,
    required this.title,
    required this.artist,
    required this.externalUrl,
    this.trackId,
    this.album,
    this.artworkUrl,
  });

  /// 'spotify' or 'link'.
  final String provider;
  final String? trackId;
  final String title;
  final String artist;
  final String? album;

  /// Provider-hosted artwork (Spotify CDN); never copied.
  final String? artworkUrl;
  final String externalUrl;

  bool get isSpotify => provider == 'spotify';

  static VibeTrack? fromJson(Object? raw) {
    if (raw is! Map ||
        raw['title'] is! String ||
        raw['artist'] is! String ||
        raw['external_url'] is! String) {
      return null;
    }
    return VibeTrack(
      provider: raw['provider'] == 'spotify' ? 'spotify' : 'link',
      trackId: raw['track_id'] as String?,
      title: raw['title'] as String,
      artist: raw['artist'] as String,
      album: raw['album'] as String?,
      artworkUrl: raw['artwork_url'] as String?,
      externalUrl: raw['external_url'] as String,
    );
  }
}

class DailyVibe {
  const DailyVibe({
    required this.id,
    required this.userId,
    required this.username,
    required this.track,
    required this.createdAt,
    this.displayName,
    this.avatarUrl,
    this.caption,
    this.everyone = false,
    this.expiresAt,
    this.reactions = const {},
    this.myReactions = const {},
    this.commentCount = 0,
    this.saved = false,
    this.heldForReview = false,
  });

  final String id;
  final String userId;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final VibeTrack track;
  final String? caption;
  final bool everyone;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final Map<String, int> reactions;
  final Set<String> myReactions;
  final int commentCount;
  final bool saved;
  final bool heldForReview;

  String get name =>
      displayName?.trim().isNotEmpty == true ? displayName!.trim() : username;

  DailyVibe copyWith({
    Map<String, int>? reactions,
    Set<String>? myReactions,
    bool? saved,
  }) => DailyVibe(
    id: id,
    userId: userId,
    username: username,
    displayName: displayName,
    avatarUrl: avatarUrl,
    track: track,
    caption: caption,
    everyone: everyone,
    expiresAt: expiresAt,
    createdAt: createdAt,
    reactions: reactions ?? this.reactions,
    myReactions: myReactions ?? this.myReactions,
    commentCount: commentCount,
    saved: saved ?? this.saved,
    heldForReview: heldForReview,
  );

  DailyVibe withReaction(String r, {required bool on}) {
    final counts = Map<String, int>.from(reactions);
    final mine = Set<String>.from(myReactions);
    if (on && mine.add(r)) counts[r] = (counts[r] ?? 0) + 1;
    if (!on && mine.remove(r)) {
      final n = (counts[r] ?? 1) - 1;
      n <= 0 ? counts.remove(r) : counts[r] = n;
    }
    return copyWith(reactions: counts, myReactions: mine);
  }

  static DailyVibe? fromRow(Map<String, dynamic> r) {
    final track = VibeTrack.fromJson(r);
    if (r['id'] is! String || r['user_id'] is! String || track == null) {
      return null;
    }
    final reactions = <String, int>{};
    if (r['reactions'] is Map) {
      (r['reactions'] as Map).forEach((k, v) {
        if (k is String && v is num) reactions[k] = v.toInt();
      });
    }
    return DailyVibe(
      id: r['id'] as String,
      userId: r['user_id'] as String,
      username: r['username']?.toString() ?? 'user',
      displayName: r['display_name'] as String?,
      avatarUrl: r['avatar_url'] as String?,
      track: track,
      caption: r['caption'] as String?,
      everyone: r['visibility'] == 'everyone',
      expiresAt: DateTime.tryParse('${r['expires_at']}'),
      createdAt:
          DateTime.tryParse('${r['created_at']}') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      reactions: reactions,
      myReactions: {
        if (r['my_reactions'] is List)
          ...(r['my_reactions'] as List).whereType<String>(),
      },
      commentCount: (r['comment_count'] as num?)?.toInt() ?? 0,
      saved: r['saved'] == true,
      heldForReview: r['held_for_review'] == true,
    );
  }
}

class VibeComment {
  const VibeComment({
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

  static VibeComment? fromRow(Map<String, dynamic> r) {
    if (r['id'] is! String || r['author_id'] is! String) return null;
    return VibeComment(
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

/// A song in my Discoveries (docs/track-reactions.md).
class Discovery {
  const Discovery(
    this.id,
    this.track, {
    this.source = 'vibe',
    this.viaUserId,
    this.viaName,
    this.savedAt,
  });
  final String id;
  final VibeTrack track;

  /// 'vibe' | 'story' | 'post' | 'community'.
  final String source;

  /// Who shared it (hidden if either blocked the other).
  final String? viaUserId;
  final String? viaName;
  final DateTime? savedAt;
}
