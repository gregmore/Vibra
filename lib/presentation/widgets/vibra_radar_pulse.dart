import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/vibra_colors.dart';

class VibraRadarPulse extends StatelessWidget {
  final double size;
  final Color color;
  final Widget? child;

  const VibraRadarPulse({
    super.key,
    this.size = 200,
    this.color = VibraColors.primary,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isTest = WidgetsBinding.instance.runtimeType.toString().contains('Test');

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.05),
              border: Border.all(
                color: color.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
          ).animate(onPlay: isTest ? null : (controller) => controller.repeat())
           .scale(begin: const Offset(0.2, 0.2), end: const Offset(1.0, 1.0), duration: 2500.ms, curve: Curves.easeOut)
           .fadeOut(duration: 2500.ms, curve: Curves.easeOut),
           
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.05),
              border: Border.all(
                color: color.withValues(alpha: 0.25),
                width: 2,
              ),
            ),
          ).animate(onPlay: isTest ? null : (controller) => controller.repeat())
           .scale(begin: const Offset(0.2, 0.2), end: const Offset(1.0, 1.0), duration: 2500.ms, delay: 1250.ms, curve: Curves.easeOut)
           .fadeOut(duration: 2500.ms, delay: 1250.ms, curve: Curves.easeOut),
           
          ?child,
        ],
      ),
    );
  }
}
