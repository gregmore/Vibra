import 'package:flutter/material.dart';
import '../../core/theme/vibra_spacing.dart';
import '../../core/theme/vibra_theme_tokens.dart';
import '../../domain/entities/inbox_notification.dart';
import '../../l10n/app_localizations.dart';
import 'common/vibra_avatar.dart';

String categoryLabel(AppLocalizations l10n, NotificationCategory c) =>
    switch (c) {
      NotificationCategory.requests => l10n.notifCatRequests,
      NotificationCategory.messages => l10n.notifCatMessages,
      NotificationCategory.communities => l10n.notifCatCommunities,
      NotificationCategory.circles => l10n.notifCatCircles,
      NotificationCategory.concerts => l10n.notifCatConcerts,
      NotificationCategory.reminders => l10n.notifCatReminders,
      NotificationCategory.recommendations => l10n.notifCatRecommendations,
      NotificationCategory.social => l10n.notifCatSocial,
      NotificationCategory.discoveries => l10n.notifCatDiscoveries,
      NotificationCategory.updates => l10n.notifCatUpdates,
    };

String categoryHint(AppLocalizations l10n, NotificationCategory c) =>
    switch (c) {
      NotificationCategory.requests => l10n.notifCatRequestsBody,
      NotificationCategory.messages => l10n.notifCatMessagesBody,
      NotificationCategory.communities => l10n.notifCatCommunitiesBody,
      NotificationCategory.circles => l10n.notifCatCirclesBody,
      NotificationCategory.concerts => l10n.notifCatConcertsBody,
      NotificationCategory.reminders => l10n.notifCatRemindersBody,
      NotificationCategory.recommendations => l10n.notifCatRecommendationsBody,
      NotificationCategory.social => l10n.notifCatSocialBody,
      NotificationCategory.discoveries => l10n.notifCatDiscoveriesBody,
      NotificationCategory.updates => l10n.notifCatUpdatesBody,
    };

IconData categoryIcon(NotificationCategory c) => switch (c) {
  NotificationCategory.requests => Icons.person_add_alt_1_rounded,
  NotificationCategory.messages => Icons.chat_bubble_outline_rounded,
  NotificationCategory.communities => Icons.groups_2_outlined,
  NotificationCategory.circles => Icons.bubble_chart_outlined,
  NotificationCategory.concerts => Icons.confirmation_number_outlined,
  NotificationCategory.reminders => Icons.alarm_rounded,
  NotificationCategory.recommendations => Icons.recommend_rounded,
  NotificationCategory.social => Icons.graphic_eq_rounded,
  NotificationCategory.discoveries => Icons.library_music_outlined,
  NotificationCategory.updates => Icons.campaign_outlined,
};

/// One notification in the Notification Center: who or what it is about,
/// the text, its category and time, a grouped count, and an unread dot.
class NotificationCard extends StatelessWidget {
  const NotificationCard({
    required this.notification,
    required this.time,
    required this.onTap,
    super.key,
  });

  final InboxNotification notification;

  /// Already formatted ("14:05", "3 Nov").
  final String time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final theme = Theme.of(context);
    final n = notification;
    final when = time;
    return Semantics(
      button: true,
      label: [if (!n.read) l10n.notifUnread, n.title, n.body].join(', '),
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(VibraSpacing.radiusMedium),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: VibraSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              n.actorName != null
                  ? VibraAvatar(
                      imageUrl: n.actorAvatar,
                      name: n.actorName,
                      radius: 20,
                    )
                  : CircleAvatar(
                      radius: 20,
                      backgroundColor: t.surfaceMuted,
                      child: Icon(
                        categoryIcon(n.category),
                        size: 20,
                        color: t.accentPrimary,
                      ),
                    ),
              const SizedBox(width: VibraSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: n.read ? FontWeight.w400 : FontWeight.w700,
                      ),
                    ),
                    if (n.body.isNotEmpty)
                      Text(
                        n.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: t.textSecondary,
                        ),
                      ),
                    Text(
                      [
                        categoryLabel(l10n, n.category),
                        when,
                        if (n.groupCount > 1) l10n.notifGrouped(n.groupCount),
                      ].join(' · '),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: t.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (!n.read)
                Padding(
                  padding: const EdgeInsets.only(top: VibraSpacing.xs),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: t.accentPrimary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
