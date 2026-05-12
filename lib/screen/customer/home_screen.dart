import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/constants.dart';
import '../../core/services/location_service.dart';
import '../../core/services/connectivity_service.dart';
import '../../widget/widgets.dart';
import '../../provider/auth_provider.dart';
import '../../l10n/app_localizations.dart';

class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    await LocationService.instance.getCurrentPosition();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final position = LocationService.instance.currentPosition;
    final loc = AppLocalizations.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Map
          MapWidget(
            initialLat: position?.latitude ?? AppConstants.defaultLat,
            initialLng: position?.longitude ?? AppConstants.defaultLng,
          ),
          // Top bar + OfflineBanner
          SafeArea(
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
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.push('/client/profile'),
                        child: CircleAvatar(
                          radius: 20.r,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            (auth.user?.fullName.isNotEmpty == true
                                    ? auth.user!.fullName.substring(0, 1)
                                    : 'U')
                                .toUpperCase(),
                            style: AppTextStyles.headline4
                                .copyWith(color: AppColors.secondary),
                          ),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => context.push('/client/notifications'),
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusFull),
                            boxShadow: [AppShadows.sm],
                          ),
                          child: Icon(Icons.notifications_outlined,
                              color: AppColors.textPrimary, size: 24.w),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Bottom card
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
                  Text(loc.whereTo, style: AppTextStyles.headline4),
                  SizedBox(height: 12.h),
                  GestureDetector(
                    onTap: () => context.push('/client/search'),
                    child: Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search,
                              color: AppColors.textHint, size: 20.w),
                          SizedBox(width: 12.w),
                          Text(loc.searchDestination,
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: AppColors.textHint)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const InggoBottomNav(currentIndex: 0),
    );
  }
}
