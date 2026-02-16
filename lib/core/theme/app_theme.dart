import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData light() {
    const colorScheme = ColorScheme.light(
      primary: AppColors.primaryAccent,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.chipDefault,
      onSecondary: AppColors.textPrimary,
      surface: AppColors.cardBackground,
      onSurface: AppColors.textPrimary,
    );

    final base = ThemeData(
      useMaterial3: true,
      fontFamily: 'NanumSquareNormal',
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.scaffoldBackground,
      colorScheme: colorScheme,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: AppColors.appBarBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.cardBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shadowColor: AppColors.cardShadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
      ),
      chipTheme: ChipThemeData.fromDefaults(
        secondaryColor: AppColors.chipSelected,
        brightness: Brightness.light,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ).copyWith(
        backgroundColor: AppColors.chipDefault,
        selectedColor: AppColors.chipSelected,
        side: const BorderSide(color: Colors.transparent),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: AppColors.navigationBackground,
        indicatorColor: AppColors.navigationIndicator,
        elevation: 8,
      ),
      textTheme: base.textTheme.copyWith(
        headlineMedium: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          height: 1.7,
          color: AppColors.textPrimary,
        ),
        titleMedium: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
        bodyMedium: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
