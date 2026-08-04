import 'package:flutter/material.dart';
import '../../../core/theme/vibra_colors.dart';

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
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _VibraLogoPainter(
          strokeWidth: strokeWidth,
          gradient: gradient ??
              const LinearGradient(
                colors: [VibraColors.primary, VibraColors.accent],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
        ),
      ),
    );
  }
}

class _VibraLogoPainter extends CustomPainter {
  _VibraLogoPainter({
    required this.strokeWidth,
    required this.gradient,
  });

  final double strokeWidth;
  final Gradient gradient;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    // Funzione helper per mappare le coordinate 0-100 alla dimensione effettiva
    Offset pt(double x, double y) {
      return Offset(x / 100.0 * size.width, y / 100.0 * size.height);
    }

    // 1. Battito esterno (sinistra)
    path.moveTo(pt(5, 50).dx, pt(5, 50).dy);
    path.lineTo(pt(15, 50).dx, pt(15, 50).dy);
    path.lineTo(pt(21, 40).dx, pt(21, 40).dy);
    path.lineTo(pt(28, 62).dx, pt(28, 62).dy);
    path.lineTo(pt(38, 22).dx, pt(38, 22).dy); // Picco alto
    path.lineTo(pt(52, 78).dx, pt(52, 78).dy); // Valle profonda
    path.lineTo(pt(58, 53).dx, pt(58, 53).dy); // Si unisce al cuore

    // 2. Contorno del Cuore Geometrico (destra)
    // Partiamo dal punto di intersezione o da un vertice
    path.moveTo(pt(55, 50).dx, pt(55, 50).dy);
    path.lineTo(pt(55, 40).dx, pt(55, 40).dy); // Bordo sinistro
    path.lineTo(pt(65, 30).dx, pt(65, 30).dy); // Tetto sinistro
    path.lineTo(pt(75, 40).dx, pt(75, 40).dy); // Avvallamento centrale
    path.lineTo(pt(85, 30).dx, pt(85, 30).dy); // Tetto destro
    path.lineTo(pt(95, 40).dx, pt(95, 40).dy); // Spigolo in alto a destra
    path.lineTo(pt(95, 50).dx, pt(95, 50).dy); // Bordo destro
    path.lineTo(pt(75, 70).dx, pt(75, 70).dy); // Punta inferiore
    path.lineTo(pt(55, 50).dx, pt(55, 50).dy); // Ritorno al bordo sinistro

    // 3. Battito interno (dentro il cuore)
    path.moveTo(pt(55, 50).dx, pt(55, 50).dy);
    path.lineTo(pt(62, 42).dx, pt(62, 42).dy);
    path.lineTo(pt(70, 55).dx, pt(70, 55).dy);
    path.lineTo(pt(78, 42).dx, pt(78, 42).dy);
    path.lineTo(pt(85, 50).dx, pt(85, 50).dy);
    path.lineTo(pt(95, 50).dx, pt(95, 50).dy);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _VibraLogoPainter oldDelegate) {
    return oldDelegate.strokeWidth != strokeWidth || oldDelegate.gradient != gradient;
  }
}
