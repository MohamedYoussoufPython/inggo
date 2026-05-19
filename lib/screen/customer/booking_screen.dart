import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/constants.dart';
import '../../widget/widgets.dart';
import '../../provider/ride_provider.dart';
import '../../l10n/app_localizations.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  String _selectedPayment = 'cash';
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    // Sync local state with the provider on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ride = ref.read(rideProvider);
      if (ride.selectedPaymentMethod != _selectedPayment) {
        setState(() => _selectedPayment = ride.selectedPaymentMethod);
      }
    });
  }

  Future<void> _confirmBooking() async {
    if (_isCreating) return;
    setState(() => _isCreating = true);
    final loc = AppLocalizations.of(context);

    // Set payment method and fixed price
    ref.read(rideProvider.notifier).setPaymentMethod(_selectedPayment);
    ref.read(rideProvider.notifier).setCalculatedPrice(AppConstants.ridePrice);

    // AWAIT the ride creation — if it fails, user stays on booking screen
    await ref.read(rideProvider.notifier).createRide();

    if (!mounted) return;

    final ride = ref.read(rideProvider);
    if (ride.error != null) {
      // Ride creation failed — show error and stay on booking screen
      setState(() => _isCreating = false);
      InggoToast.error(context, '${loc.error}: ${ride.error}');
      return;
    }

    // Ride created successfully — navigate to searching screen
    context.go('/client/searching');
  }

  @override
  Widget build(BuildContext context) {
    final ride = ref.watch(rideProvider);
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: InggoAppBar(title: loc.bookRide),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RideSummaryCard(
              pickupAddress: ride.pickupAddress ?? loc.currentPosition,
              dropoffAddress: ride.dropoffAddress ?? loc.destinationFallback,
              price: AppConstants.ridePrice, // Fixed price 250 FDJ
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
              label: _isCreating
                  ? loc.creatingBooking
                  : '${loc.confirmBookingPrice} — ${AppConstants.ridePrice.toInt()} ${AppConstants.currency}',
              isLoading: _isCreating,
              onPressed: _confirmBooking,
            ),
          ],
        ),
      ),
    );
  }
}
