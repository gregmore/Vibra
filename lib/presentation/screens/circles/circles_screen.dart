import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/music/genre_catalog.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../../domain/entities/circle.dart';
import '../../../domain/entities/event.dart';
import '../../../domain/usecases/circle_suggestions.dart';
import '../../../l10n/app_localizations.dart';
import '../../localization/music_affinity_text.dart';
import '../../providers/app_state_providers.dart';
import '../../providers/circle_providers.dart';
import '../../providers/core_providers.dart';
import '../../widgets/common/vibra_avatar.dart';
import '../../widgets/common/vibra_bottom_sheet.dart';
import '../../widgets/common/vibra_button.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_section_header.dart';
import '../../widgets/common/vibra_state_views.dart';
import '../../widgets/common/vibra_surface.dart';
import '../../widgets/circle_widgets.dart';

String circleErrorText(AppLocalizations l10n, Object e) {
  final t = '$e';
  if (t.contains('circle_full')) return l10n.circlesErrorFull;
  if (t.contains('circle_banned')) return l10n.groupErrorBanned;
  if (t.contains('circle_invite_not_allowed')) {
    return l10n.circlesErrorNotAllowed;
  }
  if (t.contains('declined_recently')) return l10n.circlesErrorDeclined;
  if (t.contains('PT429') || t.contains('Rate limit')) {
    return l10n.communitiesErrorRate;
  }
  if (t.contains('invalid_music_link')) return l10n.communitiesErrorLink;
  if (t.contains('_limit')) return l10n.communitiesErrorLimit;
  if (t.contains('suspicious_link') ||
      t.contains('too_many_links') ||
      t.contains('flood')) {
    return l10n.communitiesErrorSpam;
  }
  return l10n.circlesError;
}

