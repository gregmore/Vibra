import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_text_styles.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../../domain/entities/musical_dna.dart';
import '../../../l10n/app_localizations.dart';
import '../../localization/music_affinity_text.dart';
import '../../providers/musical_dna_providers.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_section_header.dart';
import '../../widgets/common/vibra_state_views.dart';
import '../../widgets/common/vibra_surface.dart';
import '../../widgets/musical_dna_widgets.dart';

/// Musical DNA (docs/musical-dna.md). Without [userId] it shows the
/// caller's own DNA with its evolution, sources and visibility control;
/// with [userId] it shows another person's DNA if their setting allows it.
class MusicalDnaScreen extends ConsumerWidget {
  const MusicalDnaScreen({this.userId, this.displayName, super.key});

  final String? userId;
  final String? displayName;

  bool get _isMine => userId == null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final title = _isMine || displayName == null
        ? l10n.musicalDnaTitle
        : l10n.musicalDnaUserTitle(displayName!);
    return VibraPageScaffold(
      appBar: AppBar(title: Text(title)),
      child: _isMine
          ? const _MyDna()
          : _OtherDna(userId: userId!, name: displayName),
    );
  }
}

class _MyDna extends ConsumerWidget {
  const _MyDna();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final history = ref.watch(myMusicalDnaHistoryProvider);
    return history.when(
      loading: () => const VibraLoadingView(),
      error: (e, _) => VibraErrorView(
        error: e,
        title: l10n.musicalDnaTitle,
        message: l10n.musicalDnaLoadError,
        retryLabel: l10n.commonRetry,
        onRetry: () => ref.invalidate(myMusicalDnaHistoryProvider),
      ),
      data: (snapshots) {
        if (snapshots.isEmpty) {
          return VibraEmptyView(
            title: l10n.musicalDnaEmptyTitle,
            message: l10n.musicalDnaEmptyBody,
            icon: Icons.graphic_eq_rounded,
            actionLabel: l10n.musicalDnaPickGenres,
            onActionTap: () => context.push('/music-genres'),
            secondaryActionLabel: AppConstants.spotifyEnabled
                ? l10n.myProfileConnectSpotify
                : null,
            onSecondaryActionTap: AppConstants.spotifyEnabled
                ? () => context.push('/spotify-connect')
                : null,
          );
        }
        final current = snapshots.first;
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(myMusicalDnaHistoryProvider);
            await ref.read(myMusicalDnaHistoryProvider.future);
          },
          child: ListView(
            padding: const EdgeInsets.only(bottom: VibraSpacing.colossal),
            children: [
              _Hero(dna: current, eyebrow: l10n.musicalDnaEyebrow),
              _Distribution(dna: current),
              _Diversity(dna: current),
              _Evolution(snapshots: snapshots),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: VibraSpacing.pagePadding,
                ),
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/taste-evolution'),
                  icon: const Icon(Icons.timeline_rounded),
                  label: Text(l10n.tasteOpen),
                ),
              ),
              _Sources(dna: current),
              const _Visibility(),
            ],
          ),
        );
      },
    );
  }
}

class _OtherDna extends ConsumerWidget {
  const _OtherDna({required this.userId, this.name});

  final String userId;
  final String? name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return ref
        .watch(userMusicalDnaProvider(userId))
        .when(
          loading: () => const VibraLoadingView(),
          error: (e, _) => VibraErrorView(
            error: e,
            title: l10n.musicalDnaTitle,
            message: l10n.musicalDnaLoadError,
          ),
          data: (dna) => dna == null
              ? VibraEmptyView(
                  title: l10n.musicalDnaEmptyTitle,
                  message: l10n.musicalDnaVisibilityPrivateBody,
                  icon: Icons.lock_outline_rounded,
                )
              : ListView(
                  padding: const EdgeInsets.only(bottom: VibraSpacing.colossal),
                  children: [
                    _Hero(dna: dna, eyebrow: l10n.musicalDnaUserEyebrow),
                    _Distribution(dna: dna),
                    _Diversity(dna: dna),
                  ],
                ),
        );
  }
}

String _date(BuildContext context, DateTime? date) => date == null
    ? ''
    : DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(date);

class _Hero extends StatelessWidget {
  const _Hero({required this.dna, required this.eyebrow});

