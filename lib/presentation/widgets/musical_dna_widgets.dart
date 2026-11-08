import 'package:flutter/material.dart';

import '../../core/theme/vibra_spacing.dart';
import '../../core/theme/vibra_text_styles.dart';
import '../../core/theme/vibra_theme_tokens.dart';
import '../../domain/entities/musical_dna.dart';
import '../../l10n/app_localizations.dart';
import '../localization/music_affinity_text.dart';
import 'common/vibra_surface.dart';

/// Ink tone for the family at [rank]: the leading family carries the brand
/// violet, the rest step down in white so the strip stays monochrome.
Color dnaFamilyColor(VibraThemeTokens t, int rank) {
  if (rank == 0) return t.accentPrimary;
  final alpha = (0.82 - (rank - 1) * 0.14).clamp(0.16, 0.82).toDouble();
  return t.textPrimary.withValues(alpha: alpha);
}

/// The DNA as one horizontal band, each family sized by its exact share.
class DnaStrip extends StatelessWidget {
  const DnaStrip({
    required this.families,
    this.height = 14,
    this.maxSegments = 6,
    super.key,
  });

  final List<DnaFamily> families;
  final double height;
  final int maxSegments;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final shown = families.take(maxSegments).toList();
    final rest = families
        .skip(maxSegments)
        .fold<double>(0, (a, f) => a + f.share);
    final segments = <(double, Color)>[
      for (var i = 0; i < shown.length; i++)
        (shown[i].share, dnaFamilyColor(t, i)),
      if (rest > 0) (rest, t.textPrimary.withValues(alpha: .12)),
    ].where((s) => s.$1 > 0).toList();
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: SizedBox(
          height: height,
          child: Row(
            children: [
              for (var i = 0; i < segments.length; i++) ...[
                if (i > 0)
                  SizedBox(width: 2, child: ColoredBox(color: t.surface)),
                Expanded(
                  flex: (segments[i].$1 * 1000).round().clamp(1, 1000),
                  child: ColoredBox(color: segments[i].$2),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// One family: name, percentage, a proportional bar, its strongest
/// subgenres and the artists behind it.
class DnaFamilyRow extends StatelessWidget {
  const DnaFamilyRow({
    required this.family,
    required this.rank,
    this.subgenres = const [],
    super.key,
  });

  final DnaFamily family;
  final int rank;
  final List<DnaSubgenre> subgenres;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final name = genreFamilyLabel(l10n, family.key);
    // Only subgenres more specific than the family itself are listed.
    final specific = subgenres
        .where((s) => s.key != s.family && s.percent > 0)
        .take(3);
    return Semantics(
      label: l10n.musicalDnaFamilySemantics(name, '${family.percent}'),
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: theme.textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${family.percent}%',
                style: VibraTextStyles.scoreSmall.copyWith(
                  color: rank == 0 ? t.accentPrimary : t.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: VibraSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Container(height: 6, color: t.surfaceMuted),
                FractionallySizedBox(
                  widthFactor: family.share.clamp(0.02, 1.0),
                  child: Container(height: 6, color: dnaFamilyColor(t, rank)),
                ),
              ],
            ),
          ),
          if (specific.isNotEmpty) ...[
            const SizedBox(height: VibraSpacing.sm),
            Wrap(
              spacing: VibraSpacing.xs,
              runSpacing: VibraSpacing.xs,
              children: [
                for (final s in specific)
                  _Tag('${genreLabel(l10n, s.key)} ${s.percent}%'),
              ],
            ),
          ],
          if (family.artists.isNotEmpty) ...[
            const SizedBox(height: VibraSpacing.xs + 2),
            Text(
              l10n.musicalDnaArtistsVia(family.artists.join(', ')),
              style: theme.textTheme.bodySmall?.copyWith(color: t.textMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: t.surfaceElevated,
        borderRadius: BorderRadius.circular(VibraSpacing.radiusFull),
        border: Border.all(color: t.borderDefault),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: t.textSecondary),
      ),
    );
  }
}

/// Compact DNA for profiles: strip plus the top three families.
class MusicalDnaPreviewCard extends StatelessWidget {
  const MusicalDnaPreviewCard({
    required this.dna,
    required this.title,
    this.onTap,
    super.key,
  });

  final MusicalDna dna;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final top = dna.families.take(3).toList();
    return VibraSurface(
      onTap: onTap,
      padding: const EdgeInsets.all(VibraSpacing.xl),
      semanticLabel: [
        title,
        for (final f in top)
          l10n.musicalDnaFamilySemantics(
            genreFamilyLabel(l10n, f.key),
            '${f.percent}',
          ),
      ].join('. '),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.musicalDnaTitle.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: t.accentPrimary,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.north_east_rounded,
                  size: VibraSpacing.iconMd,
                  color: t.textSecondary,
                ),
            ],
          ),
          const SizedBox(height: VibraSpacing.xs),
          Text(title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: VibraSpacing.lg),
          DnaStrip(families: dna.families, height: 10),
          const SizedBox(height: VibraSpacing.md),
          for (var i = 0; i < top.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: dnaFamilyColor(t, i),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: VibraSpacing.sm),
                  Expanded(
                    child: Text(
                      genreFamilyLabel(l10n, top[i].key),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    '${top[i].percent}%',
                    style: VibraTextStyles.scoreSmall.copyWith(
                      color: t.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
