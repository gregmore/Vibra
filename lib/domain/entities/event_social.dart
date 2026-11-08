/// Who's Going? (docs/whos-going.md). Only people whose own visibility
/// choice includes the viewer ever appear here.
enum AttendanceVisibility {
  private,
  friends,
  matches,
  public;

  static AttendanceVisibility? fromName(Object? v) => switch (v) {
    'private' => private,
    'friends' => friends,
    'matches' => matches,
    'public' => public,
    _ => null,
  };
}

class EventSocialPerson {
  const EventSocialPerson({
    required this.userId,
    required this.username,
    required this.status,
    this.displayName,
    this.avatarUrl,
    this.isFriend = false,
    this.compatibility,
    this.connection,
  });

  final String userId;
  final String username;
  final String? displayName;
  final String? avatarUrl;

  /// interested | maybe | going
  final String status;
  final bool isFriend;

  /// Cached musical affinity, when both consented to matching.
  final int? compatibility;

  /// 'accepted' / 'pending' when a connection exists or was requested.
  final String? connection;

  String get name =>
      displayName?.trim().isNotEmpty == true ? displayName!.trim() : username;
  bool get canSendVibra => connection == null;

  static EventSocialPerson? fromJson(Object? raw) {
    if (raw is! Map || raw['user_id'] is! String) return null;
    final status = raw['status'];
    if (status is! String ||
        !const {'interested', 'maybe', 'going'}.contains(status)) {
      return null;
    }
    return EventSocialPerson(
      userId: raw['user_id'] as String,
      username: raw['username']?.toString() ?? 'user',
      displayName: raw['display_name'] as String?,
      avatarUrl: raw['avatar_url'] as String?,
      status: status,
      isFriend: raw['is_friend'] == true,
      compatibility: (raw['compatibility'] as num?)?.round(),
      connection: raw['connection'] as String?,
    );
  }
}

class EventCommunityLink {
  const EventCommunityLink(this.id, this.name, this.memberCount);
  final String id;
  final String name;
  final int memberCount;
}

class EventSocial {
  const EventSocial({
    this.people = const [],
    this.communities = const [],
    this.going = 0,
    this.maybe = 0,
    this.interested = 0,
  });

  final List<EventSocialPerson> people;
  final List<EventCommunityLink> communities;
  final int going;
  final int maybe;
  final int interested;

  List<EventSocialPerson> get friends =>
      people.where((p) => p.isFriend).toList(growable: false);
  List<EventSocialPerson> get compatible => people
      .where((p) => !p.isFriend && p.compatibility != null)
      .toList(growable: false);
  List<EventSocialPerson> get others => people
      .where((p) => !p.isFriend && p.compatibility == null)
      .toList(growable: false);

  static EventSocial fromJson(Object? raw) {
    if (raw is! Map) return const EventSocial();
    final counts = raw['counts'] is Map ? raw['counts'] as Map : const {};
    int n(Object? v) => v is num ? v.toInt() : 0;
    return EventSocial(
      going: n(counts['going']),
      maybe: n(counts['maybe']),
      interested: n(counts['interested']),
      people: [
        for (final p
            in (raw['people'] is List ? raw['people'] as List : const []))
          ?EventSocialPerson.fromJson(p),
      ],
      communities: [
        for (final c
            in (raw['communities'] is List
                ? raw['communities'] as List
                : const []))
          if (c is Map && c['id'] is String && c['name'] is String)
            EventCommunityLink(
              c['id'] as String,
              c['name'] as String,
              n(c['member_count']),
            ),
      ],
    );
  }
}

class MyAttendance {
  const MyAttendance({
    this.status,
    this.visibility,
    this.defaultVisibility = AttendanceVisibility.private,
  });

  /// interested | maybe | going | null
  final String? status;

  /// This event's own choice; null follows [defaultVisibility].
  final AttendanceVisibility? visibility;
  final AttendanceVisibility defaultVisibility;

  AttendanceVisibility get effective => visibility ?? defaultVisibility;

  static MyAttendance fromJson(Object? raw) {
    if (raw is! Map) return const MyAttendance();
    final status = raw['status'];
    return MyAttendance(
      status: const {'interested', 'maybe', 'going'}.contains(status)
          ? status as String
          : null,
      visibility: AttendanceVisibility.fromName(raw['visibility']),
      defaultVisibility:
          AttendanceVisibility.fromName(raw['default_visibility']) ??
          AttendanceVisibility.private,
    );
  }
}
