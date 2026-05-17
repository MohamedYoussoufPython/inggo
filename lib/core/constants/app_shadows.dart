import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppShadows {
  AppShadows._();

  // ── 3-level elevation system (allégé) ──
  // s1 design: 6% opacity
  static BoxShadow get sm => const BoxShadow(
        color: Color(0x0F000000),
        blurRadius: 3,
        offset: Offset(0, 1),
        spreadRadius: 0,
      );

  // s2 design: 8% opacity
  static BoxShadow get md => const BoxShadow(
        color: Color(0x14000000),
        blurRadius: 12,
        offset: Offset(0, 4),
      );

  // s3 design: 10% opacity
  static BoxShadow get lg => const BoxShadow(
        color: Color(0x1A000000),
        blurRadius: 24,
        offset: Offset(0, 8),
      );

  // ── Semantic shadows ──
  static BoxShadow get card => const BoxShadow(
        color: Color(0x0F000000),
        blurRadius: 3,
        offset: Offset(0, 1),
        spreadRadius: 0,
      );

  static BoxShadow get cardHover => const BoxShadow(
        color: Color(0x1A000000),
        blurRadius: 16,
        offset: Offset(0, 6),
        spreadRadius: 0,
      );

  static BoxShadow get focusRing => BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.12),
        blurRadius: 0,
        spreadRadius: 3,
        offset: Offset.zero,
      );

  static BoxShadow get bottomNav => const BoxShadow(
        color: Color(0x0F000000),
        blurRadius: 12,
        offset: Offset(0, -2),
      );

  static BoxShadow get modal => const BoxShadow(
        color: Color(0x29000000),
        blurRadius: 24,
        offset: Offset(0, 12),
      );

  static BoxShadow get button => BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.3),
        blurRadius: 8,
        offset: const Offset(0, 4),
      );

  // ── Deprecated aliases ──
  @Deprecated('Use sm instead')
  static BoxShadow get level1 => sm;
  @Deprecated('Use md instead')
  static BoxShadow get level2 => md;
  @Deprecated('Use lg instead')
  static BoxShadow get level3 => lg;
  @Deprecated('Use lg instead')
  static BoxShadow get xl => lg;
  @Deprecated('Use button instead')
  static BoxShadow get primary => button;
}
