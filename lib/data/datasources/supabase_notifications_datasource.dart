import '../../core/constants/db_tables.dart';
import '../../core/errors/exceptions.dart';
import '../models/notification_model.dart';
import 'supabase_datasource.dart';

/// Datasource Supabase per notifiche in-app.
class SupabaseNotificationsDatasource {
  SupabaseNotificationsDatasource(this._supabase);

  final SupabaseDatasource _supabase;

  Future<List<NotificationModel>> listMyNotifications({int limit = 50}) async {
    final user = _supabase.currentUser;
    if (user == null)
      throw const AuthException(message: 'Utente non autenticato');

    final rows = await _supabase.select(
      DbTables.notifications,
      filters: {'user_id': user.id},
      orderBy: 'created_at',
      ascending: false,
      limit: limit,
    );
    return rows.map(NotificationModel.fromJson).toList(growable: false);
  }

  Future<NotificationModel> markAsRead(String notificationId) async {
    final row = await _supabase.update(
      DbTables.notifications,
      {'read': true},
      matchColumn: 'id',
      matchValue: notificationId,
    );
    return NotificationModel.fromJson(row);
  }
}
