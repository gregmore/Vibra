import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_text_styles.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../../domain/entities/music_radar.dart';
import '../../../l10n/app_localizations.dart';
import '../../localization/music_affinity_text.dart';
import '../../providers/music_radar_providers.dart';
import '../../widgets/common/vibra_button.dart';
import '../../widgets/common/vibra_editorial_event.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_section_header.dart';
import '../../widgets/common/vibra_state_views.dart';
import '../../widgets/common/vibra_surface.dart';
import '../../providers/community_providers.dart';
import '../../widgets/community_widgets.dart';
import '../../widgets/music_radar_widgets.dart';
import '../../widgets/same_frequency_widgets.dart';

/// MUSIC RADAR (docs/music-radar.md). The app never receives anyone's
/// location or distance: only who is inside the radius and area aggregates.
class MusicRadarScreen extends ConsumerWidget {
  const MusicRadarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return VibraPageScaffold(
      appBar: AppBar(title: Text(l10n.musicRadarTitle)),
      child: ref
          .watch(musicRadarProvider)
          .when(
            loading: () => const VibraLoadingView(),
            error: (e, _) => VibraErrorView(
              error: e,
              title: l10n.musicRadarTitle,
              message: l10n.musicRadarLoadError,
              retryLabel: l10n.commonRetry,
              onRetry: () => ref.invalidate(musicRadarProvider),
            ),
            data: (radar) => RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(musicRadarProvider);
                await ref.read(musicRadarProvider.future);
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  VibraSpacing.pagePadding,
                  VibraSpacing.sm,
                  VibraSpacing.pagePadding,
                  VibraSpacing.colossal,
                ),
                children: [
                  ...switch (radar.status) {
                    RadarStatus.disabled => [const _Intro()],
                    RadarStatus.locationNeeded => [const _LocationNeeded()],
                    RadarStatus.ok => _results(context, ref, radar),
                  },
                  if (radar.status != RadarStatus.disabled) ...[
                    const SizedBox(height: VibraSpacing.sectionGap),
                    _Settings(settings: radar.settings),
                  ],
                ],
              ),
            ),
          ),
    );
  }

  List<Widget> _results(BuildContext context, WidgetRef ref, MusicRadar r) {
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return [
      Text(
        l10n.musicRadarTitle.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: t.accentPrimary,
          letterSpacing: 1.6,
        ),
      ),
      const SizedBox(height: VibraSpacing.sm),
      Semantics(
        header: true,
        child: Text(
          l10n.musicRadarHeadline,
          style: theme.textTheme.headlineMedium,
        ),
      ),
      const SizedBox(height: VibraSpacing.sm),
      Text(
        l10n.musicRadarCount(r.compatibleCount, r.settings.distanceKm),
        style: theme.textTheme.bodyLarge?.copyWith(color: t.textSecondary),
      ),
      if (!r.settings.matchingConsent) ...[
        const SizedBox(height: VibraSpacing.md),
        _Note(
          text: l10n.musicRadarMatchingNote,
          action: l10n.musicRadarOpenPrivacy,
          onTap: () => context.push('/privacy-controls'),
        ),
      ],
      _SectionTitle(
        title: l10n.musicRadarAreaSound,
        subtitle: l10n.musicRadarAreaSoundSub,
      ),
      _AreaSound(genres: r.areaGenres),
      _SectionTitle(title: l10n.musicRadarPeople),
      if (r.people.isNotEmpty) ...[
        MusicRadarMap(
          people: [for (final p in r.people) p.candidate],
          onTapPerson: (p) => context.push('/user-profile', extra: p.userId),
        ),
        const SizedBox(height: VibraSpacing.lg),
      ],
      if (r.people.isEmpty)
        Text(
          l10n.musicRadarEmptyPeople,
          style: theme.textTheme.bodyMedium?.copyWith(color: t.textSecondary),
        )
      else
        for (final person in r.people)
          Padding(
            padding: const EdgeInsets.only(bottom: VibraSpacing.lg),
            child: SameFrequencyCard(
              person: person.candidate,
              onSendVibra: person.canSendVibra
                  ? () async {
                      try {
                        await ref
                            .read(musicRadarProvider.notifier)
                            .sendVibra(person.candidate.userId);
                        if (context.mounted) {
                          _snack(
                            context,
                            l10n.socialMatchVibraSent(person.candidate.name),
                          );
                        }
                      } catch (_) {
                        if (context.mounted) {
                          _snack(context, l10n.musicRadarLoadError);
                        }
                      }
                    }
                  : null,
              onToggleSaved: () async {
                final ok = await ref
                    .read(musicRadarProvider.notifier)
                    .toggleSaved(person);
                if (!ok && context.mounted) {
                  _snack(context, l10n.sameFrequencySaveError);
                }
              },
            ),
          ),
      ..._areaCommunities(ref, r, l10n),
      if (r.events.isNotEmpty) ...[
        _SectionTitle(title: l10n.musicRadarEvents),
        for (final e in r.events)
          Padding(
            padding: const EdgeInsets.only(bottom: VibraSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (e.reason != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: VibraSpacing.xs),
                    child: Text(
                      _reason(l10n, e.reason!).toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: t.textMuted,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                VibraEventRow(
                  event: e.event,
                  onTap: () => context.push('/event-detail', extra: e.event),
                ),
              ],
            ),
          ),
      ],
    ];
  }

  /// Communities for the area's main sounds (not joined yet), so the radar
  /// leads to places to meet, not only to people.
  List<Widget> _areaCommunities(
    WidgetRef ref,
    MusicRadar r,
    AppLocalizations l10n,
  ) {
    final all = ref.watch(communitiesProvider).valueOrNull ?? const [];
    final rank = {
      for (var i = 0; i < r.areaGenres.length; i++) r.areaGenres[i].family: i,
    };
    final picks =
        all
            .where((c) => !c.isMember && rank.containsKey(c.genreFamily))
            .toList()
          ..sort((a, b) {
            final byArea = rank[a.genreFamily]!.compareTo(rank[b.genreFamily]!);
            if (byArea != 0) return byArea;
            return b.memberCount.compareTo(a.memberCount);
          });
    if (picks.isEmpty) return const [];
    return [
      _SectionTitle(title: l10n.musicRadarCommunities),
      for (final c in picks.take(3)) CommunityCard(community: c),
    ];
  }

  String _reason(AppLocalizations l10n, RadarEventReason reason) =>
      switch (reason) {
        RadarEventReason.yourArtist => l10n.musicRadarEventYourArtist,
        RadarEventReason.sharedArtist => l10n.musicRadarEventSharedArtist,
        RadarEventReason.yourGenre => l10n.musicRadarEventYourGenre,
        RadarEventReason.areaGenre => l10n.musicRadarEventAreaGenre,
      };
}

