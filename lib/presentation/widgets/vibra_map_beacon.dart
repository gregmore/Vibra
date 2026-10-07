import 'package:flutter/material.dart';

import '../../core/theme/vibra_motion.dart';
import '../../core/theme/vibra_theme_tokens.dart';

/// Marker proprietario, monocromatico e leggibile anche senza colori per genere.
class VibraMapBeacon extends StatefulWidget {
  const VibraMapBeacon({super.key, this.selected = false, this.size = 42});

  final bool selected;
  final double size;

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
    )..addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant VibraMapBeacon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) _sync();
  }

  void _sync() {
    final disable = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (widget.selected && !disable) {
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
    final diameter = widget.size;
    return SizedBox(
      width: diameter + 18,
      height: diameter + 18,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.selected)
            CustomPaint(
              size: Size.square(diameter + 18),
              painter: _BeaconEchoPainter(
                progress: _controller.value,
                color: t.accentPrimary,
              ),
            ),
          Container(
            width: diameter,
            height: diameter,
            decoration: BoxDecoration(
              color: t.textPrimary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: diameter * 0.42,
                height: diameter * 0.42,
                decoration: BoxDecoration(
                  color: t.accentPrimary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.music_note_rounded,
                  size: diameter * 0.28,
                  color: t.onAccent,
                ),
              ),
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
      final radius = size.shortestSide * (0.18 + value * 0.34);
      final paint = Paint()
        ..color = color.withValues(alpha: (1 - value) * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BeaconEchoPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
