import 'event.dart';

/// Musical communities (docs/communities.md).
enum CommunityKind {
  genre,
  artist,
  interest;

  static CommunityKind fromName(Object? v) => switch (v) {
    'genre' => genre,
    'artist' => artist,
    _ => interest,
  };
}

enum CommunityRole {
  member,
  moderator,
  owner;

  static CommunityRole? fromName(Object? v) => switch (v) {
    'owner' => owner,
    'moderator' => moderator,
    'member' => member,
    _ => null,
  };

  bool get canModerate => this == moderator || this == owner;
}

class Community {
  const Community({
    required this.id,
    required this.slug,
    required this.name,
    required this.kind,
    this.description = '',
    this.genreKey,
    this.genreFamily,
    this.artistName,
    this.isOfficial = false,
    this.memberCount = 0,
    this.postCount = 0,
    this.myRole,
  });

  final String id;
  final String slug;
  final String name;
  final String description;
  final CommunityKind kind;
  final String? genreKey;
  final String? genreFamily;
  final String? artistName;
  final bool isOfficial;
  final int memberCount;
  final int postCount;
  final CommunityRole? myRole;

  bool get isMember => myRole != null;

  Community copyWith({
    CommunityRole? myRole,
    bool clearRole = false,
    int? memberCount,
  }) => Community(
    id: id,
    slug: slug,
    name: name,
    kind: kind,
    description: description,
    genreKey: genreKey,
    genreFamily: genreFamily,
    artistName: artistName,
    isOfficial: isOfficial,
    memberCount: memberCount ?? this.memberCount,
    postCount: postCount,
    myRole: clearRole ? null : (myRole ?? this.myRole),
  );

  static Community? fromRow(Map<String, dynamic> row) {
    if (row['id'] is! String || row['name'] is! String) return null;
    return Community(
      id: row['id'] as String,
      slug: row['slug']?.toString() ?? '',
      name: row['name'] as String,
      description: row['description']?.toString() ?? '',
      kind: CommunityKind.fromName(row['kind']),
      genreKey: row['genre_key'] as String?,
      genreFamily: row['genre_family'] as String?,
      artistName: row['artist_name'] as String?,
      isOfficial: row['is_official'] == true,
      memberCount: (row['member_count'] as num?)?.toInt() ?? 0,
      postCount: (row['post_count'] as num?)?.toInt() ?? 0,
      myRole: CommunityRole.fromName(row['my_role']),
    );
  }
}

enum CommunityPostKind {
  post,
  discussion,
  music,
  event;

  static CommunityPostKind fromName(Object? v) => switch (v) {
    'discussion' => discussion,
    'music' => music,
    'event' => event,
    _ => post,
  };
}

/// Reactions offered on posts (server enforces the same set).
abstract final class CommunityReactions {
  static const all = ['fire', 'heart', 'headphones', 'clap', 'mind_blown'];
  static const emoji = {
    'fire': '🔥',
    'heart': '❤️',
    'headphones': '🎧',
    'clap': '👏',
    'mind_blown': '🤯',
  };
}

class SharedMusic {
  const SharedMusic({required this.url, this.title, this.artist});
  final String url;
  final String? title;
  final String? artist;

  static SharedMusic? fromJson(Object? raw) =>
      raw is Map && raw['url'] is String
      ? SharedMusic(
          url: raw['url'] as String,
          title: raw['title'] as String?,
          artist: raw['artist'] as String?,
        )
      : null;
}

class CommunityAuthor {
  const CommunityAuthor({
    required this.id,
    required this.username,
    this.displayName,
    this.avatarUrl,
  });
  final String id;
  final String username;
  final String? displayName;
  final String? avatarUrl;

  String get name =>
      displayName?.trim().isNotEmpty == true ? displayName!.trim() : username;
}

class CommunityPost {
  const CommunityPost({
    required this.id,
    required this.communityId,
    required this.author,
    required this.kind,
    required this.createdAt,
    this.title,
    this.body = '',
    this.music,
    this.event,
    this.commentCount = 0,
    this.reactions = const {},
    this.myReactions = const {},
    this.heldForReview = false,
  });

  final String id;
  final String communityId;
  final CommunityAuthor author;
  final CommunityPostKind kind;
  final String? title;
  final String body;
  final SharedMusic? music;
  final Event? event;
  final int commentCount;
  final Map<String, int> reactions;
  final Set<String> myReactions;

  /// Visible only to its author and moderators while reports are reviewed.
  final bool heldForReview;
  final DateTime createdAt;

