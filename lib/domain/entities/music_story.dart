/// Music Stories (docs/music-stories.md): temporary, music-focused stories.
/// Metadata only: no audio is ever kept or played in Vibra.
enum StoryKind {
  nowPlaying('now_playing'),
  artist('artist'),
  album('album'),
  playlist('playlist'),
  concertPhoto('concert_photo'),
  opinion('opinion');

  const StoryKind(this.wire);
  final String wire;

  /// Kinds that name a music item (searchable on Spotify or linked).
  bool get isMusic =>
      this != StoryKind.concertPhoto && this != StoryKind.opinion;

  static StoryKind? fromWire(Object? v) =>
      StoryKind.values.where((k) => k.wire == v).firstOrNull;
}

/// Background styles for opinion stories (and items without artwork).
const storyBackgrounds = ['aurora', 'sunset', 'ocean', 'ember', 'mono'];

/// A music item picked while composing: a Spotify result or a typed link.
class StoryItem {
  const StoryItem({
    required this.provider,
    required this.title,
    required this.externalUrl,
    this.itemId,
    this.subtitle,
    this.artworkUrl,
  });

  final String provider;
  final String? itemId;
  final String title;
  final String? subtitle;

  /// Provider-hosted artwork (Spotify CDN); never copied.
  final String? artworkUrl;
  final String externalUrl;

  bool get isSpotify => provider == 'spotify';

  static StoryItem? fromJson(Object? raw) {
    if (raw is! Map ||
        raw['title'] is! String ||
        raw['external_url'] is! String) {
      return null;
    }
    return StoryItem(
      provider: raw['provider'] == 'spotify' ? 'spotify' : 'link',
      itemId: (raw['item_id'] ?? raw['track_id']) as String?,
      title: raw['title'] as String,
      subtitle: raw['subtitle'] as String?,
      artworkUrl: raw['artwork_url'] as String?,
      externalUrl: raw['external_url'] as String,
    );
  }
}

class MusicStory {
  const MusicStory({
    required this.id,
    required this.userId,
    required this.username,
    required this.kind,
    required this.createdAt,
    required this.expiresAt,
    this.displayName,
    this.avatarUrl,
    this.item,
    this.mediaPath,
    this.eventId,
    this.eventName,
    this.body,
    this.background = 'aurora',
    this.everyone = false,
    this.allowReplies = true,
    this.reactions = const {},
    this.myReactions = const {},
    this.seen = false,
    this.viewCount,
    this.replyCount,
    this.heldForReview = false,
  });

  final String id;
  final String userId;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final StoryKind kind;
  final StoryItem? item;

  /// Path in the private story-media bucket (concert photos).
  final String? mediaPath;
  final String? eventId;
  final String? eventName;
  final String? body;
  final String background;
  final bool everyone;
  final bool allowReplies;
  final DateTime createdAt;
  final DateTime expiresAt;
  final Map<String, int> reactions;
  final Set<String> myReactions;
  final bool seen;

  /// Author only.
  final int? viewCount;
  final int? replyCount;
  final bool heldForReview;

  String get name =>
      displayName?.trim().isNotEmpty == true ? displayName!.trim() : username;

  MusicStory copyWith({
    Map<String, int>? reactions,
    Set<String>? myReactions,
    bool? seen,
    bool? everyone,
    bool? allowReplies,
  }) => MusicStory(
    id: id,
    userId: userId,
    username: username,
    displayName: displayName,
    avatarUrl: avatarUrl,
    kind: kind,
    item: item,
    mediaPath: mediaPath,
    eventId: eventId,
    eventName: eventName,
    body: body,
    background: background,
    everyone: everyone ?? this.everyone,
    allowReplies: allowReplies ?? this.allowReplies,
    createdAt: createdAt,
    expiresAt: expiresAt,
    reactions: reactions ?? this.reactions,
    myReactions: myReactions ?? this.myReactions,
    seen: seen ?? this.seen,
    viewCount: viewCount,
    replyCount: replyCount,
    heldForReview: heldForReview,
  );

  MusicStory withReaction(String r, {required bool on}) {
    final counts = Map<String, int>.from(reactions);
    final mine = Set<String>.from(myReactions);
    if (on && mine.add(r)) counts[r] = (counts[r] ?? 0) + 1;
    if (!on && mine.remove(r)) {
      final n = (counts[r] ?? 1) - 1;
      n <= 0 ? counts.remove(r) : counts[r] = n;
    }
    return copyWith(reactions: counts, myReactions: mine);
  }

