import 'package:flutter/material.dart';

/// Token di spaziatura, dimensioni e animazione del design system Vibra.
/// Punto unico di verità per tutte le misure spaziali e temporali.
class VibraSpacing {
  VibraSpacing._();

  // ── Spaziatura ───────────────────────────────────────────
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  /// Padding orizzontale standard per le pagine.
  static const double pagePadding = 20.0;

  /// Padding interno card.
  static const double cardPadding = 16.0;

  // ── EdgeInsets comuni ────────────────────────────────────
  static const EdgeInsets pageHorizontal = EdgeInsets.symmetric(
    horizontal: pagePadding,
  );

  static const EdgeInsets cardAll = EdgeInsets.all(cardPadding);

  static const EdgeInsets cardMargin = EdgeInsets.symmetric(
    horizontal: pagePadding,
    vertical: sm,
  );

  // ── Border Radius ────────────────────────────────────────
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 20.0;
  static const double radiusXL = 24.0;
  static const double radiusXXL = 28.0;
  static const double radiusFull = 999.0;

  /// Bordi arrotondati preconfezionati.
  static final BorderRadius borderSmall = BorderRadius.circular(radiusSmall);
  static final BorderRadius borderMedium = BorderRadius.circular(radiusMedium);
  static final BorderRadius borderLarge = BorderRadius.circular(radiusLarge);
  static final BorderRadius borderXL = BorderRadius.circular(radiusXL);
  static final BorderRadius borderXXL = BorderRadius.circular(radiusXXL);
  static final BorderRadius borderFull = BorderRadius.circular(radiusFull);

  // ── Durate animazione ────────────────────────────────────
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 500);
  static const Duration animEmphasis = Duration(milliseconds: 700);

  // ── Curve di animazione ──────────────────────────────────
  static const Curve curveStandard = Curves.easeInOut;
  static const Curve curveEmphasized = Curves.easeOutCubic;
  static const Curve curveDecelerate = Curves.decelerate;
  static const Curve curveBounce = Curves.easeOutBack;
}
