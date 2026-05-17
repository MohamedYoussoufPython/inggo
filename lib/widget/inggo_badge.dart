import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/constants/constants.dart';
import '../l10n/app_localizations.dart';
import '../model/ride_model.dart';

/// Badge variant enum — 5 DS colors
enum InggoBadgeVariant { yellow, green, red, grey, dark }

class InggoBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? textColor;
  final InggoBadgeVariant? variant;
  final bool showDot;

  const InggoBadge({
    super.key,
    required this.label,
    this.color,
    this.textColor,
    this.variant,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    if (variant != null) return _buildVariant();

    // Fallback: auto-generate from color
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: (color ?? AppColors.primary).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                color: textColor ?? color ?? AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 6.w),
          ],
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: textColor ?? color ?? AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariant() {
    final configs = {
      InggoBadgeVariant.yellow: {
        'bg': AppColors.primaryLight,
        'text': AppColors.primaryDark,
        'border': AppColors.primaryBorder,
        'dot': AppColors.primary,
      },
      InggoBadgeVariant.green: {
        'bg': AppColors.successLight,
        'text': AppColors.successDark,
        'border': null,
        'dot': AppColors.success,
      },
      InggoBadgeVariant.red: {
        'bg': AppColors.errorLight,
        'text': AppColors.errorDark,
        'border': null,
        'dot': AppColors.error,
      },
      InggoBadgeVariant.grey: {
        'bg': AppColors.surfaceVariant,
        'text': AppColors.textSecondary,
        'border': null,
        'dot': AppColors.textHint,
      },
      InggoBadgeVariant.dark: {
        'bg': AppColors.primary,
        'text': AppColors.textPrimary,
        'border': AppColors.primaryBorder,
        'dot': AppColors.textPrimary,
      },
    };
    final cfg = configs[variant!]!;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: cfg['bg'] as Color,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: cfg['border'] != null
            ? Border.all(color: cfg['border'] as Color, width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                color: cfg['dot'] as Color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 6.w),
          ],
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: cfg['text'] as Color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class RideStatusBadge extends StatelessWidget {
  final RideStatus status;
  const RideStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final cfg = _config(loc);
    return InggoBadge(label: cfg['label'], variant: cfg['variant'], showDot: true);
  }

  Map<String, dynamic> _config(AppLocalizations loc) {
    switch (status) {
      case RideStatus.pending:
        return {'label': loc.statusPending, 'variant': InggoBadgeVariant.yellow};
      case RideStatus.searching:
        return {'label': loc.statusSearching, 'variant': InggoBadgeVariant.grey};
      case RideStatus.accepted:
        return {'label': loc.statusAccepted, 'variant': InggoBadgeVariant.green};
      case RideStatus.inProgress:
        return {'label': loc.statusInProgress, 'variant': InggoBadgeVariant.grey};
      case RideStatus.completed:
        return {'label': loc.statusCompleted, 'variant': InggoBadgeVariant.green};
      case RideStatus.cancelled:
        return {'label': loc.statusCancelled, 'variant': InggoBadgeVariant.red};
    }
  }
}
