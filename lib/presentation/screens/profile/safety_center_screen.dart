import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../../domain/entities/safety.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/core_providers.dart';
import '../../providers/safety_providers.dart';
import '../../widgets/common/vibra_avatar.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_state_views.dart';
import '../../widgets/common/vibra_surface.dart';
import '../../widgets/daily_vibe_widgets.dart' show pickReportReason;

// The newest message replaces the current one (no stale queue).
void _snack(BuildContext context, String text) => ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text(text)));

String safetyErrorText(AppLocalizations l10n, Object e) =>
    switch (safetyErrorOf(e)) {
      SafetyError.duplicateReport => l10n.safetyDuplicateReport,
      SafetyError.rateLimited => l10n.safetyRateLimited,
      SafetyError.unavailable => l10n.safetyUserUnavailable,
      SafetyError.failed => l10n.socialReportFailed,
    };

/// Report a person, from their profile or anywhere else.
Future<void> reportUserFlow(
  BuildContext context,
  WidgetRef ref,
  String userId,
) async {
  final l10n = AppLocalizations.of(context)!;
  final reason = await pickReportReason(context);
  if (reason == null || !context.mounted) return;
  try {
    await ref.read(supabaseSafetyDatasourceProvider).reportUser(userId, reason);
    if (context.mounted) _snack(context, l10n.safetyReported);
  } catch (e) {
    if (context.mounted) _snack(context, safetyErrorText(l10n, e));
  }
}

