import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/constants.dart';
import '../../widget/widgets.dart';
import '../../provider/driver_provider.dart';

class RideRequestScreen extends ConsumerStatefulWidget {
  const RideRequestScreen({super.key});

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
        Navigator.pop(context);
      }
    });
  }

  void _accept(String rideId) {
    _timer?.cancel();
    ref.read(driverProvider.notifier).acceptRide(rideId);
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    _row(Icons.trip_origin, 'Départ', 'Position client'),
                    SizedBox(height: 8.h),
                    _row(Icons.location_on, 'Arrivée', 'Destination'),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Prix', style: AppTextStyles.bodyMedium),
                        Text(Formatters.formatPrice(250), style: AppTextStyles.priceSmall),
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
                      onPressed: () => Navigator.pop(context, false),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: InggoButton(
                      label: 'Accepter',
                      onPressed: () => _accept('ride_id'),
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption),
            Text(value, style: AppTextStyles.bodyLarge),
          ],
        ),
      ],
    );
  }
}