  CommunityPost withReaction(String reaction, {required bool on}) {
    final counts = Map<String, int>.from(reactions);
    final mine = Set<String>.from(myReactions);
    if (on && mine.add(reaction)) {
      counts[reaction] = (counts[reaction] ?? 0) + 1;
    } else if (!on && mine.remove(reaction)) {
      final n = (counts[reaction] ?? 1) - 1;
      if (n <= 0) {
        counts.remove(reaction);
      } else {
        counts[reaction] = n;
      }
    }
    return CommunityPost(
      id: id,
      communityId: communityId,
      author: author,
      kind: kind,
      createdAt: createdAt,
      title: title,
      body: body,
      music: music,
      event: event,
      commentCount: commentCount,
      reactions: counts,
      myReactions: mine,
      heldForReview: heldForReview,
    );
  }

  static CommunityPost? fromRow(
    Map<String, dynamic> row, {
    required Event? Function(Map<String, dynamic>) parseEvent,
  }) {
    final id = row['id'], authorId = row['author_id'];
    if (id is! String || authorId is! String) return null;
    final reactions = <String, int>{};
    if (row['reactions'] is Map) {
      (row['reactions'] as Map).forEach((k, v) {
        if (k is String && v is num && CommunityReactions.all.contains(k)) {
          reactions[k] = v.toInt();
        }
      });
    }
    return CommunityPost(
      id: id,
      communityId: row['community_id']?.toString() ?? '',
      author: CommunityAuthor(
        id: authorId,
        username: row['author_username']?.toString() ?? 'user',
        displayName: row['author_display_name'] as String?,
        avatarUrl: row['author_avatar_url'] as String?,
      ),
      kind: CommunityPostKind.fromName(row['kind']),
      title: row['title'] as String?,
      body: row['body']?.toString() ?? '',
      music: SharedMusic.fromJson(row['music']),
      event: row['event'] is Map
          ? parseEvent(Map<String, dynamic>.from(row['event'] as Map))
          : null,
      commentCount: (row['comment_count'] as num?)?.toInt() ?? 0,
      reactions: reactions,
      myReactions: {
        if (row['my_reactions'] is List)
          ...(row['my_reactions'] as List).whereType<String>(),
      },
      heldForReview: row['held_for_review'] == true,
      createdAt:
          DateTime.tryParse('${row['created_at']}') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class CommunityComment {
  const CommunityComment({
    required this.id,
    required this.postId,
    required this.author,
    required this.body,
    required this.createdAt,
    this.heldForReview = false,
  });

  final String id;
  final String postId;
  final CommunityAuthor author;
  final String body;
  final DateTime createdAt;
  final bool heldForReview;

  static CommunityComment? fromRow(Map<String, dynamic> row) {
    final id = row['id'], authorId = row['author_id'];
    if (id is! String || authorId is! String) return null;
    return CommunityComment(
      id: id,
      postId: row['post_id']?.toString() ?? '',
      author: CommunityAuthor(
        id: authorId,
        username: row['author_username']?.toString() ?? 'user',
        displayName: row['author_display_name'] as String?,
        avatarUrl: row['author_avatar_url'] as String?,
      ),
      body: row['body']?.toString() ?? '',
      heldForReview: row['held_for_review'] == true,
      createdAt:
          DateTime.tryParse('${row['created_at']}') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class CommunityMember {
  const CommunityMember({required this.author, required this.role});
  final CommunityAuthor author;
  final CommunityRole role;

  static CommunityMember? fromRow(Map<String, dynamic> row) {
    final id = row['user_id'];
    final role = CommunityRole.fromName(row['role']);
    if (id is! String || role == null) return null;
    return CommunityMember(
      author: CommunityAuthor(
        id: id,
        username: row['username']?.toString() ?? 'user',
        displayName: row['display_name'] as String?,
        avatarUrl: row['avatar_url'] as String?,
      ),
      role: role,
    );
  }
}

/// A held or reported item in a moderator's queue.
class ModerationItem {
  const ModerationItem({
    required this.postId,
    required this.authorId,
    required this.authorUsername,
    required this.body,
    this.commentId,
    this.title,
    this.heldForReview = false,
    this.removed = false,
    this.reportCount = 0,
    this.reasons = const [],
  });

  final String postId;
  final String? commentId;
  final String authorId;
  final String authorUsername;
  final String body;
  final String? title;
  final bool heldForReview;
  final bool removed;
  final int reportCount;
  final List<String> reasons;

  static ModerationItem? fromRow(Map<String, dynamic> row) {
    if (row['post_id'] is! String || row['author_id'] is! String) return null;
    return ModerationItem(
      postId: row['post_id'] as String,
      commentId: row['comment_id'] as String?,
      authorId: row['author_id'] as String,
      authorUsername: row['author_username']?.toString() ?? 'user',
      body: row['body']?.toString() ?? '',
      title: row['title'] as String?,
      heldForReview: row['held_for_review'] == true,
      removed: row['removed'] == true,
      reportCount: (row['report_count'] as num?)?.toInt() ?? 0,
      reasons: row['reasons'] is List
          ? (row['reasons'] as List).whereType<String>().toList()
          : const [],
    );
  }
}
