import 'package:flutter/material.dart';

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
    required this.accentPrimary,
    required this.accentSecondary,
    required this.accentSoft,
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
  final Color accentPrimary, accentSecondary, accentSoft;
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

  static const light = VibraThemeTokens(
    backgroundPrimary: Color(0xFFFAF9FC),
    backgroundSecondary: Color(0xFFF3F0F7),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFF0ECF4),
    textPrimary: Color(0xFF14101C),
    textSecondary: Color(0xFF6B6478),
    textDisabled: Color(0xFF9A94A3),
    accentPrimary: Color(0xFF7C3AED),
    accentSecondary: Color(0xFFDB2777),
    accentSoft: Color(0xFFEDE9FE),
    borderDefault: Color(0x14000000),
    borderStrong: Color(0x2E000000),
    success: Color(0xFF16803A),
    warning: Color(0xFF9A5B00),
    error: Color(0xFFB42318),
    onAccent: Color(0xFFFFFFFF),
    onImage: Color(0xFFFFFFFF),
    onImageMuted: Color(0xFFE4E0E8),
    imageScrim: Color(0x99000000),
    imageOverlay: Color(0xE6000000),
    shimmerBase: Color(0xFFE7E2EC),
    shimmerHighlight: Color(0xFFFFFFFF),
    cardShadow: BoxShadow(
      color: Color(0x140F0A1A),
      blurRadius: 18,
      offset: Offset(0, 6),
      spreadRadius: -4,
    ),
    elevatedShadow: BoxShadow(
      color: Color(0x240F0A1A),
      blurRadius: 28,
      offset: Offset(0, 12),
      spreadRadius: -6,
    ),
    // Quieter on white; used only for compact brand signals such as CTAs/avatar initials.
    primaryGradient: LinearGradient(
      colors: [Color(0xFF7C3AED), Color(0xFFC026A8)],
    ),
    avatarGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF8B5CF6), Color(0xFFDB2777)],
    ),
    mapTileUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  );

  static const dark = VibraThemeTokens(
    backgroundPrimary: Color(0xFF0D0A14),
    backgroundSecondary: Color(0xFF1A1425),
    surface: Color(0xFF1A1425),
    surfaceElevated: Color(0xFF241C33),
    surfaceMuted: Color(0xFF30263F),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFB8AFC7),
    textDisabled: Color(0xFF7F758E),
    accentPrimary: Color(0xFF8B5CF6),
    accentSecondary: Color(0xFFEC4899),
    accentSoft: Color(0xFF38285E),
    borderDefault: Color(0x1AFFFFFF),
    borderStrong: Color(0x33FFFFFF),
    success: Color(0xFF4ADE80),
    warning: Color(0xFFFBBF24),
    error: Color(0xFFF87171),
    onAccent: Color(0xFF0D0A14),
    onImage: Color(0xFFFFFFFF),
    onImageMuted: Color(0xFFE4E0E8),
    imageScrim: Color(0x99000000),
    imageOverlay: Color(0xE6000000),
    shimmerBase: Color(0xFF241C33),
    shimmerHighlight: Color(0xFF30263F),
    cardShadow: BoxShadow(
      color: Color(0x33000000),
      blurRadius: 14,
      offset: Offset(0, 5),
      spreadRadius: -3,
    ),
    elevatedShadow: BoxShadow(
      color: Color(0x66000000),
      blurRadius: 24,
      offset: Offset(0, 10),
      spreadRadius: -5,
    ),
    primaryGradient: LinearGradient(
      colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    ),
    avatarGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFA78BFA), Color(0xFFF472B6)],
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
    Color? accentPrimary,
    Color? accentSecondary,
    Color? accentSoft,
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
    accentPrimary: accentPrimary ?? this.accentPrimary,
    accentSecondary: accentSecondary ?? this.accentSecondary,
    accentSoft: accentSoft ?? this.accentSoft,
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
  VibraThemeTokens lerp(VibraThemeTokens? other, double t) =>
      t < .5 ? this : other ?? this;

  /// Match labels always carry the numeric score too, so colour is never the
  /// only signal. Every returned colour passes AA as text on neutral surfaces.
  Color matchColor(double score) {
    if (score >= .8) return success;
    if (score >= .5) return warning;
    return textSecondary;
  }

  Color attendanceColor(String status) => switch (status) {
    'going' => success,
    'maybe' => warning,
    'not_going' => textSecondary,
    _ => textSecondary,
  };
}

extension VibraThemeContext on BuildContext {
  VibraThemeTokens get vibraTokens =>
      Theme.of(this).extension<VibraThemeTokens>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? VibraThemeTokens.dark
          : VibraThemeTokens.light);
}
