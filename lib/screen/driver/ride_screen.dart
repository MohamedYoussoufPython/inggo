import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/constants.dart';
import '../../widget/widgets.dart';
import '../../provider/driver_provider.dart';

class DriverRideScreen extends ConsumerStatefulWidget {
  const DriverRideScreen({super.key});

  @override
  ConsumerState<DriverRideScreen> createState() => _DriverRideScreenState();
}

class _DriverRideScreenState extends ConsumerState<DriverRideScreen> {
  bool _pickedUp = false;

  @override
  Widget build(BuildContext context) {
    final driverState = ref.watch(driverProvider);
    final ride = driverState.currentRide;
    final rideId = ride?.id;

    return Scaffold(
      body: Stack(
        children: [
          MapWidget(
            pickupLat: ride?.pickupLat,
            pickupLng: ride?.pickupLng,
            dropoffLat: ride?.dropoffLat,
            dropoffLng: ride?.dropoffLng,
            initialLat: ride?.pickupLat ?? AppConstants.defaultLat,
            initialLng: ride?.pickupLng ?? AppConstants.defaultLng,
          ),
          // Bottom panel
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
                  Text(
                    _pickedUp ? 'Course en cours' : 'Aller au départ',
                    style: AppTextStyles.headline4,
                  ),
                  SizedBox(height: 8.h),
                  if (!_pickedUp) ...[
                    Text(
                      ride?.pickupAddress ?? 'Rendez-vous au point de départ',
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary),
                    ),
                    SizedBox(height: 16.h),
                    InggoButton(
                      label: 'Arrivé au départ',
                      icon: Icons.check_circle,
                      onPressed: () => setState(() => _pickedUp = true),
                    ),
                  ] else ...[
                    Text(
                      ride?.dropoffAddress ?? 'Conduisez le client à sa destination',
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary),
                    ),
                    SizedBox(height: 16.h),
                    InggoButton(
                      label: 'Terminer la course',
                      icon: Icons.flag,
                      onPressed: () {
                        if (rideId != null) {
                          ref.read(driverProvider.notifier).completeRide(rideId);
                        }
                        context.go('/driver/end-ride');
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
