import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/core_providers.dart';
import '../../providers/same_frequency_providers.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_state_views.dart';
import '../../widgets/common/vibra_surface.dart';
import '../../widgets/same_frequency_widgets.dart';

/// SAME FREQUENCY (docs/same-frequency.md): people with a meaningful musical
/// connection, ranked from several signals, rotated and diversified.
class SameFrequencyScreen extends ConsumerStatefulWidget {
  const SameFrequencyScreen({super.key});

  @override
  ConsumerState<SameFrequencyScreen> createState() =>
      _SameFrequencyScreenState();
}

class _SameFrequencyScreenState extends ConsumerState<SameFrequencyScreen> {
  bool _savedTab = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return VibraPageScaffold(
      appBar: AppBar(title: Text(l10n.sameFrequencyTitle)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              VibraSpacing.pagePadding,
              VibraSpacing.sm,
              VibraSpacing.pagePadding,
              VibraSpacing.md,
            ),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: false,
                    label: Text(l10n.sameFrequencyTabForYou),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text(l10n.sameFrequencyTabSaved),
                  ),
                ],
                selected: {_savedTab},
                onSelectionChanged: (s) => setState(() => _savedTab = s.first),
              ),
            ),
          ),
          Expanded(child: _savedTab ? const _SavedList() : const _ForYou()),
        ],
      ),
    );
  }
}

class _ForYou extends ConsumerWidget {
  const _ForYou();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return ref
        .watch(sameFrequencyProvider)
        .when(
          loading: () => const VibraLoadingView(),
          error: (e, _) => VibraErrorView(
            error: e,
            title: l10n.sameFrequencyTitle,
            message: l10n.sameFrequencyLoadError,
            retryLabel: l10n.commonRetry,
            onRetry: () => ref.invalidate(sameFrequencyProvider),
          ),
          data: (result) => RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(sameFrequencyProvider);
              await ref.read(sameFrequencyProvider.future);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                VibraSpacing.pagePadding,
                0,
                VibraSpacing.pagePadding,
                VibraSpacing.colossal,
              ),
              children: [
                _Header(count: result.strongCount),
                const SizedBox(height: VibraSpacing.xl),
                if (result.people.isEmpty)
                  VibraEmptyView(
                    compact: true,
                    title: l10n.sameFrequencyEmptyTitle,
                    message: l10n.sameFrequencyEmptyBody,
                    icon: Icons.graphic_eq_rounded,
                    actionLabel: l10n.musicalDnaPickGenres,
                    onActionTap: () => context.push('/music-genres'),
                  )
                else
                  for (final person in result.people)
                    Padding(
                      padding: const EdgeInsets.only(bottom: VibraSpacing.lg),
                      child: SameFrequencyCard(
                        person: person,
                        onToggleSaved: () async {
                          final ok = await ref
                              .read(sameFrequencyProvider.notifier)
                              .toggleSaved(person);
                          if (!ok && context.mounted) {
                            _snack(context, l10n.sameFrequencySaveError);
                          }
                        },
                        onSendVibra: () async {
                          try {
                            await ref
                                .read(sameFrequencyProvider.notifier)
                                .sendVibra(person.userId);
                            if (context.mounted) {
                              _snack(
                                context,
                                l10n.socialMatchVibraSent(person.name),
                              );
                            }
                          } catch (_) {
                            if (context.mounted) {
                              _snack(context, l10n.sameFrequencyLoadError);
                            }
                          }
                        },
                      ),
                    ),
                const SizedBox(height: VibraSpacing.md),
                const _EventsOptIn(),
              ],
            ),
          ),
        );
  }
}

void _snack(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

class _Header extends StatelessWidget {
  const _Header({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.sameFrequencyTitle.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: t.accentPrimary,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: VibraSpacing.sm),
        Semantics(
          header: true,
          child: Text(
            l10n.sameFrequencyHeadline,
            style: theme.textTheme.headlineLarge,
          ),
        ),
        const SizedBox(height: VibraSpacing.sm),
        Text(
          l10n.sameFrequencyCount(count),
          style: theme.textTheme.bodyLarge?.copyWith(color: t.textSecondary),
        ),
      ],
    );
  }
}

class _SavedList extends ConsumerWidget {
  const _SavedList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return ref
        .watch(savedProfilesProvider)
        .when(
          loading: () => const VibraLoadingView(),
          error: (e, _) => VibraErrorView(
            error: e,
            title: l10n.sameFrequencyTabSaved,
            message: l10n.sameFrequencyLoadError,
            retryLabel: l10n.commonRetry,
            onRetry: () => ref.invalidate(savedProfilesProvider),
          ),
          data: (people) => people.isEmpty
              ? VibraEmptyView(
                  title: l10n.sameFrequencySavedEmptyTitle,
                  message: l10n.sameFrequencySavedEmptyBody,
                  icon: Icons.bookmark_border_rounded,
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(
                    VibraSpacing.pagePadding,
                    0,
                    VibraSpacing.pagePadding,
                    VibraSpacing.colossal,
                  ),
                  children: [
                    for (final person in people)
                      Padding(
                        padding: const EdgeInsets.only(bottom: VibraSpacing.lg),
                        child: SameFrequencyCard(
                          person: person,
                          onToggleSaved: () async {
                            try {
                              await ref
                                  .read(supabaseSameFrequencyDatasourceProvider)
                                  .setSaved(person.userId, saved: false);
                              ref.invalidate(savedProfilesProvider);
                              ref.invalidate(sameFrequencyProvider);
                            } catch (_) {
                              if (context.mounted) {
                                _snack(context, l10n.sameFrequencySaveError);
                              }
                            }
                          },
                        ),
                      ),
                  ],
                ),
        );
  }
}

class _EventsOptIn extends ConsumerWidget {
  const _EventsOptIn();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(sharedEventsOptInProvider);
    return VibraSurface(
      padding: const EdgeInsets.symmetric(
        horizontal: VibraSpacing.lg,
        vertical: VibraSpacing.sm,
      ),
      child: SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        value: state.valueOrNull ?? false,
        onChanged: state.hasValue
            ? (value) async {
                final ok = await ref
                    .read(sharedEventsOptInProvider.notifier)
                    .set(value);
                if (!ok && context.mounted) {
                  _snack(context, l10n.sameFrequencySaveError);
                }
              }
            : null,
        title: Text(l10n.sameFrequencyEventsOptIn),
        subtitle: Text(
          l10n.sameFrequencyEventsOptInBody,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: t.textSecondary),
        ),
      ),
    );
  }
}
