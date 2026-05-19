import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/constants.dart';
import '../../core/utils/formatters.dart';
import '../../widget/widgets.dart';
import '../../provider/driver_provider.dart';
import '../../l10n/app_localizations.dart';

class EndRideScreen extends ConsumerWidget {
  const EndRideScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driverState = ref.watch(driverProvider);
    final ride = driverState.currentRide;
    final loc = AppLocalizations.of(context);

    // Real values from the completed ride, with safe fallbacks
    final price = ride?.price ?? AppConstants.ridePrice;
    final commission = ride?.commission ?? AppConstants.rideCommission;
    final driverEarning = price - commission;
    final paymentMethod = ride?.paymentMethod.name ?? 'cash';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 64.w, color: AppColors.success),
              SizedBox(height: 16.h),
              Text(loc.rideCompletedExclamation, style: AppTextStyles.headline2),
              SizedBox(height: 24.h),
              InggoCard(
                child: Column(
                  children: [
                    _row(loc.totalPrice, Formatters.formatPrice(price)),
                    _row(loc.yourEarning, Formatters.formatPrice(driverEarning)),
                    _row(loc.commission, Formatters.formatPrice(commission)),
                    _row(loc.payment, _formatPaymentMethod(paymentMethod, loc)),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                '${loc.collectReminder} ${price.toInt()} ${AppConstants.currency} ${loc.fromClient}',
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.warning),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              InggoButton(
                label: loc.backToHome,
                onPressed: () {
                  // Clear the completed ride data and go back to home
                  ref.read(driverProvider.notifier).clearCompletedRide();
                  context.go('/driver/home');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(label, style: AppTextStyles.bodyMedium)),
          Text(value, style: AppTextStyles.labelMedium),
        ],
      ),
    );
  }

  String _formatPaymentMethod(String method, AppLocalizations loc) {
    switch (method) {
      case 'waafi':
        return loc.paymentWaafi;
      case 'dmoney':
        return loc.paymentDMoney;
      case 'cacpay':
        return loc.paymentCacPay;
      case 'sabapay':
        return loc.paymentSabaPay;
      case 'dahabplus':
        return loc.paymentDahabplus;
      default:
        return loc.paymentCash;
    }
  }
}
