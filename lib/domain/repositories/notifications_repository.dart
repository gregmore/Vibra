import '../entities/app_notification.dart';

abstract class NotificationsRepository {
  Future<List<AppNotification>> listMyNotifications({int limit = 50});

  Future<AppNotification> markAsRead(String notificationId);
}
