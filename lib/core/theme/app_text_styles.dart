import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle get h1 => GoogleFonts.inter(
      fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary);

  static TextStyle get h2 => GoogleFonts.inter(
      fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary);

  static TextStyle get h3 => GoogleFonts.inter(
      fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary);

  static TextStyle get bodyRegular => GoogleFonts.inter(
      fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.textSecondary);

  static TextStyle get caption => GoogleFonts.inter(
      fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary);

  static TextStyle get priceLarge => GoogleFonts.inter(
      fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.success);

  static TextStyle get timer => GoogleFonts.inter(
      fontSize: 14, fontWeight: FontWeight.w600);
}