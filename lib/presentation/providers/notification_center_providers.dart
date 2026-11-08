import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/supabase_notification_center_datasource.dart';
import '../../domain/entities/inbox_notification.dart';
import 'core_providers.dart';

/// Notification Center (docs/notification-center.md). Loaded one page at a
/// time (docs/performance.md): [loadMore] fetches the next page when the
/// list is scrolled near its end.
class NotificationListController
    extends AutoDisposeAsyncNotifier<List<InboxNotification>> {
  bool _loadingMore = false;
  bool _done = false;

  /// True once the oldest notification has been loaded.
  bool get done => _done;

  @override
  Future<List<InboxNotification>> build() async {
    _loadingMore = false;
    final page = await ref
        .read(supabaseNotificationCenterDatasourceProvider)
        .list();
    _done = page.length < notificationPageSize;
    return page;
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.isEmpty || _loadingMore || _done) return;
    _loadingMore = true;
    try {
      final page = await ref
          .read(supabaseNotificationCenterDatasourceProvider)
          .list(before: current.last.createdAt);
      _done = page.length < notificationPageSize;
      final known = {for (final n in current) n.id};
      final latest = state.valueOrNull ?? current;
      state = AsyncData([
        ...latest,
        ...page.where((n) => !known.contains(n.id)),
      ]);
    } catch (_) {
      // Keep what is shown; the next scroll retries.
    } finally {
      _loadingMore = false;
    }
  }

  Future<void> markRead(InboxNotification n) async {
    if (n.read) return;
    final list = state.valueOrNull;
    if (list != null) {
      state = AsyncData([
        for (final x in list) x.id == n.id ? x.markedRead() : x,
      ]);
    }
    try {
      await ref.read(supabaseNotificationCenterDatasourceProvider).markRead([
        n.id,
      ]);
    } catch (_) {}
    ref.invalidate(unreadNotificationCountProvider);
  }

  Future<void> markAllRead() async {
    final list = state.valueOrNull;
    if (list != null) {
      state = AsyncData([for (final x in list) x.markedRead()]);
    }
    try {
      await ref.read(supabaseNotificationCenterDatasourceProvider).markRead();
    } catch (_) {}
    ref.invalidate(unreadNotificationCountProvider);
  }
}

final notificationListProvider =
    AsyncNotifierProvider.autoDispose<
      NotificationListController,
      List<InboxNotification>
    >(NotificationListController.new);

final unreadNotificationCountProvider = FutureProvider.autoDispose<int>(
  (ref) =>
      ref.watch(supabaseNotificationCenterDatasourceProvider).unreadCount(),
);

final notificationSettingsProvider =
    FutureProvider.autoDispose<NotificationSettings>(
      (ref) =>
          ref.watch(supabaseNotificationCenterDatasourceProvider).settings(),
    );
