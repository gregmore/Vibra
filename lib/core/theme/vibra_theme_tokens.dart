import 'package:flutter/material.dart';

import 'vibra_colors.dart';

/// Semantic visual tokens for Vibra.
///
/// Components describe *what* a colour is for, never its literal value. The
/// palettes below are therefore the only place where a visual mode is chosen.
@immutable
class VibraThemeTokens extends ThemeExtension<VibraThemeTokens> {
  const VibraThemeTokens({
    required this.backgroundPrimary,
    required this.backgroundSecondary,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceMuted,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.textMuted,
    required this.accentPrimary,
    required this.accentSecondary,
    required this.accentSoft,
    required this.accentFill,
    required this.borderDefault,
    required this.borderStrong,
    required this.success,
    required this.warning,
    required this.error,
    required this.onAccent,
    required this.onImage,
    required this.onImageMuted,
    required this.imageScrim,
    required this.imageOverlay,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.cardShadow,
    required this.elevatedShadow,
    required this.primaryGradient,
    required this.avatarGradient,
    required this.mapTileUrl,
  });

  final Color backgroundPrimary,
      backgroundSecondary,
      surface,
      surfaceElevated,
      surfaceMuted;
  final Color textPrimary, textSecondary, textDisabled;

  /// Non-essential copy (timestamps, placeholders). Not for body text.
  final Color textMuted;
  final Color accentPrimary, accentSecondary, accentSoft;

  /// Accent used as a background behind [onAccent] copy (AA compliant).
  final Color accentFill;
  final Color borderDefault,
      borderStrong,
      success,
      warning,
      error,
      onAccent,
      onImage,
      onImageMuted,
      shimmerBase,
      shimmerHighlight;

  /// A 60% black scrim keeps white copy above 4.5:1 even on a white image.
  final Color imageScrim;

  /// Always dark and reserved for the copy-bearing area of image cards.
  final Color imageOverlay;
  final BoxShadow cardShadow, elevatedShadow;
  final LinearGradient primaryGradient, avatarGradient;

  /// OpenStreetMap standard raster tiles. The dark presentation is produced
  /// locally so both modes keep the same geographic source and attribution.
  final String mapTileUrl;

