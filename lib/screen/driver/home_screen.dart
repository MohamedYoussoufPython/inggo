import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/constants.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/utils/formatters.dart';
import '../../widget/widgets.dart';
import '../../provider/driver_provider.dart';
import '../../model/ride_model.dart';

class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(driverProvider.notifier).loadDriver();
      // If there's already a pending ride when the screen loads, show it
      final driver = ref.read(driverProvider);
      if (driver.pendingRide != null) {
        _showRideRequest(driver.pendingRide!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final driver = ref.watch(driverProvider);

    // Listen for new ride requests from Realtime
    ref.listen<DriverState>(driverProvider, (prev, next) {
      // When a new pendingRide arrives and we didn't have one before, show the request screen
      if (next.pendingRide != null && prev?.pendingRide == null) {
        _showRideRequest(next.pendingRide!);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Offline banner
            StreamBuilder<bool>(
              stream: ConnectivityService.instance.connectionStream,
              initialData: ConnectivityService.instance.isOnline,
              builder: (context, snapshot) {
                return OfflineBanner(isOnline: snapshot.data ?? true);
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.screenPadding),
                child: Column(
                  children: [
                    SizedBox(height: 16.h),
                    // Online/Offline toggle
                    GestureDetector(
                      onTap: driver.isLoading
                          ? null
                          : () =>
                              ref.read(driverProvider.notifier).toggleOnline(),
                      child: Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: driver.isOnline
                              ? AppColors.success.withValues(alpha: 0.1)
                              : AppColors.error.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusXl),
                          border: Border.all(
                            color: driver.isOnline
                                ? AppColors.success
                                : AppColors.error,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (driver.isLoading)
                              SizedBox(
                                width: 24.w,
                                height: 24.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: driver.isOnline
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                              )
                            else
                              Icon(
                                driver.isOnline ? Icons.wifi : Icons.wifi_off,
                                color: driver.isOnline
                                    ? AppColors.success
                                    : AppColors.error,
                                size: 32.w,
                              ),
                            SizedBox(width: 16.w),
                            Text(
                              driver.isOnline ? 'En ligne' : 'Hors ligne',
                              style: AppTextStyles.headline3.copyWith(
                                color: driver.isOnline
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    // Stats
                    Row(
                      children: [
                        Expanded(
                          child: InggoCard(
                            child: Column(
                              children: [
                                Text(
                                    Formatters.formatPrice(
                                        driver.totalEarnings),
                                    style: AppTextStyles.priceSmall),
                                SizedBox(height: 4.h),
                                Text('Revenus', style: AppTextStyles.bodySmall),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: InggoCard(
                            child: Column(
                              children: [
                                Text('${driver.totalRides}',
                                    style: AppTextStyles.headline3),
                                SizedBox(height: 4.h),
                                Text('Courses', style: AppTextStyles.bodySmall),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32.h),
                    if (!driver.isOnline)
                      Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Column(
                          children: [
                            Icon(Icons.motorcycle,
                                size: 64.w, color: AppColors.textHint),
                            SizedBox(height: 16.h),
                            Text(
                                'Activez-vous pour recevoir des courses',
                                style: AppTextStyles.bodyLarge.copyWith(
                                    color: AppColors.textSecondary),
                                textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: InggoBottomNav(currentIndex: 0, isDriver: true),
    );
  }

  /// Navigate to the ride request screen with the ride data
  void _showRideRequest(RideModel ride) {
    context.go('/driver/ride-request', extra: ride);
  }
}
