import 'package:flutter/material.dart';
import '../../core/theme/vibra_colors.dart';
import '../../core/theme/vibra_shadows.dart';
import '../../core/theme/vibra_spacing.dart';

class VibraNeonMapPin extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  const VibraNeonMapPin({
    super.key,
    required this.icon,
    this.color = VibraColors.accent,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: VibraSpacing.animNormal,
        width: isSelected ? 48 : 36,
        height: isSelected ? 48 : 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.2),
          border: Border.all(
            color: color,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            if (isSelected) VibraShadows.neonGlow(color, intensity: 0.35),
            VibraShadows.buttonElevation,
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            color: color,
            size: isSelected ? 24 : 18,
          ),
        ),
      ),
    );
  }
}
