import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppShadows {
  AppShadows._();

  static BoxShadow get sm => BoxShadow(
        color: AppColors.shadow,
        blurRadius: 4,
        offset: const Offset(0, 2),
      );

  static BoxShadow get md => BoxShadow(
        color: AppColors.shadow,
        blurRadius: 8,
        offset: const Offset(0, 4),
      );

  static BoxShadow get lg => BoxShadow(
        color: AppColors.shadow,
        blurRadius: 16,
        offset: const Offset(0, 8),
      );

  static BoxShadow get xl => BoxShadow(
        color: AppColors.shadow,
        blurRadius: 24,
        offset: const Offset(0, 12),
      );

  static BoxShadow get primary => BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.3),
        blurRadius: 8,
        offset: const Offset(0, 4),
      );

  static BoxShadow get card => BoxShadow(
        color: AppColors.shadow,
        blurRadius: 8,
        offset: const Offset(0, 2),
        spreadRadius: 0,
      );

  static BoxShadow get bottomNav => BoxShadow(
        color: AppColors.shadow,
        blurRadius: 12,
        offset: const Offset(0, -2),
      );
}
