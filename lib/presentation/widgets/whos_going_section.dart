import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/vibra_spacing.dart';
import '../../core/theme/vibra_theme_tokens.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/event_social.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_state_providers.dart';
import '../providers/circle_providers.dart';
import '../providers/core_providers.dart';
import '../providers/event_social_providers.dart';
import 'common/vibra_avatar.dart';
import 'common/vibra_bottom_sheet.dart';
import 'common/vibra_section_header.dart';
import 'common/vibra_surface.dart';

String attendanceStatusLabel(AppLocalizations l10n, String status) =>
    switch (status) {
      'going' => l10n.eventDetailAttend,
      'maybe' => l10n.eventDetailMaybe,
      _ => l10n.eventDetailInterested,
    };

String visibilityLabel(AppLocalizations l10n, AttendanceVisibility v) =>
    switch (v) {
      AttendanceVisibility.private => l10n.visibilityPrivate,
      AttendanceVisibility.friends => l10n.visibilityFriends,
      AttendanceVisibility.matches => l10n.visibilityMatches,
      AttendanceVisibility.public => l10n.visibilityPublic,
    };

/// WHO'S GOING? (docs/whos-going.md) on the event screen: the caller's own
/// visibility choice, then the people whose choice includes the caller.
class WhosGoingSection extends ConsumerWidget {
  const WhosGoingSection({required this.event, super.key});

  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventId = ref
        .watch(eventCatalogueIdProvider(eventRefOf(event)))
        .valueOrNull;
    // Not in the catalogue yet: nobody can have saved it.
    if (eventId == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final theme = Theme.of(context);
    final mine = ref.watch(myAttendanceProvider(eventId)).valueOrNull;
    final social = ref.watch(eventSocialProvider(eventId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (mine?.status != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              VibraSpacing.pagePadding,
              VibraSpacing.sm,
              VibraSpacing.pagePadding,
              0,
            ),
            child: _VisibilityRow(eventId: eventId, mine: mine!),
          ),
        VibraSectionHeader(
          title: l10n.whosGoingTitle,
          subtitle: l10n.whosGoingSubtitle,
          actionLabel: l10n.concertMatchTitle,
          onActionTap: () => context.push('/concert-match', extra: event),
          padding: const EdgeInsets.fromLTRB(
            VibraSpacing.pagePadding,
            VibraSpacing.sectionGap,
            VibraSpacing.pagePadding,
            VibraSpacing.md,
          ),
        ),
        Padding(
          padding: VibraSpacing.pageHorizontal,
          child: social.when(
            loading: () => const SizedBox(height: 48),
            error: (_, _) => const SizedBox.shrink(),
            data: (s) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (s.people.isEmpty)
                  Text(
                    l10n.whosGoingEmpty,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: t.textSecondary,
                    ),
                  )
                else ...[
                  Text(
                    [
                      if (s.going > 0) l10n.whosGoingGoing(s.going),
                      if (s.maybe > 0) l10n.whosGoingMaybe(s.maybe),
                      if (s.interested > 0)
                        l10n.whosGoingInterested(s.interested),
                    ].join(' · '),
                    style: theme.textTheme.titleSmall,
                  ),
                  for (final (title, people) in [
                    (l10n.whosGoingFriends, s.friends),
                    (l10n.whosGoingCompatible, s.compatible),
                    (l10n.whosGoingOthers, s.others),
                  ])
                    if (people.isNotEmpty) ...[
                      const SizedBox(height: VibraSpacing.md),
                      Text(
                        title.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: t.textMuted,
                          letterSpacing: 1.1,
                        ),
                      ),
                      for (final p in people.take(8))
                        _PersonTile(person: p, eventId: eventId),
                    ],
                ],
                const SizedBox(height: VibraSpacing.sm),
                Text(
                  l10n.whosGoingPrivacyNote,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: t.textMuted,
                  ),
                ),
                _EventGroups(event: event, eventId: eventId),
                if (s.communities.isNotEmpty) ...[
                  const SizedBox(height: VibraSpacing.lg),
                  Text(
                    l10n.whosGoingCommunities.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: t.textMuted,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: VibraSpacing.xs),
                  Wrap(
                    spacing: VibraSpacing.xs,
                    runSpacing: VibraSpacing.xs,
                    children: [
                      for (final c in s.communities)
                        ActionChip(
                          avatar: const Icon(Icons.groups_2_outlined, size: 18),
                          label: Text(c.name),
                          onPressed: () =>
                              context.push('/community', extra: c.id),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PersonTile extends ConsumerStatefulWidget {
  const _PersonTile({required this.person, required this.eventId});
  final EventSocialPerson person;
  final String eventId;

  @override
  ConsumerState<_PersonTile> createState() => _PersonTileState();
}

class _PersonTileState extends ConsumerState<_PersonTile> {
  bool _sent = false;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.person;
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final subtitle = [
      attendanceStatusLabel(l10n, p.status),
      if (p.compatibility != null) l10n.whosGoingAffinity(p.compatibility!),
    ].join(' · ');
    final canConnect = p.canSendVibra && !_sent;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () => context.push('/user-profile', extra: p.userId),
      leading: VibraAvatar(imageUrl: p.avatarUrl, name: p.name),
      title: Text(p.name),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: p.status == 'going' ? t.accentPrimary : t.textSecondary,
        ),
      ),
      trailing: canConnect
          ? TextButton(
              onPressed: _busy
                  ? null
                  : () async {
                      setState(() => _busy = true);
                      try {
                        await ref
                            .read(matchedUsersProvider.notifier)
                            .sendVibra(p.userId);
                        if (mounted) setState(() => _sent = true);
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.communitiesError)),
                          );
                        }
                      } finally {
                        if (mounted) setState(() => _busy = false);
                      }
                    },
              child: Text(l10n.socialMatchSendVibra),
            )
          : (p.connection == 'pending' || _sent)
          ? Text(l10n.whosGoingRequested, style: TextStyle(color: t.textMuted))
          : null,
    );
  }
}

