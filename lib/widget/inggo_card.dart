import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/constants/constants.dart';
import '../core/utils/formatters.dart';
import '../l10n/app_localizations.dart';

class InggoCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final VoidCallback? onTap;
  final bool isAccent;
  final Color? accentColor;

  const InggoCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.onTap,
    this.isAccent = false,
    this.accentColor,
  });

  @override
  State<InggoCard> createState() => _InggoCardState();
}

class _InggoCardState extends State<InggoCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: widget.padding ?? EdgeInsets.all(AppSpacing.cardPadding),
          margin: widget.margin,
          decoration: BoxDecoration(
            color: widget.color ?? AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            boxShadow: [_isHovered ? AppShadows.cardHover : AppShadows.card],
            border: Border(
              top: widget.isAccent
                  ? BorderSide(
                      color: widget.accentColor ?? AppColors.primary,
                      width: 3,
                    )
                  : BorderSide(color: AppColors.border, width: 1),
              left: BorderSide(color: AppColors.border, width: 1),
              right: BorderSide(color: AppColors.border, width: 1),
              bottom: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          child: widget.child,
        ),
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
    final loc = AppLocalizations.of(context);
    final paymentLabel = paymentMethod == 'cash'
        ? loc.paymentCash
        : paymentMethod == 'waafi'
            ? loc.paymentWaafi
            : paymentMethod == 'dmoney'
                ? loc.paymentDMoney
                : paymentMethod;
    return InggoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(loc.rideSummary, style: AppTextStyles.labelLarge),
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
          _infoRow(loc.price, Formatters.formatPrice(price),
              valueStyle: AppTextStyles.priceSmall),
          if (distance != null)
            _infoRow(loc.distance, Formatters.formatDistance(distance!)),
          if (duration != null)
            _infoRow(loc.estimatedDuration, Formatters.formatDuration(duration!)),
          _infoRow(loc.payment, paymentLabel),
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
