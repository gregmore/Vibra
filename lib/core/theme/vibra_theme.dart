import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'vibra_colors.dart';
import 'vibra_spacing.dart';
import 'vibra_text_styles.dart';

/// Tema completo dell'app Vibra.
/// Dark theme premium con palette viola, glassmorphism, e Material 3.
class VibraTheme {
  VibraTheme._();



  /// Il tema dark principale dell'app.
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // ── Color Scheme ───────────────────────────────────────
      colorScheme: const ColorScheme.dark(
        primary: VibraColors.primary,
        onPrimary: VibraColors.textPrimary,
        primaryContainer: VibraColors.primaryDark,
        secondary: VibraColors.accent,
        onSecondary: VibraColors.textPrimary,
        surface: VibraColors.surface,
        onSurface: VibraColors.textPrimary,
        surfaceContainerHighest: VibraColors.surfaceElevated,
        error: VibraColors.error,
        onError: VibraColors.textPrimary,
        surfaceTint: Colors.transparent,
      ),

      // ── Sfondo ─────────────────────────────────────────────
      scaffoldBackgroundColor: VibraColors.background,

      // ── Tipografia ─────────────────────────────────────────
      textTheme: VibraTextStyles.textTheme,

      // ── AppBar ─────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: VibraTextStyles.headlineMedium,
        iconTheme: const IconThemeData(color: VibraColors.textPrimary),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),

      // ── Card ───────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: VibraColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(VibraSpacing.radiusLarge),
          side: const BorderSide(
            color: VibraColors.glassBorder,
            width: 0.5,
          ),
        ),
        margin: VibraSpacing.cardMargin,
      ),

      // ── ElevatedButton ─────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: VibraColors.primary,
          foregroundColor: VibraColors.textPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: VibraSpacing.borderFull,
          ),
          textStyle: VibraTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── OutlinedButton ─────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: VibraColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: VibraSpacing.borderFull,
          ),
          side: const BorderSide(color: VibraColors.primary, width: 1.5),
          textStyle: VibraTextStyles.labelLarge,
        ),
      ),

      // ── TextButton ─────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: VibraColors.accent,
          textStyle: VibraTextStyles.labelLarge,
        ),
      ),

      // ── FloatingActionButton ───────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: VibraColors.accent,
        foregroundColor: VibraColors.textPrimary,
        elevation: 4,
        shape: const CircleBorder(),
      ),

      // ── IconButton ─────────────────────────────────────────
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: VibraColors.textPrimary,
          hoverColor: VibraColors.primary.withValues(alpha: 0.1),
          focusColor: VibraColors.primary.withValues(alpha: 0.15),
          highlightColor: VibraColors.primary.withValues(alpha: 0.1),
        ),
      ),

      // ── Input / TextField ──────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: VibraColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: VibraSpacing.borderSmall,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: VibraSpacing.borderSmall,
          borderSide: const BorderSide(
            color: VibraColors.glassBorder,
            width: 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: VibraSpacing.borderSmall,
          borderSide: const BorderSide(
            color: VibraColors.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: VibraSpacing.borderSmall,
          borderSide: const BorderSide(
            color: VibraColors.error,
            width: 1.0,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        hintStyle: VibraTextStyles.bodyMedium.copyWith(
          color: VibraColors.textDisabled,
        ),
        labelStyle: VibraTextStyles.labelMedium,
      ),

      // ── Chip ───────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: VibraColors.surfaceVariant,
        selectedColor: VibraColors.primary.withValues(alpha: 0.25),
        labelStyle: VibraTextStyles.labelMedium,
        side: const BorderSide(color: VibraColors.glassBorder, width: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: VibraSpacing.borderSmall,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),

      // ── BottomSheet ────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: VibraColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(VibraSpacing.radiusXL),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: VibraColors.textDisabled,
      ),

      // ── Dialog ─────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: VibraColors.surfaceElevated,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: VibraSpacing.borderXL,
        ),
        titleTextStyle: VibraTextStyles.headlineSmall,
        contentTextStyle: VibraTextStyles.bodyMedium,
      ),

      // ── SnackBar ───────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: VibraColors.surfaceElevated,
        contentTextStyle: VibraTextStyles.bodyMedium,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: VibraSpacing.borderSmall,
          side: BorderSide(
            color: VibraColors.accent.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
      ),

      // ── BottomNavigationBar ────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: VibraColors.surface,
        selectedItemColor: VibraColors.accent,
        unselectedItemColor: VibraColors.textDisabled,
        selectedLabelStyle: VibraTextStyles.labelSmall,
        unselectedLabelStyle: VibraTextStyles.labelSmall,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // ── NavigationBar (Material 3) ─────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: VibraColors.navBarBackground,
        indicatorColor: VibraColors.primary.withValues(alpha: 0.2),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: VibraColors.accent, size: 24);
          }
          return const IconThemeData(color: VibraColors.textDisabled, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return VibraTextStyles.labelSmall
                .copyWith(color: VibraColors.accent, fontWeight: FontWeight.w600);
          }
          return VibraTextStyles.labelSmall;
        }),
        elevation: 0,
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      // ── TabBar ─────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: VibraColors.accent,
        unselectedLabelColor: VibraColors.textSecondary,
        labelStyle: VibraTextStyles.labelLarge,
        unselectedLabelStyle: VibraTextStyles.labelMedium,
        indicatorColor: VibraColors.accent,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
      ),

      // ── Divider ────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: VibraColors.glassBorder,
        thickness: 0.5,
        space: 1,
      ),

      // ── ProgressIndicator ──────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: VibraColors.accent,
        linearTrackColor: VibraColors.surfaceVariant,
        circularTrackColor: VibraColors.surfaceVariant,
      ),

      // ── Switch ─────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return VibraColors.accent;
          }
          return VibraColors.textDisabled;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return VibraColors.accent.withValues(alpha: 0.3);
          }
          return VibraColors.surfaceVariant;
        }),
      ),

      // ── ListTile ───────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        iconColor: VibraColors.textSecondary,
        textColor: VibraColors.textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: VibraSpacing.borderMedium,
        ),
      ),

      // ── Tooltip ────────────────────────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: VibraColors.surfaceElevated,
          borderRadius: VibraSpacing.borderSmall,
          border: Border.all(color: VibraColors.glassBorder, width: 0.5),
        ),
        textStyle: VibraTextStyles.bodySmall,
      ),
    );
  }
}
