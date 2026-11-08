/// Concert Match (docs/concert-match.md). People appear because their plans
/// for this event are visible to the viewer, or because they are a mutual
/// musical match who loves the event's artist (no attendance shown then).
class ConcertMatchPerson {
  const ConcertMatchPerson({
    required this.userId,
    required this.username,
    this.displayName,
    this.avatarUrl,
    this.status,
    this.artistFan = false,
    this.compatibility,
    this.isFriend = false,
    this.connection,
    this.canInvite = false,
  });

  final String userId;
  final String username;
  final String? displayName;
  final String? avatarUrl;

  /// interested | maybe | going, only when visible to the viewer.
  final String? status;
  final bool artistFan;
  final int? compatibility;
  final bool isFriend;
  final String? connection;

  /// Invitable to a circle (connection or mutual musical match).
  final bool canInvite;

  String get name =>
      displayName?.trim().isNotEmpty == true ? displayName!.trim() : username;

  static ConcertMatchPerson? fromJson(Object? raw) {
    if (raw is! Map || raw['user_id'] is! String) return null;
    final status = raw['status'];
    return ConcertMatchPerson(
      userId: raw['user_id'] as String,
      username: raw['username']?.toString() ?? 'user',
      displayName: raw['display_name'] as String?,
      avatarUrl: raw['avatar_url'] as String?,
      status: const {'interested', 'maybe', 'going'}.contains(status)
          ? status as String
          : null,
      artistFan: raw['artist_fan'] == true,
      compatibility: (raw['compatibility'] as num?)?.round(),
      isFriend: raw['is_friend'] == true,
      connection: raw['connection'] as String?,
      canInvite: raw['can_invite'] == true,
    );
  }
}

class ConcertMatch {
  const ConcertMatch({
    this.myStatus,
    this.interestedCount = 0,
    this.people = const [],
  });

  final String? myStatus;

  /// Other people whose plans for this event the viewer can see.
  final int interestedCount;
  final List<ConcertMatchPerson> people;

  static ConcertMatch fromJson(Object? raw) {
    if (raw is! Map) return const ConcertMatch();
    final status = raw['my_status'];
    return ConcertMatch(
      myStatus: status is String ? status : null,
      interestedCount: (raw['interested_count'] as num?)?.toInt() ?? 0,
      people: [
        for (final p
            in (raw['people'] is List ? raw['people'] as List : const []))
          ?ConcertMatchPerson.fromJson(p),
      ],
    );
  }
}

/// A group activity inside a circle.
class CirclePlan {
  const CirclePlan({
    required this.id,
    required this.title,
    required this.createdBy,
    this.startsAt,
    this.note,
    this.participants = 0,
    this.joined = false,
  });

  final String id;
  final String title;
  final DateTime? startsAt;
  final String? note;
  final String createdBy;
  final int participants;
  final bool joined;

  static CirclePlan? fromRow(Map<String, dynamic> r) {
    if (r['id'] is! String || r['title'] is! String) return null;
    return CirclePlan(
      id: r['id'] as String,
      title: r['title'] as String,
      startsAt: DateTime.tryParse('${r['starts_at']}'),
      note: r['note'] as String?,
      createdBy: r['created_by']?.toString() ?? '',
      participants: (r['participants'] as num?)?.toInt() ?? 0,
      joined: r['joined'] == true,
    );
  }
}
