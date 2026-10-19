import 'package:vibra/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../core/theme/vibra_text_styles.dart';
import '../../core/theme/vibra_spacing.dart';
import '../../core/theme/vibra_motion.dart';
import '../../core/theme/vibra_theme_tokens.dart';

/// Bottone "pill" principale con neon glow per le Call to Action.
class VibraPillButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final IconData? icon;
  final bool isGhost;
  final bool isLoading;
  final bool isDisabled;

  const VibraPillButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.icon,
    this.isGhost = false,
    this.isLoading = false,
    this.isDisabled = false,
  });

  @override
  State<VibraPillButton> createState() => _VibraPillButtonState();
}

class _VibraPillButtonState extends State<VibraPillButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final isActuallyDisabled = widget.isDisabled || widget.isLoading;

    Color bgColor;
    if (widget.isGhost) {
      bgColor = Colors.transparent;
    } else {
      bgColor = widget.isPrimary ? Colors.transparent : t.surfaceMuted;
    }

    final fgColor = widget.isGhost
        ? t.accentPrimary
        : (widget.isPrimary ? t.onAccent : t.textPrimary);

    return Semantics(
      button: true,
      enabled: !isActuallyDisabled,
      label: widget.isLoading
          ? AppLocalizations.of(context)!.commonLoadingLabel(widget.text)
          : widget.text,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: VibraMotion.durationFor(context, VibraSpacing.animFast),
        child: Opacity(
          opacity: isActuallyDisabled ? 0.45 : 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: widget.isPrimary && !widget.isGhost ? null : bgColor,
              gradient: widget.isPrimary && !widget.isGhost
                  ? t.primaryGradient
                  : null,
              borderRadius: BorderRadius.circular(VibraSpacing.radiusFull),
              boxShadow: [
                if (widget.isPrimary && !widget.isGhost && !isActuallyDisabled)
                  t.cardShadow,
              ],
              border: widget.isGhost ? Border.all(color: t.borderStrong) : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(VibraSpacing.radiusFull),
                onTap: isActuallyDisabled ? null : widget.onPressed,
                onHighlightChanged: (h) => setState(() => _isPressed = h),
                splashColor: fgColor.withValues(alpha: 0.1),
                hoverColor: fgColor.withValues(alpha: 0.08),
                focusColor: fgColor.withValues(alpha: 0.12),
                highlightColor: fgColor.withValues(alpha: 0.10),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: VibraSpacing.xxxl,
                      vertical: VibraSpacing.lg,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.isLoading)
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: fgColor,
                            ),
                          )
                        else ...[
                          if (widget.icon != null) ...[
                            Icon(widget.icon, color: fgColor, size: 20),
                            const SizedBox(width: VibraSpacing.sm),
                          ],
                          Flexible(
                            child: Text(
                              widget.text,
                              textAlign: TextAlign.center,
                              style: VibraTextStyles.labelLarge.copyWith(
                                color: fgColor,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
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
    );
  }
}
