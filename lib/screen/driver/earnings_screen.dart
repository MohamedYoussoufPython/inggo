import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/constants.dart';
import '../../core/utils/formatters.dart';
import '../../widget/widgets.dart';
import '../../provider/driver_provider.dart';

class EarningsScreen extends ConsumerStatefulWidget {
  const EarningsScreen({super.key});

  @override
  ConsumerState<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends ConsumerState<EarningsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(driverProvider.notifier).loadDriver());
  }

  @override
  Widget build(BuildContext context) {
    final driver = ref.watch(driverProvider);

    return Scaffold(
      appBar: const InggoAppBar(title: 'Revenus'),
      body: Padding(
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
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.secondary)),
                  SizedBox(height: 8.h),
                  Text(Formatters.formatPrice(driver.totalEarnings),
                      style: AppTextStyles.headline1.copyWith(
                          color: AppColors.secondary)),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Icon(Icons.motorcycle, color: AppColors.secondary, size: 20.w),
                      SizedBox(width: 8.w),
                      Text('${driver.totalRides} courses',
                          style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.secondary)),
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
          ],
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
}