  static MusicStory? fromRow(Map<String, dynamic> r) {
    final kind = StoryKind.fromWire(r['kind']);
    final expires = DateTime.tryParse('${r['expires_at']}');
    if (r['id'] is! String ||
        r['user_id'] is! String ||
        kind == null ||
        expires == null) {
      return null;
    }
    final item = kind.isMusic ? StoryItem.fromJson(r) : null;
    if (kind.isMusic && item == null) return null;
    final reactions = <String, int>{};
    if (r['reactions'] is Map) {
      (r['reactions'] as Map).forEach((k, v) {
        if (k is String && v is num) reactions[k] = v.toInt();
      });
    }
    return MusicStory(
      id: r['id'] as String,
      userId: r['user_id'] as String,
      username: r['username']?.toString() ?? 'user',
      displayName: r['display_name'] as String?,
      avatarUrl: r['avatar_url'] as String?,
      kind: kind,
      item: item,
      mediaPath: r['media_path'] as String?,
      eventId: r['event_id'] as String?,
      eventName: r['event_name'] as String?,
      body: r['body'] as String?,
      background: storyBackgrounds.contains(r['background'])
          ? r['background'] as String
          : 'aurora',
      everyone: r['visibility'] == 'everyone',
      allowReplies: r['allow_replies'] != false,
      createdAt:
          DateTime.tryParse('${r['created_at']}') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      expiresAt: expires,
      reactions: reactions,
      myReactions: {
        if (r['my_reactions'] is List)
          ...(r['my_reactions'] as List).whereType<String>(),
      },
      seen: r['seen'] == true,
      viewCount: (r['view_count'] as num?)?.toInt(),
      replyCount: (r['reply_count'] as num?)?.toInt(),
      heldForReview: r['held_for_review'] == true,
    );
  }
}

/// One avatar in the story ring.
class StoryRingEntry {
  const StoryRingEntry({
    required this.userId,
    required this.username,
    required this.storyCount,
    required this.allSeen,
    this.displayName,
    this.avatarUrl,
  });

  final String userId;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final int storyCount;
  final bool allSeen;

  String get name =>
      displayName?.trim().isNotEmpty == true ? displayName!.trim() : username;

  static StoryRingEntry? fromRow(Map<String, dynamic> r) {
    if (r['user_id'] is! String) return null;
    return StoryRingEntry(
      userId: r['user_id'] as String,
      username: r['username']?.toString() ?? 'user',
      displayName: r['display_name'] as String?,
      avatarUrl: r['avatar_url'] as String?,
      storyCount: (r['story_count'] as num?)?.toInt() ?? 0,
      allSeen: r['all_seen'] == true,
    );
  }
}

/// A person in a story list: viewers, hidden-from list, audience candidates.
class StoryPerson {
  const StoryPerson({
    required this.userId,
    required this.username,
    this.displayName,
    this.avatarUrl,
    this.flag = false,
    this.reactions = const [],
  });

  final String userId;
  final String username;
  final String? displayName;
  final String? avatarUrl;

  /// Hidden (audience candidates).
  final bool flag;

  /// Reactions left (viewers).
  final List<String> reactions;

  String get name =>
      displayName?.trim().isNotEmpty == true ? displayName!.trim() : username;

  static StoryPerson? fromRow(Map<String, dynamic> r) {
    if (r['user_id'] is! String) return null;
    return StoryPerson(
      userId: r['user_id'] as String,
      username: r['username']?.toString() ?? 'user',
      displayName: r['display_name'] as String?,
      avatarUrl: r['avatar_url'] as String?,
      flag: r['hidden'] == true,
      reactions: [
        if (r['reactions'] is List)
          ...(r['reactions'] as List).whereType<String>(),
      ],
    );
  }
}

class StoryReply {
  const StoryReply({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.username,
    required this.body,
    required this.createdAt,
    this.displayName,
    this.avatarUrl,
  });

  final String id;
  final String senderId;
  final String recipientId;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final String body;
  final DateTime createdAt;

  String get name =>
      displayName?.trim().isNotEmpty == true ? displayName!.trim() : username;

  static StoryReply? fromRow(Map<String, dynamic> r) {
    if (r['id'] is! String ||
        r['sender_id'] is! String ||
        r['recipient_id'] is! String) {
      return null;
    }
    return StoryReply(
      id: r['id'] as String,
      senderId: r['sender_id'] as String,
      recipientId: r['recipient_id'] as String,
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

/// Groups replies into one thread per viewer (for the author).
Map<String, List<StoryReply>> storyThreads(
  List<StoryReply> replies,
  String authorId,
) {
  final threads = <String, List<StoryReply>>{};
  for (final r in replies) {
    final viewer = r.senderId == authorId ? r.recipientId : r.senderId;
    threads.putIfAbsent(viewer, () => []).add(r);
  }
  return threads;
}

class StorySettings {
  const StorySettings({this.everyone = false, this.allowReplies = true});
  final bool everyone;
  final bool allowReplies;
}
