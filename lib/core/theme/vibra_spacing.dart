import 'package:flutter/material.dart';

/// Spatial tokens for VIBRA: spacing (4 px grid), radii, icon sizes,
/// elevation and touch targets. Single source of truth for every dimension.
class VibraSpacing {
  VibraSpacing._();

  // ── Spacing scale (multiples of 4) ───────────────────────
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 40.0;
  static const double giant = 48.0;
  static const double colossal = 64.0;

  /// Standard horizontal page gutter.
  static const double pagePadding = 20.0;

  /// Inner padding for cards.
  static const double cardPadding = 16.0;

  /// Vertical rhythm between home/profile sections.
  static const double sectionGap = 32.0;

  /// Space reserved under scrolling content for the floating navigation bar.
  static const double navBarClearance = 112.0;

  // ── Common insets ────────────────────────────────────────
  static const EdgeInsets pageHorizontal = EdgeInsets.symmetric(
    horizontal: pagePadding,
  );

  static const EdgeInsets cardAll = EdgeInsets.all(cardPadding);

  static const EdgeInsets cardMargin = EdgeInsets.symmetric(
    horizontal: pagePadding,
    vertical: sm,
  );

  // ── Radii (12–24 by hierarchy) ───────────────────────────
  /// Chips, inputs, small buttons.
  static const double radiusSmall = 12.0;

  /// Cards, list tiles, primary buttons.
  static const double radiusMedium = 16.0;

  /// Feature cards, media.
  static const double radiusLarge = 20.0;

  /// Hero cards, sheets, dialogs.
  static const double radiusXL = 24.0;
  static const double radiusXXL = 28.0;
  static const double radiusFull = 999.0;

  static final BorderRadius borderSmall = BorderRadius.circular(radiusSmall);
  static final BorderRadius borderMedium = BorderRadius.circular(radiusMedium);
  static final BorderRadius borderLarge = BorderRadius.circular(radiusLarge);
  static final BorderRadius borderXL = BorderRadius.circular(radiusXL);
  static final BorderRadius borderXXL = BorderRadius.circular(radiusXXL);
  static final BorderRadius borderFull = BorderRadius.circular(radiusFull);

  // ── Icons ────────────────────────────────────────────────
  static const double iconXs = 14.0;
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 32.0;

  // ── Touch targets & controls ─────────────────────────────
  static const double minTouchTarget = 48.0;
  static const double buttonHeight = 56.0;
  static const double buttonHeightCompact = 44.0;
  static const double inputHeight = 56.0;

  // ── Elevation (dark-first: separation by surface, not shadow) ──
  static const double elevationNone = 0;
  static const double elevationCard = 0;
  static const double elevationRaised = 2;
  static const double elevationOverlay = 8;

  // ── Animation durations (legacy names; see VibraMotion) ──
  static const Duration animFast = Duration(milliseconds: 180);
  static const Duration animNormal = Duration(milliseconds: 280);
  static const Duration animSlow = Duration(milliseconds: 420);
  static const Duration animEmphasis = Duration(milliseconds: 650);

  // ── Curves ───────────────────────────────────────────────
  static const Curve curveStandard = Curves.easeInOutCubic;
  static const Curve curveEmphasized = Curves.easeOutCubic;
  static const Curve curveDecelerate = Curves.decelerate;
  static const Curve curveBounce = Curves.easeOutBack;
}
