import 'package:flutter/material.dart';
import 'app_colors.dart';
// import 'app_text_styles.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      primaryColor: AppColors.primary500,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent500,
        surface: AppColors.lightBackground, // Changed from lightCard

        onPrimary: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      cardColor: AppColors.lightCard,
      dividerColor: AppColors.dividerLight,
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: AppColors.lightTitle),
        bodyMedium: TextStyle(color: AppColors.lightBody),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        titleTextStyle: TextStyle(color: AppColors.lightTitle, fontSize: 18, fontFamily: 'Inter'),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      // cardTheme: customized via cardColor and components
    );
  }

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary600,
        secondary: AppColors.accent500,
        surface: AppColors.darkCard,
        onPrimary: Colors.white,
      ),
      primaryColor: AppColors.primary600,
      scaffoldBackgroundColor: AppColors.darkBackground,
      cardColor: AppColors.darkCard,
      dividerColor: const Color(0xFF1F2937),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: AppColors.darkTitle),
        bodyMedium: TextStyle(color: AppColors.darkBody),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkCard,
        elevation: 0,
        titleTextStyle: TextStyle(color: AppColors.darkTitle, fontSize: 18),
        iconTheme: IconThemeData(color: AppColors.darkBody),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      // cardTheme: customized via cardColor and components
    );
  }
}