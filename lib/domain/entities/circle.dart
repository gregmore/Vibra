import 'event.dart';

/// VIBRA Circles (docs/circles.md): small invite-only music groups.
enum CircleBasis {
  genre,
  artist,
  concert,
  interest,
  activity;

  static CircleBasis fromName(Object? v) => switch (v) {
    'genre' => genre,
    'artist' => artist,
    'concert' => concert,
    'activity' => activity,
    _ => interest,
  };
}

class Circle {
  const Circle({
    required this.id,
    required this.name,
    required this.basis,
    this.description = '',
    this.genreKey,
    this.artistName,
    this.eventId,
    this.topic,
    this.memberCount = 0,
    this.maxMembers = 12,
    this.isAdmin = false,
    this.muted = false,
    this.lastMessageAt,
  });

  final String id;
  final String name;
  final String description;
  final CircleBasis basis;
  final String? genreKey;
  final String? artistName;
  final String? eventId;
  final String? topic;
  final int memberCount;
  final int maxMembers;
  final bool isAdmin;
  final bool muted;
  final DateTime? lastMessageAt;

  Circle copyWith({bool? muted}) => Circle(
    id: id,
    name: name,
    basis: basis,
    description: description,
    genreKey: genreKey,
    artistName: artistName,
    eventId: eventId,
    topic: topic,
    memberCount: memberCount,
    maxMembers: maxMembers,
    isAdmin: isAdmin,
    muted: muted ?? this.muted,
    lastMessageAt: lastMessageAt,
  );

  static Circle? fromRow(Map<String, dynamic> r) {
    if (r['id'] is! String || r['name'] is! String) return null;
    return Circle(
      id: r['id'] as String,
      name: r['name'] as String,
      description: r['description']?.toString() ?? '',
      basis: CircleBasis.fromName(r['basis']),
      genreKey: r['genre_key'] as String?,
      artistName: r['artist_name'] as String?,
      eventId: r['event_id'] as String?,
      topic: r['topic'] as String?,
      memberCount: (r['member_count'] as num?)?.toInt() ?? 0,
      maxMembers: (r['max_members'] as num?)?.toInt() ?? 12,
      isAdmin: r['my_role'] == 'admin',
      muted: r['muted'] == true,
      lastMessageAt: DateTime.tryParse('${r['last_message_at']}'),
    );
  }
}

class CirclePerson {
  const CirclePerson({
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

  static CirclePerson? fromRow(
    Map<String, dynamic> r, {
    String idKey = 'user_id',
  }) {
    final id = r[idKey];
    if (id is! String) return null;
    return CirclePerson(
      id: id,
      username: r['username']?.toString() ?? 'user',
      displayName: r['display_name'] as String?,
      avatarUrl: r['avatar_url'] as String?,
    );
  }
}

class CircleMember {
  const CircleMember(this.person, {this.isAdmin = false, this.eventStatus});
  final CirclePerson person;
  final bool isAdmin;

  /// interested | maybe | going for the circle's concert (members only).
  final String? eventStatus;
}

/// A circle the user belongs to that is about one event.
class EventCircle {
  const EventCircle(this.id, this.name, this.memberCount);
  final String id;
  final String name;
  final int memberCount;
}

class CircleInvitation {
  const CircleInvitation({
    required this.id,
    required this.circleId,
    required this.circleName,
    required this.inviter,
    this.circleDescription = '',
    this.basis = CircleBasis.interest,
    this.memberCount = 0,
  });

  final String id;
  final String circleId;
  final String circleName;
  final String circleDescription;
  final CircleBasis basis;
  final int memberCount;
  final CirclePerson inviter;

  static CircleInvitation? fromRow(Map<String, dynamic> r) {
    final inviter = CirclePerson(
      id: r['inviter_id']?.toString() ?? '',
      username: r['inviter_username']?.toString() ?? 'user',
      displayName: r['inviter_display_name'] as String?,
      avatarUrl: r['inviter_avatar_url'] as String?,
    );
    if (r['id'] is! String || r['circle_id'] is! String) return null;
    return CircleInvitation(
      id: r['id'] as String,
      circleId: r['circle_id'] as String,
      circleName: r['circle_name']?.toString() ?? '',
      circleDescription: r['circle_description']?.toString() ?? '',
      basis: CircleBasis.fromName(r['basis']),
      memberCount: (r['member_count'] as num?)?.toInt() ?? 0,
      inviter: inviter,
    );
  }
}

/// An invitation the circle sent that is still waiting for an answer.
class PendingCircleInvite {
  const PendingCircleInvite(this.id, this.person);
  final String id;
  final CirclePerson person;
}

class CircleMessage {
  const CircleMessage({
    required this.id,
    required this.senderId,
    required this.body,
    required this.createdAt,
    this.heldForReview = false,
  });
  final String id;
  final String senderId;
  final String body;
  final DateTime createdAt;

  /// Hidden from other members while admins review reports.
  final bool heldForReview;

  static CircleMessage? fromRow(Map<String, dynamic> r) {
    if (r['id'] is! String || r['sender_id'] is! String) return null;
    return CircleMessage(
      id: r['id'] as String,
      senderId: r['sender_id'] as String,
      body: r['body']?.toString() ?? '',
      heldForReview: r['held_for_review'] == true,
      createdAt:
          DateTime.tryParse('${r['created_at']}') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class PlaylistItem {
  const PlaylistItem({
    required this.id,
    required this.url,
    required this.addedBy,
    this.title,
    this.artist,
    this.addedByUsername,
  });
  final String id;
  final String url;
  final String? title;
  final String? artist;
  final String addedBy;
  final String? addedByUsername;

  static PlaylistItem? fromRow(Map<String, dynamic> r) {
    if (r['id'] is! String || r['url'] is! String) return null;
    return PlaylistItem(
      id: r['id'] as String,
      url: r['url'] as String,
      title: r['title'] as String?,
      artist: r['artist'] as String?,
      addedBy: r['added_by']?.toString() ?? '',
      addedByUsername: r['added_by_username'] as String?,
    );
  }
}

/// Shared upcoming events of a circle.
typedef CircleEvents = List<Event>;
