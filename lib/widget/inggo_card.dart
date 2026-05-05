import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/constants/constants.dart';
import '../core/utils/formatters.dart';

class InggoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final VoidCallback? onTap;

  const InggoCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? EdgeInsets.all(AppSpacing.cardPadding),
        margin: margin,
        decoration: BoxDecoration(
          color: color ?? AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: [AppShadows.card],
          border: Border.all(color: AppColors.border),
        ),
        child: child,
      ),
    );
  }
}

class RideSummaryCard extends StatelessWidget {
  final String pickupAddress;
  final String dropoffAddress;
  final double price;
  final String paymentMethod;
  final double? distance;
  final int? duration;

  const RideSummaryCard({
    super.key,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.price,
    required this.paymentMethod,
    this.distance,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return InggoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Récapitulatif', style: AppTextStyles.labelLarge),
          SizedBox(height: 12.h),
          _routeRow(Icons.trip_origin, AppColors.primary, pickupAddress),
          Padding(
            padding: EdgeInsets.only(left: 11.w),
            child: Container(width: 2.w, height: 24.h, color: AppColors.border),
          ),
          _routeRow(Icons.location_on, AppColors.error, dropoffAddress),
          SizedBox(height: 12.h),
          const Divider(),
          SizedBox(height: 8.h),
          _infoRow('Prix', Formatters.formatPrice(price),
              valueStyle: AppTextStyles.priceSmall),
          if (distance != null)
            _infoRow('Distance', Formatters.formatDistance(distance!)),
          if (duration != null)
            _infoRow('Durée estimée', Formatters.formatDuration(duration!)),
          _infoRow('Paiement',
              paymentMethod == 'cash' ? 'Espèces' : paymentMethod),
        ],
      ),
    );
  }

  Widget _routeRow(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22.w),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(text,
              style: AppTextStyles.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Text(value, style: valueStyle ?? AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
