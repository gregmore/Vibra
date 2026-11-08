import 'package:flutter/material.dart';

/// The raw VIBRA palette.
///
/// These literals exist only here. Screens and components never reference
/// them directly: they read the semantic roles in `VibraThemeTokens`, which
/// map this palette onto the dark (primary) and light presentations.
///
/// Identity: black and white carry the brand, exactly like the logo.
/// Violet is a signal, used sparingly for action, selection and match.
abstract final class VibraPalette {
  // ── Ink (dark-first canvas) ───────────────────────────────
  static const Color ink950 = Color(0xFF000000); // primary background
  static const Color ink900 = Color(0xFF0A0A0A); // secondary background
  static const Color ink850 = Color(0xFF101010); // cards
  static const Color ink800 = Color(0xFF181818); // elevated surfaces
  static const Color ink750 = Color(0xFF1F1F1F); // muted fills, chips
  static const Color ink700 = Color(0xFF242424); // borders
  static const Color ink600 = Color(0xFF3F3F46); // strong borders

  // ── Paper (light presentation) ────────────────────────────
  static const Color paper50 = Color(0xFFFAFAFA);
  static const Color paper100 = Color(0xFFF4F4F5);
  static const Color paper200 = Color(0xFFE4E4E7);
  static const Color paper300 = Color(0xFFD4D4D8);
  static const Color white = Color(0xFFFFFFFF);

  // ── Text ──────────────────────────────────────────────────
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textOnDarkSecondary = Color(0xFFA1A1AA);
  static const Color textOnDarkMuted = Color(0xFF71717A);
  static const Color textOnLight = Color(0xFF0A0A0A);
  static const Color textOnLightSecondary = Color(0xFF52525B);
  static const Color textOnLightMuted = Color(0xFFA1A1AA);

  // ── Signal ────────────────────────────────────────────────
  /// Brand violet: selection, indicators, focus, match rings, icons.
  static const Color violet = Color(0xFF8B5CF6);

  /// Electric indigo: secondary accent and gradient partner.
  static const Color indigo = Color(0xFF6366F1);

  /// Deeper violet used as a *fill* behind white copy. #8B5CF6 with white
  /// text is 4.2:1; this shade keeps primary buttons at WCAG AA (5.7:1).
  static const Color violetFill = Color(0xFF7C3AED);

  /// Deeper indigo partner for filled gradients behind white copy (6.3:1).
  static const Color indigoFill = Color(0xFF4F46E5);

  static const Color violetTintDark = Color(0xFF1C1430);
  static const Color violetTintLight = Color(0xFFEDE9FE);

  // ── Status ────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color successOnLight = Color(0xFF15803D);
  static const Color warningOnLight = Color(0xFFB45309);
  static const Color errorOnLight = Color(0xFFB91C1C);

  // ── Third-party brand marks ───────────────────────────────
  /// Spotify brand green. Used only next to the Spotify name/logo, as the
  /// Spotify brand guidelines require; never as a VIBRA accent.
  static const Color spotifyGreen = Color(0xFF1DB954);

  /// Copy colour for Spotify-green surfaces (AA on #1DB954).
  static const Color onSpotifyGreen = Color(0xFF07170C);
}
