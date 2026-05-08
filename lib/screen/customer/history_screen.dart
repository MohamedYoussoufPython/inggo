import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/constants.dart';
import '../../core/utils/formatters.dart';
import '../../widget/widgets.dart';
import '../../provider/ride_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(rideProvider.notifier).loadHistory());
  }

  @override
  Widget build(BuildContext context) {
    final ride = ref.watch(rideProvider);

    return Scaffold(
      appBar: const InggoAppBar(title: 'Historique'),
      body: ride.isLoading
          ? const InggoLoading()
          : ride.rideHistory.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history, size: 64.w, color: AppColors.textHint),
                      SizedBox(height: 16.h),
                      Text('Aucune course', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(AppSpacing.screenPadding),
                  itemCount: ride.rideHistory.length,
                  itemBuilder: (context, index) {
                    final r = ride.rideHistory[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: InggoCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                RideStatusBadge(status: r.status),
                                Text(Formatters.formatPrice(r.price),
                                    style: AppTextStyles.priceSmall),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            _row(Icons.trip_origin, r.pickupAddress),
                            SizedBox(height: 4.h),
                            _row(Icons.location_on, r.dropoffAddress),
                            if (r.createdAt != null) ...[
                              SizedBox(height: 8.h),
                              Text(Formatters.formatDateTime(r.createdAt!),
                                  style: AppTextStyles.caption),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: const InggoBottomNav(currentIndex: 1),
    );
  }

  Widget _row(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.w, color: AppColors.textSecondary),
        SizedBox(width: 8.w),
        Expanded(child: Text(text, style: AppTextStyles.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
