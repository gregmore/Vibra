import 'package:flutter/material.dart';

import '../../../core/theme/vibra_motion.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_text_styles.dart';
import '../../../core/theme/vibra_theme_tokens.dart';

/// Standard VIBRA modal sheet: elevated surface, 24 px top radius, drag
/// handle, optional title, keyboard- and safe-area-aware padding, and the
/// house enter curve.
class VibraBottomSheet extends StatelessWidget {
  const VibraBottomSheet({
    required this.child,
    super.key,
    this.title,
    this.subtitle,
    this.padding = const EdgeInsets.fromLTRB(
      VibraSpacing.pagePadding,
      0,
      VibraSpacing.pagePadding,
      VibraSpacing.xl,
    ),
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final EdgeInsetsGeometry padding;

  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    bool isScrollControlled = true,
    bool useSafeArea = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      useSafeArea: useSafeArea,
      showDragHandle: true,
      sheetAnimationStyle: AnimationStyle(
        duration: VibraMotion.durationFor(context, VibraMotion.page),
        reverseDuration: VibraMotion.durationFor(context, VibraMotion.medium),
        curve: VibraMotion.emphasized,
        reverseCurve: VibraMotion.exit,
      ),
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title != null) ...[
                Semantics(
                  header: true,
                  child: Text(
                    title!,
                    style: VibraTextStyles.headlineSmall.copyWith(
                      color: t.textPrimary,
                    ),
                  ),
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
                const SizedBox(height: VibraSpacing.lg),
              ],
              Flexible(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
