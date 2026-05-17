import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/constants/constants.dart';

/// Inggo VTC Design System — Barre de progression v2.0
/// Label + valeur · Barre 6px · Fill jaune (default) ou vert (success)
class InggoProgressBar extends StatelessWidget {
  final String label;
  final String valueText;
  final double progress; // 0.0 à 1.0
  final bool isSuccess;
  final Color? fillColor;

  const InggoProgressBar({
    super.key,
    required this.label,
    required this.valueText,
    required this.progress,
    this.isSuccess = false,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Label + Valeur
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                )),
            Text(valueText,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                )),
          ],
        ),
        SizedBox(height: 6.h),
        // Barre
        ClipRRect(
          borderRadius: BorderRadius.circular(3.r),
          child: Container(
            height: 6.h,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(3.r),
            ),
            child: FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: fillColor ??
                      (isSuccess ? AppColors.success : AppColors.primary),
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