  /// Light presentation: the logo's black-on-white variant. Paper canvas,
  /// ink type, the same violet signal.
  static const light = VibraThemeTokens(
    backgroundPrimary: VibraPalette.paper50,
    backgroundSecondary: VibraPalette.paper100,
    surface: VibraPalette.white,
    surfaceElevated: VibraPalette.white,
    surfaceMuted: VibraPalette.paper100,
    textPrimary: VibraPalette.textOnLight,
    textSecondary: VibraPalette.textOnLightSecondary,
    textDisabled: VibraPalette.textOnLightMuted,
    textMuted: VibraPalette.textOnLightMuted,
    accentPrimary: VibraPalette.violetFill,
    accentSecondary: VibraPalette.indigoFill,
    accentSoft: VibraPalette.violetTintLight,
    accentFill: VibraPalette.violetFill,
    borderDefault: VibraPalette.paper200,
    borderStrong: VibraPalette.paper300,
    success: VibraPalette.successOnLight,
    warning: VibraPalette.warningOnLight,
    error: VibraPalette.errorOnLight,
    onAccent: VibraPalette.white,
    onImage: VibraPalette.white,
    onImageMuted: Color(0xFFE4E4E7),
    imageScrim: Color(0x99000000),
    imageOverlay: Color(0xE6000000),
    shimmerBase: VibraPalette.paper200,
    shimmerHighlight: VibraPalette.paper50,
    cardShadow: BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 16,
      offset: Offset(0, 4),
      spreadRadius: -4,
    ),
    elevatedShadow: BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 28,
      offset: Offset(0, 12),
      spreadRadius: -8,
    ),
    primaryGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [VibraPalette.violetFill, VibraPalette.indigoFill],
    ),
    avatarGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF27272A), Color(0xFF0A0A0A)],
    ),
    mapTileUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  );

  /// Dark-first presentation: the logo's white-on-black original.
  static const dark = VibraThemeTokens(
    backgroundPrimary: VibraPalette.ink950,
    backgroundSecondary: VibraPalette.ink900,
    surface: VibraPalette.ink850,
    surfaceElevated: VibraPalette.ink800,
    surfaceMuted: VibraPalette.ink750,
    textPrimary: VibraPalette.textOnDark,
    textSecondary: VibraPalette.textOnDarkSecondary,
    textDisabled: VibraPalette.textOnDarkMuted,
    textMuted: VibraPalette.textOnDarkMuted,
    accentPrimary: VibraPalette.violet,
    accentSecondary: VibraPalette.indigo,
    accentSoft: VibraPalette.violetTintDark,
    accentFill: VibraPalette.violetFill,
    borderDefault: VibraPalette.ink700,
    borderStrong: VibraPalette.ink600,
    success: VibraPalette.success,
    warning: VibraPalette.warning,
    error: VibraPalette.error,
    onAccent: VibraPalette.white,
    onImage: VibraPalette.white,
    onImageMuted: Color(0xFFD4D4D8),
    imageScrim: Color(0x99000000),
    imageOverlay: Color(0xE6000000),
    shimmerBase: Color(0xFF141414),
    shimmerHighlight: Color(0xFF222222),
    cardShadow: BoxShadow(
      color: Color(0x66000000),
      blurRadius: 16,
      offset: Offset(0, 6),
      spreadRadius: -6,
    ),
    elevatedShadow: BoxShadow(
      color: Color(0x99000000),
      blurRadius: 32,
      offset: Offset(0, 16),
      spreadRadius: -8,
    ),
    primaryGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [VibraPalette.violetFill, VibraPalette.indigoFill],
    ),
    avatarGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF27272A), Color(0xFF111113)],
    ),
    mapTileUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  );

  @override
  VibraThemeTokens copyWith({
    Color? backgroundPrimary,
    Color? backgroundSecondary,
    Color? surface,
    Color? surfaceElevated,
    Color? surfaceMuted,
    Color? textPrimary,
    Color? textSecondary,
    Color? textDisabled,
    Color? textMuted,
    Color? accentPrimary,
    Color? accentSecondary,
    Color? accentSoft,
    Color? accentFill,
    Color? borderDefault,
    Color? borderStrong,
    Color? success,
    Color? warning,
    Color? error,
    Color? onAccent,
    Color? onImage,
    Color? onImageMuted,
    Color? imageScrim,
    Color? imageOverlay,
    Color? shimmerBase,
    Color? shimmerHighlight,
    BoxShadow? cardShadow,
    BoxShadow? elevatedShadow,
    LinearGradient? primaryGradient,
    LinearGradient? avatarGradient,
    String? mapTileUrl,
  }) => VibraThemeTokens(
    backgroundPrimary: backgroundPrimary ?? this.backgroundPrimary,
    backgroundSecondary: backgroundSecondary ?? this.backgroundSecondary,
    surface: surface ?? this.surface,
    surfaceElevated: surfaceElevated ?? this.surfaceElevated,
    surfaceMuted: surfaceMuted ?? this.surfaceMuted,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    textDisabled: textDisabled ?? this.textDisabled,
    textMuted: textMuted ?? this.textMuted,
    accentPrimary: accentPrimary ?? this.accentPrimary,
    accentSecondary: accentSecondary ?? this.accentSecondary,
    accentSoft: accentSoft ?? this.accentSoft,
    accentFill: accentFill ?? this.accentFill,
    borderDefault: borderDefault ?? this.borderDefault,
    borderStrong: borderStrong ?? this.borderStrong,
    success: success ?? this.success,
    warning: warning ?? this.warning,
    error: error ?? this.error,
    onAccent: onAccent ?? this.onAccent,
    onImage: onImage ?? this.onImage,
    onImageMuted: onImageMuted ?? this.onImageMuted,
    imageScrim: imageScrim ?? this.imageScrim,
    imageOverlay: imageOverlay ?? this.imageOverlay,
    shimmerBase: shimmerBase ?? this.shimmerBase,
    shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
    cardShadow: cardShadow ?? this.cardShadow,
    elevatedShadow: elevatedShadow ?? this.elevatedShadow,
    primaryGradient: primaryGradient ?? this.primaryGradient,
    avatarGradient: avatarGradient ?? this.avatarGradient,
    mapTileUrl: mapTileUrl ?? this.mapTileUrl,
  );

  @override
  VibraThemeTokens lerp(VibraThemeTokens? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    final snap = t < .5 ? this : other;
    return VibraThemeTokens(
      backgroundPrimary: c(backgroundPrimary, other.backgroundPrimary),
      backgroundSecondary: c(backgroundSecondary, other.backgroundSecondary),
      surface: c(surface, other.surface),
      surfaceElevated: c(surfaceElevated, other.surfaceElevated),
      surfaceMuted: c(surfaceMuted, other.surfaceMuted),
      textPrimary: c(textPrimary, other.textPrimary),
      textSecondary: c(textSecondary, other.textSecondary),
      textDisabled: c(textDisabled, other.textDisabled),
      textMuted: c(textMuted, other.textMuted),
      accentPrimary: c(accentPrimary, other.accentPrimary),
      accentSecondary: c(accentSecondary, other.accentSecondary),
      accentSoft: c(accentSoft, other.accentSoft),
      accentFill: c(accentFill, other.accentFill),
      borderDefault: c(borderDefault, other.borderDefault),
      borderStrong: c(borderStrong, other.borderStrong),
      success: c(success, other.success),
      warning: c(warning, other.warning),
      error: c(error, other.error),
      onAccent: c(onAccent, other.onAccent),
      onImage: c(onImage, other.onImage),
      onImageMuted: c(onImageMuted, other.onImageMuted),
      imageScrim: c(imageScrim, other.imageScrim),
      imageOverlay: c(imageOverlay, other.imageOverlay),
      shimmerBase: c(shimmerBase, other.shimmerBase),
      shimmerHighlight: c(shimmerHighlight, other.shimmerHighlight),
      cardShadow: BoxShadow.lerp(cardShadow, other.cardShadow, t)!,
      elevatedShadow: BoxShadow.lerp(elevatedShadow, other.elevatedShadow, t)!,
      primaryGradient: snap.primaryGradient,
      avatarGradient: snap.avatarGradient,
      mapTileUrl: snap.mapTileUrl,
    );
  }

  /// Compatibility tiers. Labels always carry the numeric score too, so
  /// colour is never the only signal.
  ///
  /// * high (≥ 75%): the brand violet — the strongest signal in the system.
  /// * medium (≥ 45%): electric indigo.
  /// * low: neutral secondary ink.
  Color matchColor(double score) {
    if (score >= .75) return accentPrimary;
    if (score >= .45) return accentSecondary;
    return textSecondary;
  }

  VibraMatchTier matchTier(double score) {
    if (score >= .75) return VibraMatchTier.high;
    if (score >= .45) return VibraMatchTier.medium;
    return VibraMatchTier.low;
  }

  Color attendanceColor(String status) => switch (status) {
    'going' => success,
    'maybe' => warning,
    'not_going' => textSecondary,
    _ => textSecondary,
  };
}

enum VibraMatchTier { high, medium, low }

extension VibraThemeContext on BuildContext {
  VibraThemeTokens get vibraTokens =>
      Theme.of(this).extension<VibraThemeTokens>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? VibraThemeTokens.dark
          : VibraThemeTokens.light);
}
