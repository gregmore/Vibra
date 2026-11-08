import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vibra/l10n/app_localizations.dart';

import '../../../core/theme/vibra_motion.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_text_styles.dart';
import '../../../core/theme/vibra_theme_tokens.dart';

/// VIBRA compatibility indicator.
///
/// A ring that fills to the score returned by the backend — never
/// recalculated here. The arc carries the tier through colour *and* weight:
///
/// * high (≥ 75): violet → indigo sweep, thick arc, outer echo ring
/// * medium (≥ 45): indigo arc
/// * low: neutral arc
///
/// The number is always printed in primary ink, so the score is readable at
/// any size and in any tier without relying on colour.
class VibraMatchIndicator extends StatelessWidget {
  const VibraMatchIndicator({
    required this.percentage,
    super.key,
    this.size = 64,
    this.showTierLabel = false,
    this.label,
    this.animate = true,
  });

  /// Compatibility 0–100 as returned by the backend.
  final int percentage;
  final double size;

  /// Prints the tier (e.g. "High match") under the ring. Large sizes only.
  final bool showTierLabel;

  /// Optional eyebrow above the ring (e.g. "MATCH SCORE").
  final String? label;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    final value = percentage.clamp(0, 100);
    final tier = t.matchTier(value / 100);
    final tierLabel = switch (tier) {
      VibraMatchTier.high => l10n.matchTierHigh,
      VibraMatchTier.medium => l10n.matchTierMedium,
      VibraMatchTier.low => l10n.matchTierLow,
    };
    final duration = animate
        ? VibraMotion.durationFor(context, VibraMotion.score)
        : Duration.zero;
    final stroke = math.max(
      3.0,
      size * (tier == VibraMatchTier.high ? .085 : .07),
    );
    final numberStyle = size >= 120
        ? VibraTextStyles.scoreXL.copyWith(fontSize: size * .3)
        : size >= 56
        ? VibraTextStyles.scoreLarge.copyWith(fontSize: size * .3)
        : VibraTextStyles.scoreSmall.copyWith(
            fontSize: math.max(11, size * .3),
          );

    return Semantics(
      label: '${l10n.eventAffinitySemantics(value)}, $tierLabel',
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: VibraTextStyles.labelSmall.copyWith(
                color: t.textSecondary,
              ),
            ),
            const SizedBox(height: VibraSpacing.md),
          ],
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value / 100),
            duration: duration,
            curve: VibraMotion.signalCurve,
            builder: (context, progress, _) => SizedBox.square(
              dimension: size,
              child: CustomPaint(
                painter: _MatchRingPainter(
                  progress: progress,
                  stroke: stroke,
                  track: t.surfaceMuted,
                  tier: tier,
                  tokens: t,
                ),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: EdgeInsets.all(stroke * 1.4),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: '${(progress * 100).round()}'),
                            TextSpan(
                              text: '%',
                              style: TextStyle(
                                fontSize: (numberStyle.fontSize ?? 14) * .5,
                                color: t.textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        style: numberStyle.copyWith(color: t.textPrimary),
                        textScaler: TextScaler.noScaling,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (showTierLabel) ...[
            const SizedBox(height: VibraSpacing.md),
            VibraMatchTierChip(percentage: value),
          ],
        ],
      ),
    );
  }
}

class _MatchRingPainter extends CustomPainter {
  _MatchRingPainter({
    required this.progress,
    required this.stroke,
    required this.track,
    required this.tier,
    required this.tokens,
  });

  final double progress;
  final double stroke;
  final Color track;
  final VibraMatchTier tier;
  final VibraThemeTokens tokens;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = track,
    );
    if (progress <= 0) return;
    final sweep = 2 * math.pi * progress;
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    switch (tier) {
      case VibraMatchTier.high:
        arc.shader = SweepGradient(
          startAngle: 0,
          endAngle: 2 * math.pi,
          colors: [
            tokens.accentPrimary,
            tokens.accentSecondary,
            tokens.accentPrimary,
          ],
          transform: const GradientRotation(-math.pi / 2),
        ).createShader(rect);
        // Quiet echo ring: the "vibration" that marks a strong match.
        canvas.drawCircle(
          center,
          radius + stroke * 1.1,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1
            ..color = tokens.accentPrimary.withValues(alpha: .28 * progress),
        );
      case VibraMatchTier.medium:
        arc.color = tokens.accentSecondary;
      case VibraMatchTier.low:
        arc.color = tokens.textSecondary;
    }
    canvas.drawArc(rect, -math.pi / 2, sweep, false, arc);
  }

  @override
  bool shouldRepaint(_MatchRingPainter old) =>
      old.progress != progress ||
      old.tier != tier ||
      old.stroke != stroke ||
      old.track != track ||
      old.tokens != tokens;
}

/// Compact pill: a tiny ring + the number. For cards and list rows.
class VibraMatchBadge extends StatelessWidget {
  const VibraMatchBadge({
    required this.percentage,
    super.key,
    this.onImage = false,
  });

  final int percentage;

  /// Uses an opaque ink background for legibility over photography.
  final bool onImage;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final value = percentage.clamp(0, 100);
    final color = t.matchColor(value / 100);
    return Semantics(
      label: AppLocalizations.of(context)!.eventAffinitySemantics(value),
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 4, 10, 4),
        decoration: BoxDecoration(
          color: onImage ? t.imageOverlay : t.surfaceMuted,
          borderRadius: VibraSpacing.borderFull,
          border: Border.all(color: color.withValues(alpha: .55)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: 16,
              child: CustomPaint(
                painter: _MatchRingPainter(
                  progress: value / 100,
                  stroke: 2.5,
                  track: (onImage ? t.onImage : t.textPrimary).withValues(
                    alpha: .16,
                  ),
                  tier: t.matchTier(value / 100),
                  tokens: t,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$value%',
              style: VibraTextStyles.scoreSmall.copyWith(
                fontSize: 13,
                color: onImage ? t.onImage : t.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tier label chip ("High match"), always paired with a score elsewhere.
class VibraMatchTierChip extends StatelessWidget {
  const VibraMatchTierChip({required this.percentage, super.key});

  final int percentage;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    final tier = t.matchTier(percentage / 100);
    final (label, color) = switch (tier) {
      VibraMatchTier.high => (l10n.matchTierHigh, t.accentPrimary),
      VibraMatchTier.medium => (l10n.matchTierMedium, t.accentSecondary),
      VibraMatchTier.low => (l10n.matchTierLow, t.textSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .14),
        borderRadius: VibraSpacing.borderFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: VibraTextStyles.labelMedium.copyWith(color: t.textPrimary),
          ),
        ],
      ),
    );
  }
}
