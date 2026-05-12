import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/constants/constants.dart';
import '../l10n/app_localizations.dart';
import '../core/utils/formatters.dart';

class DriverCard extends StatelessWidget {
  final String name;
  final double rating;
  final int totalRides;
  final String? plateNumber;
  final String? vehicleColor;
  final String? avatarUrl;

  const DriverCard({
    super.key,
    required this.name,
    required this.rating,
    required this.totalRides,
    this.plateNumber,
    this.vehicleColor,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            backgroundImage:
                avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null
                ? Icon(Icons.person, color: AppColors.primary, size: 24.w)
                : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.labelMedium),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Icon(Icons.star, color: AppColors.primary, size: 14.w),
                    SizedBox(width: 4.w),
                    Text(Formatters.formatRating(rating),
                        style: AppTextStyles.bodySmall),
                    SizedBox(width: 8.w),
                    Text('($totalRides ${loc.ridesCount})', style: AppTextStyles.bodySmall),
                  ],
                ),
                if (plateNumber != null) ...[
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Icon(Icons.motorcycle,
                          color: AppColors.textSecondary, size: 14.w),
                      SizedBox(width: 4.w),
                      Text(
                        '$plateNumber${vehicleColor != null ? " • $vehicleColor" : ""}',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
