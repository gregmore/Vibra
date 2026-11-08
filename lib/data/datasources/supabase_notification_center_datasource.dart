import '../../core/errors/exceptions.dart';
import '../../domain/entities/inbox_notification.dart';
import 'supabase_datasource.dart';

/// Page size of the notification list (the server caps it at 100).
const notificationPageSize = 40;

/// Notification Center (docs/notification-center.md). Delivery decisions
/// are made on the server; this only reads my notifications and settings.
class SupabaseNotificationCenterDatasource {
  const SupabaseNotificationCenterDatasource(this._supabase);

  final SupabaseDatasource _supabase;

  void _requireUser() {
    if (_supabase.currentUser == null) {
      throw const AuthException(message: 'Utente non autenticato');
    }
  }

  /// One page, newest first; pass the oldest loaded `createdAt` as
  /// [before] for the next page.
  Future<List<InboxNotification>> list({
    DateTime? before,
    int limit = notificationPageSize,
  }) async {
    _requireUser();
    final rows = await _supabase.rpc(
      'get_notifications',
      params: {'p_before': before?.toUtc().toIso8601String(), 'p_limit': limit},
    );
    return [
      for (final r in (rows is List ? rows : const []))
        if (r is Map) ?InboxNotification.fromRow(Map<String, dynamic>.from(r)),
    ];
  }

  Future<int> unreadCount() async {
    if (_supabase.currentUser == null) return 0;
    final n = await _supabase.rpc('get_unread_notification_count');
    return n is num ? n.toInt() : 0;
  }

  /// Null marks everything read.
  Future<void> markRead([List<String>? ids]) {
    _requireUser();
    return _supabase.rpc('mark_notifications_read', params: {'p_ids': ids});
  }

  Future<NotificationSettings> settings() async {
    _requireUser();
    return NotificationSettings.fromJson(
      await _supabase.rpc('get_notification_settings'),
    );
  }

  Future<void> setCategory(NotificationCategory c, bool push) {
    _requireUser();
    return _supabase.rpc(
      'set_notification_category',
      params: {'p_category': c.name, 'p_push': push},
    );
  }

  Future<void> setSchedule({int? quietStart, int? quietEnd, int? dailyCap}) {
    _requireUser();
    return _supabase.rpc(
      'set_notification_schedule',
      params: {
        'p_quiet_start': quietStart,
        'p_quiet_end': quietEnd,
        'p_timezone': null,
        'p_daily_cap': dailyCap,
      },
    );
  }
}