void circleSnack(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

/// Circles hub: invitations to answer, VIBRA's suggestions, your circles.
class CirclesScreen extends ConsumerWidget {
  const CirclesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final circles = ref.watch(myCirclesProvider);
    final invitations =
        ref.watch(circleInvitationsProvider).valueOrNull ?? const [];
    final suggestions =
        ref.watch(circleSuggestionsProvider).valueOrNull ?? const [];
    return VibraPageScaffold(
      appBar: AppBar(
        title: Text(l10n.circlesTitle),
        actions: [
          IconButton(
            tooltip: l10n.circlesCreate,
            icon: const Icon(Icons.add_rounded),
            onPressed: () => showCreateCircle(context, ref),
          ),
        ],
      ),
      child: circles.when(
        loading: () => const VibraLoadingView(),
        error: (e, _) => VibraErrorView(
          error: e,
          title: l10n.circlesTitle,
          message: l10n.circlesLoadError,
          retryLabel: l10n.commonRetry,
          onRetry: () => ref.invalidate(myCirclesProvider),
        ),
        data: (mine) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(myCirclesProvider);
            ref.invalidate(circleInvitationsProvider);
            ref.invalidate(circleSuggestionsProvider);
            await ref.read(myCirclesProvider.future);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              VibraSpacing.pagePadding,
              0,
              VibraSpacing.pagePadding,
              VibraSpacing.colossal,
            ),
            children: [
              if (invitations.isNotEmpty) ...[
                _Header(l10n.circlesInvitations),
                for (final i in invitations) _InvitationCard(invitation: i),
              ],
              if (suggestions.isNotEmpty) ...[
                _Header(l10n.circlesSuggested),
                for (final s in suggestions) _SuggestionCard(suggestion: s),
              ],
              _Header(l10n.circlesMine),
              if (mine.isEmpty)
                VibraEmptyView(
                  compact: true,
                  title: l10n.circlesEmptyTitle,
                  message: l10n.circlesEmptyBody,
                  icon: Icons.bubble_chart_outlined,
                  actionLabel: l10n.circlesCreate,
                  onActionTap: () => showCreateCircle(context, ref),
                )
              else
                for (final c in mine)
                  Padding(
                    padding: const EdgeInsets.only(bottom: VibraSpacing.sm),
                    child: VibraCircleCard(
                      circle: c,
                      onTap: () => context.push('/circle', extra: c.id),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => VibraSectionHeader(
    title: title,
    padding: const EdgeInsets.only(
      top: VibraSpacing.xl,
      bottom: VibraSpacing.md,
    ),
  );
}

class _InvitationCard extends ConsumerStatefulWidget {
  const _InvitationCard({required this.invitation});
  final CircleInvitation invitation;

  @override
  ConsumerState<_InvitationCard> createState() => _InvitationCardState();
}

class _InvitationCardState extends ConsumerState<_InvitationCard> {
  bool _busy = false;

  Future<void> _respond(bool accept) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      final id = await ref
          .read(supabaseCirclesDatasourceProvider)
          .respond(widget.invitation.id, accept: accept);
      ref.invalidate(circleInvitationsProvider);
      ref.invalidate(myCirclesProvider);
      if (!mounted) return;
      if (accept && id != null) {
        context.push('/circle', extra: id);
      } else if (!accept) {
        circleSnack(context, l10n.circlesInviteDeclined);
      }
    } catch (e) {
      if (mounted) circleSnack(context, circleErrorText(l10n, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final i = widget.invitation;
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: VibraSpacing.sm),
      child: VibraSurface(
        padding: const EdgeInsets.all(VibraSpacing.lg),
        borderColor: t.accentPrimary.withValues(alpha: .4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                VibraAvatar(
                  imageUrl: i.inviter.avatarUrl,
                  name: i.inviter.name,
                  radius: 18,
                ),
                const SizedBox(width: VibraSpacing.md),
                Expanded(
                  child: Text(
                    l10n.circlesInvitedBy(i.inviter.name),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: t.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: VibraSpacing.sm),
            Text(i.circleName, style: theme.textTheme.titleMedium),
            if (i.circleDescription.isNotEmpty)
              Text(i.circleDescription, style: theme.textTheme.bodyMedium),
            Text(
              '${circleBasisLabel(l10n, i.basis)} · ${l10n.circlesMembers(i.memberCount, 12)}',
              style: theme.textTheme.bodySmall?.copyWith(color: t.textMuted),
            ),
            const SizedBox(height: VibraSpacing.md),
            Row(
              children: [
                Expanded(
                  child: VibraButton(
                    label: l10n.circlesAccept,
                    tone: VibraButtonTone.signal,
                    size: VibraButtonSize.compact,
                    expanded: true,
                    loading: _busy,
                    onPressed: _busy ? null : () => _respond(true),
                  ),
                ),
                const SizedBox(width: VibraSpacing.sm),
                Expanded(
                  child: VibraButton(
                    label: l10n.circlesDecline,
                    tone: VibraButtonTone.outline,
                    size: VibraButtonSize.compact,
                    expanded: true,
                    onPressed: _busy ? null : () => _respond(false),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionCard extends ConsumerStatefulWidget {
  const _SuggestionCard({required this.suggestion});
  final CircleSuggestion suggestion;

  @override
  ConsumerState<_SuggestionCard> createState() => _SuggestionCardState();
}

class _SuggestionCardState extends ConsumerState<_SuggestionCard> {
  bool _busy = false;

  String _topic(AppLocalizations l10n) =>
      widget.suggestion.basis == SuggestionBasis.artist
      ? widget.suggestion.key
      : genreLabel(l10n, widget.suggestion.key);

  /// Creates the circle, then sends one invitation per person. Each person
  /// still has to accept: nobody is added by this.
  Future<void> _create() async {
    final l10n = AppLocalizations.of(context)!;
    final s = widget.suggestion;
    final source = ref.read(supabaseCirclesDatasourceProvider);
    setState(() => _busy = true);
    try {
      final id = await source.create(
        name: l10n.circlesSuggestionName(_topic(l10n)),
        description: '',
        basis: s.basis == SuggestionBasis.artist
            ? CircleBasis.artist
            : CircleBasis.genre,
        genreKey: s.basis == SuggestionBasis.genre ? s.key : null,
        artistName: s.basis == SuggestionBasis.artist ? s.key : null,
      );
      var sent = 0;
      for (final p in s.people) {
        try {
          await source.invite(id, p.userId);
          sent++;
        } catch (_) {}
      }
      ref.invalidate(myCirclesProvider);
      ref.invalidate(circleSuggestionsProvider);
      if (!mounted) return;
      circleSnack(context, l10n.circlesInvitesSent(sent));
      context.push('/circle', extra: id);
    } catch (e) {
      if (mounted) circleSnack(context, circleErrorText(l10n, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.suggestion;
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final theme = Theme.of(context);
    final count = s.people.length + 1;
    return Padding(
      padding: const EdgeInsets.only(bottom: VibraSpacing.sm),
      child: VibraSurface(
        padding: const EdgeInsets.all(VibraSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.basis == SuggestionBasis.artist
                  ? l10n.circlesSuggestionArtist(count, s.key)
                  : l10n.circlesSuggestionGenre(count, _topic(l10n)),
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: VibraSpacing.sm),
            Wrap(
              spacing: VibraSpacing.sm,
              runSpacing: VibraSpacing.sm,
              children: [
                for (final p in s.people)
                  Chip(
                    avatar: VibraAvatar(
                      imageUrl: p.avatarUrl,
                      name: p.name,
                      radius: 12,
                    ),
                    label: Text('${p.name} · ${p.compatibility}%'),
                  ),
              ],
            ),
            const SizedBox(height: VibraSpacing.sm),
            Text(
              l10n.circlesSuggestionConsent,
              style: theme.textTheme.bodySmall?.copyWith(color: t.textMuted),
            ),
            const SizedBox(height: VibraSpacing.md),
            VibraButton(
              label: l10n.circlesCreateAndInvite,
              tone: VibraButtonTone.signal,
              size: VibraButtonSize.compact,
              loading: _busy,
              onPressed: _busy ? null : _create,
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showCreateCircle(BuildContext context, WidgetRef ref) async {
  final id = await VibraBottomSheet.show<String>(
    context,
    builder: (_) => const _CreateCircleSheet(),
  );
  if (id != null && context.mounted) {
    ref.invalidate(myCirclesProvider);
    context.push('/circle', extra: id);
  }
}

class _CreateCircleSheet extends ConsumerStatefulWidget {
  const _CreateCircleSheet();

  @override
  ConsumerState<_CreateCircleSheet> createState() => _CreateCircleSheetState();
}

class _CreateCircleSheetState extends ConsumerState<_CreateCircleSheet> {
  CircleBasis _basis = CircleBasis.genre;
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _detail = TextEditingController();
  String _genre = GenreCatalog.families.first.key;
  Event? _event;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _detail.dispose();
    super.dispose();
  }

  bool get _valid =>
      _name.text.trim().length >= 3 &&
      switch (_basis) {
        CircleBasis.artist => _detail.text.trim().isNotEmpty,
        CircleBasis.concert => _event != null,
        CircleBasis.interest ||
        CircleBasis.activity => _detail.text.trim().isNotEmpty,
        CircleBasis.genre => true,
      };

  Future<void> _create() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      final id = await ref
          .read(supabaseCirclesDatasourceProvider)
          .create(
            name: _name.text.trim(),
            description: _description.text.trim(),
            basis: _basis,
            genreKey: _basis == CircleBasis.genre ? _genre : null,
            artistName: _basis == CircleBasis.artist
                ? _detail.text.trim()
                : null,
            eventId: _basis == CircleBasis.concert ? _event?.id : null,
            topic:
                _basis == CircleBasis.interest || _basis == CircleBasis.activity
                ? _detail.text.trim()
                : null,
          );
      if (mounted) Navigator.of(context).pop(id);
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        circleSnack(context, circleErrorText(l10n, e));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final events = ref.watch(myEventsProvider);
    final upcoming = [
      ...events.going,
      ...events.saved,
    ].where((e) => e.eventDate.isAfter(DateTime.now())).toList();
    void rebuild(String _) => setState(() {});
    return VibraBottomSheet(
      title: l10n.circlesCreate,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: VibraSpacing.xs,
            runSpacing: VibraSpacing.xs,
            children: [
              for (final b in CircleBasis.values)
                ChoiceChip(
                  label: Text(circleBasisLabel(l10n, b)),
                  selected: _basis == b,
                  onSelected: (_) => setState(() => _basis = b),
                ),
            ],
          ),
          const SizedBox(height: VibraSpacing.md),
          switch (_basis) {
            CircleBasis.genre => DropdownButtonFormField<String>(
              initialValue: _genre,
              decoration: InputDecoration(labelText: l10n.circlesBasisGenre),
              items: [
                for (final f in GenreCatalog.families)
                  DropdownMenuItem(
                    value: f.key,
                    child: Text(genreFamilyLabel(l10n, f.key)),
                  ),
              ],
              onChanged: (v) => setState(() => _genre = v ?? _genre),
            ),
            CircleBasis.concert =>
              upcoming.isEmpty
                  ? Text(l10n.circlesNoSavedEvents)
                  : DropdownButtonFormField<String>(
                      initialValue: _event?.id,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: l10n.circlesBasisConcert,
                      ),
                      items: [
                        for (final e in upcoming)
                          DropdownMenuItem(
                            value: e.id,
                            child: Text(
                              e.artistName ?? e.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: (v) => setState(
                        () => _event = upcoming.firstWhere((e) => e.id == v),
                      ),
                    ),
            _ => TextField(
              controller: _detail,
              maxLength: _basis == CircleBasis.artist ? 80 : 60,
              decoration: InputDecoration(
                labelText: _basis == CircleBasis.artist
                    ? l10n.circlesBasisArtist
                    : l10n.circlesTopic,
              ),
              onChanged: rebuild,
            ),
          },
          TextField(
            controller: _name,
            maxLength: 50,
            decoration: InputDecoration(labelText: l10n.circlesName),
            onChanged: rebuild,
          ),
          TextField(
            controller: _description,
            maxLength: 300,
            minLines: 1,
            maxLines: 3,
            decoration: InputDecoration(labelText: l10n.circlesDescription),
          ),
          const SizedBox(height: VibraSpacing.sm),
          VibraButton(
            label: l10n.circlesCreateAction,
            tone: VibraButtonTone.signal,
            expanded: true,
            loading: _busy,
            onPressed: _valid && !_busy ? _create : null,
          ),
        ],
      ),
    );
  }
}
