import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'vibra_colors.dart';

/// Tipografia del brand Vibra.
/// - Syne: titoli bold e moderni
/// - Inter: body text leggibile
/// - JetBrains Mono: dati numerici, score, percentuali
class VibraTextStyles {
  VibraTextStyles._();

  // ── Display (Syne) ───────────────────────────────────────
  /// Titolo display grande — per schermate principali.
  static TextStyle displayLarge = GoogleFonts.syne(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: VibraColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  /// Titolo display medio.
  static TextStyle displayMedium = GoogleFonts.syne(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: VibraColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.25,
  );

  /// Titolo display piccolo.
  static TextStyle displaySmall = GoogleFonts.syne(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: VibraColors.textPrimary,
    height: 1.3,
  );

  // ── Headlines (Syne) ─────────────────────────────────────
  static TextStyle headlineLarge = GoogleFonts.syne(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: VibraColors.textPrimary,
    height: 1.3,
  );

  static TextStyle headlineMedium = GoogleFonts.syne(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: VibraColors.textPrimary,
    height: 1.3,
  );

  static TextStyle headlineSmall = GoogleFonts.syne(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: VibraColors.textPrimary,
    height: 1.35,
  );

  // ── Titles (Syne) ────────────────────────────────────────
  static TextStyle titleLarge = GoogleFonts.syne(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: VibraColors.textPrimary,
    height: 1.35,
  );

  static TextStyle titleMedium = GoogleFonts.syne(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: VibraColors.textPrimary,
    height: 1.4,
  );

  static TextStyle titleSmall = GoogleFonts.syne(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: VibraColors.textPrimary,
    height: 1.4,
  );

  // ── Body (Inter) ─────────────────────────────────────────
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: VibraColors.textPrimary,
    height: 1.5,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: VibraColors.textPrimary,
    height: 1.5,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: VibraColors.textSecondary,
    height: 1.4,
  );

  // ── Labels (Inter) ───────────────────────────────────────
  static TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: VibraColors.textPrimary,
    height: 1.3,
  );

  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: VibraColors.textSecondary,
    height: 1.3,
  );

  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: VibraColors.textSecondary,
    letterSpacing: 0.5,
    height: 1.3,
  );

  // ── Dati / Score (JetBrains Mono) ────────────────────────
  /// Per score numerici giganti (es: "94%" centrale).
  static TextStyle scoreXL = GoogleFonts.jetBrainsMono(
    fontSize: 56,
    fontWeight: FontWeight.w800,
    color: VibraColors.matchHigh,
    letterSpacing: -2.0,
  );

  /// Per score numerici grandi (es: "94%").
  static TextStyle scoreLarge = GoogleFonts.jetBrainsMono(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: VibraColors.matchHigh,
  );

  /// Per score numerici medi.
  static TextStyle scoreMedium = GoogleFonts.jetBrainsMono(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: VibraColors.matchHigh,
  );

  /// Per dati e metriche piccoli.
  static TextStyle scoreSmall = GoogleFonts.jetBrainsMono(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: VibraColors.textSecondary,
  );

  /// Crea un [TextTheme] completo per Material 3.
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
