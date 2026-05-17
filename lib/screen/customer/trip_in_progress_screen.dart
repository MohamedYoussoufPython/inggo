import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/constants.dart';
import '../../core/utils/formatters.dart';
import '../../widget/widgets.dart';
import '../../provider/ride_provider.dart';
import '../../model/ride_model.dart';
import '../../l10n/app_localizations.dart';

class TripInProgressScreen extends ConsumerWidget {
  const TripInProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ride = ref.watch(rideProvider);
    final loc = AppLocalizations.of(context);

    ref.listen<RideState>(rideProvider, (prev, next) {
      if (next.currentRide?.status == RideStatus.completed) {
        context.go('/client/end-trip');
      }
      if (next.currentRide?.status == RideStatus.cancelled) {
        context.go('/client/home');
      }
    });

    final currentRide = ride.currentRide;
    final isInProgress = currentRide?.status == RideStatus.inProgress;
    final statusLabel = isInProgress ? loc.rideInProgressLabel : loc.driverOnTheWayLabel;
    final topLabel = isInProgress ? loc.rideInProgressLabel : loc.driverEnRoute;

    return Scaffold(
      body: Stack(
        children: [
          MapWidget(
            pickupLat: currentRide?.pickupLat,
            pickupLng: currentRide?.pickupLng,
            dropoffLat: currentRide?.dropoffLat,
            dropoffLng: currentRide?.dropoffLng,
            driverLat: ride.driverLat,
            driverLng: ride.driverLng,
          ),
          // Top info
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Row(
                  children: [
                    Icon(
                        isInProgress
                            ? Icons.motorcycle
                            : Icons.access_time,
                        color: AppColors.secondary,
                        size: 24.w),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(topLabel,
                              style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.secondary)),
                          Text(
                            Formatters.formatPrice(
                                currentRide?.price ?? 250),
                            style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.secondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Bottom driver info
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.all(AppSpacing.screenPadding),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppSpacing.radiusXl)),
                boxShadow: [AppShadows.lg],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(statusLabel, style: AppTextStyles.labelLarge),
                  SizedBox(height: 12.h),
                  DriverCard(
                    name: ride.driverName ?? loc.driver,
                    rating: ride.driverRating,
                    totalRides: ride.driverTotalRides,
                    plateNumber: ride.driverPlateNumber,
                    avatarUrl: ride.driverAvatarUrl,
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: InggoButton(
                          label: loc.callDriver,
                          type: InggoButtonType.outline,
                          size: InggoButtonSize.medium,
                          icon: Icons.phone,
                          onPressed: () => _callDriver(
                              context, ride.driverPhone),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: InggoButton(
                          label: loc.cancelRideLabel,
                          type: InggoButtonType.danger,
                          size: InggoButtonSize.medium,
                          onPressed: () {
                            ref
                                .read(rideProvider.notifier)
                                .cancelRide(loc.cancelReasonClient);
                            context.go('/client/home');
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Launch phone dialer with the driver's phone number
  Future<void> _callDriver(BuildContext context, String? phone) async {
    final loc = AppLocalizations.of(context);
    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.driverPhoneUnavailable),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Ensure the phone number includes the country code (+253 for Djibouti)
    final formattedPhone = phone.startsWith('+') ? phone : '+253$phone';
    final uri = Uri(scheme: 'tel', path: formattedPhone);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.unableToMakeCall),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
