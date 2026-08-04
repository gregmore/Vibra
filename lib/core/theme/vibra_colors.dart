import 'package:flutter/material.dart';

/// Palette colori del brand Vibra.
/// Tema dark premium con accenti viola/rosa e profondità a 4 livelli.
class VibraColors {
  VibraColors._();

  // ── Colori Primari ───────────────────────────────────────
  /// Viola principale del brand — vibrante e moderno.
  static const Color primary = Color(0xFF8B5CF6);

  /// Viola più chiaro per hover/stati attivi.
  static const Color primaryLight = Color(0xFFA78BFA);

  /// Viola più scuro per profondità e container.
  static const Color primaryDark = Color(0xFF6D28D9);

  // ── Sfondo (4 livelli di profondità) ─────────────────────
  /// Sfondo principale — nero profondo con sottotono blu.
  static const Color background = Color(0xFF08080F);

  /// Sfondo secondario per card base e nav bar.
  static const Color surface = Color(0xFF12121E);

  /// Sfondo terziario per elementi innestati (input, chip).
  static const Color surfaceVariant = Color(0xFF1C1C32);

  /// Sfondo elevato per card prominenti, dialoghi, bottom sheet.
  static const Color surfaceElevated = Color(0xFF252540);

  // ── Accenti ──────────────────────────────────────────────
  /// Rosa caldo per CTA primari e elementi interattivi.
  static const Color accent = Color(0xFFF472B6);

  /// Arancione caldo per CTA secondari e highlight.
  static const Color accentWarm = Color(0xFFFB923C);

  /// Verde elegante per match alto e successo.
  static const Color matchHigh = Color(0xFF34D399);

  /// Amber morbido per avvisi e match medio.
  static const Color matchMedium = Color(0xFFFBBF24);

  /// Rosso morbido per errori e match basso.
  static const Color matchLow = Color(0xFFF87171);

  // Alias semantici
  static const Color success = matchHigh;
  static const Color warning = matchMedium;
  static const Color error = matchLow;

  // Alias per retrocompatibilità tema
  static const Color green = matchHigh;

  // ── Testo ────────────────────────────────────────────────
  /// Testo principale — bianco caldo Apple-style.
  static const Color textPrimary = Color(0xFFF5F5F7);

  /// Testo secondario — grigio neutro.
  static const Color textSecondary = Color(0xFF9CA3AF);

  /// Testo disabilitato.
  static const Color textDisabled = Color(0xFF4B5563);

  // ── Gradienti ────────────────────────────────────────────
  /// Gradiente principale per header e bottoni primari.
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, accent],
  );

  /// Gradiente caldo per CTA secondari.
  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentWarm],
  );

  /// Gradiente per card eventi (overlay immagine).
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x00000000), // trasparente
      Color(0x8008080F), // 50% sfondo
      Color(0xDD08080F), // 87% sfondo
    ],
    stops: [0.0, 0.5, 1.0],
  );

  /// Gradiente per sfondo schermata.
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF120A20), // viola molto scuro
      background,
    ],
  );

  /// Gradiente per il punteggio di compatibilità (basso → alto).
  static const LinearGradient matchScoreGradient = LinearGradient(
    colors: [matchLow, matchMedium, matchHigh],
    stops: [0.0, 0.5, 1.0],
  );

  // ── Glassmorphism ────────────────────────────────────────
  /// Colore base per effetti glassmorphism.
  static const Color glassBackground = Color(0x0AFFFFFF); // bianco ~4%

  /// Bordo sottile per effetto vetro.
  static const Color glassBorder = Color(0x18FFFFFF); // bianco ~9%

  // ── Shimmer / Skeleton ───────────────────────────────────
  /// Colore base per skeleton loading.
  static const Color shimmerBase = Color(0xFF1A1A2E);

  /// Colore highlight per skeleton loading.
  static const Color shimmerHighlight = Color(0xFF2A2A48);

  // ── Navigation Bar ───────────────────────────────────────
  /// Background dedicato per la nav bar (leggermente più luminoso).
  static const Color navBarBackground = Color(0xF012121E); // surface ~94% opaco

  // ── Utilità ──────────────────────────────────────────────
  /// Restituisce il colore appropriato per un punteggio di match.
  static Color getMatchColor(double score) {
    if (score >= 0.8) return matchHigh;
    if (score >= 0.5) return matchMedium;
    return matchLow;
  }

  /// Restituisce il colore per lo stato di partecipazione.
  static Color attendanceColor(String status) {
    return switch (status) {
      'going' => matchHigh,
      'maybe' => matchMedium,
      'not_going' => matchLow,
      _ => textSecondary,
    };
  }
}