class _VisibilityRow extends ConsumerWidget {
  const _VisibilityRow({required this.eventId, required this.mine});
  final String eventId;
  final MyAttendance mine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    return VibraSurface(
      onTap: () => _choose(context, ref),
      padding: const EdgeInsets.symmetric(
        horizontal: VibraSpacing.lg,
        vertical: VibraSpacing.md,
      ),
      child: Row(
        children: [
          Icon(
            mine.effective == AttendanceVisibility.private
                ? Icons.lock_outline_rounded
                : Icons.visibility_outlined,
            size: VibraSpacing.iconMd,
            color: t.textSecondary,
          ),
          const SizedBox(width: VibraSpacing.md),
          Expanded(child: Text(l10n.attendanceVisibility)),
          Text(
            visibilityLabel(l10n, mine.effective),
            style: TextStyle(color: t.accentPrimary),
          ),
          Icon(Icons.chevron_right_rounded, color: t.textSecondary),
        ],
      ),
    );
  }

  Future<void> _choose(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    var selected = mine.effective;
    var asDefault = false;
    final ok = await VibraBottomSheet.show<bool>(
      context,
      builder: (sheet) => StatefulBuilder(
        builder: (context, setState) => VibraBottomSheet(
          title: l10n.attendanceVisibility,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.attendanceVisibilityHint,
                style: TextStyle(color: context.vibraTokens.textSecondary),
              ),
              RadioGroup<AttendanceVisibility>(
                groupValue: selected,
                onChanged: (v) => setState(() => selected = v ?? selected),
                child: Column(
                  children: [
                    for (final v in AttendanceVisibility.values)
                      RadioListTile<AttendanceVisibility>(
                        contentPadding: EdgeInsets.zero,
                        value: v,
                        title: Text(visibilityLabel(l10n, v)),
                      ),
                  ],
                ),
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.attendanceVisibilityDefault),
                value: asDefault,
                onChanged: (v) => setState(() => asDefault = v),
              ),
              const SizedBox(height: VibraSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(sheet).pop(true),
                  child: Text(l10n.circlesSave),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (ok != true) return;
    try {
      await ref
          .read(supabaseEventSocialDatasourceProvider)
          .setVisibility(eventId, selected, makeDefault: asDefault);
      ref.invalidate(myAttendanceProvider(eventId));
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.attendanceVisibilitySaved)));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.communitiesError)));
      }
    }
  }
}

/// Concert groups the user belongs to for this event, and a way to start
/// one (through Concert Match, which only sends invitations).
class _EventGroups extends ConsumerWidget {
  const _EventGroups({required this.event, required this.eventId});
  final Event event;
  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final groups =
        ref.watch(eventCirclesProvider(eventId)).valueOrNull ?? const [];
    return Padding(
      padding: const EdgeInsets.only(top: VibraSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (groups.isNotEmpty) ...[
            Text(
              l10n.groupYourGroups.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: t.textMuted,
                letterSpacing: 1.1,
              ),
            ),
            for (final g in groups)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.bubble_chart_outlined),
                title: Text(g.name),
                subtitle: Text(l10n.circlesMembers(g.memberCount, 12)),
                onTap: () => context.push('/circle', extra: g.id),
              ),
          ],
          TextButton.icon(
            onPressed: () => context.push('/concert-match', extra: event),
            icon: const Icon(Icons.group_add_outlined),
            label: Text(l10n.groupStart),
          ),
        ],
      ),
    );
  }
}
