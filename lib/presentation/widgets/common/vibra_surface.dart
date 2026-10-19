import 'package:flutter/material.dart';

import '../../../core/theme/vibra_motion.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_theme_tokens.dart';

/// Una superficie Signal Paper: opaca, calma e con un solo bordo hairline.
class VibraSurface extends StatefulWidget {
  const VibraSurface({
    required this.child,
    super.key,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.borderColor,
    this.radius = VibraSpacing.radiusMedium,
    this.semanticLabel,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final double radius;
  final String? semanticLabel;

  @override
  State<VibraSurface> createState() => _VibraSurfaceState();
}

class _VibraSurfaceState extends State<VibraSurface> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final borderRadius = BorderRadius.circular(widget.radius);
    final content = AnimatedScale(
      scale: _pressed && widget.onTap != null ? 0.98 : 1,
      duration: VibraMotion.durationFor(
        context,
        _pressed ? VibraMotion.tapIn : VibraMotion.tapOut,
      ),
      curve: VibraMotion.signalCurve,
      child: Container(
        margin: widget.margin,
        decoration: BoxDecoration(
          color: widget.color ?? t.surfaceElevated,
          borderRadius: borderRadius,
          border: Border.all(color: widget.borderColor ?? t.borderDefault),
          boxShadow: Theme.of(context).brightness == Brightness.light
              ? [t.cardShadow]
              : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: widget.onTap,
            onHighlightChanged: (value) => setState(() => _pressed = value),
            borderRadius: borderRadius,
            splashColor: t.accentPrimary.withValues(alpha: 0.18),
            hoverColor: t.accentPrimary.withValues(alpha: 0.08),
            focusColor: t.accentPrimary.withValues(alpha: 0.12),
            highlightColor: t.accentPrimary.withValues(alpha: 0.10),
            child: Padding(
              padding: widget.padding ?? const EdgeInsets.all(VibraSpacing.lg),
              child: widget.child,
            ),
          ),
        ),
      ),
    );

    if (widget.onTap == null) return content;
    return Semantics(button: true, label: widget.semanticLabel, child: content);
  }
}
