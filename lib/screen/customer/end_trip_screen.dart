import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/constants.dart';
import '../../core/utils/formatters.dart';
import '../../widget/widgets.dart';
import '../../provider/ride_provider.dart';
import '../../l10n/app_localizations.dart';

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

  /// Map PaymentMethod enum to a human-readable localized label
  String _paymentMethodLabel(PaymentMethod method, AppLocalizations loc) {
    if (method == PaymentMethod.waafi) return loc.paymentWaafi;
    if (method == PaymentMethod.dmoney) return loc.paymentDMoney;
    if (method == PaymentMethod.cacpay) return loc.paymentCacPay;
    if (method == PaymentMethod.sabapay) return loc.paymentSabaPay;
    if (method == PaymentMethod.dahabplus) return loc.paymentDahabplus;
    return loc.paymentCash;
  }

  @override
  Widget build(BuildContext context) {
    final ride = ref.watch(rideProvider);
    final currentRide = ride.currentRide;
    final loc = AppLocalizations.of(context);

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
              Text(loc.rideCompletedExclamation,
                  style: AppTextStyles.headline2),
              SizedBox(height: 24.h),
              InggoCard(
                child: Column(
                  children: [
                    _infoRow(loc.pickup, currentRide?.pickupAddress ?? '-'),
                    _infoRow(loc.dropoff, currentRide?.dropoffAddress ?? '-'),
                    const Divider(),
                    _infoRow(loc.price,
                        Formatters.formatPrice(currentRide?.price ?? 250.0),
                        valueStyle: AppTextStyles.priceSmall),
                    _infoRow(
                      loc.payment,
                      _paymentMethodLabel(
                          currentRide?.paymentMethod ?? PaymentMethod.cash, loc),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),
              Text(loc.rateDriver,
                  style: AppTextStyles.labelLarge),
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
                hint: loc.leaveReview,
                controller: _reviewController,
                maxLines: 3,
              ),
              SizedBox(height: 32.h),
              InggoButton(
                label: loc.done,
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
