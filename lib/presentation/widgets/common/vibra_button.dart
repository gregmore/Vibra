import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibra/l10n/app_localizations.dart';

import '../../../core/theme/vibra_motion.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_text_styles.dart';
import '../../../core/theme/vibra_theme_tokens.dart';

/// Visual roles for VIBRA buttons.
///
/// * [signal] — violet primary action. One per view.
/// * [ink] — maximum-contrast monochrome (white on black, like the logo).
/// * [secondary] — quiet filled surface.
/// * [outline] — hairline border, transparent.
/// * [text] — inline action without a container.
/// * [danger] — destructive confirmation.
enum VibraButtonTone { signal, ink, secondary, outline, text, danger }

enum VibraButtonSize { regular, compact }

/// The single button implementation behind every VIBRA CTA.
///
/// Press feedback is a short compression ([VibraMotion.pressedScale]) plus a
/// selection haptic; both respect reduced motion. Loading keeps the button's
/// width so layouts never jump.
class VibraButton extends StatefulWidget {
  const VibraButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.tone = VibraButtonTone.ink,
    this.size = VibraButtonSize.regular,
    this.leadingIcon,
    this.trailingIcon,
    this.expanded = false,
    this.loading = false,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final VibraButtonTone tone;
  final VibraButtonSize size;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool expanded;
  final bool loading;
  final String? semanticLabel;

  @override
  State<VibraButton> createState() => _VibraButtonState();
}

class _VibraButtonState extends State<VibraButton> {
  bool _pressed = false;

  ({Color background, Color foreground, Color border}) _colors(
    VibraThemeTokens t,
  ) => switch (widget.tone) {
    VibraButtonTone.signal => (
      background: t.accentFill,
      foreground: t.onAccent,
      border: Colors.transparent,
    ),
    VibraButtonTone.ink => (
      background: t.textPrimary,
      foreground: t.backgroundPrimary,
      border: Colors.transparent,
    ),
    VibraButtonTone.secondary => (
      background: t.surfaceMuted,
      foreground: t.textPrimary,
      border: Colors.transparent,
    ),
    VibraButtonTone.outline => (
      background: Colors.transparent,
      foreground: t.textPrimary,
      border: t.borderStrong,
    ),
    VibraButtonTone.text => (
      background: Colors.transparent,
      foreground: t.accentPrimary,
      border: Colors.transparent,
    ),
    VibraButtonTone.danger => (
      background: t.error.withValues(alpha: 0.12),
      foreground: t.error,
      border: t.error.withValues(alpha: 0.4),
    ),
  };

  void _handleTap() {
    HapticFeedback.selectionClick();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null || widget.loading;
    final t = context.vibraTokens;
    final colors = _colors(t);
    final compact = widget.size == VibraButtonSize.compact;
    final height = compact
        ? VibraSpacing.buttonHeightCompact
        : VibraSpacing.buttonHeight;
    final radius = BorderRadius.circular(
      compact ? VibraSpacing.radiusSmall : VibraSpacing.radiusMedium,
    );
    final iconSize = compact ? VibraSpacing.iconSm : VibraSpacing.iconMd;
    final textStyle =
        (compact ? VibraTextStyles.labelMedium : VibraTextStyles.labelLarge)
            .copyWith(color: colors.foreground, fontWeight: FontWeight.w700);
    final duration = VibraMotion.durationFor(
      context,
      _pressed ? VibraMotion.tapIn : VibraMotion.tapOut,
    );
    final l10n = AppLocalizations.of(context);

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.leadingIcon != null) ...[
          Icon(widget.leadingIcon, size: iconSize, color: colors.foreground),
          const SizedBox(width: VibraSpacing.sm),
        ],
        Flexible(
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textStyle,
          ),
        ),
        if (widget.trailingIcon != null) ...[
          const SizedBox(width: VibraSpacing.sm),
          Icon(widget.trailingIcon, size: iconSize, color: colors.foreground),
        ],
      ],
    );

    return Semantics(
      button: true,
      enabled: !disabled,
      label: widget.loading
          ? (l10n?.commonLoadingLabel(widget.label) ?? widget.label)
          : (widget.semanticLabel ?? widget.label),
      excludeSemantics: true,
      child: AnimatedOpacity(
        opacity: disabled && !widget.loading ? 0.4 : 1,
        duration: VibraMotion.durationFor(context, VibraMotion.fast),
        child: AnimatedScale(
          scale: _pressed ? VibraMotion.pressedScale : 1,
          duration: duration,
          curve: VibraMotion.signalCurve,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: height,
              minWidth: compact ? 44 : 64,
            ),
            child: SizedBox(
              width: widget.expanded ? double.infinity : null,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: radius,
                  border: colors.border == Colors.transparent
                      ? null
                      : Border.all(color: colors.border),
                ),
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    borderRadius: radius,
                    onTap: disabled ? null : _handleTap,
                    onHighlightChanged: (value) =>
                        setState(() => _pressed = value),
                    splashColor: colors.foreground.withValues(alpha: 0.10),
                    hoverColor: colors.foreground.withValues(alpha: 0.06),
                    focusColor: t.accentPrimary.withValues(alpha: 0.24),
                    highlightColor: colors.foreground.withValues(alpha: 0.06),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: compact ? VibraSpacing.lg : 22,
                        vertical: compact ? 10 : 16,
                      ),
                      child: Center(
                        heightFactor: 1,
                        widthFactor: widget.expanded ? null : 1,
                        child: widget.loading
                            ? Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Keeps the intrinsic width while loading.
                                  Opacity(opacity: 0, child: content),
                                  SizedBox.square(
                                    dimension: iconSize,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colors.foreground,
                                    ),
                                  ),
                                ],
                              )
                            : content,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Primary call to action: violet fill, white copy (AA 5.7:1).