  final MusicalDna dna;
  final String eyebrow;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final top = dna.families.first;
    final name = genreFamilyLabel(l10n, top.key);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        VibraSpacing.pagePadding,
        VibraSpacing.md,
        VibraSpacing.pagePadding,
        0,
      ),
      child: VibraSurface(
        padding: const EdgeInsets.all(VibraSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eyebrow.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: t.accentPrimary,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: VibraSpacing.md),
            Semantics(
              label: l10n.musicalDnaFamilySemantics(name, '${top.percent}'),
              excludeSemantics: true,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      name,
                      style: theme.textTheme.displaySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: VibraSpacing.md),
                  Text(
                    '${top.percent}%',
                    style: VibraTextStyles.scoreLarge.copyWith(
                      color: t.accentPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: VibraSpacing.xl),
            DnaStrip(families: dna.families),
            const SizedBox(height: VibraSpacing.md),
            Wrap(
              spacing: VibraSpacing.lg,
              runSpacing: VibraSpacing.xs,
              children: [
                for (var i = 0; i < dna.families.length && i < 6; i++)
                  _Legend(
                    color: dnaFamilyColor(t, i),
                    label:
                        '${genreFamilyLabel(l10n, dna.families[i].key)} ${dna.families[i].percent}%',
                  ),
              ],
            ),
            if (dna.capturedOn != null) ...[
              const SizedBox(height: VibraSpacing.lg),
              Text(
                l10n.musicalDnaUpdated(_date(context, dna.capturedOn)),
                style: theme.textTheme.bodySmall?.copyWith(color: t.textMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: context.vibraTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.subtitle});

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VibraSectionHeader(
          title: title,
          subtitle: subtitle,
          padding: const EdgeInsets.fromLTRB(
            VibraSpacing.pagePadding,
            VibraSpacing.sectionGap,
            VibraSpacing.pagePadding,
            VibraSpacing.md,
          ),
        ),
        Padding(padding: VibraSpacing.pageHorizontal, child: child),
      ],
    );
  }
}

class _Distribution extends StatelessWidget {
  const _Distribution({required this.dna});

