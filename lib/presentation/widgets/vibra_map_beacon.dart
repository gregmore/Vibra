import 'package:flutter/material.dart';

import '../../core/theme/vibra_motion.dart';
import '../../core/theme/vibra_theme_tokens.dart';
import 'common/vibra_logo.dart';

/// VIBRA map marker.
///
/// A monochrome disc carrying the VIBRA mark — ink-on-white in the dark map,
/// white-on-ink in the light map. The selected marker turns violet, grows slightly and emits a slow
/// echo ring (static under reduced motion), so selection never relies on
/// colour alone.
class VibraMapBeacon extends StatefulWidget {
  const VibraMapBeacon({
    super.key,
    this.selected = false,
    this.size = 40,
    this.pulse = true,
  });

  final bool selected;
  final double size;

  /// Whether the selected marker emits its echo ring. Disable for static
  /// previews (e.g. Event Detail) so the frame can settle.
  final bool pulse;

  @override
  State<VibraMapBeacon> createState() => _VibraMapBeaconState();
}

class _VibraMapBeaconState extends State<VibraMapBeacon>
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
    _sync();
  }

  @override
  void didUpdateWidget(covariant VibraMapBeacon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected ||
        oldWidget.pulse != widget.pulse) {
      _sync();
    }
  }

  void _sync() {
    if (widget.selected && widget.pulse && !VibraMotion.reduced(context)) {
      _controller.repeat();
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
    final t = context.vibraTokens;
    final selected = widget.selected;
    final diameter = selected ? widget.size * 1.1 : widget.size * .9;
    final fill = selected ? t.accentFill : t.textPrimary;
    final mark = selected ? t.onAccent : t.backgroundPrimary;
    final ring = selected ? t.onAccent : t.backgroundPrimary;
    return SizedBox(
      width: widget.size + 18,
      height: widget.size + 18,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (selected)
            RepaintBoundary(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => CustomPaint(
                  size: Size.square(widget.size + 18),
                  painter: _BeaconEchoPainter(
                    progress: _controller.value,
                    color: t.accentPrimary,
                  ),
                ),
              ),
            ),
          AnimatedContainer(
            duration: VibraMotion.durationFor(context, VibraMotion.medium),
            curve: VibraMotion.signalCurve,
            width: diameter,
            height: diameter,
            decoration: BoxDecoration(
              color: fill,
              shape: BoxShape.circle,
              border: Border.all(color: ring, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: VibraLogo(
              width: diameter * .5,
              height: diameter * .5,
              color: mark,
            ),
          ),
        ],
      ),
    );
  }
}

class _BeaconEchoPainter extends CustomPainter {
  const _BeaconEchoPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    for (var index = 0; index < 2; index++) {
      final value = (progress + index * 0.5) % 1;
      final radius = size.shortestSide * (0.3 + value * 0.2);
      final paint = Paint()
        ..color = color.withValues(alpha: (1 - value) * 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BeaconEchoPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
