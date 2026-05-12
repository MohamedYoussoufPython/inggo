import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/constants.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/formatters.dart';
import '../../model/ride_model.dart';
import '../../widget/widgets.dart';
import '../../provider/driver_provider.dart';
import '../../l10n/app_localizations.dart';

class EarningsScreen extends ConsumerStatefulWidget {
  const EarningsScreen({super.key});

  @override
  ConsumerState<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends ConsumerState<EarningsScreen> {
  List<RideModel> _rideHistory = [];
  bool _isLoadingHistory = false;
  int _historyPage = 0;
  bool _hasMoreHistory = true;
  static const int _pageSize = 20;

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

      final data = await SupabaseService.instance.getAllPaginated(
        'rides',
        query: {
          'driver_id': userId,
          'status': 'completed',
        },
        orderBy: 'created_at',
        ascending: false,
        limit: _pageSize,
        offset: 0,
      );
      if (mounted) {
        setState(() {
          _rideHistory = data.map((e) => RideModel.fromJson(e)).toList();
          _isLoadingHistory = false;
          _historyPage = 1;
          _hasMoreHistory = data.length >= _pageSize;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingHistory = false);
    }
  }

  Future<void> _loadMoreHistory() async {
    if (!_hasMoreHistory || _isLoadingHistory) return;

    setState(() => _isLoadingHistory = true);
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) return;

      final offset = _historyPage * _pageSize;
      final data = await SupabaseService.instance.getAllPaginated(
        'rides',
        query: {
          'driver_id': userId,
          'status': 'completed',
        },
        orderBy: 'created_at',
        ascending: false,
        limit: _pageSize,
        offset: offset,
      );
      if (mounted) {
        final newRides = data.map((e) => RideModel.fromJson(e)).toList();
        setState(() {
          _rideHistory = [..._rideHistory, ...newRides];
          _isLoadingHistory = false;
          _historyPage++;
          _hasMoreHistory = newRides.length >= _pageSize;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingHistory = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final driver = ref.watch(driverProvider);
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: InggoAppBar(title: loc.earnings),
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
                    Text(loc.totalEarningsLabel,
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
                        Text('${driver.totalRides} ${loc.ridesCount}',
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.secondary)),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Text(loc.details, style: AppTextStyles.labelLarge),
              SizedBox(height: 12.h),
              InggoCard(
                child: Column(
                  children: [
                    _row(loc.pricePerRide, Formatters.formatPrice(AppConstants.ridePrice)),
                    _row(loc.yourEarningPerRide, Formatters.formatPrice(AppConstants.driverEarning)),
                    _row(loc.commission50, Formatters.formatPrice(AppConstants.rideCommission)),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Text(loc.rideHistory, style: AppTextStyles.labelLarge),
              SizedBox(height: 12.h),
              _rideHistory.isEmpty && _isLoadingHistory
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
                                Text(loc.noCompletedRides,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _rideHistory.length + (_hasMoreHistory ? 1 : 0),
                          itemBuilder: (context, index) {
                            // Load more trigger
                            if (index == _rideHistory.length) {
                              _loadMoreHistory();
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                child: const Center(
                                    child: CircularProgressIndicator()),
                              );
                            }

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
                                            status: ride.status),
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
