import 'package:flutter/material.dart';
import '../../core/theme/vibra_colors.dart';
import '../../core/theme/vibra_shadows.dart';
import '../../core/theme/vibra_text_styles.dart';
import '../../core/theme/vibra_spacing.dart';

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
    final isActuallyDisabled = widget.isDisabled || widget.isLoading;

    Color bgColor;
    if (widget.isGhost) {
      bgColor = Colors.transparent;
    } else {
      bgColor = widget.isPrimary
          ? Colors.transparent
          : VibraColors.surfaceVariant;
    }

    final fgColor = widget.isGhost
        ? VibraColors.accent
        : (widget.isPrimary ? Colors.white : VibraColors.textPrimary);

    final glow = widget.isPrimary && !widget.isGhost && !isActuallyDisabled
        ? VibraShadows.neonGlow(VibraColors.primary, intensity: 0.5)
        : null;

    return AnimatedScale(
      scale: _isPressed ? 0.96 : 1.0,
      duration: VibraSpacing.animFast,
      child: Opacity(
        opacity: widget.isDisabled ? 0.4 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: widget.isPrimary && !widget.isGhost ? null : bgColor,
            gradient: widget.isPrimary && !widget.isGhost
                ? VibraColors.primaryGradient
                : null,
            borderRadius: BorderRadius.circular(VibraSpacing.radiusFull),
            boxShadow: [
              ?glow,
              if (widget.isPrimary && !widget.isGhost && !isActuallyDisabled)
                VibraShadows.buttonElevation,
            ],
            border: widget.isGhost
                ? Border.all(color: VibraColors.accent.withValues(alpha: 0.5))
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(VibraSpacing.radiusFull),
              onTap: isActuallyDisabled ? null : widget.onPressed,
              onHighlightChanged: (h) => setState(() => _isPressed = h),
              splashColor: fgColor.withValues(alpha: 0.1),
              highlightColor: Colors.transparent,
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
                      Text(
                        widget.text,
                        style: VibraTextStyles.labelLarge.copyWith(
                          color: fgColor,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
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
    );
  }
}
