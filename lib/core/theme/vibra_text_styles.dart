import 'package:flutter/material.dart';

/// Due sole voci: Syne rende Vibra riconoscibile, Inter rende tutto leggibile.
class VibraTextStyles {
  VibraTextStyles._();

  static const double minimumBodyFontSize = 12;
  static const double minimumLabelFontSize = 11;
  static const double paragraphLineHeight = 1.5;

  static final TextStyle displayLarge = const TextStyle(
    fontFamily: 'Syne',
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -2.0,
    height: 0.96,
  );
  static final TextStyle displayMedium = const TextStyle(
    fontFamily: 'Syne',
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.2,
    height: 1.02,
  );
  static final TextStyle displaySmall = const TextStyle(
    fontFamily: 'Syne',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
    height: 1.08,
  );

  static final TextStyle headlineLarge = const TextStyle(
    fontFamily: 'Syne',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.12,
  );
  static final TextStyle headlineMedium = const TextStyle(
    fontFamily: 'Syne',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.35,
    height: 1.18,
  );
  static final TextStyle headlineSmall = const TextStyle(
    fontFamily: 'Syne',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    height: 1.22,
  );

  static final TextStyle titleLarge = const TextStyle(
    fontFamily: 'Syne',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.22,
  );
  static final TextStyle titleMedium = const TextStyle(
    fontFamily: 'Syne',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.28,
  );
  static final TextStyle titleSmall = const TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static final TextStyle bodyLarge = const TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: paragraphLineHeight,
  );
  static final TextStyle bodyMedium = const TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: paragraphLineHeight,
  );
  static final TextStyle bodySmall = const TextStyle(
    fontFamily: 'Inter',
    fontSize: minimumBodyFontSize,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static final TextStyle labelLarge = const TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );
  static final TextStyle labelMedium = const TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );
  static final TextStyle labelSmall = const TextStyle(
    fontFamily: 'Inter',
    fontSize: minimumLabelFontSize,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.7,
    height: 1.25,
  );

  // Gli score usano il display del brand, non un font tecnico separato.
  static final TextStyle scoreXL = displayLarge.copyWith(
    fontSize: 64,
    letterSpacing: -3,
  );
  static final TextStyle scoreLarge = displayMedium.copyWith(fontSize: 30);
  static final TextStyle scoreMedium = displaySmall.copyWith(fontSize: 20);
  static final TextStyle scoreSmall = labelLarge;

  static TextTheme get textTheme => TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
}
