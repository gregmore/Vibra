import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'vibra_spacing.dart';
import 'vibra_text_styles.dart';
import 'vibra_theme_tokens.dart';

/// Both Material themes are built from the same semantic token contract.
class VibraTheme {
  VibraTheme._();

  static ThemeData get lightTheme =>
      _build(VibraThemeTokens.light, Brightness.light);
  static ThemeData get darkTheme =>
      _build(VibraThemeTokens.dark, Brightness.dark);

  /// Compatibility name for older call sites while they are migrated.
  static ThemeData get signalPaperTheme => lightTheme;

  static ThemeData _build(VibraThemeTokens t, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final textTheme = VibraTextStyles.textTheme.apply(
      bodyColor: t.textPrimary,
      displayColor: t.textPrimary,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      extensions: [t],
      colorScheme: ColorScheme.fromSeed(
        seedColor: t.accentPrimary,
        brightness: brightness,
        primary: t.accentPrimary,
        onPrimary: t.onAccent,
        secondary: t.accentSecondary,
        onSecondary: t.onAccent,
        surface: t.surface,
        onSurface: t.textPrimary,
        error: t.error,
        onError: t.onAccent,
      ),
      scaffoldBackgroundColor: t.backgroundPrimary,
      canvasColor: t.backgroundPrimary,
      disabledColor: t.textDisabled,
      hoverColor: t.accentPrimary.withValues(alpha: isDark ? 0.12 : 0.08),
      focusColor: t.accentPrimary.withValues(alpha: 0.16),
      highlightColor: t.accentPrimary.withValues(alpha: 0.10),
      splashColor: t.accentPrimary.withValues(alpha: 0.14),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: t.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.headlineMedium,
        iconTheme: IconThemeData(color: t.textPrimary),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: brightness,
        ),
      ),
      cardTheme: CardThemeData(
        color: t.surfaceElevated,
        elevation: isDark ? 0 : 1,
        shadowColor: t.cardShadow.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(VibraSpacing.radiusMedium),
          side: BorderSide(color: t.borderDefault),
        ),
        margin: VibraSpacing.cardMargin,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: t.accentPrimary,
          foregroundColor: t.onAccent,
          minimumSize: const Size(0, 48),
          elevation: 0,
          disabledBackgroundColor: t.surfaceMuted,
          disabledForegroundColor: t.textDisabled,
          overlayColor: t.onAccent.withValues(alpha: 0.12),
          shape: RoundedRectangleBorder(borderRadius: VibraSpacing.borderSmall),
          textStyle: textTheme.labelLarge,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: t.accentPrimary,
          foregroundColor: t.onAccent,
          minimumSize: const Size(0, 48),
          disabledBackgroundColor: t.surfaceMuted,
          disabledForegroundColor: t.textDisabled,
          overlayColor: t.onAccent.withValues(alpha: 0.12),
          shape: RoundedRectangleBorder(borderRadius: VibraSpacing.borderSmall),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: t.textPrimary,
          side: BorderSide(color: t.borderStrong),
          minimumSize: const Size(0, 48),
          disabledForegroundColor: t.textDisabled,
          overlayColor: t.accentPrimary.withValues(alpha: 0.10),
          shape: RoundedRectangleBorder(borderRadius: VibraSpacing.borderSmall),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: t.accentPrimary,
          disabledForegroundColor: t.textDisabled,
          minimumSize: const Size(48, 48),
          overlayColor: t.accentPrimary.withValues(alpha: 0.10),
          shape: RoundedRectangleBorder(borderRadius: VibraSpacing.borderSmall),
          textStyle: textTheme.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: t.textPrimary,
          disabledForegroundColor: t.textDisabled,
          minimumSize: const Size(48, 48),
          hoverColor: t.accentPrimary.withValues(alpha: 0.10),
          focusColor: t.accentPrimary.withValues(alpha: 0.14),
          highlightColor: t.accentPrimary.withValues(alpha: 0.14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: t.surface,
        hintStyle: textTheme.bodyMedium?.copyWith(color: t.textSecondary),
        labelStyle: textTheme.bodyMedium?.copyWith(color: t.textSecondary),
        floatingLabelStyle: textTheme.bodyMedium?.copyWith(
          color: t.accentPrimary,
          fontWeight: FontWeight.w600,
        ),
        errorStyle: textTheme.bodySmall?.copyWith(
          color: t.error,
          fontWeight: FontWeight.w600,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: t.borderDefault),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: t.accentPrimary, width: 2),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: t.error, width: 1.5),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: t.error, width: 2),
        ),
        disabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: t.borderDefault),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: t.surfaceElevated,
        selectedColor: t.accentSoft,
        disabledColor: t.surfaceMuted,
        labelStyle: textTheme.labelMedium?.copyWith(color: t.textPrimary),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
          color: t.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        side: BorderSide(color: t.borderStrong),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: t.surfaceElevated,
        modalBackgroundColor: t.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(VibraSpacing.radiusXL),
          ),
        ),
        dragHandleColor: t.borderStrong,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: t.surfaceElevated,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(VibraSpacing.radiusLarge),
          side: BorderSide(color: t.borderDefault),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: t.accentSoft,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? t.accentPrimary
                : t.textSecondary,
            size: 22,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelSmall?.copyWith(
            color: states.contains(WidgetState.selected)
                ? t.textPrimary
                : t.textSecondary,
          ),
        ),
        elevation: 0,
        height: 68,
      ),
      dividerTheme: DividerThemeData(
        color: t.borderDefault,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: t.surfaceElevated,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: t.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: VibraSpacing.borderMedium),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: t.textSecondary,
        textColor: t.textPrimary,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: t.accentPrimary,
        linearTrackColor: t.surfaceMuted,
        circularTrackColor: t.surfaceMuted,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: t.textPrimary,
          borderRadius: VibraSpacing.borderSmall,
        ),
        textStyle: textTheme.bodySmall?.copyWith(color: t.backgroundPrimary),
      ),
    );
  }
}
