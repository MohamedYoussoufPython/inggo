import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppShadows {
  AppShadows._();

  // ── 3-level elevation system ──
  static BoxShadow get level1 => BoxShadow(
        color: AppColors.shadow,
        blurRadius: 4,
        offset: const Offset(0, 2),
      );

  static BoxShadow get level2 => BoxShadow(
        color: AppColors.shadow,
        blurRadius: 8,
        offset: const Offset(0, 4),
      );

  static BoxShadow get level3 => BoxShadow(
        color: const Color(0x29000000),
        blurRadius: 16,
        offset: const Offset(0, 8),
      );

  // ── Semantic shadows ──
  static BoxShadow get card => BoxShadow(
        color: AppColors.shadow,
        blurRadius: 8,
        offset: const Offset(0, 2),
        spreadRadius: 0,
      );

  static BoxShadow get cardHover => BoxShadow(
        color: const Color(0x29000000),
        blurRadius: 16,
        offset: const Offset(0, 6),
        spreadRadius: 0,
      );

  static BoxShadow get bottomNav => BoxShadow(
        color: AppColors.shadow,
        blurRadius: 12,
        offset: const Offset(0, -2),
      );

  static BoxShadow get modal => BoxShadow(
        color: const Color(0x33000000),
        blurRadius: 24,
        offset: const Offset(0, 12),
      );

  static BoxShadow get button => BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.3),
        blurRadius: 8,
        offset: const Offset(0, 4),
      );

  static BoxShadow get focusRing => BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.25),
        blurRadius: 0,
        spreadRadius: 3,
        offset: Offset.zero,
      );

  // ── Deprecated aliases ──
  @Deprecated('Use level1 instead')
  static BoxShadow get sm => level1;
  @Deprecated('Use level2 instead')
  static BoxShadow get md => level2;
  @Deprecated('Use level3 instead')
  static BoxShadow get lg => level3;
  @Deprecated('Use level3 instead')
  static BoxShadow get xl => level3;
  @Deprecated('Use button instead')
  static BoxShadow get primary => button;
}
