import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: 'NanumSquareNormal',
      brightness: Brightness.light,
      colorSchemeSeed: AppColors.accent,
      scaffoldBackgroundColor: AppColors.background,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
      ),
    );
  }
}
