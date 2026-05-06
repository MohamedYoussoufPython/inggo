import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/constants.dart';
import '../../core/utils/formatters.dart';
import '../../widget/widgets.dart';
import '../../provider/driver_provider.dart';

class DriverRideScreen extends ConsumerStatefulWidget {
  const DriverRideScreen({super.key});

  @override
  ConsumerState<DriverRideScreen> createState() => _DriverRideScreenState();
}

class _DriverRideScreenState extends ConsumerState<DriverRideScreen> {
  bool _pickedUp = false;
  bool _isCompleting = false;

  @override
  Widget build(BuildContext context) {
    final driverState = ref.watch(driverProvider);
    final ride = driverState.currentRide;

    // If no current ride, show loading
    if (ride == null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                SizedBox(height: 16.h),
                Text('Chargement de la course...', style: AppTextStyles.bodyLarge),
                SizedBox(height: 16.h),
                InggoButton(
                  label: 'Retour',
                  type: InggoButtonType.outline,
                  onPressed: () => context.go('/driver/home'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Map with REAL coordinates from currentRide
          MapWidget(
            pickupLat: ride.pickupLat,
            pickupLng: ride.pickupLng,
            dropoffLat: ride.dropoffLat,
            dropoffLng: ride.dropoffLng,
            initialLat: ride.pickupLat != 0.0 ? ride.pickupLat : AppConstants.defaultLat,
            initialLng: ride.pickupLng != 0.0 ? ride.pickupLng : AppConstants.defaultLng,
          ),
          // Bottom panel with ride info
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
                  // Price badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                    ),
                    child: Text(
                      Formatters.formatPrice(ride.price),
                      style: AppTextStyles.headline4.copyWith(color: AppColors.secondary),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    _pickedUp ? 'Course en cours' : 'Aller au départ',
                    style: AppTextStyles.headline4,
                  ),
                  SizedBox(height: 8.h),
                  if (!_pickedUp) ...[
                    Row(
                      children: [
                        Icon(Icons.trip_origin, size: 16.w, color: AppColors.primary),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            ride.pickupAddress,
                            style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    InggoButton(
                      label: 'Arrivé au départ',
                      icon: Icons.check_circle,
                      onPressed: () => setState(() => _pickedUp = true),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16.w, color: AppColors.error),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            ride.dropoffAddress,
                            style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _isCompleting
                        ? const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          )
                        : InggoButton(
                            label: 'Terminer la course',
                            icon: Icons.flag,
                            onPressed: () async {
                              setState(() => _isCompleting = true);
                              final success = await ref
                                  .read(driverProvider.notifier)
                                  .completeRide();
                              if (!mounted) return;
                              if (success) {
                                context.go('/driver/end-ride');
                              } else {
                                setState(() => _isCompleting = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Erreur lors de la finalisation de la course.'),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
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