class VibraPrimaryButton extends StatelessWidget {
  const VibraPrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.trailingIcon,
    this.expanded = true,
    this.loading = false,
    this.size = VibraButtonSize.regular,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool expanded;
  final bool loading;
  final VibraButtonSize size;

  @override
  Widget build(BuildContext context) => VibraButton(
    label: label,
    onPressed: onPressed,
    tone: VibraButtonTone.signal,
    size: size,
    leadingIcon: icon,
    trailingIcon: trailingIcon,
    expanded: expanded,
    loading: loading,
  );
}

/// Secondary action: hairline outline by default, or a quiet fill.
class VibraSecondaryButton extends StatelessWidget {
  const VibraSecondaryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.expanded = true,
    this.loading = false,
    this.filled = false,
    this.size = VibraButtonSize.regular,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;
  final bool loading;
  final bool filled;
  final VibraButtonSize size;

  @override
  Widget build(BuildContext context) => VibraButton(
    label: label,
    onPressed: onPressed,
    tone: filled ? VibraButtonTone.secondary : VibraButtonTone.outline,
    size: size,
    leadingIcon: icon,
    expanded: expanded,
    loading: loading,
  );
}

/// Circular icon action (Ignore / Send Vibra, toolbar actions).
class VibraIconButton extends StatefulWidget {
  const VibraIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    super.key,
    this.size = 48,
    this.tone = VibraButtonTone.secondary,
    this.loading = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final double size;
  final VibraButtonTone tone;
  final bool loading;

  @override
  State<VibraIconButton> createState() => _VibraIconButtonState();
}

class _VibraIconButtonState extends State<VibraIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final (bg, fg, border) = switch (widget.tone) {
      VibraButtonTone.signal => (t.accentFill, t.onAccent, null),
      VibraButtonTone.ink => (t.textPrimary, t.backgroundPrimary, null),
      VibraButtonTone.outline => (
        Colors.transparent,
        t.textPrimary,
        t.borderStrong,
      ),
      VibraButtonTone.text => (Colors.transparent, t.textPrimary, null),
      VibraButtonTone.danger => (
        t.error.withValues(alpha: 0.12),
        t.error,
        null,
      ),
      VibraButtonTone.secondary => (t.surfaceElevated, t.textPrimary, null),
    };
    final disabled = widget.onPressed == null || widget.loading;
    return Tooltip(
      message: widget.tooltip,
      child: Semantics(
        button: true,
        enabled: !disabled,
        label: widget.tooltip,
        excludeSemantics: true,
        child: AnimatedScale(
          scale: _pressed ? 0.92 : 1,
          duration: VibraMotion.durationFor(
            context,
            _pressed ? VibraMotion.tapIn : VibraMotion.tapOut,
          ),
          curve: VibraMotion.signalCurve,
          child: Opacity(
            opacity: disabled && !widget.loading ? 0.4 : 1,
            child: Material(
              color: bg,
              shape: CircleBorder(
                side: border == null
                    ? BorderSide.none
                    : BorderSide(color: border),
              ),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: disabled
                    ? null
                    : () {
                        HapticFeedback.selectionClick();
                        widget.onPressed!();
                      },
                onHighlightChanged: (v) => setState(() => _pressed = v),
                child: SizedBox.square(
                  dimension: widget.size.clamp(
                    VibraSpacing.minTouchTarget,
                    double.infinity,
                  ),
                  child: Center(
                    child: widget.loading
                        ? SizedBox.square(
                            dimension: widget.size * .36,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: fg,
                            ),
                          )
                        : Icon(widget.icon, color: fg, size: widget.size * .42),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
