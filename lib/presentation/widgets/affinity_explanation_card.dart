import 'package:flutter/material.dart';

import '../../core/theme/vibra_spacing.dart';
import '../../core/theme/vibra_theme_tokens.dart';
import '../../domain/entities/music_affinity.dart';
import '../../l10n/app_localizations.dart';
import '../localization/music_affinity_text.dart';
import 'common/vibra_surface.dart';

/// "Why you match": the score as a sentence and one line per server reason.
/// Every line comes from the cached pair's details; with no reasons nothing
/// is shown rather than a made-up explanation.
class AffinityExplanationCard extends StatelessWidget {
  const AffinityExplanationCard({
    required this.score,
    required this.details,
    super.key,
  });

  final int score;
  final AffinityDetails details;

  @override
  Widget build(BuildContext context) {
    if (!details.hasExplanation) return const SizedBox.shrink();
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final lines = [
      for (final reason in details.reasons) affinityReasonText(l10n, reason),
    ];
    return VibraSurface(
      padding: const EdgeInsets.all(VibraSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.affinityWhy.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: t.accentPrimary,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: VibraSpacing.xs),
          Text(
            l10n.affinityHeadlineSentence(score),
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: VibraSpacing.md),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: VibraSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: t.accentPrimary,
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
          if (details.sharedArtists.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: VibraSpacing.xs),
              child: Wrap(
                spacing: VibraSpacing.xs,
                runSpacing: VibraSpacing.xs,
                children: [
                  for (final artist in details.sharedArtists)
                    Chip(
                      avatar: Icon(
                        Icons.music_note_rounded,
                        size: 14,
                        color: t.accentPrimary,
                      ),
                      label: Text(artist),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
