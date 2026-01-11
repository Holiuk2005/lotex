import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'lotex_ui_tokens.dart';

class LotexTheme {
  LotexTheme._();

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: false);
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: LotexUiColors.lightBody,
      displayColor: LotexUiColors.lightTitle,
    );

    return base.copyWith(
      primaryColor: LotexUiColors.violet600,
      colorScheme: const ColorScheme.light(
        primary: LotexUiColors.violet600,
        secondary: LotexUiColors.neonOrange,
        surface: LotexUiColors.lightCard,
        onPrimary: Colors.white,
        error: LotexUiColors.error,
      ),
      scaffoldBackgroundColor: LotexUiColors.lightBackground,
      cardColor: LotexUiColors.lightCard,
      dividerColor: LotexUiColors.dividerLight,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: LotexUiColors.lightBackground,
        elevation: 0,
        foregroundColor: LotexUiColors.lightTitle,
        iconTheme: IconThemeData(color: LotexUiColors.lightTitle),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: LotexUiColors.violet600,
          foregroundColor: Colors.white,
          elevation: 10,
          shadowColor: LotexUiColors.violet600.withAlpha((0.40 * 255).round()),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: const CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        elevation: 12,
        shadowColor: Color(0x5E1F2687),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: false);
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: LotexUiColors.darkBody,
      displayColor: LotexUiColors.darkTitle,
    );

    return base.copyWith(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: LotexUiColors.violet600,
        secondary: LotexUiColors.neonOrange,
        surface: LotexUiColors.darkCard,
        onPrimary: Colors.white,
        error: LotexUiColors.error,
      ),
      primaryColor: LotexUiColors.violet600,
      scaffoldBackgroundColor: LotexUiColors.darkBackground,
      cardColor: LotexUiColors.darkCard,
      dividerColor: const Color(0x1AFFFFFF),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: LotexUiColors.darkBackground.withAlpha((0.80 * 255).round()),
        elevation: 0,
        foregroundColor: LotexUiColors.darkTitle,
        iconTheme: const IconThemeData(color: LotexUiColors.darkBody),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: LotexUiColors.violet600,
          foregroundColor: Colors.white,
          elevation: 10,
          shadowColor: LotexUiColors.violet600.withAlpha((0.40 * 255).round()),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: const CardThemeData(
        color: LotexUiColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        elevation: 12,
        shadowColor: Color(0x5E1F2687),
      ),
    );
  }
}
