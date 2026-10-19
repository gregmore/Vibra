import 'package:flutter/material.dart';

/// La firma di movimento di Vibra: un segnale si comprime e torna piano.
class VibraMotion {
  VibraMotion._();

  static const Curve signalCurve = Cubic(0.22, 1.0, 0.36, 1.0);
  static const Duration tapIn = Duration(milliseconds: 90);
  static const Duration tapOut = Duration(milliseconds: 210);
  static const Duration reveal = Duration(milliseconds: 360);
  static const Duration page = Duration(milliseconds: 420);
  static const Duration score = Duration(milliseconds: 650);
  static const Duration waveIdle = Duration(seconds: 5);

  /// Restituisce una durata nulla quando il sistema richiede meno movimento.
  /// Usare questo helper per ogni animazione che non sia un feedback essenziale.
  static Duration durationFor(BuildContext context, Duration duration) {
    return MediaQuery.maybeOf(context)?.disableAnimations ?? false
        ? Duration.zero
        : duration;
  }
}
