import 'package:flutter/material.dart';

class AppColors {
  // Основний
  // Поєднання стилю «Lotex UI/UX» (фіолетово-синій градієнт) та нейтральної колірної гами «Marketplace UI».
  static const Color primary600 = Color(0xFF7C3AED); // violet-600
  static const Color primary500 = Color(0xFF8B5CF6); // violet-500
  static const Color primary = primary500;

  // Додатковий (використовується для посилань/виділення)
  static const Color secondary500 = Color(0xFF2563EB); // blue-600-ish

  // Акцент
  static const Color accent500 = Color(0xFFFF7E33); // neon orange

  // Неонові вивіски (за бажанням)
  static const Color neonPink = Color(0xFFE879F9); // fuchsia-400
  static const Color neonGreen = Color(0xFF4ADE80); // green-400

  // Семантика
  static const Color success = Color(0xFF16A34A);
  static const Color error = Color(0xFFEF4444);

  // Токени LIGHT (псевдоніми)
  // База даних LIGHT, схожа на маркетплейс
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTitle = Color(0xFF0F172A);
  static const Color lightBody = Color(0xFF334155);
  static const Color lightMuted = Color(0xFF94A3B8);

  static const Color lightBorder = Color(0x1A000000); // rgba(0,0,0,0.10)
  static const Color lightInputBackground = Color(0xFFF3F3F5);

  // Токени DARK
  // Темна базова колірна гама інтерфейсу Lotex (slate-950) + картка зі скляним ефектом
  static const Color darkBackground = Color(0xFF020617); // slate-950
  static const Color darkCard = Color(0x990F172A); // slate-900 @ 60%
  static const Color darkTitle = Color(0xFFE5E7EB);
  static const Color darkBody = Color(0xFFCBD5E1);
  static const Color darkMuted = Color(0xFF64748B);

  static const Color darkBorder = Color(0x14FFFFFF); // white @ 8%
  static const Color darkInputBackground = Color(0xCC0F172A);

  // Нейтральний / спільний
  static const Color backgroundLight = lightBackground;
  static const Color cardLight = lightCard;
  static const Color textPrimary = lightTitle;
  static const Color textSecondary = lightBody;
  static const Color dividerLight = Color(0xFFE5E7EB);
}