import 'package:flutter/material.dart';

/// VIBRA motion tokens.
///
/// Signature: a signal compresses on touch and settles back slowly —
/// fast in, soft out. Every non-essential animation must go through
/// [durationFor] so it collapses to zero when the system asks for reduced
/// motion.
class VibraMotion {
  VibraMotion._();

  // ── Curves ───────────────────────────────────────────────
  /// House curve: quick attack, long gentle release.
  static const Curve signalCurve = Cubic(0.22, 1.0, 0.36, 1.0);
  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve emphasized = Cubic(0.2, 0.0, 0.0, 1.0);

  // ── Durations ────────────────────────────────────────────
  static const Duration tapIn = Duration(milliseconds: 90);
  static const Duration tapOut = Duration(milliseconds: 220);
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration medium = Duration(milliseconds: 260);
  static const Duration reveal = Duration(milliseconds: 360);
  static const Duration page = Duration(milliseconds: 380);
  static const Duration score = Duration(milliseconds: 900);
  static const Duration logo = Duration(milliseconds: 900);
  static const Duration waveIdle = Duration(seconds: 5);

  /// Delay between items in a staggered list entrance.
  static const Duration stagger = Duration(milliseconds: 45);

  /// Touch feedback scale for pressable surfaces.
  static const double pressedScale = 0.97;

  /// Whether the platform requested reduced motion.
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  /// Returns [Duration.zero] when the system requests reduced motion.
  /// Use for every animation that is not essential feedback.
  static Duration durationFor(BuildContext context, Duration duration) =>
      reduced(context) ? Duration.zero : duration;

  /// Staggered entrance delay for list item [index], capped so long lists
  /// never wait visibly.
  static Duration staggerFor(BuildContext context, int index) =>
      reduced(context) ? Duration.zero : stagger * index.clamp(0, 8);
}
