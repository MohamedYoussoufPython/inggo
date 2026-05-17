import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/constants.dart';
import '../../core/utils/formatters.dart';
import '../../widget/widgets.dart';
import '../../provider/ride_provider.dart';
import '../../l10n/app_localizations.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(rideProvider.notifier).loadHistory());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    final ride = ref.read(rideProvider);
    if (!ride.hasMoreHistory || _isLoadingMore) return;

    setState(() => _isLoadingMore = true);
    await ref.read(rideProvider.notifier).loadMoreHistory();
    if (mounted) setState(() => _isLoadingMore = false);
  }

  Future<void> _refresh() async {
    await ref.read(rideProvider.notifier).loadHistory();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ride = ref.watch(rideProvider);
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: InggoAppBar(title: loc.history),
      body: ride.isLoading && ride.rideHistory.isEmpty
          ? const InggoLoading()
          : ride.rideHistory.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history, size: 64.w, color: AppColors.textHint),
                      SizedBox(height: 16.h),
                      Text(loc.noRides, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(AppSpacing.screenPadding),
                    itemCount: ride.rideHistory.length + (_isLoadingMore || ride.hasMoreHistory ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Loading indicator at the bottom
                      if (index == ride.rideHistory.length) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: Center(
                            child: InggoLoading(),
                          ),
                        );
                      }

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
                                    style: AppTextStyles.bodySmall),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
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
