import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/vibra_spacing.dart';
import '../../core/theme/vibra_theme_tokens.dart';
import '../../domain/entities/event.dart';
import '../../l10n/app_localizations.dart';
import '../localization/music_affinity_text.dart';
import '../providers/app_state_providers.dart';
import '../providers/circle_providers.dart';
import '../providers/musical_dna_providers.dart';
import '../providers/same_frequency_providers.dart';
import 'common/vibra_avatar.dart';
import 'common/vibra_section_header.dart';
import 'common/vibra_surface.dart';
import 'musical_dna_widgets.dart';

/// "Find your people through music": the four signature features on Home
/// (docs/ui-architecture.md). Each tile shows one live fact from the
/// user's real data and opens the feature. A section that fails to load
/// falls back to its invitation text, so Home never shows an error here.
class HomeSignatureSection extends StatelessWidget {
  const HomeSignatureSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VibraSectionHeader(
          eyebrow: l10n.homeSignatureEyebrow,
          title: l10n.homeSignatureTitle,
          // Aligned with the tiles: Home already applies the page padding.
          padding: EdgeInsets.zero,
        ),
        const SizedBox(height: VibraSpacing.sm),
        LayoutBuilder(
          builder: (context, c) {
            // Two per row on phones, four on wide screens.
            final columns = c.maxWidth >= 640 ? 4 : 2;
            final gap = VibraSpacing.sm;
            final width = (c.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final tile in const [
                  _DnaTile(),
                  _FrequencyTile(),
                  _ConcertMatchTile(),
                  _CirclesTile(),
                ])
                  SizedBox(width: width, child: tile),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.detail,
    required this.onTap,
    this.visual,
  });

  final IconData icon;
  final String title;
  final String detail;
  final VoidCallback onTap;
  final Widget? visual;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: '$title. $detail',
      excludeSemantics: true,
      child: VibraSurface(
        onTap: onTap,
        padding: const EdgeInsets.all(VibraSpacing.md),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 112),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: t.accentPrimary, size: VibraSpacing.iconLg),
              const SizedBox(height: VibraSpacing.sm),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 2),
              Text(
                detail,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: t.textSecondary,
                ),
              ),
              if (visual != null) ...[
                const SizedBox(height: VibraSpacing.sm),
                visual!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DnaTile extends ConsumerWidget {
  const _DnaTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final dna = ref.watch(myMusicalDnaHistoryProvider).valueOrNull?.firstOrNull;
    final top = dna?.families.firstOrNull;
    return _Tile(
      icon: Icons.fingerprint_rounded,
      title: l10n.musicalDnaTitle,
      detail: top == null
          ? l10n.homeDnaEmpty
          : l10n.homeDnaTop(genreFamilyLabel(l10n, top.key)),
      onTap: () => context.push(dna == null ? '/music-genres' : '/musical-dna'),
      visual: dna == null ? null : DnaStrip(families: dna.families, height: 8),
    );
  }
}

class _FrequencyTile extends ConsumerWidget {
  const _FrequencyTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final people =
        ref.watch(sameFrequencyPreviewProvider).valueOrNull?.people ?? const [];
    return _Tile(
      icon: Icons.graphic_eq_rounded,
      title: l10n.sameFrequencyTitle,
      detail: l10n.homeFrequencyCount(people.length),
      onTap: () => context.push('/same-frequency'),
      visual: people.isEmpty
          ? null
          : SizedBox(
              height: 28,
              child: Stack(
                children: [
                  for (var i = 0; i < people.length && i < 3; i++)
                    Positioned(
                      left: i * 20.0,
                      child: VibraAvatar(
                        imageUrl: people[i].avatarUrl,
                        name: people[i].name,
                        radius: 14,
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _ConcertMatchTile extends ConsumerWidget {
  const _ConcertMatchTile();

  /// The next concert I'm going to, if any.
  static Event? nextGoing(List<Event> going, DateTime now) {
    final upcoming = going.where((e) => !e.eventDate.isBefore(now)).toList()
      ..sort((a, b) => a.eventDate.compareTo(b.eventDate));
    return upcoming.firstOrNull;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final next = nextGoing(ref.watch(myEventsProvider).going, DateTime.now());
    return _Tile(
      icon: Icons.confirmation_number_outlined,
      title: l10n.concertMatchTitle,
      detail: next == null
          ? l10n.homeConcertMatchNone
          : l10n.homeConcertMatchNext(next.artistName ?? next.name),
      onTap: () => next == null
          ? context.push('/concerts')
          : context.push('/concert-match', extra: next),
    );
  }
}

class _CirclesTile extends ConsumerWidget {
  const _CirclesTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final invitations =
        ref.watch(circleInvitationsProvider).valueOrNull?.length ?? 0;
    final circles = ref.watch(myCirclesProvider).valueOrNull?.length ?? 0;
    return _Tile(
      icon: Icons.bubble_chart_outlined,
      title: l10n.circlesTitle,
      detail: invitations > 0
          ? l10n.homeCirclesInvites(invitations)
          : l10n.homeCirclesCount(circles),
      onTap: () => context.push('/circles'),
    );
  }
}
