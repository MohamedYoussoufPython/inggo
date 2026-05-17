import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/constants/constants.dart';
import 'inggo_badge.dart';

/// Inggo VTC Design System — Carte profil conducteur v2.0
/// Avatar + nom + rôle + badges + stats en ligne
class InggoProfileCard extends StatelessWidget {
  final String initials;
  final String name;
  final String role;
  final double? rating;
  final int? totalRides;
  final String? punctuality;
  final String? seniority;
  final bool isVerified;
  final List<Widget>? extraBadges;

  const InggoProfileCard({
    super.key,
    required this.initials,
    required this.name,
    this.role = 'Conducteur',
    this.rating,
    this.totalRides,
    this.punctuality,
    this.seniority,
    this.isVerified = false,
    this.extraBadges,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: [AppShadows.card],
      ),
      child: Column(
        children: [
          // ── Header : Avatar + Info ──
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 24.w, 24.w, 16.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar rond avec initiales
                Container(
                  width: AppSpacing.iconAvatar,
                  height: AppSpacing.iconAvatar,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 3),
                  ),
                  child: Center(
                    child: Text(
                      initials.toUpperCase(),
                      style: AppTextStyles.headline3.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: AppTextStyles.headline2
                              .copyWith(fontSize: 16)),
                      SizedBox(height: 2.h),
                      Text(
                        '$role · ${isVerified ? "Approuvé" : "En attente"}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isVerified
                              ? AppColors.success
                              : AppColors.textHint,
                          fontWeight:
                              isVerified ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                      if (rating != null || totalRides != null) ...[
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            if (rating != null)
                              InggoBadge(
                                label:
                                    '★ ${rating!.toStringAsFixed(1)}',
                                variant: InggoBadgeVariant.yellow,
                              ),
                            if (totalRides != null) ...[
                              SizedBox(width: 4.w),
                              InggoBadge(
                                label: '$totalRides courses',
                                variant: InggoBadgeVariant.grey,
                              ),
                            ],
                            ...?extraBadges,
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ── Stats en ligne ──
          if (rating != null ||
              totalRides != null ||
              punctuality != null ||
              seniority != null)
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              padding: EdgeInsets.fromLTRB(0, 14.h, 0, 14.h),
              child: Row(
                children: [
                  if (rating != null)
                    _buildStat(rating!.toStringAsFixed(1), 'Note'),
                  if (totalRides != null) _buildStat('$totalRides', 'Courses'),
                  if (punctuality != null)
                    _buildStat(punctuality!, 'Ponctualité'),
                  if (seniority != null) _buildStat(seniority!, 'Ancienneté'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTextStyles.statValue),
          SizedBox(height: 3.h),
          Text(label, style: AppTextStyles.statLabel),
        ],
      ),
    );
  }
}