  final MusicalDna dna;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _Section(
      title: l10n.musicalDnaDistribution,
      subtitle: l10n.musicalDnaDistributionSub,
      child: VibraSurface(
        padding: const EdgeInsets.all(VibraSpacing.xl),
        child: Column(
          children: [
            for (var i = 0; i < dna.families.length; i++) ...[
              if (i > 0) const SizedBox(height: VibraSpacing.xl),
              DnaFamilyRow(
                family: dna.families[i],
                rank: i,
                subgenres: dna.subgenresOf(dna.families[i].key),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Diversity extends StatelessWidget {
  const _Diversity({required this.dna});

  final MusicalDna dna;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final (tier, body) = switch (dna.diversityTier) {
      DnaDiversityTier.focused => (
        l10n.musicalDnaDiversityFocused,
        l10n.musicalDnaDiversityFocusedBody,
      ),
      DnaDiversityTier.balanced => (
        l10n.musicalDnaDiversityBalanced,
        l10n.musicalDnaDiversityBalancedBody,
      ),
      DnaDiversityTier.eclectic => (
        l10n.musicalDnaDiversityEclectic,
        l10n.musicalDnaDiversityEclecticBody,
      ),
    };
    final families = dna.families.length;
    final subgenres = dna.subgenres.length;
    return _Section(
      title: l10n.musicalDnaDiversity,
      child: VibraSurface(
        padding: const EdgeInsets.all(VibraSpacing.xl),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 72,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: dna.diversityScore / 100,
                      strokeWidth: 5,
                      backgroundColor: t.surfaceMuted,
                      color: t.textPrimary,
                      semanticsLabel: '${l10n.musicalDnaDiversity}: $tier',
                      semanticsValue: '${dna.diversityScore}',
                    ),
                  ),
                  Text(
                    '${dna.diversityScore}',
                    style: VibraTextStyles.scoreMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: VibraSpacing.xl),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tier, style: theme.textTheme.titleLarge),
                  const SizedBox(height: VibraSpacing.xs),
                  Text(
                    body,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: t.textSecondary,
                    ),
                  ),
                  const SizedBox(height: VibraSpacing.sm),
                  Text(
                    l10n.musicalDnaDiversityCounts('$families', '$subgenres'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: t.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Evolution extends StatelessWidget {
  const _Evolution({required this.snapshots});

  /// Newest first.
  final List<MusicalDna> snapshots;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final oldest = snapshots.last;
    if (snapshots.length < 2) {
      return _Section(
        title: l10n.musicalDnaEvolution,
        subtitle: l10n.musicalDnaEvolutionSub,
        child: VibraSurface(
          padding: const EdgeInsets.all(VibraSpacing.xl),
          child: Text(
            l10n.musicalDnaEvolutionEmpty(_date(context, oldest.capturedOn)),
            style: theme.textTheme.bodyMedium?.copyWith(color: t.textSecondary),
          ),
        ),
      );
    }
    final timeline = sampleDnaHistory(snapshots);
    final shifts = dnaShifts(oldest, snapshots.first).take(4).toList();
    // Colours follow the current ranking so a family keeps its tone across rows.
    final rankOf = {
      for (var i = 0; i < snapshots.first.families.length; i++)
        snapshots.first.families[i].key: i,
    };
    return _Section(
      title: l10n.musicalDnaEvolution,
      subtitle: l10n.musicalDnaEvolutionSub,
      child: VibraSurface(
        padding: const EdgeInsets.all(VibraSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final dna in timeline)
              Padding(
                padding: const EdgeInsets.only(bottom: VibraSpacing.sm),
                child: Row(
                  children: [
                    SizedBox(
                      width: 92,
                      child: Text(
                        _date(context, dna.capturedOn),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: t.textMuted,
                        ),
                      ),
                    ),
                    Expanded(
                      child: DnaStrip(
                        families: [...dna.families]
                          ..sort(
                            (a, b) => (rankOf[a.key] ?? 99).compareTo(
                              rankOf[b.key] ?? 99,
                            ),
                          ),
                        height: 8,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: VibraSpacing.md),
            Text(
              l10n
                  .musicalDnaShiftSince(_date(context, oldest.capturedOn))
                  .toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: t.textSecondary,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: VibraSpacing.sm),
            if (shifts.isEmpty)
              Text(
                l10n.musicalDnaNoShift,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: t.textSecondary,
                ),
              )
            else
              for (final s in shifts)
                Semantics(
                  label: l10n.musicalDnaShiftSemantics(
                    genreFamilyLabel(l10n, s.family),
                    '${s.from}',
                    '${s.to}',
                  ),
                  excludeSemantics: true,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Icon(
                          s.delta > 0
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          size: VibraSpacing.iconSm,
                          color: s.delta > 0 ? t.accentPrimary : t.textMuted,
                        ),
                        const SizedBox(width: VibraSpacing.sm),
                        Expanded(
                          child: Text(
                            genreFamilyLabel(l10n, s.family),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        Text(
                          '${s.from}% → ${s.to}%',
                          style: VibraTextStyles.scoreSmall.copyWith(
                            color: t.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _Sources extends StatelessWidget {
  const _Sources({required this.dna});

  final MusicalDna dna;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final s = dna.sources;
    final lines = <String>[
      if (s.spotify && s.artists > 0)
        l10n.musicalDnaSourceArtists('${s.artistsClassified}', '${s.artists}')
      else if (s.spotify)
        l10n.musicalDnaSourceSpotifyGenres,
      if (s.spotify && s.tracks > 0) l10n.musicalDnaSourceTracks('${s.tracks}'),
      if (s.manual) l10n.musicalDnaSourceGenres('${s.manualGenres}'),
    ];
    return _Section(
      title: l10n.musicalDnaSources,
      child: VibraSurface(
        padding: const EdgeInsets.all(VibraSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final line in lines)
              Padding(
                padding: const EdgeInsets.only(bottom: VibraSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: t.textSecondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: VibraSpacing.md),
                    Expanded(
                      child: Text(
                        line,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: t.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            TextButton.icon(
              onPressed: () => context.push('/music-genres'),
              icon: const Icon(Icons.tune_rounded, size: VibraSpacing.iconMd),
              label: Text(l10n.musicalDnaEditGenres),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                foregroundColor: t.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Visibility extends ConsumerWidget {
  const _Visibility();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final state = ref.watch(dnaVisibilityProvider);
    final current = state.valueOrNull ?? DnaVisibility.private;
    final body = switch (current) {
      DnaVisibility.public => l10n.musicalDnaVisibilityPublicBody,
      DnaVisibility.matches => l10n.musicalDnaVisibilityMatchesBody,
      DnaVisibility.private => l10n.musicalDnaVisibilityPrivateBody,
    };
    return _Section(
      title: l10n.musicalDnaVisibility,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<DnaVisibility>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: DnaVisibility.public,
                  icon: const Icon(Icons.public_rounded),
                  label: Text(l10n.musicalDnaVisibilityPublic),
                ),
                ButtonSegment(
                  value: DnaVisibility.matches,
                  icon: const Icon(Icons.people_outline_rounded),
                  label: Text(l10n.musicalDnaVisibilityMatches),
                ),
                ButtonSegment(
                  value: DnaVisibility.private,
                  icon: const Icon(Icons.lock_outline_rounded),
                  label: Text(l10n.musicalDnaVisibilityPrivate),
                ),
              ],
              selected: {current},
              onSelectionChanged: state.isLoading
                  ? null
                  : (selection) async {
                      final ok = await ref
                          .read(dnaVisibilityProvider.notifier)
                          .select(selection.first);
                      if (!ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.musicalDnaVisibilityError),
                          ),
                        );
                      }
                    },
            ),
          ),
          const SizedBox(height: VibraSpacing.sm),
          Text(
            body,
            style: theme.textTheme.bodySmall?.copyWith(color: t.textSecondary),
          ),
        ],
      ),
    );
  }
}
