import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/vibra_spacing.dart';
import '../../core/theme/vibra_theme_tokens.dart';
import '../../domain/entities/same_frequency.dart';
import '../../l10n/app_localizations.dart';
import 'common/vibra_avatar.dart';

/// MUSIC RADAR map (docs/music-radar.md): the compatible people around me
/// drawn as a radar of **musical affinity**, not of places. The distance
/// from the centre is the affinity (closer = more in common) and the angle
/// comes from a hash of the user id, so the picture is stable but carries
/// no location: the server returns no coordinates, distances or order by
/// distance, and this widget is given none.
class MusicRadarMap extends StatelessWidget {
  const MusicRadarMap({
    required this.people,
    this.onTapPerson,
    this.maxPeople = 12,
    super.key,
  });

  final List<FrequencyCandidate> people;
  final ValueChanged<FrequencyCandidate>? onTapPerson;

  /// More dots than this stop being readable; the list below shows all.
  final int maxPeople;

  /// Position in the unit circle for a person: radius from affinity only,
  /// angle from the id only.
  static Offset placement(String userId, int compatibility) {
    final affinity = compatibility.clamp(0, 100) / 100;
    final radius = 0.24 + 0.68 * (1 - affinity);
    final angle = _hash(userId) / 0xffffffff * 2 * math.pi;
    return Offset(math.cos(angle) * radius, math.sin(angle) * radius);
  }

  /// Centres of the avatars in a square of [size]: each person keeps the
  /// distance from the centre given by their affinity; only the angle is
  /// turned, in small steps, when two would overlap.
  static List<Offset> layout(
    List<FrequencyCandidate> people,
    double size,
    double dotRadius,
  ) {
    final centre = Offset(size / 2, size / 2);
    final reach = size / 2 - dotRadius - 2;
    final placed = <Offset>[];
    for (final p in people) {
      final base = placement(p.userId, p.compatibility);
      final r = base.distance * reach;
      final angle = math.atan2(base.dy, base.dx);
      var best = centre + Offset(math.cos(angle) * r, math.sin(angle) * r);
      for (var step = 0; step < 24; step++) {
        final a = angle + (step.isEven ? 1 : -1) * ((step + 1) ~/ 2) * 0.27;
        final candidate = centre + Offset(math.cos(a) * r, math.sin(a) * r);
        if (placed.every((o) => (o - candidate).distance >= dotRadius * 2.1)) {
          best = candidate;
          break;
        }
      }
      placed.add(best);
    }
    return placed;
  }

  /// FNV-1a, 32 bit: stable across runs and platforms.
  static int _hash(String s) {
    var h = 0x811c9dc5;
    for (final unit in s.codeUnits) {
      h ^= unit;
      h = (h * 0x01000193) & 0xffffffff;
    }
    return h;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final shown =
        ([...people]
              ..sort((a, b) => b.compatibility.compareTo(a.compatibility)))
            .take(maxPeople)
            .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, c) {
            final size = math.min(c.maxWidth, 360.0);
            const dot = 18.0;
            final centres = layout(shown, size, dot);
            // Painted last = on top: the strongest match stays fully visible.
            final order = [for (var i = shown.length - 1; i >= 0; i--) i];
            return Center(
              child: Semantics(
                container: true,
                label: l10n.musicRadarMapSemantics(shown.length),
                child: SizedBox.square(
                  dimension: size,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _RadarPainter(
                            ring: t.borderDefault,
                            sweep: t.accentPrimary,
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: t.accentPrimary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      for (final i in order)
                        Positioned(
                          left: centres[i].dx - dot,
                          top: centres[i].dy - dot,
                          child: Semantics(
                            button: onTapPerson != null,
                            label: l10n.musicRadarMapPerson(
                              shown[i].name,
                              shown[i].compatibility,
                            ),
                            excludeSemantics: true,
                            child: GestureDetector(
                              onTap: onTapPerson == null
                                  ? null
                                  : () => onTapPerson!(shown[i]),
                              child: VibraAvatar(
                                imageUrl: shown[i].avatarUrl,
                                name: shown[i].name,
                                radius: dot,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: VibraSpacing.sm),
        Text(
          l10n.musicRadarMapNote,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: t.textMuted),
        ),
      ],
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({required this.ring, required this.sweep});

  final Color ring;
  final Color sweep;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [sweep.withValues(alpha: .14), sweep.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    final line = Paint()
      ..color = ring
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final f in const [.33, .66, 1.0]) {
      canvas.drawCircle(c, r * f - 1, line);
    }
    canvas.drawLine(Offset(c.dx - r, c.dy), Offset(c.dx + r, c.dy), line);
    canvas.drawLine(Offset(c.dx, c.dy - r), Offset(c.dx, c.dy + r), line);
  }

  @override
  bool shouldRepaint(_RadarPainter old) =>
      old.ring != ring || old.sweep != sweep;
}
