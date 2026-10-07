import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/vibra_text_styles.dart';
import '../../core/theme/vibra_theme_tokens.dart';
import 'vibra_signal_wave.dart';

/// Scanner musicale usato durante la ricerca di nuove affinità.
///
/// L'animazione è puramente decorativa e si arresta quando il sistema richiede
/// la riduzione del movimento.
class VibraMatchScanner extends StatefulWidget {
  const VibraMatchScanner({
    required this.title,
    required this.subtitle,
    super.key,
  });

  final String title;
  final String subtitle;

  @override
  State<VibraMatchScanner> createState() => _VibraMatchScannerState();
}

class _VibraMatchScannerState extends State<VibraMatchScanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) {
      _controller
        ..stop()
        ..value = .32;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;

    return Semantics(
      liveRegion: true,
      label: '${widget.title}. ${widget.subtitle}',
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => SizedBox.square(
                dimension: 278,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            t.accentPrimary.withValues(alpha: .18),
                            t.accentPrimary.withValues(alpha: .04),
                            Colors.transparent,
                          ],
                          stops: const [.05, .55, 1],
                        ),
                      ),
                      child: const SizedBox.expand(),
                    ),
                    CustomPaint(
                      size: const Size.square(278),
                      painter: _ScannerPainter(
                        progress: _controller.value,
                        accent: t.accentPrimary,
                        secondary: t.accentSecondary,
                        border: t.borderStrong,
                      ),
                    ),
                    _OrbitNode(
                      progress: _controller.value,
                      radius: 101,
                      phase: .08,
                      size: 32,
                      color: t.accentSecondary,
                      icon: Icons.music_note_rounded,
                    ),
                    _OrbitNode(
                      progress: -_controller.value * .72,
                      radius: 72,
                      phase: .62,
                      size: 27,
                      color: t.accentPrimary,
                      icon: Icons.favorite_rounded,
                    ),
                    Transform.scale(
                      scale:
                          1 + math.sin(_controller.value * math.pi * 2) * .045,
                      child: Container(
                        width: 104,
                        height: 104,
                        padding: const EdgeInsets.symmetric(horizontal: 17),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: t.primaryGradient,
                          border: Border.all(
                            color: t.onAccent.withValues(alpha: .28),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: t.accentPrimary.withValues(alpha: .3),
                              blurRadius: 34,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: VibraSignalWave(
                          height: 42,
                          color: t.onAccent,
                          secondaryColor: t.onAccent,
                          amplitude: 9,
                          strokeWidth: 2.5,
                          animate: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: VibraTextStyles.headlineMedium.copyWith(
                color: t.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 310),
              child: Text(
                widget.subtitle,
                textAlign: TextAlign.center,
                style: VibraTextStyles.bodyMedium.copyWith(
                  color: t.textSecondary,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _SearchingDots(animation: _controller),
          ],
        ),
      ),
    );
  }
}

class _OrbitNode extends StatelessWidget {
  const _OrbitNode({
    required this.progress,
    required this.radius,
    required this.phase,
    required this.size,
    required this.color,
    required this.icon,
  });

  final double progress;
  final double radius;
  final double phase;
  final double size;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final angle = (progress + phase) * math.pi * 2;
    return Transform.translate(
      offset: Offset(math.cos(angle) * radius, math.sin(angle) * radius),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: context.vibraTokens.surfaceElevated,
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: .72)),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: .24), blurRadius: 12),
          ],
        ),
        child: Icon(icon, size: size * .48, color: color),
      ),
    );
  }
}

class _SearchingDots extends StatelessWidget {
  const _SearchingDots({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          final wave =
              (math.sin((animation.value * math.pi * 2) - index * .85) + 1) / 2;
          return Container(
            width: 7,
            height: 7,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color.lerp(t.borderStrong, t.accentPrimary, wave),
            ),
          );
        }),
      ),
    );
  }
}

class _ScannerPainter extends CustomPainter {
  const _ScannerPainter({
    required this.progress,
    required this.accent,
    required this.secondary,
    required this.border,
  });

  final double progress;
  final Color accent;
  final Color secondary;
  final Color border;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    for (final radius in [72.0, 101.0, 132.0]) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = border.withValues(alpha: radius == 132 ? .38 : .56)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }

    final rect = Rect.fromCircle(center: center, radius: 132);
    canvas.drawArc(
      rect,
      progress * math.pi * 2,
      math.pi * .62,
      false,
      Paint()
        ..shader = SweepGradient(
          colors: [Colors.transparent, accent, secondary],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    final pulse = (progress * 3) % 1;
    canvas.drawCircle(
      center,
      54 + pulse * 76,
      Paint()
        ..color = accent.withValues(alpha: (1 - pulse) * .18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _ScannerPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.accent != accent ||
      oldDelegate.secondary != secondary ||
      oldDelegate.border != border;
}
