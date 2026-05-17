import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/constants/constants.dart';

/// Toast variant — aligné sur le Design System
enum ToastVariant { dark, success, error, warning }

class InggoToast {
  InggoToast._();

  // ── BuildContext API (sync code) ──

  static void show(BuildContext context, String message,
      {ToastVariant variant = ToastVariant.dark, Duration? duration}) {
    ScaffoldMessenger.of(context).showSnackBar(
      _buildSnackBar(message, variant, duration),
    );
  }

  static void success(BuildContext context, String message) =>
      show(context, message, variant: ToastVariant.success);

  static void error(BuildContext context, String message) =>
      show(context, message, variant: ToastVariant.error);

  static void warning(BuildContext context, String message) =>
      show(context, message, variant: ToastVariant.warning);

  static void info(BuildContext context, String message) =>
      show(context, message, variant: ToastVariant.dark);

  // ── ScaffoldMessengerState API (after async gaps) ──

  static void showMessenger(ScaffoldMessengerState messenger, String message,
      {ToastVariant variant = ToastVariant.dark, Duration? duration}) {
    messenger.showSnackBar(
      _buildSnackBar(message, variant, duration),
    );
  }

  static void successMessenger(ScaffoldMessengerState messenger, String message) =>
      showMessenger(messenger, message, variant: ToastVariant.success);

  static void errorMessenger(ScaffoldMessengerState messenger, String message) =>
      showMessenger(messenger, message, variant: ToastVariant.error);

  static void warningMessenger(ScaffoldMessengerState messenger, String message) =>
      showMessenger(messenger, message, variant: ToastVariant.warning);

  // ── Internal ──

  static SnackBar _buildSnackBar(String message, ToastVariant variant, Duration? duration) {
    final cfg = _variantConfig(variant);
    return SnackBar(
      content: Row(
        children: [
          // Icône ronde 26x26
          Container(
            width: 26.r,
            height: 26.r,
            decoration: BoxDecoration(
              color: cfg['iconBg'] as Color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                cfg['icon'] as IconData,
                size: 12.r,
                color: cfg['iconColor'] as Color,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: cfg['textColor'] as Color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: cfg['bgColor'] as Color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        side: cfg['border'] != null
            ? BorderSide(color: cfg['border'] as Color, width: 1)
            : BorderSide.none,
      ),
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      duration: duration ?? const Duration(seconds: 3),
      elevation: cfg['elevation'] as double,
    );
  }

  static Map<String, dynamic> _variantConfig(ToastVariant variant) {
    switch (variant) {
      // Dark: fond blanc, icône jaune ronde
      case ToastVariant.dark:
        return {
          'bgColor': AppColors.surface,
          'textColor': AppColors.textPrimary,
          'border': AppColors.border,
          'iconBg': AppColors.primary,
          'iconColor': AppColors.textPrimary,
          'icon': Icons.check,
          'elevation': 4.0,
        };
      // Success: fond vert clair, icône verte
      case ToastVariant.success:
        return {
          'bgColor': AppColors.successLight,
          'textColor': AppColors.successDark,
          'border': const Color(0xFFBBF7D0),
          'iconBg': AppColors.success,
          'iconColor': AppColors.textWhite,
          'icon': Icons.check,
          'elevation': 0.0,
        };
      // Error: fond rouge clair, icône rouge
      case ToastVariant.error:
        return {
          'bgColor': AppColors.errorLight,
          'textColor': AppColors.errorDark,
          'border': const Color(0xFFFECACA),
          'iconBg': AppColors.error,
          'iconColor': AppColors.textWhite,
          'icon': Icons.close,
          'elevation': 0.0,
        };
      // Warning: fond jaune clair, icône jaune
      case ToastVariant.warning:
        return {
          'bgColor': AppColors.primaryLight,
          'textColor': AppColors.primaryDark,
          'border': AppColors.primaryBorder,
          'iconBg': AppColors.primary,
          'iconColor': AppColors.textPrimary,
          'icon': Icons.priority_high,
          'elevation': 0.0,
        };
    }
  }
}
