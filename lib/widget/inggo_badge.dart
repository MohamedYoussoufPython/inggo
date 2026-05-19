import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/constants/constants.dart';
import '../l10n/app_localizations.dart';
import '../model/ride_model.dart';

class InggoBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? bgColor;
  final bool showDot;

  const InggoBadge({
    super.key,
    required this.label,
    this.color,
    this.bgColor,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: bgColor ?? (color ?? AppColors.primary).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100), // pill — était 8px
        border: Border.all(
          color: (color ?? AppColors.primary).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                color: color ?? AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 5.w),
          ],
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color ?? AppColors.primaryDark,
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
    return InggoBadge(
      label: cfg['label'] as String,
      color: cfg['color'] as Color,
      bgColor: cfg['bgColor'] as Color,
      showDot: true,
    );
  }

  Map<String, dynamic> _config(AppLocalizations loc) {
    switch (status) {
      case RideStatus.pending:
        return {
          'label': loc.statusPending,
          'color': AppColors.primary,
          'bgColor': AppColors.primaryLight,
        };
      case RideStatus.searching:
        return {
          'label': loc.statusSearching,
          'color': AppColors.textHint,
          'bgColor': AppColors.background,
        };
      case RideStatus.accepted:
        return {
          'label': loc.statusAccepted,
          'color': AppColors.success,
          'bgColor': AppColors.successLight,
        };
      case RideStatus.inProgress:
        return {
          'label': loc.statusInProgress,
          'color': AppColors.textHint,
          'bgColor': AppColors.background,
        };
      case RideStatus.completed:
        return {
          'label': loc.statusCompleted,
          'color': AppColors.success,
          'bgColor': AppColors.successLight,
        };
      case RideStatus.cancelled:
        return {
          'label': loc.statusCancelled,
          'color': AppColors.error,
          'bgColor': AppColors.errorLight,
        };
    }
  }
}