void _snack(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => VibraSectionHeader(
    title: title,
    subtitle: subtitle,
    padding: const EdgeInsets.only(
      top: VibraSpacing.sectionGap,
      bottom: VibraSpacing.md,
    ),
  );
}

class _AreaSound extends StatelessWidget {
  const _AreaSound({required this.genres});

  final List<AreaGenre> genres;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    if (genres.isEmpty) {
      return Text(
        l10n.musicRadarAreaTooFew,
        style: theme.textTheme.bodyMedium?.copyWith(color: t.textSecondary),
      );
    }
    final total = genres.fold<double>(0, (a, g) => a + g.share);
    return VibraSurface(
      padding: const EdgeInsets.all(VibraSpacing.xl),
      child: Column(
        children: [
          for (var i = 0; i < genres.length; i++) ...[
            if (i > 0) const SizedBox(height: VibraSpacing.md),
            Row(
              children: [
                SizedBox(
                  width: 110,
                  child: Text(
                    genreFamilyLabel(l10n, genres[i].family),
                    style: theme.textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Stack(
                      children: [
                        Container(height: 6, color: t.surfaceMuted),
                        FractionallySizedBox(
                          widthFactor: total > 0
                              ? (genres[i].share / total).clamp(0.03, 1.0)
                              : 0.03,
                          child: Container(
                            height: 6,
                            color: i == 0
                                ? t.accentPrimary
                                : t.textPrimary.withValues(
                                    alpha: (0.8 - i * 0.14).clamp(0.2, 0.8),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: VibraSpacing.md),
                SizedBox(
                  width: 40,
                  child: Text(
                    '${total > 0 ? (genres[i].share / total * 100).round() : 0}%',
                    textAlign: TextAlign.end,
                    style: VibraTextStyles.scoreSmall.copyWith(
                      color: t.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Intro extends ConsumerWidget {
  const _Intro();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: VibraSpacing.lg),
        Icon(Icons.radar_rounded, size: 48, color: t.accentPrimary),
        const SizedBox(height: VibraSpacing.lg),
        Text(l10n.musicRadarIntroTitle, style: theme.textTheme.headlineMedium),
        const SizedBox(height: VibraSpacing.sm),
        Text(
          l10n.musicRadarIntroBody,
          style: theme.textTheme.bodyLarge?.copyWith(color: t.textSecondary),
        ),
        const SizedBox(height: VibraSpacing.xl),
        for (final line in [
          l10n.musicRadarPrivacy1,
          l10n.musicRadarPrivacy2,
          l10n.musicRadarPrivacy3,
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: VibraSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: VibraSpacing.iconMd,
                  color: t.textSecondary,
                ),
                const SizedBox(width: VibraSpacing.md),
                Expanded(child: Text(line, style: theme.textTheme.bodyMedium)),
              ],
            ),
          ),
        const SizedBox(height: VibraSpacing.lg),
        VibraButton(
          label: l10n.musicRadarTurnOn,
          tone: VibraButtonTone.signal,
          expanded: true,
          onPressed: () async {
            final ok = await ref
                .read(musicRadarProvider.notifier)
                .saveSettings(enabled: true);
            if (!ok && context.mounted) {
              _snack(context, l10n.musicRadarSaveError);
            }
          },
        ),
      ],
    );
  }
}

class _LocationNeeded extends ConsumerWidget {
  const _LocationNeeded();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return VibraEmptyView(
      compact: true,
      title: l10n.musicRadarLocationTitle,
      message: l10n.musicRadarLocationBody,
      icon: Icons.location_off_outlined,
      actionLabel: l10n.musicRadarOpenPrivacy,
      onActionTap: () async {
        await context.push('/privacy-controls');
        ref.invalidate(musicRadarProvider);
      },
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.text, required this.action, required this.onTap});

  final String text;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return VibraSurface(
      padding: const EdgeInsets.all(VibraSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: t.textSecondary),
          ),
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: Text(action),
          ),
        ],
      ),
    );
  }
}

class _Settings extends ConsumerWidget {
  const _Settings({required this.settings});

  final RadarSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final controller = ref.read(musicRadarProvider.notifier);
    Future<void> save(Future<bool> action) async {
      if (!await action && context.mounted) {
        _snack(context, l10n.musicRadarSaveError);
      }
    }

    final caption = theme.textTheme.bodySmall?.copyWith(color: t.textSecondary);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.musicRadarSettings, style: theme.textTheme.titleLarge),
        const SizedBox(height: VibraSpacing.md),
        VibraSurface(
          padding: const EdgeInsets.symmetric(
            horizontal: VibraSpacing.lg,
            vertical: VibraSpacing.sm,
          ),
          child: Column(
            children: [
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.musicRadarEnabled),
                value: settings.enabled,
                onChanged: (v) => save(controller.saveSettings(enabled: v)),
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.musicRadarVisible),
                subtitle: Text(l10n.musicRadarVisibleBody, style: caption),
                value: settings.visible,
                onChanged: (v) => save(controller.saveSettings(visible: v)),
              ),
            ],
          ),
        ),
        const SizedBox(height: VibraSpacing.xl),
        Text(l10n.musicRadarDistance, style: theme.textTheme.titleSmall),
        const SizedBox(height: VibraSpacing.sm),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<int>(
            showSelectedIcon: false,
            segments: [
              for (final km in RadarSettings.distances)
                ButtonSegment(
                  value: km,
                  label: Text(l10n.musicRadarDistanceValue(km)),
                ),
            ],
            selected: {settings.distanceKm},
            onSelectionChanged: (s) =>
                save(controller.saveSettings(distanceKm: s.first)),
          ),
        ),
        const SizedBox(height: VibraSpacing.xl),
        Text(l10n.musicRadarPrecision, style: theme.textTheme.titleSmall),
        const SizedBox(height: VibraSpacing.sm),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<RadarPrecision>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: RadarPrecision.area,
                label: Text(l10n.musicRadarPrecisionArea),
              ),
              ButtonSegment(
                value: RadarPrecision.region,
                label: Text(l10n.musicRadarPrecisionRegion),
              ),
            ],
            selected: {settings.precision},
            onSelectionChanged: (s) =>
                save(controller.saveSettings(precision: s.first)),
          ),
        ),
        const SizedBox(height: VibraSpacing.sm),
        Text(l10n.musicRadarPrecisionBody, style: caption),
        const SizedBox(height: VibraSpacing.lg),
        for (final line in [l10n.musicRadarPrivacy1, l10n.musicRadarPrivacy2])
          Padding(
            padding: const EdgeInsets.only(bottom: VibraSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: VibraSpacing.iconSm,
                  color: t.textMuted,
                ),
                const SizedBox(width: VibraSpacing.sm),
                Expanded(child: Text(line, style: caption)),
              ],
            ),
          ),
      ],
    );
  }
}
