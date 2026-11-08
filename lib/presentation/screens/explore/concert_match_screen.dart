import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../../domain/entities/circle.dart';
import '../../../domain/entities/concert_match.dart';
import '../../../domain/entities/event.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/app_state_providers.dart';
import '../../providers/circle_providers.dart';
import '../../providers/core_providers.dart';
import '../../providers/event_social_providers.dart';
import '../../widgets/common/vibra_bottom_sheet.dart';
import '../../widgets/common/vibra_button.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_state_views.dart';
import '../../widgets/concert_widgets.dart';
import '../circles/circles_screen.dart';

/// CONCERT MATCH (docs/concert-match.md): people to connect with through one
/// concert. Shows only what each person allowed (their visible plans) or
/// what the viewer already shares with them (a loved artist). Never any
/// location or travel information.
class ConcertMatchScreen extends ConsumerStatefulWidget {
  const ConcertMatchScreen({required this.event, super.key});

  final Event event;

  @override
  ConsumerState<ConcertMatchScreen> createState() => _ConcertMatchScreenState();
}

class _ConcertMatchScreenState extends ConsumerState<ConcertMatchScreen> {
  final _selected = <String>{};
  final _requested = <String>{};
  bool _creating = false;

  String _when(BuildContext context) => DateFormat.MMMd(
    Localizations.localeOf(context).toString(),
  ).format(widget.event.eventDate.toLocal());

  String get _eventLabel => widget.event.artistName ?? widget.event.name;

  /// Creates a concert circle and sends invitations; people join only if
  /// they accept.
  Future<void> _createGroup(String eventId) async {
    final l10n = AppLocalizations.of(context)!;
    final source = ref.read(supabaseCirclesDatasourceProvider);
    setState(() => _creating = true);
    try {
      final id = await source.create(
        name: '$_eventLabel · ${_when(context)}',
        description: '',
        basis: CircleBasis.concert,
        eventId: eventId,
      );
      var sent = 0;
      for (final userId in _selected) {
        try {
          await source.invite(id, userId);
          sent++;
        } catch (_) {}
      }
      ref.invalidate(myCirclesProvider);
      if (!mounted) return;
      circleSnack(context, l10n.circlesInvitesSent(sent));
      context.push('/circle', extra: id);
    } catch (e) {
      if (mounted) circleSnack(context, circleErrorText(l10n, e));
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  /// Shares the event (name and date only) into one of the user's circles.
  Future<void> _share(String eventId) async {
    final l10n = AppLocalizations.of(context)!;
    final circles = await ref.read(myCirclesProvider.future);
    if (!mounted) return;
    final circleId = await VibraBottomSheet.show<String>(
      context,
      builder: (sheet) => VibraBottomSheet(
        title: l10n.concertMatchShare,
        child: circles.isEmpty
            ? Text(l10n.concertMatchNoCircles)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final c in circles)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.bubble_chart_outlined),
                      title: Text(c.name),
                      onTap: () => Navigator.of(sheet).pop(c.id),
                    ),
                ],
              ),
      ),
    );
    if (circleId == null || !mounted) return;
    // Only the event's name and date go into the circle chat.
    final message = l10n.concertMatchSharedMessage(_eventLabel, _when(context));
    try {
      final source = ref.read(supabaseCirclesDatasourceProvider);
      await source.setEvent(circleId, eventId, true);
      await source.send(circleId, message);
      ref.invalidate(circleEventsProvider(circleId));
      if (mounted) circleSnack(context, l10n.concertMatchShared);
    } catch (e) {
      if (mounted) circleSnack(context, circleErrorText(l10n, e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final eventId = ref
        .watch(eventCatalogueIdProvider(eventRefOf(widget.event)))
        .valueOrNull;
    return VibraPageScaffold(
      appBar: AppBar(
        title: Text(l10n.concertMatchTitle),
        actions: [
          if (eventId != null)
            IconButton(
              tooltip: l10n.concertMatchShare,
              icon: const Icon(Icons.ios_share_rounded),
              onPressed: () => _share(eventId),
            ),
        ],
      ),
      child: eventId == null
          ? VibraEmptyView(
              title: l10n.concertMatchTitle,
              message: l10n.concertMatchEmpty,
              icon: Icons.groups_2_outlined,
            )
          : ref
                .watch(concertMatchProvider(eventId))
                .when(
                  loading: () => const VibraLoadingView(),
                  error: (e, _) => VibraErrorView(
                    error: e,
                    title: l10n.concertMatchTitle,
                    message: l10n.circlesLoadError,
                    retryLabel: l10n.commonRetry,
                    onRetry: () =>
                        ref.invalidate(concertMatchProvider(eventId)),
                  ),
                  data: (m) => _body(context, m, eventId),
                ),
    );
  }

  Widget _body(BuildContext context, ConcertMatch m, String eventId) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final theme = Theme.of(context);
    final invitable = m.people.where((p) => p.canInvite).length;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(VibraSpacing.pagePadding),
            children: [
              Text(
                _eventLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: t.accentPrimary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: VibraSpacing.xs),
              Text(
                m.myStatus != null
                    ? l10n.concertMatchHeadlineMine(m.interestedCount)
                    : l10n.concertMatchHeadlineOthers(m.interestedCount),
                style: theme.textTheme.headlineSmall,
              ),
              if (invitable > 0) ...[
                const SizedBox(height: VibraSpacing.sm),
                Text(
                  l10n.concertMatchSelectHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: t.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: VibraSpacing.md),
              if (m.people.isEmpty)
                Text(
                  l10n.concertMatchEmpty,
                  style: TextStyle(color: t.textSecondary),
                ),
              for (final p in m.people) _tile(context, p),
            ],
          ),
        ),
        if (invitable > 0)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                VibraSpacing.pagePadding,
                VibraSpacing.sm,
                VibraSpacing.pagePadding,
                VibraSpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.concertMatchGroupNote,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: t.textMuted,
                    ),
                  ),
                  const SizedBox(height: VibraSpacing.sm),
                  VibraButton(
                    label: l10n.concertMatchCreateGroup(_selected.length),
                    tone: VibraButtonTone.signal,
                    expanded: true,
                    loading: _creating,
                    onPressed: _selected.isEmpty || _creating
                        ? null
                        : () => _createGroup(eventId),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _tile(BuildContext context, ConcertMatchPerson p) {
    final l10n = AppLocalizations.of(context)!;
    return ConcertMatchCard(
      person: p,
      eventLabel: _eventLabel,
      selected: p.canInvite ? _selected.contains(p.userId) : null,
      onSelected: (v) => setState(
        () => v ? _selected.add(p.userId) : _selected.remove(p.userId),
      ),
      requested: _requested.contains(p.userId),
      onSendVibra: () async {
        try {
          await ref.read(matchedUsersProvider.notifier).sendVibra(p.userId);
          if (mounted) setState(() => _requested.add(p.userId));
        } catch (e) {
          if (context.mounted) circleSnack(context, circleErrorText(l10n, e));
        }
      },
    );
  }
}
