import 'package:flutter/material.dart';

/// VIBRA typography: one geometric sans (Inter), tight at display sizes,
/// open at reading sizes. Hierarchy comes from size and weight, never from
/// a second decorative face.
///
/// Scale (logical px):
/// * Display 32–40 · H1 28 · H2 24 · H3 20
/// * Body 15–16 · Secondary 13–14 · Caption 11–12
///
/// Every style is resolved through the platform text scaler, so dynamic type
/// is respected automatically.
class VibraTextStyles {
  VibraTextStyles._();

  static const String fontFamily = 'Inter';

  static const double minimumBodyFontSize = 12;
  static const double minimumLabelFontSize = 11;
  static const double paragraphLineHeight = 1.45;

  // ── Display ───────────────────────────────────────────────
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 40,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.6,
    height: 1.05,
  );
  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 34,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.2,
    height: 1.08,
  );
  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
    height: 1.1,
  );

  // ── Headings ──────────────────────────────────────────────
  /// Heading 1 — 28 px.
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
    height: 1.15,
  );

  /// Heading 2 — 24 px.
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    height: 1.2,
  );

  /// Heading 3 — 20 px.
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    height: 1.25,
  );

  // ── Titles (cards, list rows) ─────────────────────────────
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.25,
  );
  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
  );
  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.3,
  );

  // ── Body ──────────────────────────────────────────────────
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.1,
    height: paragraphLineHeight,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.05,
    height: paragraphLineHeight,
  );

  /// Secondary copy — 13 px.
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  // ── Labels ────────────────────────────────────────────────
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.25,
  );
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  /// Caption / eyebrow — 11 px, tracked.
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: minimumLabelFontSize,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.9,
    height: 1.25,
  );

  /// Caption — 12 px, untracked.
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: minimumBodyFontSize,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  // ── Numerals (scores, stats) ──────────────────────────────
  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];
  static final TextStyle scoreXL = displayLarge.copyWith(
    fontSize: 56,
    letterSpacing: -2.4,
    height: 1,
    fontFeatures: _tabular,
  );
  static final TextStyle scoreLarge = displayMedium.copyWith(
    fontSize: 30,
    height: 1,
    fontFeatures: _tabular,
  );
  static final TextStyle scoreMedium = headlineSmall.copyWith(
    height: 1,
    fontFeatures: _tabular,
  );
  static final TextStyle scoreSmall = labelLarge.copyWith(
    fontWeight: FontWeight.w700,
    fontFeatures: _tabular,
  );

  static TextTheme get textTheme => const TextTheme(
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
