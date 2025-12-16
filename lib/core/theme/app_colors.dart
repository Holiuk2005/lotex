import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primary600 = Color(0xFF4F46E5);
  static const Color primary500 = Color(0xFF6366F1);
  static const Color primary = Color(0xFF0F766E);

  // Accent
  static const Color accent500 = Color(0xFFF59E0B);

  // Semantic
  static const Color success = Color(0xFF16A34A);
  static const Color error = Color(0xFFEF4444);

  // LIGHT tokens (aliases)
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTitle = Color(0xFF0F172A);
  static const Color lightBody = Color(0xFF334155);
  static const Color lightMuted = Color(0xFF94A3B8);

  // DARK tokens
  static const Color darkBackground = Color(0xFF020617);
  static const Color darkCard = Color(0xFF0B1220);
  static const Color darkTitle = Color(0xFFE5E7EB);
  static const Color darkBody = Color(0xFFCBD5E1);
  static const Color darkMuted = Color(0xFF64748B);

  // Neutral / shared
  static const Color backgroundLight = lightBackground;
  static const Color cardLight = lightCard;
  static const Color textPrimary = lightTitle;
  static const Color textSecondary = lightBody;
  static const Color dividerLight = Color(0xFFE5E7EB);
}