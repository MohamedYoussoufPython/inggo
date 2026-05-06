import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/constants.dart';
import '../../core/utils/formatters.dart';
import '../../widget/widgets.dart';
import '../../provider/driver_provider.dart';

class EndRideScreen extends ConsumerWidget {
  const EndRideScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driverState = ref.watch(driverProvider);
    final ride = driverState.currentRide;

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
              Text('Course terminée !', style: AppTextStyles.headline2),
              SizedBox(height: 24.h),
              InggoCard(
                child: Column(
                  children: [
                    _row('Prix total', Formatters.formatPrice(price)),
                    _row('Votre gain', Formatters.formatPrice(driverEarning)),
                    _row('Commission', Formatters.formatPrice(commission)),
                    _row('Paiement', _formatPaymentMethod(paymentMethod)),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'N\'oubliez pas de collecter les ${price.toInt()} FDJ du client.',
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.warning),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              InggoButton(
                label: 'Retour à l\'accueil',
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
          Text(label, style: AppTextStyles.bodyMedium),
          Text(value, style: AppTextStyles.labelMedium),
        ],
      ),
    );
  }

  String _formatPaymentMethod(String method) {
    switch (method) {
      case 'waafi':
        return 'Waafi';
      case 'dmoney':
        return 'DMoney';
      case 'cacpay':
        return 'CacPay';
      case 'sabapay':
        return 'SabaPay';
      case 'dahabplus':
        return 'Dahab+';
      default:
        return 'Espèces';
    }
  }
}
