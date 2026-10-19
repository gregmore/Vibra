import 'package:vibra/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/vibra_motion.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_text_styles.dart';
import '../../../core/theme/vibra_theme_tokens.dart';

enum VibraButtonTone { ink, signal, outline, text }

/// CTA riutilizzabile con una silhouette semplice, mai una pill neon.
class VibraButton extends StatefulWidget {
  const VibraButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.tone = VibraButtonTone.ink,
    this.leadingIcon,
    this.trailingIcon,
    this.expanded = false,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final VibraButtonTone tone;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool expanded;
  final bool loading;

  @override
  State<VibraButton> createState() => _VibraButtonState();
}

class _VibraButtonState extends State<VibraButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null || widget.loading;
    final t = context.vibraTokens;
    final colors = switch (widget.tone) {
      VibraButtonTone.ink => (
        background: t.textPrimary,
        foreground: t.backgroundPrimary,
        border: t.textPrimary,
      ),
      VibraButtonTone.signal => (
        background: t.accentPrimary,
        foreground: t.onAccent,
        border: t.accentPrimary,
      ),
      VibraButtonTone.outline => (
        background: t.surface,
        foreground: t.textPrimary,
        border: t.borderStrong,
      ),
      VibraButtonTone.text => (
        background: Colors.transparent,
        foreground: t.textPrimary,
        border: Colors.transparent,
      ),
    };
    final borderRadius = VibraSpacing.borderSmall;

    final animationDuration = VibraMotion.durationFor(
      context,
      _pressed ? VibraMotion.tapIn : VibraMotion.tapOut,
    );
    return Semantics(
      button: true,
      enabled: !disabled,
      label: widget.loading
          ? AppLocalizations.of(context)!.commonLoadingLabel(widget.label)
          : widget.label,
      child: AnimatedOpacity(
        opacity: disabled ? 0.45 : 1,
        duration: animationDuration,
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1,
          duration: animationDuration,
          curve: VibraMotion.signalCurve,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: SizedBox(
              width: widget.expanded ? double.infinity : null,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: borderRadius,
                  border: Border.all(color: colors.border),
                ),
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    borderRadius: borderRadius,
                    onTap: disabled ? null : widget.onPressed,
                    onHighlightChanged: (value) =>
                        setState(() => _pressed = value),
                    splashColor: colors.foreground.withValues(alpha: 0.12),
                    hoverColor: colors.foreground.withValues(alpha: 0.08),
                    focusColor: colors.foreground.withValues(alpha: 0.12),
                    highlightColor: colors.foreground.withValues(alpha: 0.10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Center(
                        heightFactor: 1,
                        child: widget.loading
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colors.foreground,
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (widget.leadingIcon != null) ...[
                                    Icon(
                                      widget.leadingIcon,
                                      size: 18,
                                      color: colors.foreground,
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Flexible(
                                    child: Text(
                                      widget.label,
                                      textAlign: TextAlign.center,
                                      style: VibraTextStyles.labelLarge
                                          .copyWith(color: colors.foreground),
                                    ),
                                  ),
                                  if (widget.trailingIcon != null) ...[
                                    const SizedBox(width: 8),
                                    Icon(
                                      widget.trailingIcon,
                                      size: 18,
                                      color: colors.foreground,
                                    ),
                                  ],
                                ],
                              ),
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
