import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/constants.dart';
import '../../core/utils/formatters.dart';
import '../../model/ride_model.dart';
import '../../widget/widgets.dart';
import '../../provider/driver_provider.dart';

class RideRequestScreen extends ConsumerStatefulWidget {
  final RideModel ride;

  const RideRequestScreen({super.key, required this.ride});

  @override
  ConsumerState<RideRequestScreen> createState() => _RideRequestScreenState();
}

class _RideRequestScreenState extends ConsumerState<RideRequestScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _remainingSeconds = AppConstants.rideRequestTimeoutSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: AppConstants.rideRequestTimeoutSeconds),
    )..forward();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _remainingSeconds--);
      if (_remainingSeconds <= 0) {
        timer.cancel();
        ref.read(driverProvider.notifier).rejectRide();
        Navigator.pop(context);
      }
    });
  }

  void _accept() {
    _timer?.cancel();
    final rideId = widget.ride.id;
    ref.read(driverProvider.notifier).acceptRide(rideId);
    Navigator.pop(context, true);
  }

  void _reject() {
    _timer?.cancel();
    ref.read(driverProvider.notifier).rejectRide();
    Navigator.pop(context, false);
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ride = widget.ride;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Nouvelle demande !',
                  style: AppTextStyles.headline2),
              SizedBox(height: 8.h),
              Text('$_remainingSeconds s',
                  style: AppTextStyles.price.copyWith(color: _remainingSeconds <= 3 ? AppColors.error : AppColors.primary)),
              SizedBox(height: 24.h),
              InggoCard(
                child: Column(
                  children: [
                    _row(Icons.trip_origin, 'Départ', ride.pickupAddress),
                    SizedBox(height: 8.h),
                    _row(Icons.location_on, 'Arrivée', ride.dropoffAddress),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Prix', style: AppTextStyles.bodyMedium),
                        Text(Formatters.formatPrice(ride.price),
                        style: AppTextStyles.priceSmall),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Paiement', style: AppTextStyles.bodyMedium),
                        Text(_formatPaymentMethod(ride.paymentMethod.name),
                            style: AppTextStyles.bodyLarge),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),
              Row(
                children: [
                  Expanded(
                    child: InggoButton(
                      label: 'Refuser',
                      type: InggoButtonType.outline,
                      onPressed: _reject,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: InggoButton(
                      label: 'Accepter',
                      onPressed: _accept,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20.w, color: AppColors.primary),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption),
              Text(value, style: AppTextStyles.bodyLarge, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
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
