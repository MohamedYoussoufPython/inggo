import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/constants.dart';
import '../../core/utils/formatters.dart';
import '../../model/ride_model.dart';
import '../../widget/widgets.dart';
import '../../provider/driver_provider.dart';
import '../../l10n/app_localizations.dart';

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
  bool _isAccepting = false;

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
        context.go('/driver/home');
      }
    });
  }

  Future<void> _accept() async {
    // Prevent double-tap
    if (_isAccepting) return;
    setState(() => _isAccepting = true);

    _timer?.cancel();
    final rideId = widget.ride.id;

    // Await the accept — it fetches the full ride from DB
    final success = await ref.read(driverProvider.notifier).acceptRide(rideId);

    if (!mounted) return;

    if (success) {
      // Navigate to the active ride screen with the map
      context.go('/driver/ride');
    } else {
      // Accept failed (ride taken by another driver, network error, etc.)
      setState(() => _isAccepting = false);
      InggoToast.error(context, AppLocalizations.of(context).rideAcceptFailed);
      context.go('/driver/home');
    }
  }

  void _reject() {
    _timer?.cancel();
    ref.read(driverProvider.notifier).rejectRide();
    context.go('/driver/home');
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final ride = widget.ride;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _reject();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(loc.newRideRequestExclamation, style: AppTextStyles.headline2),
                SizedBox(height: 8.h),
                Text(
                  '$_remainingSeconds s',
                  style: AppTextStyles.price.copyWith(
                    color: _remainingSeconds <= 3 ? AppColors.error : AppColors.primary,
                  ),
                ),
                SizedBox(height: 24.h),
                InggoCard(
                  child: Column(
                    children: [
                      _row(Icons.trip_origin, loc.pickup, ride.pickupAddress),
                      SizedBox(height: 8.h),
                      _row(Icons.location_on, loc.dropoff, ride.dropoffAddress),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(loc.price, style: AppTextStyles.bodyMedium),
                          Text(Formatters.formatPrice(ride.price),
                              style: AppTextStyles.priceSmall),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(loc.payment, style: AppTextStyles.bodyMedium),
                          Text(_formatPaymentMethod(ride.paymentMethod.name, loc),
                              style: AppTextStyles.bodyLarge),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),
                if (_isAccepting)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: InggoLoading(),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: InggoButton(
                          label: loc.decline,
                          type: InggoButtonType.outline,
                          onPressed: _reject,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: InggoButton(
                          label: loc.accept,
                          onPressed: _accept,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
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
              Text(label, style: AppTextStyles.bodySmall),
              Text(value,
                  style: AppTextStyles.bodyLarge,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
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
