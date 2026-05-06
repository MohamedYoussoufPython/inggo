import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/constants.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/formatters.dart';
import '../../model/ride_model.dart';
import '../../widget/widgets.dart';
import '../../provider/driver_provider.dart';

class EarningsScreen extends ConsumerStatefulWidget {
  const EarningsScreen({super.key});

  @override
  ConsumerState<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends ConsumerState<EarningsScreen> {
  List<RideModel> _rideHistory = [];
  bool _isLoadingHistory = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(driverProvider.notifier).loadDriver();
      _loadRideHistory();
    });
  }

  Future<void> _loadRideHistory() async {
    setState(() => _isLoadingHistory = true);
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) return;

      final data = await SupabaseService.instance.getAll(
        'rides',
        query: {
          'driver_id': userId,
          'status': 'completed',
        },
        orderBy: 'created_at',
        ascending: false,
      );
      if (mounted) {
        setState(() {
          _rideHistory = data.map((e) => RideModel.fromJson(e)).toList();
          _isLoadingHistory = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingHistory = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final driver = ref.watch(driverProvider);

    return Scaffold(
      appBar: const InggoAppBar(title: 'Revenus'),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ref.read(driverProvider.notifier).loadDriver(),
            _loadRideHistory(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total earnings card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Revenus totaux',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.secondary)),
                    SizedBox(height: 8.h),
                    Text(Formatters.formatPrice(driver.totalEarnings),
                        style: AppTextStyles.headline1
                            .copyWith(color: AppColors.secondary)),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Icon(Icons.motorcycle,
                            color: AppColors.secondary, size: 20.w),
                        SizedBox(width: 8.w),
                        Text('${driver.totalRides} courses',
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.secondary)),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Text('Détails', style: AppTextStyles.labelLarge),
              SizedBox(height: 12.h),
              InggoCard(
                child: Column(
                  children: [
                    _row('Prix par course', Formatters.formatPrice(250)),
                    _row('Votre gain/course', Formatters.formatPrice(125)),
                    _row('Commission (50%)', Formatters.formatPrice(125)),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Text('Historique des courses', style: AppTextStyles.labelLarge),
              SizedBox(height: 12.h),
              _isLoadingHistory
                  ? const InggoLoading()
                  : _rideHistory.isEmpty
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 32.h),
                            child: Column(
                              children: [
                                Icon(Icons.history,
                                    size: 48.w, color: AppColors.textHint),
                                SizedBox(height: 8.h),
                                Text('Aucune course terminée',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _rideHistory.length,
                          itemBuilder: (context, index) {
                            final ride = _rideHistory[index];
                            return Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: InggoCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        RideStatusBadge(
                                            status: ride.status.name),
                                        Text(
                                            Formatters.formatPrice(ride.price),
                                            style: AppTextStyles.priceSmall),
                                      ],
                                    ),
                                    SizedBox(height: 8.h),
                                    _rideRow(
                                        Icons.trip_origin, ride.pickupAddress),
                                    SizedBox(height: 4.h),
                                    _rideRow(
                                        Icons.location_on, ride.dropoffAddress),
                                    if (ride.completedAt != null) ...[
                                      SizedBox(height: 8.h),
                                      Text(
                                        Formatters.formatDateTime(
                                            ride.completedAt!),
                                        style: AppTextStyles.caption,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: InggoBottomNav(currentIndex: 1, isDriver: true),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Text(value, style: AppTextStyles.labelMedium),
        ],
      ),
    );
  }

  Widget _rideRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.w, color: AppColors.textSecondary),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(text,
              style: AppTextStyles.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