/// Block a person after confirming. Returns true when blocked.
Future<bool> blockUserFlow(
  BuildContext context,
  WidgetRef ref,
  String userId,
  String name,
) async {
  final l10n = AppLocalizations.of(context)!;
  final ok = await showDialog<bool>(
    context: context,
    builder: (d) => AlertDialog(
      title: Text(l10n.safetyBlockTitle(name)),
      content: Text(l10n.safetyBlockBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(d).pop(false),
          child: Text(l10n.commonCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(d).pop(true),
          child: Text(l10n.socialBlockAction),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return false;
  try {
    await ref.read(supabaseSafetyDatasourceProvider).block(userId);
    ref.invalidate(blockedUsersProvider);
    ref.invalidate(safetyOverviewProvider);
    if (context.mounted) _snack(context, l10n.socialBlockSuccess);
    return true;
  } catch (e) {
    if (context.mounted) _snack(context, safetyErrorText(l10n, e));
    return false;
  }
}

/// SAFETY CENTER (docs/safety.md): every safety and privacy control in one
/// place, with what each currently does.
class SafetyCenterScreen extends ConsumerWidget {
  const SafetyCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final theme = Theme.of(context);
    final overview = ref.watch(safetyOverviewProvider);
    final o = overview.valueOrNull;
    String audience(String v) => switch (v) {
      'public' || 'everyone' => l10n.profileLevelPublic,
      'matches' || 'connections' || 'friends' => l10n.profileLevelConnections,
      _ => l10n.profileLevelPrivate,
    };
    Widget tile(
      IconData icon,
      String title,
      String? status,
      String route, {
      Object? extra,
    }) => ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: t.accentPrimary),
      title: Text(title),
      subtitle: status == null ? null : Text(status),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => context.push(route, extra: extra),
    );
    Widget group(String title, List<Widget> children) => Padding(
      padding: const EdgeInsets.only(bottom: VibraSpacing.lg),
      child: VibraSurface(
        padding: const EdgeInsets.fromLTRB(
          VibraSpacing.lg,
          VibraSpacing.md,
          VibraSpacing.md,
          VibraSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleSmall),
            ...children,
          ],
        ),
      ),
    );

    return VibraPageScaffold(
      appBar: AppBar(title: Text(l10n.safetyTitle)),
      child: RefreshIndicator(
        onRefresh: () async => ref.invalidate(safetyOverviewProvider),
        child: ListView(
          padding: const EdgeInsets.all(VibraSpacing.pagePadding),
          children: [
            Text(
              l10n.safetyIntro,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: t.textSecondary,
              ),
            ),
            // The links below still work without the overview; only the
            // current values are missing, so say so and offer a retry.
            if (overview.hasError && o == null)
              VibraErrorView(
                error: overview.error,
                compact: true,
                title: l10n.safetyTitle,
                message: l10n.safetyOverviewError,
                onRetry: () => ref.invalidate(safetyOverviewProvider),
              ),
            const SizedBox(height: VibraSpacing.lg),
            group(l10n.safetyPeople, [
              tile(
                Icons.block_rounded,
                l10n.safetyBlockedTitle,
                o == null ? null : l10n.safetyBlockedCount(o.blockedCount),
                '/blocked-users',
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: VibraSpacing.sm),
                child: Text(
                  l10n.safetyBlockExplain,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: t.textMuted,
                  ),
                ),
              ),
            ]),
            group(l10n.safetyVisibility, [
              tile(
                Icons.person_outline_rounded,
                l10n.profilePrivacyTitle,
                l10n.profilePrivacyTile,
                '/profile-privacy',
              ),
              if (AppConstants.spotifyEnabled)
                tile(
                  Icons.donut_large_rounded,
                  l10n.musicalDnaProfileTile,
                  o == null ? null : audience(o.dnaVisibility),
                  '/musical-dna',
                ),
              tile(
                Icons.auto_stories_outlined,
                l10n.storySettingsTitle,
                o == null
                    ? null
                    : [
                        audience(o.storyAudience),
                        if (o.hiddenStoryViewers > 0)
                          l10n.safetyHiddenFrom(o.hiddenStoryViewers),
                      ].join(' · '),
                '/story-settings',
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.event_rounded, color: t.accentPrimary),
                title: Text(l10n.safetyAttendance),
                subtitle: Text(
                  o == null
                      ? l10n.safetyAttendanceBody
                      : '${audience(o.attendanceVisibility)} · ${l10n.safetyAttendanceBody}',
                ),
              ),
            ]),
            group(l10n.safetyLocation, [
              tile(
                Icons.location_on_outlined,
                l10n.privacyPreciseLocation,
                o == null
                    ? null
                    : o.locationProcessing
                    ? l10n.safetyOn
                    : l10n.safetyOff,
                '/privacy-controls',
              ),
              tile(
                Icons.radar_rounded,
                l10n.musicRadarTitle,
                o == null
                    ? null
                    : !o.radarEnabled
                    ? l10n.safetyOff
                    : o.radarVisible
                    ? l10n.safetyRadarVisible
                    : l10n.safetyRadarHidden,
                '/music-radar',
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: VibraSpacing.sm),
                child: Text(
                  l10n.safetyLocationExplain,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: t.textMuted,
                  ),
                ),
              ),
            ]),
            group(l10n.safetyData, [
              if (AppConstants.spotifyEnabled)
                tile(
                  Icons.timeline_rounded,
                  l10n.tasteKeepHistory,
                  o == null
                      ? null
                      : o.tasteHistory
                      ? l10n.safetyOn
                      : l10n.safetyOff,
                  '/taste-evolution',
                ),
              tile(
                Icons.auto_awesome_outlined,
                l10n.aiTitle,
                o == null
                    ? null
                    : o.aiAssistant
                    ? l10n.safetyOn
                    : l10n.safetyOff,
                '/assistant',
              ),
              tile(
                Icons.tune_rounded,
                l10n.safetyAllPrivacy,
                l10n.safetyAllPrivacyBody,
                '/privacy-controls',
              ),
            ]),
            group(l10n.safetyReporting, [
              const SizedBox(height: VibraSpacing.sm),
              Text(l10n.safetyReportingBody, style: theme.textTheme.bodySmall),
              const SizedBox(height: VibraSpacing.sm),
              tile(
                Icons.support_agent_rounded,
                l10n.safetyContact,
                null,
                '/report-problem',
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class BlockedUsersScreen extends ConsumerWidget {
  const BlockedUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    return VibraPageScaffold(
      appBar: AppBar(title: Text(l10n.safetyBlockedTitle)),
      child: ref
          .watch(blockedUsersProvider)
          .when(
            loading: () => const VibraLoadingView(),
            error: (e, _) => VibraErrorView(
              error: e,
              title: l10n.safetyBlockedTitle,
              message: l10n.socialReportFailed,
              retryLabel: l10n.commonRetry,
              onRetry: () => ref.invalidate(blockedUsersProvider),
            ),
            data: (list) => list.isEmpty
                ? VibraEmptyView(
                    title: l10n.safetyNoBlocked,
                    message: l10n.safetyBlockExplain,
                    icon: Icons.shield_outlined,
                  )
                : ListView(
                    padding: const EdgeInsets.all(VibraSpacing.pagePadding),
                    children: [
                      for (final u in list)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: VibraAvatar(
                            imageUrl: u.avatarUrl,
                            name: u.name,
                            radius: 20,
                          ),
                          title: Text(u.name),
                          subtitle: u.blockedAt == null
                              ? null
                              : Text(
                                  l10n.safetyBlockedOn(
                                    DateFormat.yMMMd(
                                      locale,
                                    ).format(u.blockedAt!.toLocal()),
                                  ),
                                ),
                          trailing: TextButton(
                            onPressed: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (d) => AlertDialog(
                                  title: Text(l10n.safetyUnblockTitle(u.name)),
                                  content: Text(l10n.safetyUnblockBody),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(d).pop(false),
                                      child: Text(l10n.commonCancel),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(d).pop(true),
                                      child: Text(l10n.safetyUnblock),
                                    ),
                                  ],
                                ),
                              );
                              if (ok != true) return;
                              try {
                                await ref
                                    .read(supabaseSafetyDatasourceProvider)
                                    .unblock(u.userId);
                                ref.invalidate(blockedUsersProvider);
                                ref.invalidate(safetyOverviewProvider);
                                if (context.mounted) {
                                  _snack(context, l10n.safetyUnblocked(u.name));
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  _snack(context, safetyErrorText(l10n, e));
                                }
                              }
                            },
                            child: Text(l10n.safetyUnblock),
                          ),
                        ),
                    ],
                  ),
          ),
    );
  }
}
