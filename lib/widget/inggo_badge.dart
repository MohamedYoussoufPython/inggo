import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/constants/constants.dart';
import '../model/ride_model.dart';

class InggoBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? textColor;

  const InggoBadge({
    super.key,
    required this.label,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: (color ?? AppColors.primary).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: textColor ?? color ?? AppColors.primary,
        ),
      ),
    );
  }
}

class RideStatusBadge extends StatelessWidget {
  final RideStatus status;
  const RideStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final cfg = _config();
    return InggoBadge(label: cfg['label'], color: cfg['color']);
  }

  Map<String, dynamic> _config() {
    switch (status) {
      case RideStatus.pending:
        return {'label': 'En attente', 'color': AppColors.pending};
      case RideStatus.searching:
        return {'label': 'Recherche...', 'color': AppColors.searching};
      case RideStatus.accepted:
        return {'label': 'Acceptée', 'color': AppColors.accepted};
      case RideStatus.inProgress:
        return {'label': 'En cours', 'color': AppColors.inProgress};
      case RideStatus.completed:
        return {'label': 'Terminée', 'color': AppColors.completed};
      case RideStatus.cancelled:
        return {'label': 'Annulée', 'color': AppColors.cancelled};
    }
  }
}
