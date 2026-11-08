import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/vibra_spacing.dart';
import '../../core/theme/vibra_theme_tokens.dart';
import '../../domain/entities/musical_dna.dart';
import '../../domain/entities/taste_evolution.dart';
import '../../l10n/app_localizations.dart';
import '../localization/music_affinity_text.dart';
import 'common/vibra_surface.dart';
import 'musical_dna_widgets.dart';

String _date(BuildContext context, DateTime? d) => d == null
    ? ''
    : DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(d);

/// TASTE EVOLUTION chart (docs/taste-evolution.md): then vs now for each
/// genre family and, with at least three real snapshots, the timeline of
/// the Musical DNA across the period. Only stored snapshots are drawn;
/// nothing is interpolated.
class TasteEvolutionChart extends StatelessWidget {
  const TasteEvolutionChart({required this.evolution, super.key});

  /// Must have a baseline and a current snapshot.
  final TasteEvolution evolution;

  @override
  Widget build(BuildContext context) {
    if (evolution.baseline == null || evolution.current == null) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ThenNow(evolution: evolution),
        if (evolution.timeline.length >= 3) ...[
          const SizedBox(height: VibraSpacing.lg),
          _Timeline(evolution: evolution),
        ],
      ],
    );
  }
}

/// Then vs now: both DNA bands, and each family's two bars side by side.
class _ThenNow extends StatelessWidget {
  const _ThenNow({required this.evolution});
  final TasteEvolution evolution;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final theme = Theme.of(context);
    final base = evolution.baseline!, now = evolution.current!;
    final rows = evolution.distribution.take(8).toList();
    Widget band(String label, MusicalDna dna) => Row(
      children: [
        SizedBox(
          width: 96,
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(color: t.textMuted),
          ),
        ),
        Expanded(child: DnaStrip(families: dna.families, height: 12)),
      ],
    );
    Widget bar(int percent, Color color) => LayoutBuilder(
      builder: (_, c) => Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: c.maxWidth * (percent.clamp(0, 100) / 100),
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
    return VibraSurface(
      padding: const EdgeInsets.all(VibraSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.tasteThenNow, style: theme.textTheme.titleSmall),
          const SizedBox(height: VibraSpacing.md),
          band(_date(context, base.capturedOn), base),
          const SizedBox(height: VibraSpacing.xs),
          band(_date(context, now.capturedOn), now),
          const SizedBox(height: VibraSpacing.lg),
          for (final f in rows)
            Semantics(
              label: l10n.musicalDnaShiftSemantics(
                genreFamilyLabel(l10n, f.key),
                '${f.before}',
                '${f.now}',
              ),
              excludeSemantics: true,
              child: Padding(
                padding: const EdgeInsets.only(bottom: VibraSpacing.sm),
                child: Row(
                  children: [
                    SizedBox(
                      width: 96,
                      child: Text(
                        genreFamilyLabel(l10n, f.key),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          bar(f.before, t.textPrimary.withValues(alpha: .25)),
                          const SizedBox(height: 3),
                          bar(f.now, t.accentPrimary),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 78,
                      child: Text(
                        '${f.before}% → ${f.now}%',
                        textAlign: TextAlign.end,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: f.delta > 0
                              ? t.accentPrimary
                              : t.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Row(
            children: [
              _Legend(
                color: t.textPrimary.withValues(alpha: .25),
                text: l10n.tasteThen,
              ),
              const SizedBox(width: VibraSpacing.md),
              _Legend(color: t.accentPrimary, text: l10n.tasteNow),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.text});
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 12,
        height: 8,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      const SizedBox(width: 4),
      Text(text, style: Theme.of(context).textTheme.labelSmall),
    ],
  );
}

/// Real snapshots spread across the period, one band each.
class _Timeline extends StatelessWidget {
  const _Timeline({required this.evolution});
  final TasteEvolution evolution;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final theme = Theme.of(context);
    // Colours follow the current ranking so a family keeps its tone.
    final rankOf = {
      for (var i = 0; i < evolution.current!.families.length; i++)
        evolution.current!.families[i].key: i,
    };
    return VibraSurface(
      padding: const EdgeInsets.all(VibraSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.tasteTimeline, style: theme.textTheme.titleSmall),
          Text(
            l10n.tasteTimelineBody(evolution.timeline.length),
            style: theme.textTheme.bodySmall?.copyWith(color: t.textSecondary),
          ),
          const SizedBox(height: VibraSpacing.md),
          for (final p in evolution.timeline)
            Padding(
              padding: const EdgeInsets.only(bottom: VibraSpacing.xs),
              child: Row(
                children: [
                  SizedBox(
                    width: 96,
                    child: Text(
                      _date(context, p.capturedOn),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: t.textMuted,
                      ),
                    ),
                  ),
                  Expanded(
                    child: DnaStrip(
                      families: [...p.families]
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
        ],
      ),
    );
  }
}
