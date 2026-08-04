import '../entities/app_notification.dart';
import '../repositories/notifications_repository.dart';
import 'usecase.dart';

class ListNotificationsUseCase implements UseCase<List<AppNotification>, int> {
  ListNotificationsUseCase(this._repository);

  final NotificationsRepository _repository;

  @override
  Future<List<AppNotification>> call(int params) {
    return _repository.listMyNotifications(limit: params);
  }
}

class MarkNotificationAsReadUseCase
    implements UseCase<AppNotification, String> {
  MarkNotificationAsReadUseCase(this._repository);

  final NotificationsRepository _repository;

  @override
  Future<AppNotification> call(String params) {
    return _repository.markAsRead(params);
  }
}

