import 'package:vibra/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../core/theme/vibra_motion.dart';
import '../../core/theme/vibra_text_styles.dart';
import '../../core/theme/vibra_theme_tokens.dart';
import 'vibra_signal_wave.dart';

/// Visualizzazione dell'affinità: numero grande e segnale, senza gauge fitness.
class VibraAffinityScore extends StatelessWidget {
  const VibraAffinityScore({
    required this.score,
    super.key,
    this.label,
    this.caption,
    this.compact = false,
  });

  final double score;
  final String? label;
  final String? caption;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final displayLabel =
        label ?? AppLocalizations.of(context)!.socialAffinity.toUpperCase();
    final normalized = score.clamp(0.0, 1.0).toDouble();
    final percentage = (normalized * 100).round();
    final duration = MediaQuery.maybeOf(context)?.disableAnimations ?? false
        ? Duration.zero
        : VibraMotion.score;

    return Semantics(
      liveRegion: true,
      label: AppLocalizations.of(
        context,
      )!.commonPercentLabel(percentage, displayLabel),
      value: '$percentage%',
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            displayLabel,
            style: VibraTextStyles.labelSmall.copyWith(
              color: t.textSecondary,
              letterSpacing: 1.35,
            ),
          ),
          const SizedBox(height: 2),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: percentage),
            duration: duration,
            curve: VibraMotion.signalCurve,
            builder: (context, value, _) => Text(
              '$value',
              style:
                  (compact
                          ? VibraTextStyles.displayMedium
                          : VibraTextStyles.scoreXL)
                      .copyWith(color: t.textPrimary),
            ),
          ),
          const SizedBox(height: 4),
          LayoutBuilder(
            builder: (context, constraints) => SizedBox(
              width: compact ? 112 : 180,
              height: compact ? 22 : 34,
              child: Stack(
                children: [
                  VibraSignalWave(
                    height: compact ? 22 : 34,
                    color: t.borderStrong,
                    secondaryColor: t.borderStrong,
                    amplitude: compact ? 4 : 7,
                    strokeWidth: 1.5,
                  ),
                  ClipRect(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: normalized,
                      child: SizedBox(
                        width: compact ? 112 : 180,
                        child: VibraSignalWave(
                          height: compact ? 22 : 34,
                          color: t.accentPrimary,
                          secondaryColor: t.textPrimary,
                          amplitude: compact ? 4 : 7,
                          strokeWidth: 2,
                          animate: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (caption != null) ...[
            const SizedBox(height: 6),
            Text(
              caption!,
              textAlign: TextAlign.center,
              style: VibraTextStyles.bodySmall.copyWith(color: t.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
