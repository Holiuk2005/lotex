import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LotexUiColors {
  // Tailwind-ish palette (ported from earlier UI reference values)
  static const Color slate950 = Color(0xFF020617);

  // Tailwind default purple (used directly in React components via `purple-*` classes)
  static const Color purple300 = Color(0xFFD8B4FE);
  static const Color purple500 = Color(0xFFA855F7);
  static const Color purple600 = Color(0xFF9333EA);

  static const Color violet400 = Color(0xFFA78BFA);
  static const Color violet500 = Color(0xFF8B5CF6);
  static const Color violet600 = Color(0xFF7C3AED);
  static const Color violet900 = Color(0xFF4C1D95);
  static const Color violet950 = Color(0xFF2E1065);

  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB);

  static const Color neonOrange = Color(0xFFFF7E33);
  static const Color neonPink = Color(0xFFEC4899);
  static const Color neonGreen = Color(0xFF10B981);

  // Semantic
  static const Color success = neonGreen;
  static const Color error = Color(0xFFEF4444);

  // Defaults referenced by classes (Tailwind default palette)
  static const Color blue900 = Color(0xFF1E3A8A);
  static const Color indigo950 = Color(0xFF1E1B4B);

  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);

  // App surfaces / text (ported from legacy AppColors)
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTitle = Color(0xFF0F172A);
  static const Color lightBody = Color(0xFF334155);
  static const Color lightMuted = Color(0xFF94A3B8);

  static const Color darkBackground = slate950;
  // Glass surface: bg-white/5
  static const Color darkCard = Color(0x0DFFFFFF);
  static const Color darkTitle = Color(0xFFE5E7EB);
  static const Color darkBody = Color(0xFFCBD5E1);
  static const Color darkMuted = Color(0xFF64748B);

  static const Color dividerLight = Color(0xFFE5E7EB);
}

abstract class LotexUiSpacing {
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

class LotexUiTextStyles {
  static TextStyle get h1 => GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: LotexUiColors.lightTitle,
      );

  static TextStyle get h2 => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: LotexUiColors.lightTitle,
      );

  static TextStyle get h3 => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: LotexUiColors.lightTitle,
      );

  static TextStyle get bodyRegular => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: LotexUiColors.lightBody,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: LotexUiColors.lightBody,
      );

  static TextStyle get priceLarge => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: LotexUiColors.violet600,
      );

  static TextStyle get timer => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      );
}

class LotexUiGradients {
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [LotexUiColors.violet900, LotexUiColors.blue600],
  );

  static const LinearGradient accent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [LotexUiColors.neonOrange, LotexUiColors.neonPink],
  );

  static const LinearGradient glass = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color.fromRGBO(255, 255, 255, 0.08), Color.fromRGBO(255, 255, 255, 0.03)],
  );

  static const LinearGradient heroText = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [LotexUiColors.violet400, LotexUiColors.neonPink, LotexUiColors.blue400],
  );

  static const LinearGradient bottomNavActive = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [LotexUiColors.violet500, LotexUiColors.blue500],
  );

  static const LinearGradient sidebarActive = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [LotexUiColors.violet500, LotexUiColors.blue500],
  );
}

class LotexUiShadows {
  static const List<BoxShadow> glow = [
    BoxShadow(
      color: Color.fromRGBO(124, 58, 237, 0.5),
      blurRadius: 20,
      spreadRadius: 0,
      offset: Offset(0, 0),
    ),
  ];
}
