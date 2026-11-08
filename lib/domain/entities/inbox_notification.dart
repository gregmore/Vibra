/// Notification Center (docs/notification-center.md).
enum NotificationCategory {
  requests,
  messages,
  communities,
  circles,
  concerts,
  reminders,
  recommendations,
  social,
  discoveries,
  updates;

  static NotificationCategory fromWire(Object? v) =>
      NotificationCategory.values.where((c) => c.name == v).firstOrNull ??
      NotificationCategory.updates;

  /// Push at most once a day each (the server enforces it).
  bool get lowPriority => const {
    NotificationCategory.communities,
    NotificationCategory.recommendations,
    NotificationCategory.discoveries,
    NotificationCategory.updates,
  }.contains(this);
}

class InboxNotification {
  const InboxNotification({
    required this.id,
    required this.type,
    required this.category,
    required this.title,
    required this.body,
    required this.createdAt,
    this.data = const {},
    this.read = false,
    this.groupCount = 1,
    this.actorId,
    this.actorName,
    this.actorAvatar,
  });

  final String id;
  final String type;
  final NotificationCategory category;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final bool read;

  /// How many events this one notification groups.
  final int groupCount;
  final String? actorId;
  final String? actorName;
  final String? actorAvatar;
  final DateTime createdAt;

  InboxNotification markedRead() => InboxNotification(
    id: id,
    type: type,
    category: category,
    title: title,
    body: body,
    createdAt: createdAt,
    data: data,
    read: true,
    groupCount: groupCount,
    actorId: actorId,
    actorName: actorName,
    actorAvatar: actorAvatar,
  );

  static InboxNotification? fromRow(Map<String, dynamic> r) {
    if (r['id'] is! String || r['type'] is! String) return null;
    return InboxNotification(
      id: r['id'] as String,
      type: r['type'] as String,
      category: NotificationCategory.fromWire(r['category']),
      title: r['title']?.toString() ?? '',
      body: r['body']?.toString() ?? '',
      data: r['data'] is Map
          ? Map<String, dynamic>.from(r['data'] as Map)
          : const {},
      read: r['read'] == true,
      groupCount: (r['group_count'] as num?)?.toInt() ?? 1,
      actorId: r['actor_id'] as String?,
      actorName: r['actor_name'] as String?,
      actorAvatar: r['actor_avatar'] as String?,
      createdAt:
          DateTime.tryParse('${r['created_at']}') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class NotificationSettings {
  const NotificationSettings({
    this.pushEnabled = true,
    this.hasDevice = false,
    this.categories = const {},
    this.quietStart = 22,
    this.quietEnd = 8,
    this.timezone = 'Europe/Rome',
    this.dailyCap = 20,
  });

  final bool pushEnabled;

  /// A device is registered for push (FCM token stored).
  final bool hasDevice;
  final Map<NotificationCategory, bool> categories;
  final int quietStart;
  final int quietEnd;
  final String timezone;
  final int dailyCap;

  bool push(NotificationCategory c) => categories[c] ?? true;

  NotificationSettings copyWith({
    Map<NotificationCategory, bool>? categories,
    int? quietStart,
    int? quietEnd,
    int? dailyCap,
  }) => NotificationSettings(
    pushEnabled: pushEnabled,
    hasDevice: hasDevice,
    categories: categories ?? this.categories,
    quietStart: quietStart ?? this.quietStart,
    quietEnd: quietEnd ?? this.quietEnd,
    timezone: timezone,
    dailyCap: dailyCap ?? this.dailyCap,
  );

  static NotificationSettings fromJson(Object? raw) {
    if (raw is! Map) return const NotificationSettings();
    final cats = raw['categories'] is Map ? raw['categories'] as Map : const {};
    return NotificationSettings(
      pushEnabled: raw['push_enabled'] != false,
      hasDevice: raw['has_device'] == true,
      categories: {
        for (final e in cats.entries)
          NotificationCategory.fromWire(e.key): e.value != false,
      },
      quietStart: (raw['quiet_start'] as num?)?.toInt() ?? 22,
      quietEnd: (raw['quiet_end'] as num?)?.toInt() ?? 8,
      timezone: raw['timezone']?.toString() ?? 'Europe/Rome',
      dailyCap: (raw['daily_cap'] as num?)?.toInt() ?? 20,
    );
  }
}
