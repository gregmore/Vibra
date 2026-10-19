import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../core/theme/vibra_theme_tokens.dart';

/// Two continuous sound waves form a V, shared with the native app icons.
class VibraLogo extends StatelessWidget {
  const VibraLogo({
    super.key,
    this.width = 100,
    this.height = 100,
    this.strokeWidth = 6.0,
    this.gradient,
    this.animate = false,
  });

  final double width;
  final double height;
  final double strokeWidth;
  final Gradient? gradient;
  final bool animate;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: VibraLogoPainter(
          strokeWidth: strokeWidth,
          gradient:
              gradient ??
              LinearGradient(
                colors: [
                  context.vibraTokens.accentPrimary,
                  context.vibraTokens.accentPrimary,
                ],
              ),
        ),
      ),
    ),
  );
}

/// Public so export tooling uses exactly the same geometry as the application.
class VibraLogoPainter extends CustomPainter {
  const VibraLogoPainter({required this.strokeWidth, required this.gradient});

  final double strokeWidth;
  final Gradient gradient;

  static Path get signalPath => Path()
    ..moveTo(18, 27)
    ..cubicTo(30, 27, 34, 42, 41, 59)
    ..cubicTo(45, 69, 47, 74, 52, 74)
    ..cubicTo(58, 74, 62, 56, 67, 42)
    ..cubicTo(71, 31, 76, 27, 83, 27)
    ..moveTo(18, 46)
    ..cubicTo(28, 46, 32, 54, 37, 66)
    ..cubicTo(43, 82, 48, 87, 55, 87)
    ..cubicTo(64, 87, 69, 71, 74, 60)
    ..cubicTo(78, 50, 82, 46, 88, 46);

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height);
    if (side <= 0) return;
    canvas.save();
    canvas.translate((size.width - side) / 2, (size.height - side) / 2);
    canvas.scale(side / 100);
    // Optical centring: the wave's lower turn otherwise sits below the square.
    canvas.translate(-3, -7);
    final paint = Paint()
      ..shader = gradient.createShader(const Rect.fromLTWH(0, 0, 100, 100))
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.min(strokeWidth * 100 / side, 10)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(signalPath, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant VibraLogoPainter oldDelegate) =>
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.gradient != gradient;
}
