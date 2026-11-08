import 'package:flutter/material.dart';

import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_text_styles.dart';
import '../../../core/theme/vibra_theme_tokens.dart';

enum VibraBadgeTone { neutral, accent, success, warning, error, onImage }

/// Small status label. Always text (optionally with an icon or dot), so the
/// meaning never relies on colour alone.
class VibraBadge extends StatelessWidget {
  const VibraBadge({
    required this.label,
    super.key,
    this.tone = VibraBadgeTone.neutral,
    this.icon,
    this.dot = false,
    this.uppercase = false,
  });

  final String label;
  final VibraBadgeTone tone;
  final IconData? icon;
  final bool dot;
  final bool uppercase;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final (bg, fg, accent) = switch (tone) {
      VibraBadgeTone.neutral => (
        t.surfaceMuted,
        t.textPrimary,
        t.textSecondary,
      ),
      VibraBadgeTone.accent => (t.accentSoft, t.textPrimary, t.accentPrimary),
      VibraBadgeTone.success => (
        t.success.withValues(alpha: .14),
        t.textPrimary,
        t.success,
      ),
      VibraBadgeTone.warning => (
        t.warning.withValues(alpha: .14),
        t.textPrimary,
        t.warning,
      ),
      VibraBadgeTone.error => (
        t.error.withValues(alpha: .14),
        t.textPrimary,
        t.error,
      ),
      VibraBadgeTone.onImage => (t.imageOverlay, t.onImage, t.onImage),
    };
    final text = uppercase ? label.toUpperCase() : label;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: VibraSpacing.borderFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ] else if (icon != null) ...[
            Icon(icon, size: 13, color: accent),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  (uppercase
                          ? VibraTextStyles.labelSmall
                          : VibraTextStyles.labelMedium.copyWith(fontSize: 12))
                      .copyWith(color: fg),
            ),
          ),
        ],
      ),
    );
  }
}

/// Numeric counter (unread messages, requests). Hidden at zero.
class VibraCountBadge extends StatelessWidget {
  const VibraCountBadge({required this.count, super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    final t = context.vibraTokens;
    return Container(
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: t.accentFill,
        borderRadius: VibraSpacing.borderFull,
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: VibraTextStyles.labelSmall.copyWith(
          color: t.onAccent,
          letterSpacing: 0,
          fontSize: 11,
        ),
      ),
    );
  }
}
