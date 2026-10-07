import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Due sole voci: Syne rende Vibra riconoscibile, Inter rende tutto leggibile.
class VibraTextStyles {
  VibraTextStyles._();

  static const double minimumBodyFontSize = 12;
  static const double minimumLabelFontSize = 11;
  static const double paragraphLineHeight = 1.5;

  static TextStyle displayLarge = GoogleFonts.syne(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -2.0,
    height: 0.96,
  );
  static TextStyle displayMedium = GoogleFonts.syne(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.2,
    height: 1.02,
  );
  static TextStyle displaySmall = GoogleFonts.syne(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
    height: 1.08,
  );

  static TextStyle headlineLarge = GoogleFonts.syne(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.12,
  );
  static TextStyle headlineMedium = GoogleFonts.syne(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.35,
    height: 1.18,
  );
  static TextStyle headlineSmall = GoogleFonts.syne(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    height: 1.22,
  );

  static TextStyle titleLarge = GoogleFonts.syne(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.22,
  );
  static TextStyle titleMedium = GoogleFonts.syne(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.28,
  );
  static TextStyle titleSmall = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: paragraphLineHeight,
  );
  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: paragraphLineHeight,
  );
  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: minimumBodyFontSize,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );
  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );
  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: minimumLabelFontSize,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.7,
    height: 1.25,
  );

  // Gli score usano il display del brand, non un font tecnico separato.
  static TextStyle scoreXL = displayLarge.copyWith(
    fontSize: 64,
    letterSpacing: -3,
  );
  static TextStyle scoreLarge = displayMedium.copyWith(fontSize: 30);
  static TextStyle scoreMedium = displaySmall.copyWith(fontSize: 20);
  static TextStyle scoreSmall = labelLarge;

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
