import 'package:flutter/material.dart';
import 'vibra_colors.dart';

/// Effetti di ombra ed elevazione per il tema Vibra.
/// Approccio "elegante" — glow sottili e ombre di profondità.
class VibraShadows {
  VibraShadows._();

  /// Genera un'ombra al neon per un dato colore.
  /// Intensità ridotta rispetto al vecchio tema per un look più raffinato.
  static BoxShadow neonGlow(Color color, {double intensity = 1.0}) {
    return BoxShadow(
      color: color.withValues(alpha: 0.35 * intensity),
      blurRadius: 12 * intensity,
      spreadRadius: 1 * intensity,
    );
  }

  /// Glow viola per elementi primari e focus.
  static BoxShadow get purpleGlow => neonGlow(VibraColors.primary);

  /// Glow rosa/magenta per bottoni CTA e accenti.
  static BoxShadow get magentaGlow => neonGlow(VibraColors.accent);

  /// Glow verde per punteggi match elevati e successo.
  static BoxShadow get greenGlow => neonGlow(VibraColors.matchHigh);

  /// Glow giallo per punteggi match medi.
  static BoxShadow get yellowGlow => neonGlow(VibraColors.matchMedium);

  /// Glow rosso per punteggi match bassi.
  static BoxShadow get redGlow => neonGlow(VibraColors.matchLow);

  // ── Ombre di profondità (non neon) ───────────────────────
  /// Ombra sottile per card — profondità base.
  static const BoxShadow cardElevation = BoxShadow(
    color: Color(0x40000000), // nero 25%
    blurRadius: 16,
    offset: Offset(0, 4),
    spreadRadius: -2,
  );

  /// Ombra per card elevate (dialoghi, popup).
  static const BoxShadow cardElevationHigh = BoxShadow(
    color: Color(0x50000000), // nero 31%
    blurRadius: 24,
    offset: Offset(0, 8),
    spreadRadius: -4,
  );

  /// Ombra per bottoni pressed/elevated.
  static const BoxShadow buttonElevation = BoxShadow(
    color: Color(0x30000000), // nero 19%
    blurRadius: 8,
    offset: Offset(0, 2),
    spreadRadius: 0,
  );

  /// Gradiente lineare per i bordi delle card glassmorphic (riflesso speculare).
  static const LinearGradient glassBorderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x28FFFFFF), // Bianco semitrasparente (16%) in alto a sx
      Color(0x00FFFFFF), // Trasparente in basso a dx
    ],
  );
}
