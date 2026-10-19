import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/vibra_motion.dart';
import '../../core/theme/vibra_theme_tokens.dart';

/// Il segno ricorrente di Vibra: due onde morbide, sfasate e a tinta unica.
///
/// Può essere una firma piccola, un meter o una texture ampia senza introdurre
/// un nuovo asset o un'ulteriore dipendenza.
class VibraSignalWave extends StatefulWidget {
  const VibraSignalWave({
    super.key,
    this.height = 48,
    this.color,
    this.secondaryColor,
    this.strokeWidth = 2,
    this.amplitude = 12,
    this.animate = false,
    this.opacity = 1,
    this.semanticsLabel,
  });

  final double height;
  final Color? color;
  final Color? secondaryColor;
  final double strokeWidth;
  final double amplitude;
  final bool animate;
  final double opacity;
  final String? semanticsLabel;

  @override
  State<VibraSignalWave> createState() => _VibraSignalWaveState();
}

class _VibraSignalWaveState extends State<VibraSignalWave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: VibraMotion.waveIdle,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant VibraSignalWave oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate != widget.animate) {
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (widget.animate &&
        !disableAnimations &&
        TickerMode.valuesOf(context).enabled) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color ?? context.vibraTokens.accentPrimary;
    final wave = SizedBox(
      width: double.infinity,
      height: widget.height,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _VibraSignalWavePainter(
            color: effectiveColor,
            secondaryColor: widget.secondaryColor ?? effectiveColor,
            animation: _controller,
            strokeWidth: widget.strokeWidth,
            amplitude: widget.amplitude,
            opacity: widget.opacity,
          ),
        ),
      ),
    );

    if (widget.semanticsLabel == null) return ExcludeSemantics(child: wave);
    return Semantics(label: widget.semanticsLabel, image: true, child: wave);
  }
}

class VibraWaveBackdrop extends StatelessWidget {
  const VibraWaveBackdrop({
    required this.child,
    super.key,
    this.color,
    this.height = 150,
    this.opacity = 0.34,
    this.alignment = Alignment.bottomRight,
  });

  final Widget child;
  final Color? color;
  final double height;
  final double opacity;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? context.vibraTokens.accentPrimary;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: -36,
          right: -36,
          top: alignment.y < 0 ? -height * 0.25 : null,
          bottom: alignment.y >= 0 ? -height * 0.25 : null,
          child: IgnorePointer(
            child: Opacity(
              opacity: opacity,
              child: VibraSignalWave(
                height: height,
                color: effectiveColor,
                secondaryColor: effectiveColor,
                amplitude: height * 0.16,
                strokeWidth: 2,
                animate: true,
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _VibraSignalWavePainter extends CustomPainter {
  _VibraSignalWavePainter({
    required this.color,
    required this.secondaryColor,
    required this.animation,
    required this.strokeWidth,
    required this.amplitude,
    required this.opacity,
  }) : super(repaint: animation);

  final Color color;
  final Color secondaryColor;
  final Animation<double> animation;
  final double strokeWidth;
  final double amplitude;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final phase = animation.value * math.pi * 2;
    final primaryPath = Path();
    final secondaryPath = Path();
    final steps = math.max(28, (size.width / 4).round());

    for (var index = 0; index <= steps; index++) {
      final x = size.width * index / steps;
      final normalized = index / steps;
      final envelope = 0.45 + (math.sin(normalized * math.pi) * 0.55);
      final primaryY =
          size.height / 2 +
          math.sin(normalized * math.pi * 3 + phase) * amplitude * envelope;
      final secondaryY =
          size.height / 2 +
          math.sin(normalized * math.pi * 3 + phase + 1.25) *
              amplitude *
              0.62 *
              envelope;

      if (index == 0) {
        primaryPath.moveTo(x, primaryY);
        secondaryPath.moveTo(x, secondaryY);
      } else {
        primaryPath.lineTo(x, primaryY);
        secondaryPath.lineTo(x, secondaryY);
      }
    }

    final primaryPaint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final secondaryPaint = Paint()
      ..color = secondaryColor.withValues(alpha: opacity * 0.48)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(primaryPath, primaryPaint);
    canvas.drawPath(secondaryPath, secondaryPaint);
  }

  @override
  bool shouldRepaint(covariant _VibraSignalWavePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.animation != animation ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.amplitude != amplitude ||
        oldDelegate.opacity != opacity;
  }
}
