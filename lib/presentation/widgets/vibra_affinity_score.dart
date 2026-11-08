import 'package:flutter/material.dart';
import 'package:vibra/l10n/app_localizations.dart';

import '../../core/theme/vibra_spacing.dart';
import '../../core/theme/vibra_text_styles.dart';
import '../../core/theme/vibra_theme_tokens.dart';
import 'common/vibra_match_indicator.dart';

/// Hero compatibility block: eyebrow, animated ring, tier and caption.
/// Thin wrapper over [VibraMatchIndicator] kept for existing call sites.
class VibraAffinityScore extends StatelessWidget {
  const VibraAffinityScore({
    required this.score,
    super.key,
    this.label,
    this.caption,
    this.compact = false,
  });

  /// Normalised 0–1 score from the backend.
  final double score;
  final String? label;
  final String? caption;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final percentage = (score.clamp(0.0, 1.0) * 100).round();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        VibraMatchIndicator(
          percentage: percentage,
          size: compact ? 88 : 140,
          showTierLabel: !compact,
          label:
              label ??
              AppLocalizations.of(context)!.socialAffinity.toUpperCase(),
        ),
        if (caption != null) ...[
          const SizedBox(height: VibraSpacing.md),
          Text(
            caption!,
            textAlign: TextAlign.center,
            style: VibraTextStyles.bodySmall.copyWith(color: t.textSecondary),
          ),
        ],
      ],
    );
  }
}
