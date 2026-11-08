import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/navigation/notification_routing.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../../domain/entities/inbox_notification.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/app_state_providers.dart' show pushEnabledProvider;
import '../../providers/core_providers.dart';
import '../../providers/notification_center_providers.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_state_views.dart';
import '../../widgets/common/vibra_surface.dart';
import '../../widgets/notification_widgets.dart';

/// NOTIFICATION CENTER (docs/notification-center.md): every notification
/// in one place, grouped by day, newest first.
class NotificationCenterScreen extends ConsumerWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final async = ref.watch(notificationListProvider);
    final controller = ref.read(notificationListProvider.notifier);
    final locale = Localizations.localeOf(context).toString();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    String section(DateTime d) {
      final local = d.toLocal();
      final day = DateTime(local.year, local.month, local.day);
      if (!day.isBefore(today)) return l10n.notifToday;
      if (!day.isBefore(today.subtract(const Duration(days: 6)))) {
        return l10n.notifThisWeek;
      }
      return l10n.notifEarlier;
    }

    return VibraPageScaffold(
      appBar: AppBar(
        title: Text(l10n.notifTitle),
        actions: [
          if (async.valueOrNull?.any((n) => !n.read) ?? false)
            TextButton(
              onPressed: controller.markAllRead,
              child: Text(l10n.notifMarkAllRead),
            ),
          IconButton(
            tooltip: l10n.notifSettingsTitle,
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => context.push('/notification-settings'),
          ),
        ],
      ),
      child: async.when(
        loading: () => const VibraLoadingView(),
        error: (e, _) => VibraErrorView(
          error: e,
          title: l10n.notifTitle,
          message: l10n.notifError,
          retryLabel: l10n.commonRetry,
          onRetry: () => ref.invalidate(notificationListProvider),
        ),
        data: (list) {
          if (list.isEmpty) {
            return VibraEmptyView(
              title: l10n.notifEmptyTitle,
              message: l10n.notifEmptyBody,
              icon: Icons.notifications_none_rounded,
            );
          }
          // Rows are built lazily as they scroll into view.
          final children = <Widget Function()>[];
          String? current;
          for (final n in list) {
            final s = section(n.createdAt);
            if (s != current) {
              current = s;
              children.add(
                () => Padding(
                  padding: const EdgeInsets.fromLTRB(
                    0,
                    VibraSpacing.md,
                    0,
                    VibraSpacing.xs,
                  ),
                  child: Text(s, style: theme.textTheme.titleSmall),
                ),
              );
            }
            final local = n.createdAt.toLocal();
            final when = section(n.createdAt) == l10n.notifToday
                ? DateFormat.Hm(locale).format(local)
                : DateFormat.MMMd(locale).format(local);
            children.add(
              () => NotificationCard(
                notification: n,
                time: when,
                onTap: () {
                  controller.markRead(n);
                  openNotificationTarget(
                    context,
                    n.type,
                    n.data,
                    senderName: n.actorName,
                  );
                },
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(notificationListProvider);
              ref.invalidate(unreadNotificationCountProvider);
            },
            child: NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (n.metrics.pixels > n.metrics.maxScrollExtent - 600) {
                  controller.loadMore();
                }
                return false;
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  VibraSpacing.pagePadding,
                  0,
                  VibraSpacing.pagePadding,
                  VibraSpacing.colossal,
                ),
                itemCount: children.length + 1,
                itemBuilder: (context, i) => i < children.length
                    ? children[i]()
                    : controller.done
                    ? const SizedBox(height: VibraSpacing.lg)
                    : const Padding(
                        padding: EdgeInsets.all(VibraSpacing.md),
                        child: VibraLoadingIndicator(),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Bell with the unread count, for app bars.
class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final unread = ref.watch(unreadNotificationCountProvider).valueOrNull ?? 0;
    return IconButton(
      tooltip: unread > 0 ? l10n.notifUnreadCount(unread) : l10n.notifTitle,
      onPressed: () async {
        await context.push('/notifications');
        ref.invalidate(unreadNotificationCountProvider);
      },
      icon: Badge(
        isLabelVisible: unread > 0,
        label: Text(unread > 99 ? '99+' : '$unread'),
        child: const Icon(Icons.notifications_none_rounded),
      ),
    );
  }
}

/// Which notifications may push, when, and how many (docs/notification-center.md).
class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  NotificationSettings? _local;

  Future<void> _save(
    NotificationSettings next,
    Future<void> Function() call,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final previous = _local;
    setState(() => _local = next);
    try {
      await call();
    } catch (_) {
      if (!mounted) return;
      setState(() => _local = previous);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.notifError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final theme = Theme.of(context);
    final source = ref.read(supabaseNotificationCenterDatasourceProvider);
    final pushOn = ref.watch(pushEnabledProvider);
    String hour(int h) => '${h.toString().padLeft(2, '0')}:00';
    return VibraPageScaffold(
      appBar: AppBar(title: Text(l10n.notifSettingsTitle)),
      child: ref
          .watch(notificationSettingsProvider)
          .when(
            loading: () => const VibraLoadingView(),
            error: (e, _) => VibraErrorView(
              error: e,
              title: l10n.notifSettingsTitle,
              message: l10n.notifError,
              retryLabel: l10n.commonRetry,
              onRetry: () => ref.invalidate(notificationSettingsProvider),
            ),
            data: (loaded) {
              final s = _local ?? loaded;
              return ListView(
                padding: const EdgeInsets.all(VibraSpacing.pagePadding),
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.notifPushAll),
                    subtitle: Text(l10n.notifPushAllBody),
                    value: pushOn,
                    onChanged: (v) =>
                        ref.read(pushEnabledProvider.notifier).toggle(v),
                  ),
                  if (!s.hasDevice)
                    Padding(
                      padding: const EdgeInsets.only(bottom: VibraSpacing.md),
                      child: Text(
                        l10n.notifNoDevice,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: t.textMuted,
                        ),
                      ),
                    ),
                  const Divider(),
                  Text(
                    l10n.notifCategoriesTitle,
                    style: theme.textTheme.titleSmall,
                  ),
                  Text(
                    l10n.notifCategoriesBody,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: t.textSecondary,
                    ),
                  ),
                  for (final c in NotificationCategory.values)
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: Icon(categoryIcon(c), color: t.accentPrimary),
                      title: Text(categoryLabel(l10n, c)),
                      subtitle: Text(
                        c.lowPriority
                            ? '${categoryHint(l10n, c)} ${l10n.notifOncePerDay}'
                            : categoryHint(l10n, c),
                      ),
                      value: s.push(c),
                      onChanged: pushOn
                          ? (v) => _save(
                              s.copyWith(categories: {...s.categories, c: v}),
                              () => source.setCategory(c, v),
                            )
                          : null,
                    ),
                  const Divider(),
                  Text(l10n.notifQuietTitle, style: theme.textTheme.titleSmall),
                  Text(
                    l10n.notifQuietBody,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: t.textSecondary,
                    ),
                  ),
                  const SizedBox(height: VibraSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: s.quietStart,
                          decoration: InputDecoration(
                            labelText: l10n.notifQuietFrom,
                          ),
                          items: [
                            for (var h = 0; h < 24; h++)
                              DropdownMenuItem(value: h, child: Text(hour(h))),
                          ],
                          onChanged: (v) => v == null
                              ? null
                              : _save(
                                  s.copyWith(quietStart: v),
                                  () => source.setSchedule(quietStart: v),
                                ),
                        ),
                      ),
                      const SizedBox(width: VibraSpacing.md),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: s.quietEnd,
                          decoration: InputDecoration(
                            labelText: l10n.notifQuietTo,
                          ),
                          items: [
                            for (var h = 0; h < 24; h++)
                              DropdownMenuItem(value: h, child: Text(hour(h))),
                          ],
                          onChanged: (v) => v == null
                              ? null
                              : _save(
                                  s.copyWith(quietEnd: v),
                                  () => source.setSchedule(quietEnd: v),
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: VibraSpacing.lg),
                  Text(
                    l10n.notifDailyCap(s.dailyCap),
                    style: theme.textTheme.titleSmall,
                  ),
                  Slider(
                    value: s.dailyCap.toDouble().clamp(5, 50),
                    min: 5,
                    max: 50,
                    divisions: 9,
                    label: '${s.dailyCap}',
                    onChanged: (v) => setState(
                      () => _local = s.copyWith(dailyCap: v.round()),
                    ),
                    onChangeEnd: (v) => _save(
                      s.copyWith(dailyCap: v.round()),
                      () => source.setSchedule(dailyCap: v.round()),
                    ),
                  ),
                  const SizedBox(height: VibraSpacing.md),
                  VibraSurface(
                    padding: const EdgeInsets.all(VibraSpacing.lg),
                    child: Text(
                      l10n.notifCalmExplain,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              );
            },
          ),
    );
  }
}
