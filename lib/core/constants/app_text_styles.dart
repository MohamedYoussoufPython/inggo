import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ── Headlines (DM Sans) ──
  static TextStyle get headline1 => GoogleFonts.dmSans(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get headline2 => GoogleFonts.dmSans(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get headline3 => GoogleFonts.dmSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get headline4 => GoogleFonts.dmSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  // ── Body ──
  static TextStyle get bodyLarge => GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  // ── Labels ──
  static TextStyle get labelLarge => GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get labelMedium => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get labelSmall => GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  /// Section heading label (uppercase, small, bold, secondary color)
  static TextStyle get labelSection => GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        height: 1.4,
        letterSpacing: 0.5,
      );

  /// Input field label (uppercase, small, medium weight, secondary color)
  static TextStyle get labelInput => GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        height: 1.4,
        letterSpacing: 0.3,
      );

  // ── Caption ──
  static TextStyle get caption => GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textHint,
        height: 1.4,
      );

  // ── Button ──
  static TextStyle get button => GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textWhite,
        height: 1.2,
      );

  static TextStyle get buttonSmall => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textWhite,
        height: 1.2,
      );

  static TextStyle get buttonLarge => GoogleFonts.dmSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textWhite,
        height: 1.2,
      );

  // ── Price ──
  static TextStyle get price => GoogleFonts.dmSans(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: AppColors.primary,
        height: 1.2,
      );

  static TextStyle get priceSmall => GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        height: 1.2,
      );

  // ── Stats (ProfileCard) ──
  static TextStyle get statValue => GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get statLabel => GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textHint,
        height: 1.4,
      );

  // ── Accent ──
  static TextStyle get accent => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        height: 1.3,
      );

  // ── Deprecated aliases ──
  @Deprecated('Use headline2 instead')
  static TextStyle get h2 => headline2;
  @Deprecated('Use headline3 instead')
  static TextStyle get h3 => headline3;
}
