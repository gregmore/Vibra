import 'package:flutter/material.dart';

import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_text_styles.dart';
import '../../../core/theme/vibra_theme_tokens.dart';

/// Section title used across Home, Profile and lists.
///
/// Optional tracked eyebrow, H3 title, secondary subtitle and a trailing
/// text action. No decorative bars: hierarchy comes from type alone.
class VibraSectionHeader extends StatelessWidget {
  const VibraSectionHeader({
    required this.title,
    this.subtitle,
    this.eyebrow,
    this.actionLabel,
    this.onActionTap,
    this.padding = const EdgeInsets.symmetric(
      horizontal: VibraSpacing.pagePadding,
    ),
    this.large = false,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String? eyebrow;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final EdgeInsetsGeometry padding;

  /// Uses Heading 2 instead of Heading 3.
  final bool large;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (eyebrow != null) ...[
                    Text(
                      eyebrow!.toUpperCase(),
                      style: VibraTextStyles.labelSmall.copyWith(
                        color: t.accentPrimary,
                      ),
                    ),
                    const SizedBox(height: VibraSpacing.xs + 2),
                  ],
                  Text(
                    title,
                    style:
                        (large
                                ? VibraTextStyles.headlineMedium
                                : VibraTextStyles.headlineSmall)
                            .copyWith(color: t.textPrimary),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: VibraSpacing.xs),
                    Text(
                      subtitle!,
                      style: VibraTextStyles.bodySmall.copyWith(
                        color: t.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (actionLabel != null && onActionTap != null)
            TextButton(
              onPressed: onActionTap,
              style: TextButton.styleFrom(
                foregroundColor: t.textSecondary,
                padding: const EdgeInsets.only(left: VibraSpacing.md),
                minimumSize: const Size(48, 44),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionLabel!,
                    style: VibraTextStyles.labelMedium.copyWith(
                      color: t.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: VibraSpacing.iconMd,
                    color: t.textSecondary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
