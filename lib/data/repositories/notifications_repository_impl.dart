import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/supabase_notifications_datasource.dart';
import '../mappers/domain_mappers.dart';

/// Repository concreto per notifiche.
class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(this._datasource);

  final SupabaseNotificationsDatasource _datasource;

  @override
  Future<List<AppNotification>> listMyNotifications({int limit = 50}) async {
    final models = await _datasource.listMyNotifications(limit: limit);
    return models.map((item) => item.toEntity()).toList(growable: false);
  }

  @override
  Future<AppNotification> markAsRead(String notificationId) async {
    final model = await _datasource.markAsRead(notificationId);
    return model.toEntity();
  }
}
