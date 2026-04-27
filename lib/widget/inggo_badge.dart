import 'package:flutter/material.dart';
import '../core/theme/inggo_theme.dart';

enum InggoBadgeVariant {
  pending,
  approved,
  rejected,
  client,
  driver,
  neutral,
  rating,
  verified
}

class InggoBadge extends StatelessWidget {
  final String label;
  final InggoBadgeVariant variant;
  final IconData? icon;
  final bool showDot;

  const InggoBadge({
    super.key,
    required this.label,
    this.variant = InggoBadgeVariant.neutral,
    this.icon,
    this.showDot = false,
  });

  Color get _backgroundColor {
    switch (variant) {
      case InggoBadgeVariant.pending:
        return InggoColors.primaryLight;
      case InggoBadgeVariant.approved:
        return InggoColors.successLight;
      case InggoBadgeVariant.rejected:
        return InggoColors.errorLight;
      case InggoBadgeVariant.client:
        return const Color(0xFFF0F0F0);
      case InggoBadgeVariant.driver:
        return InggoColors.text1;
      case InggoBadgeVariant.neutral:
        return const Color(0xFFF0F0F0);
      case InggoBadgeVariant.rating:
        return InggoColors.primaryLight;
      case InggoBadgeVariant.verified:
        return InggoColors.successLight;
    }
  }

  Color get _textColor {
    switch (variant) {
      case InggoBadgeVariant.pending:
        return InggoColors.primaryDark;
      case InggoBadgeVariant.approved:
        return InggoColors.successDark;
      case InggoBadgeVariant.rejected:
        return InggoColors.errorDark;
      case InggoBadgeVariant.client:
        return InggoColors.text2;
      case InggoBadgeVariant.driver:
        return InggoColors.primary;
      case InggoBadgeVariant.neutral:
        return InggoColors.text2;
      case InggoBadgeVariant.rating:
        return InggoColors.primaryDark;
      case InggoBadgeVariant.verified:
        return InggoColors.successDark;
    }
  }

  Color? get _dotColor {
    switch (variant) {
      case InggoBadgeVariant.pending:
        return InggoColors.primary;
      case InggoBadgeVariant.approved:
        return InggoColors.success;
      case InggoBadgeVariant.rejected:
        return InggoColors.error;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(InggoSpacing.xs),
        border: variant == InggoBadgeVariant.pending ||
                variant == InggoBadgeVariant.rating
            ? Border.all(color: InggoColors.primaryBorder, width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot && _dotColor != null) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: _dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ],
          if (icon != null) ...[
            Icon(icon, size: 14, color: _textColor),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _textColor,
              fontFamily: InggoTextStyles.fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}

class InggoRatingBadge extends StatelessWidget {
  final double rating;
  final int? reviewCount;

  const InggoRatingBadge({
    super.key,
    required this.rating,
    this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: InggoColors.primaryLight,
        borderRadius: BorderRadius.circular(InggoSpacing.xs),
        border: Border.all(color: InggoColors.primaryBorder, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 14, color: InggoColors.primaryDark),
          const SizedBox(width: 5),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: InggoColors.primaryDark,
              fontFamily: InggoTextStyles.fontFamily,
            ),
          ),
          if (reviewCount != null) ...[
            Text(
              ' ($reviewCount)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: InggoColors.text3,
                fontFamily: InggoTextStyles.fontFamily,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class InggoStatusDot extends StatelessWidget {
  final bool isActive;
  final Color? activeColor;
  final double size;

  const InggoStatusDot({
    super.key,
    required this.isActive,
    this.activeColor,
    this.size = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isActive
            ? (activeColor ?? InggoColors.success)
            : InggoColors.border2,
        shape: BoxShape.circle,
      ),
    );
  }
}
