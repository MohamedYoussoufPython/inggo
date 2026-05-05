import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/constants.dart';
import '../../widget/widgets.dart';
import '../../provider/ride_provider.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  String _selectedPayment = 'cash';

  @override
  Widget build(BuildContext context) {
    final ride = ref.watch(rideProvider);

    return Scaffold(
      appBar: InggoAppBar(title: 'Réserver'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RideSummaryCard(
              pickupAddress: ride.pickupAddress ?? 'Position actuelle',
              dropoffAddress: ride.dropoffAddress ?? 'Destination',
              price: AppConstants.ridePrice,
              paymentMethod: _selectedPayment,
            ),
            SizedBox(height: 24.h),
            PaymentMethodSelector(
              selectedMethod: _selectedPayment,
              onMethodSelected: (method) {
                setState(() => _selectedPayment = method);
                ref.read(rideProvider.notifier).setPaymentMethod(method);
              },
            ),
            SizedBox(height: 32.h),
            InggoButton(
              label: 'Confirmer la réservation — ${AppConstants.ridePrice.toInt()} FDJ',
              onPressed: () {
                ref.read(rideProvider.notifier).createRide();
                context.go('/client/searching');
              },
            ),
          ],
        ),
      ),
    );
  }
}
