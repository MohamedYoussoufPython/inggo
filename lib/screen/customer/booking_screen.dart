import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/constants.dart';
import '../../core/utils/formatters.dart';
import '../../widget/widgets.dart';
import '../../provider/ride_provider.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  String _selectedPayment = 'cash';

  /// Calculate distance between two coordinates using Haversine formula (in km)
  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // km
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRad(double deg) => deg * pi / 180;

  /// Calculate price based on distance.
  /// Base price: 250 FDJ (covers up to 3 km).
  /// Each additional km: 50 FDJ.
  /// Minimum price: 250 FDJ.
  double _calculatePrice(double distanceKm) {
    const double basePrice = 250;
    const double baseDistanceKm = 3.0;
    const double pricePerKm = 50;

    if (distanceKm <= baseDistanceKm) return basePrice;
    final extraKm = distanceKm - baseDistanceKm;
    return basePrice + (extraKm * pricePerKm).ceilToDouble();
  }

  @override
  Widget build(BuildContext context) {
    final ride = ref.watch(rideProvider);

    // Calculate distance and dynamic price
    final double distanceKm;
    if (ride.pickupLat != null &&
        ride.pickupLng != null &&
        ride.dropoffLat != null &&
        ride.dropoffLng != null) {
      distanceKm = _calculateDistance(
        ride.pickupLat!,
        ride.pickupLng!,
        ride.dropoffLat!,
        ride.dropoffLng!,
      );
    } else {
      distanceKm = 0;
    }

    final price = _calculatePrice(distanceKm);

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
              price: price,
              paymentMethod: _selectedPayment,
            ),
            if (distanceKm > 0)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Text(
                  'Distance estimée : ${Formatters.formatDistance(distanceKm * 1000)}',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
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
              label: 'Confirmer la réservation — ${price.toInt()} FDJ',
              onPressed: () {
                // Update the price in the ride state before creating
                ref.read(rideProvider.notifier).setCalculatedPrice(price);
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
