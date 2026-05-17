import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/constants/constants.dart';

enum InggoButtonType {
  primary,
  primaryLight,
  secondary,
  outline,
  ghost,
  danger,
  dangerLight,
  greyOutline,
  text,
}

enum InggoButtonSize { large, medium, small }

class InggoButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final InggoButtonType type;
  final InggoButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;

  const InggoButton({
    super.key,
    required this.label,
    this.onPressed,
    this.type = InggoButtonType.primary,
    this.size = InggoButtonSize.large,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final style = _getStyle();
    final height = _getHeight();
    final padding = _getPadding();
    final textStyle = _getTextStyle();

    Widget child = isLoading
        ? SizedBox(
            height: 20.w,
            width: 20.w,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor:
                  AlwaysStoppedAnimation<Color>(style['textColor'] as Color),
            ),
          )
        : Row(
            mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon,
                    size: _getIconSize(),
                    color: style['textColor'] as Color),
                SizedBox(width: 8.w),
              ],
              Text(label,
                  style:
                      textStyle.copyWith(color: style['textColor'] as Color)),
            ],
          );

    // ── Outline-style buttons (secondary + outline + ghost + greyOutline + dangerLight + primaryLight) ──
    if (type == InggoButtonType.outline ||
        type == InggoButtonType.ghost ||
        type == InggoButtonType.greyOutline ||
        type == InggoButtonType.dangerLight ||
        type == InggoButtonType.primaryLight ||
        type == InggoButtonType.secondary) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: Size(isFullWidth ? double.infinity : 0, height),
          padding: padding,
          side: BorderSide(
            color: (style['borderColor'] ?? AppColors.border) as Color,
            width: 1.5,
          ),
          backgroundColor: style['bgColor'] as Color?,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
        child: child,
      );
    }

    // ── Text-style button ──
    if (type == InggoButtonType.text) {
      return TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          minimumSize: Size(isFullWidth ? double.infinity : 0, height),
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
        child: child,
      );
    }

    // ── Filled buttons (primary, danger) ──
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: style['bgColor'] as Color,
        foregroundColor: style['textColor'] as Color,
        disabledBackgroundColor:
            (style['bgColor'] as Color).withValues(alpha: 0.5),
        minimumSize: Size(isFullWidth ? double.infinity : 0, height),
        padding: padding,
        elevation: (style['elevation'] ?? 0.0) as double,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
      child: child,
    );
  }

  Map<String, dynamic> _getStyle() {
    switch (type) {
      case InggoButtonType.primary:
        return {
          'bgColor': AppColors.primary,
          'textColor': AppColors.secondary,
          'elevation': 2.0,
        };
      case InggoButtonType.primaryLight:
        return {
          'bgColor': AppColors.primaryLight,
          'borderColor': AppColors.primaryBorder,
          'textColor': AppColors.primaryDark,
          'elevation': 0.0,
        };
      // secondary = bouton jaune light "En attente"
      case InggoButtonType.secondary:
        return {
          'bgColor': AppColors.primaryLight, // #FFF8E1
          'textColor': AppColors.primaryDark, // #B38A00
          'borderColor': AppColors.primaryBorder, // #FFE070
          'elevation': 0.0,
        };
      // outline = bouton "Annuler" — fond blanc, bordure grise
      case InggoButtonType.outline:
        return {
          'borderColor': AppColors.border2, // #D0D0D0
          'textColor': AppColors.textPrimary, // #1A1A1A
          'bgColor': AppColors.surface,
        };
      case InggoButtonType.ghost:
        return {
          'borderColor': AppColors.border,
          'textColor': AppColors.textSecondary,
          'bgColor': Colors.transparent,
        };
      case InggoButtonType.danger:
        return {
          'bgColor': AppColors.error,
          'textColor': AppColors.textWhite,
          'elevation': 0.0,
        };
      case InggoButtonType.dangerLight:
        return {
          'borderColor': AppColors.error,
          'textColor': AppColors.errorDark,
          'bgColor': AppColors.errorLight,
        };
      case InggoButtonType.greyOutline:
        return {
          'borderColor': AppColors.border2,
          'textColor': AppColors.textSecondary,
          'bgColor': Colors.transparent,
        };
      case InggoButtonType.text:
        return {
          'textColor': AppColors.primary,
        };
    }
  }

  // Hauteurs alignées avec le design system
  double _getHeight() {
    switch (size) {
      case InggoButtonSize.large:
        return 52.h; // était 48
      case InggoButtonSize.medium:
        return 44.h; // était 40
      case InggoButtonSize.small:
        return 34.h; // était 32
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case InggoButtonSize.large:
        return EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h);
      case InggoButtonSize.medium:
        return EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h);
      case InggoButtonSize.small:
        return EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h);
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case InggoButtonSize.large:
        return AppTextStyles.button;
      case InggoButtonSize.medium:
        return AppTextStyles.buttonSmall;
      case InggoButtonSize.small:
        return AppTextStyles.labelSmall;
    }
  }

  double _getIconSize() {
    switch (size) {
      case InggoButtonSize.large:
        return 20.w;
      case InggoButtonSize.medium:
        return 18.w;
      case InggoButtonSize.small:
        return 16.w;
    }
  }
}
