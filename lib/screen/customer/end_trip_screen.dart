import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/constants.dart';
import '../../core/utils/formatters.dart';
import '../../widget/widgets.dart';
import '../../provider/ride_provider.dart';

class EndTripScreen extends ConsumerStatefulWidget {
  const EndTripScreen({super.key});

  @override
  ConsumerState<EndTripScreen> createState() => _EndTripScreenState();
}

class _EndTripScreenState extends ConsumerState<EndTripScreen> {
  double _rating = 5.0;
  final _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  /// Map PaymentMethod enum to a human-readable French label
  String _paymentMethodLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Espèces';
      case PaymentMethod.waafi:
        return 'Waafi';
      case PaymentMethod.dmoney:
        return 'D-Money';
      case PaymentMethod.cacpay:
        return 'CAC Pay';
      case PaymentMethod.sabapay:
        return 'Saba Pay';
      case PaymentMethod.dahabplus:
        return 'Dahabplus';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ride = ref.watch(rideProvider);
    final currentRide = ride.currentRide;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              Icon(Icons.check_circle,
                  size: 64.w, color: AppColors.success),
              SizedBox(height: 16.h),
              Text('Course terminée !',
                  style: AppTextStyles.headline2),
              SizedBox(height: 24.h),
              InggoCard(
                child: Column(
                  children: [
                    _infoRow('Départ', currentRide?.pickupAddress ?? '-'),
                    _infoRow('Arrivée', currentRide?.dropoffAddress ?? '-'),
                    const Divider(),
                    _infoRow('Prix',
                        Formatters.formatPrice(currentRide?.price ?? 250),
                        valueStyle: AppTextStyles.priceSmall),
                    _infoRow(
                      'Paiement',
                      _paymentMethodLabel(
                          currentRide?.paymentMethod ?? PaymentMethod.cash),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),
              Text('Notez votre chauffeur',
                  style: AppTextStyles.headline4),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => GestureDetector(
                    onTap: () =>
                        setState(() => _rating = (index + 1).toDouble()),
                    child: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: AppColors.primary,
                      size: 40.w,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              InggoInput(
                hint: 'Laisser un avis (optionnel)',
                controller: _reviewController,
                maxLines: 3,
              ),
              SizedBox(height: 32.h),
              InggoButton(
                label: 'Terminé',
                onPressed: () {
                  ref.read(rideProvider.notifier).rateDriver(
                        _rating,
                        review: _reviewController.text.trim().isEmpty
                            ? null
                            : _reviewController.text.trim(),
                      );
                  ref.read(rideProvider.notifier).reset();
                  context.go('/client/home');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Text(value, style: valueStyle ?? AppTextStyles.bodyLarge),
        ],
      ),
    );
  }
}
