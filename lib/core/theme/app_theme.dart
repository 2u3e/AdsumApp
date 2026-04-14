import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Adsum tema yapılandırması - Light & Dark
class AppTheme {
  AppTheme._();

  // ─── Light Theme ────────────────────────────────────────────
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          primaryContainer: AppColors.primarySurface,
          onPrimaryContainer: AppColors.primaryDark,
          secondary: AppColors.gray600,
          onSecondary: Colors.white,
          secondaryContainer: AppColors.gray100,
          onSecondaryContainer: AppColors.gray900,
          tertiary: AppColors.info,
          error: AppColors.error,
          onError: Colors.white,
          errorContainer: AppColors.errorSurface,
          onErrorContainer: AppColors.errorDark,
          surface: AppColors.surfaceLight,
          onSurface: AppColors.textPrimaryLight,
          onSurfaceVariant: AppColors.textSecondaryLight,
          outline: AppColors.borderLight,
          outlineVariant: AppColors.dividerLight,
        ),
        scaffoldBackgroundColor: AppColors.backgroundLight,
        textTheme: AppTypography.textTheme.apply(
          bodyColor: AppColors.textPrimaryLight,
          displayColor: AppColors.textPrimaryLight,
        ),

        // AppBar
        appBarTheme: AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0.5,
          centerTitle: false,
          backgroundColor: AppColors.surfaceLight,
          foregroundColor: AppColors.textPrimaryLight,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimaryLight,
          ),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),

        // Card
        cardTheme: CardThemeData(
          elevation: 0,
          color: AppColors.cardLight,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMd,
            side: const BorderSide(color: AppColors.borderLight, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),

        // Input
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.gray50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: AppSpacing.borderRadiusSm,
            borderSide: const BorderSide(color: AppColors.borderLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderRadiusSm,
            borderSide: const BorderSide(color: AppColors.borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderRadiusSm,
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderRadiusSm,
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderRadiusSm,
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
          hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiaryLight),
          labelStyle: AppTypography.labelMedium.copyWith(color: AppColors.textSecondaryLight),
          errorStyle: AppTypography.labelSmall.copyWith(color: AppColors.error),
        ),

        // Elevated Button
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusSm),
            textStyle: AppTypography.labelLarge,
          ),
        ),

        // Outlined Button
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusSm),
            side: const BorderSide(color: AppColors.borderLight),
            textStyle: AppTypography.labelLarge,
          ),
        ),

        // Text Button
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            textStyle: AppTypography.labelLarge,
          ),
        ),

        // Chip
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.gray100,
          selectedColor: AppColors.primarySurface,
          labelStyle: AppTypography.labelMedium,
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusFull),
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),

        // Bottom Navigation
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surfaceLight,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.gray400,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          showUnselectedLabels: true,
        ),

        // Divider
        dividerTheme: const DividerThemeData(
          color: AppColors.dividerLight,
          thickness: 1,
          space: 1,
        ),

        // Bottom Sheet
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.surfaceLight,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
          ),
        ),

        // Dialog
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.surfaceLight,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusMd),
        ),

        // Floating Action Button
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: CircleBorder(),
        ),
      );

  // ─── Dark Theme ─────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryLight,
          onPrimary: AppColors.gray900,
          primaryContainer: AppColors.primarySurfaceDark,
          onPrimaryContainer: AppColors.primaryLight,
          secondary: AppColors.gray400,
          onSecondary: AppColors.gray900,
          secondaryContainer: AppColors.gray700,
          onSecondaryContainer: AppColors.gray100,
          tertiary: AppColors.infoLight,
          error: AppColors.errorLight,
          onError: AppColors.gray900,
          errorContainer: AppColors.errorSurfaceDark,
          onErrorContainer: AppColors.errorLight,
          surface: AppColors.surfaceDark,
          onSurface: AppColors.textPrimaryDark,
          onSurfaceVariant: AppColors.textSecondaryDark,
          outline: AppColors.borderDark,
          outlineVariant: AppColors.dividerDark,
        ),
        scaffoldBackgroundColor: AppColors.backgroundDark,
        textTheme: AppTypography.textTheme.apply(
          bodyColor: AppColors.textPrimaryDark,
          displayColor: AppColors.textPrimaryDark,
        ),

        // AppBar
        appBarTheme: AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0.5,
          centerTitle: false,
          backgroundColor: AppColors.surfaceDark,
          foregroundColor: AppColors.textPrimaryDark,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimaryDark,
          ),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),

        // Card
        cardTheme: CardThemeData(
          elevation: 0,
          color: AppColors.cardDark,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMd,
            side: const BorderSide(color: AppColors.borderDark, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),

        // Input
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.gray800,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: AppSpacing.borderRadiusSm,
            borderSide: const BorderSide(color: AppColors.borderDark),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderRadiusSm,
            borderSide: const BorderSide(color: AppColors.borderDark),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderRadiusSm,
            borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderRadiusSm,
            borderSide: const BorderSide(color: AppColors.errorLight),
          ),
          hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiaryDark),
          labelStyle: AppTypography.labelMedium.copyWith(color: AppColors.textSecondaryDark),
          errorStyle: AppTypography.labelSmall.copyWith(color: AppColors.errorLight),
        ),

        // Elevated Button
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusSm),
            textStyle: AppTypography.labelLarge,
          ),
        ),

        // Outlined Button
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryLight,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusSm),
            side: const BorderSide(color: AppColors.borderDark),
            textStyle: AppTypography.labelLarge,
          ),
        ),

        // Text Button
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryLight,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            textStyle: AppTypography.labelLarge,
          ),
        ),

        // Chip
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.gray700,
          selectedColor: AppColors.primarySurfaceDark,
          labelStyle: AppTypography.labelMedium,
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusFull),
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),

        // Bottom Navigation
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surfaceDark,
          selectedItemColor: AppColors.primaryLight,
          unselectedItemColor: AppColors.gray500,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          showUnselectedLabels: true,
        ),

        // Divider
        dividerTheme: const DividerThemeData(
          color: AppColors.dividerDark,
          thickness: 1,
          space: 1,
        ),

        // Bottom Sheet
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.surfaceDark,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
          ),
        ),

        // Dialog
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.surfaceDark,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusMd),
        ),

        // Floating Action Button
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: CircleBorder(),
        ),
      );
}
