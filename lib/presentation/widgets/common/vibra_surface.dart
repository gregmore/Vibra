import 'package:flutter/material.dart';

import '../../../core/theme/vibra_motion.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_theme_tokens.dart';

/// The base VIBRA card.
///
/// Dark-first: content is separated by surface steps (#101010 on #000000),
/// not by borders or shadows. In the light presentation a hairline border
/// and a very soft shadow provide the same separation on paper.
class VibraSurface extends StatefulWidget {
  const VibraSurface({
    required this.child,
    super.key,
    this.padding,
    this.margin,
    this.onTap,
    this.onLongPress,
    this.color,
    this.borderColor,
    this.radius = VibraSpacing.radiusLarge,
    this.semanticLabel,
    this.elevated = false,
    this.clip = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final Color? borderColor;
  final double radius;
  final String? semanticLabel;

  /// Uses the elevated surface step (#181818) instead of the card step.
  final bool elevated;

  /// Clips children (e.g. media) to the rounded shape.
  final bool clip;

  @override
  State<VibraSurface> createState() => _VibraSurfaceState();
}

class _VibraSurfaceState extends State<VibraSurface> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final borderRadius = BorderRadius.circular(widget.radius);
    final interactive = widget.onTap != null || widget.onLongPress != null;
    final border = widget.borderColor ?? (isLight ? t.borderDefault : null);
    final content = AnimatedScale(
      scale: _pressed && interactive ? VibraMotion.pressedScale + .01 : 1,
      duration: VibraMotion.durationFor(
        context,
        _pressed ? VibraMotion.tapIn : VibraMotion.tapOut,
      ),
      curve: VibraMotion.signalCurve,
      child: Container(
        margin: widget.margin,
        clipBehavior: widget.clip ? Clip.antiAlias : Clip.none,
        decoration: BoxDecoration(
          color:
              widget.color ?? (widget.elevated ? t.surfaceElevated : t.surface),
          borderRadius: borderRadius,
          border: border == null ? null : Border.all(color: border),
          boxShadow: isLight ? [t.cardShadow] : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            onHighlightChanged: interactive
                ? (value) => setState(() => _pressed = value)
                : null,
            borderRadius: borderRadius,
            splashColor: t.accentPrimary.withValues(alpha: 0.10),
            hoverColor: t.textPrimary.withValues(alpha: 0.03),
            focusColor: t.accentPrimary.withValues(alpha: 0.14),
            highlightColor: t.textPrimary.withValues(alpha: 0.03),
            child: Padding(
              padding: widget.padding ?? const EdgeInsets.all(VibraSpacing.lg),
              child: widget.child,
            ),
          ),
        ),
      ),
    );

    if (!interactive) return content;
    return Semantics(button: true, label: widget.semanticLabel, child: content);
  }
}
