import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/vibra_colors.dart';
import 'package:vibra/l10n/app_localizations.dart';
import '../../core/theme/vibra_text_styles.dart';

class VibraArcGauge extends StatelessWidget {
  final double score; // 0.0 a 1.0
  final double size;
  final double strokeWidth;

  const VibraArcGauge({
    super.key,
    required this.score,
    this.size = 200,
    this.strokeWidth = 12,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: score),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
        builder: (context, animatedScore, child) {
          return CustomPaint(
            painter: _ArcGaugePainter(
              score: animatedScore,
              strokeWidth: strokeWidth,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(animatedScore * 100).toInt()}%',
                    style: VibraTextStyles.scoreXL.copyWith(
                      color: VibraColors.getMatchColor(animatedScore),
                      shadows: [
                        Shadow(
                          color: VibraColors.getMatchColor(animatedScore).withValues(alpha: 0.5),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.matchScore,
                    style: VibraTextStyles.labelSmall.copyWith(
                      letterSpacing: 2.0,
                      color: VibraColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ArcGaugePainter extends CustomPainter {
  final double score;
  final double strokeWidth;

  _ArcGaugePainter({
    required this.score,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    
    const startAngle = pi * 0.75;
    const maxSweepAngle = pi * 1.5;
    
    final trackPaint = Paint()
      ..color = VibraColors.surfaceVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
      
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      maxSweepAngle,
      false,
      trackPaint,
    );
    
    final sweepAngle = maxSweepAngle * score;
    
    // Colore dinamico in base allo score
    final color = VibraColors.getMatchColor(score);
    
    final rect = Rect.fromCircle(center: center, radius: radius);
    
    final scorePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
      
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    if (sweepAngle > 0) {
      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle,
        false,
        glowPaint,
      );
      
      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle,
        false,
        scorePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ArcGaugePainter oldDelegate) {
    return oldDelegate.score != score;
  }
}
