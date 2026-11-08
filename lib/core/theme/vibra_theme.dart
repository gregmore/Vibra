import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'vibra_spacing.dart';
import 'vibra_text_styles.dart';
import 'vibra_theme_tokens.dart';

/// Both Material themes are built from the same semantic token contract, so
/// every stock Material widget already speaks the VIBRA language.
class VibraTheme {
  VibraTheme._();

  static ThemeData get lightTheme =>
      _build(VibraThemeTokens.light, Brightness.light);
  static ThemeData get darkTheme =>
      _build(VibraThemeTokens.dark, Brightness.dark);

  /// Compatibility name for older call sites.
  static ThemeData get signalPaperTheme => lightTheme;

  static ThemeData _build(VibraThemeTokens t, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final textTheme = VibraTextStyles.textTheme.apply(
      bodyColor: t.textPrimary,
      displayColor: t.textPrimary,
    );
    final inputRadius = BorderRadius.circular(VibraSpacing.radiusMedium);
    OutlineInputBorder inputBorder(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: BorderSide(color: color, width: width),
        );
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(VibraSpacing.radiusMedium),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: VibraTextStyles.fontFamily,
      extensions: [t],
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: t.accentPrimary,
        onPrimary: t.onAccent,
        primaryContainer: t.accentSoft,
        onPrimaryContainer: t.textPrimary,
        secondary: t.accentSecondary,
        onSecondary: t.onAccent,
        secondaryContainer: t.surfaceMuted,
        onSecondaryContainer: t.textPrimary,
        tertiary: t.accentSecondary,
        onTertiary: t.onAccent,
        error: t.error,
        onError: t.onAccent,
        surface: t.surface,
        onSurface: t.textPrimary,
        onSurfaceVariant: t.textSecondary,
        surfaceContainerLowest: t.backgroundPrimary,
        surfaceContainerLow: t.backgroundSecondary,
        surfaceContainer: t.surface,
        surfaceContainerHigh: t.surfaceElevated,
        surfaceContainerHighest: t.surfaceMuted,
        outline: t.borderStrong,
        outlineVariant: t.borderDefault,
        inverseSurface: t.textPrimary,
        onInverseSurface: t.backgroundPrimary,
        inversePrimary: t.accentSoft,
        shadow: Colors.black,
        scrim: Colors.black,
        surfaceTint: Colors.transparent,
      ),
      scaffoldBackgroundColor: t.backgroundPrimary,
      canvasColor: t.backgroundPrimary,
      disabledColor: t.textDisabled,
      hoverColor: t.textPrimary.withValues(alpha: 0.04),
      focusColor: t.accentPrimary.withValues(alpha: 0.16),
      highlightColor: t.textPrimary.withValues(alpha: 0.04),
      splashColor: t.accentPrimary.withValues(alpha: 0.12),
      splashFactory: InkSparkle.splashFactory,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      iconTheme: IconThemeData(color: t.textPrimary, size: VibraSpacing.iconLg),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: t.backgroundPrimary,
        surfaceTintColor: Colors.transparent,
        foregroundColor: t.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: VibraSpacing.pagePadding,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: t.textPrimary, size: 22),
        actionsIconTheme: IconThemeData(color: t.textPrimary, size: 22),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: brightness,
          systemNavigationBarColor: t.backgroundPrimary,
          systemNavigationBarIconBrightness: isDark
              ? Brightness.light
              : Brightness.dark,
        ),
      ),
      cardTheme: CardThemeData(
        color: t.surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(VibraSpacing.radiusLarge),
          side: isDark ? BorderSide.none : BorderSide(color: t.borderDefault),
        ),
        margin: VibraSpacing.cardMargin,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: t.accentFill,
          foregroundColor: t.onAccent,
          minimumSize: const Size(64, VibraSpacing.buttonHeightCompact),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          elevation: 0,
          disabledBackgroundColor: t.surfaceMuted,
          disabledForegroundColor: t.textDisabled,
          overlayColor: t.onAccent.withValues(alpha: 0.12),
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: t.accentFill,
          foregroundColor: t.onAccent,
          minimumSize: const Size(64, VibraSpacing.buttonHeightCompact),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          disabledBackgroundColor: t.surfaceMuted,
          disabledForegroundColor: t.textDisabled,
          overlayColor: t.onAccent.withValues(alpha: 0.12),
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: t.textPrimary,
          backgroundColor: Colors.transparent,
          side: BorderSide(color: t.borderStrong),
          minimumSize: const Size(64, VibraSpacing.buttonHeightCompact),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          disabledForegroundColor: t.textDisabled,
          overlayColor: t.textPrimary.withValues(alpha: 0.08),
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: t.accentPrimary,
          disabledForegroundColor: t.textDisabled,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 12),
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
          hoverColor: t.textPrimary.withValues(alpha: 0.06),
          focusColor: t.accentPrimary.withValues(alpha: 0.14),
          highlightColor: t.textPrimary.withValues(alpha: 0.08),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: t.accentFill,
        foregroundColor: t.onAccent,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: VibraSpacing.borderLarge),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? t.surface : t.surfaceElevated,
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: VibraSpacing.lg,
          vertical: VibraSpacing.lg,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: t.textSecondary),
        labelStyle: textTheme.bodyMedium?.copyWith(color: t.textSecondary),
        floatingLabelStyle: textTheme.bodyMedium?.copyWith(
          color: t.accentPrimary,
          fontWeight: FontWeight.w600,
        ),
        helperStyle: textTheme.bodySmall?.copyWith(color: t.textSecondary),
        errorStyle: textTheme.bodySmall?.copyWith(
          color: t.error,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.focused)
              ? t.accentPrimary
              : t.textSecondary,
        ),
        suffixIconColor: t.textSecondary,
        border: inputBorder(t.borderDefault),
        enabledBorder: inputBorder(t.borderDefault),
        focusedBorder: inputBorder(t.accentPrimary, 1.5),
        errorBorder: inputBorder(t.error),
        focusedErrorBorder: inputBorder(t.error, 1.5),
        disabledBorder: inputBorder(t.borderDefault.withValues(alpha: 0.5)),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: t.accentPrimary,
        selectionColor: t.accentPrimary.withValues(alpha: 0.32),
        selectionHandleColor: t.accentPrimary,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: t.surfaceMuted,
        selectedColor: t.accentSoft,
        disabledColor: t.surfaceMuted,
        checkmarkColor: t.accentPrimary,
        deleteIconColor: t.textSecondary,
        labelStyle: textTheme.labelMedium?.copyWith(color: t.textPrimary),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
          color: t.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        side: WidgetStateBorderSide.resolveWith(
          (states) => BorderSide(
            color: states.contains(WidgetState.selected)
                ? t.accentPrimary
                : t.borderDefault,
          ),
        ),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        showCheckmark: false,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? t.onAccent
              : t.textSecondary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? t.accentFill
              : t.surfaceMuted,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.transparent
              : t.borderStrong,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? t.accentFill
              : Colors.transparent,
        ),
        checkColor: WidgetStatePropertyAll(t.onAccent),
        side: BorderSide(color: t.borderStrong, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? t.accentPrimary
              : t.borderStrong,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: t.accentPrimary,
        inactiveTrackColor: t.surfaceMuted,
        thumbColor: t.textPrimary,
        overlayColor: t.accentPrimary.withValues(alpha: 0.16),
        valueIndicatorColor: t.surfaceElevated,
        valueIndicatorTextStyle: textTheme.labelMedium?.copyWith(
          color: t.textPrimary,
        ),
        trackHeight: 4,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? t.accentSoft
                : Colors.transparent,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? t.textPrimary
                : t.textSecondary,
          ),
          side: WidgetStatePropertyAll(BorderSide(color: t.borderDefault)),
          textStyle: WidgetStatePropertyAll(textTheme.labelMedium),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: t.textPrimary,
        unselectedLabelColor: t.textSecondary,
        labelStyle: textTheme.titleSmall,
        unselectedLabelStyle: textTheme.titleSmall,
        indicatorColor: t.accentPrimary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: t.borderDefault,
        overlayColor: WidgetStatePropertyAll(
          t.accentPrimary.withValues(alpha: 0.08),
        ),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: t.accentPrimary, width: 2.5),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: t.surfaceElevated,
        modalBackgroundColor: t.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: Colors.black.withValues(alpha: 0.6),
        elevation: 0,
        modalElevation: 0,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(VibraSpacing.radiusXL),
          ),
        ),
        dragHandleColor: t.borderStrong,
        dragHandleSize: const Size(36, 4),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: t.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        barrierColor: Colors.black.withValues(alpha: 0.6),
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: t.textSecondary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(VibraSpacing.radiusXL),
          side: BorderSide(color: t.borderDefault),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: t.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        textStyle: textTheme.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: VibraSpacing.borderMedium,
          side: BorderSide(color: t.borderDefault),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? t.accentPrimary
                : t.textMuted,
            size: VibraSpacing.iconLg,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelSmall?.copyWith(
            letterSpacing: 0.2,
            color: states.contains(WidgetState.selected)
                ? t.textPrimary
                : t.textMuted,
          ),
        ),
        elevation: 0,
        height: 64,
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: t.accentFill,
        textColor: t.onAccent,
        textStyle: textTheme.labelSmall?.copyWith(
          fontSize: 10,
          letterSpacing: 0,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: t.borderDefault,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: t.surfaceElevated,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: t.textPrimary),
        actionTextColor: t.accentPrimary,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(
          borderRadius: VibraSpacing.borderMedium,
          side: BorderSide(color: t.borderDefault),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: t.textSecondary,
        textColor: t.textPrimary,
        titleTextStyle: textTheme.titleSmall,
        subtitleTextStyle: textTheme.bodySmall?.copyWith(
          color: t.textSecondary,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: VibraSpacing.lg),
        minVerticalPadding: VibraSpacing.md,
        shape: RoundedRectangleBorder(borderRadius: VibraSpacing.borderMedium),
      ),
      expansionTileTheme: ExpansionTileThemeData(
        iconColor: t.accentPrimary,
        collapsedIconColor: t.textSecondary,
        textColor: t.textPrimary,
        collapsedTextColor: t.textPrimary,
        shape: const Border(),
        collapsedShape: const Border(),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: t.accentPrimary,
        linearTrackColor: t.surfaceMuted,
        circularTrackColor: Colors.transparent,
        refreshBackgroundColor: t.surfaceElevated,
        linearMinHeight: 4,
        borderRadius: VibraSpacing.borderFull,
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
