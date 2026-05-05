import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/supabase_service.dart';
import '../core/services/location_service.dart';
import '../core/constants/app_constants.dart';
import '../model/ride_model.dart';

class RideState {
  final bool isLoading;
  final RideModel? currentRide;
  final List<RideModel> rideHistory;
  final String? error;
  final String selectedPaymentMethod;
  final String? pickupAddress;
  final double? pickupLat;
  final double? pickupLng;
  final String? dropoffAddress;
  final double? dropoffLat;
  final double? dropoffLng;

  const RideState({
    this.isLoading = false,
    this.currentRide,
    this.rideHistory = const [],
    this.error,
    this.selectedPaymentMethod = AppConstants.paymentCash,
    this.pickupAddress,
    this.pickupLat,
    this.pickupLng,
    this.dropoffAddress,
    this.dropoffLat,
    this.dropoffLng,
  });

  RideState copyWith({
    bool? isLoading,
    RideModel? currentRide,
    List<RideModel>? rideHistory,
    String? error,
    String? selectedPaymentMethod,
    String? pickupAddress,
    double? pickupLat,
    double? pickupLng,
    String? dropoffAddress,
    double? dropoffLat,
    double? dropoffLng,
  }) {
    return RideState(
      isLoading: isLoading ?? this.isLoading,
      currentRide: currentRide ?? this.currentRide,
      rideHistory: rideHistory ?? this.rideHistory,
      error: error,
      selectedPaymentMethod:
          selectedPaymentMethod ?? this.selectedPaymentMethod,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      dropoffLat: dropoffLat ?? this.dropoffLat,
      dropoffLng: dropoffLng ?? this.dropoffLng,
    );
  }
}

class RideNotifier extends StateNotifier<RideState> {
  RideNotifier() : super(const RideState());

  void setPickup(String address, double lat, double lng) {
    state = state.copyWith(
      pickupAddress: address,
      pickupLat: lat,
      pickupLng: lng,
    );
  }

  void setDropoff(String address, double lat, double lng) {
    state = state.copyWith(
      dropoffAddress: address,
      dropoffLat: lat,
      dropoffLng: lng,
    );
  }

  void setPaymentMethod(String method) {
    state = state.copyWith(selectedPaymentMethod: method);
  }

  Future<void> createRide() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) throw Exception('Non authentifié');

      final position = await LocationService.instance.getCurrentPosition();
      final pickupLat = state.pickupLat ?? position?.latitude ?? AppConstants.defaultLat;
      final pickupLng = state.pickupLng ?? position?.longitude ?? AppConstants.defaultLng;

      final data = await SupabaseService.instance.insert('rides', {
        'client_id': userId,
        'pickup_address': state.pickupAddress ?? 'Position actuelle',
        'pickup_lat': pickupLat,
        'pickup_lng': pickupLng,
        'dropoff_address': state.dropoffAddress ?? '',
        'dropoff_lat': state.dropoffLat ?? 0.0,
        'dropoff_lng': state.dropoffLng ?? 0.0,
        'price': AppConstants.ridePrice,
        'commission': AppConstants.rideCommission,
        'payment_method': state.selectedPaymentMethod,
        'status': 'searching',
      });

      final ride = RideModel.fromJson(data);
      state = state.copyWith(isLoading: false, currentRide: ride);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> cancelRide(String reason) async {
    if (state.currentRide == null) return;
    try {
      await SupabaseService.instance.update(
        'rides',
        state.currentRide!.id,
        {'status': 'cancelled', 'cancel_reason': reason},
      );
      state = state.copyWith(
        currentRide: state.currentRide!.copyWith(
          status: RideStatus.cancelled,
          cancelReason: reason,
        ),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> rateDriver(double rating, {String? review}) async {
    if (state.currentRide == null) return;
    try {
      await SupabaseService.instance.update(
        'rides',
        state.currentRide!.id,
        {'rating': rating, 'review': review},
      );
      state = state.copyWith(
        currentRide: state.currentRide!.copyWith(rating: rating, review: review),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true);
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) return;

      final data = await SupabaseService.instance.getAll(
        'rides',
        query: {'client_id': userId},
        orderBy: 'created_at',
        ascending: false,
      );
      final rides = data.map((e) => RideModel.fromJson(e)).toList();
      state = state.copyWith(isLoading: false, rideHistory: rides);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() {
    state = const RideState();
  }
}

final rideProvider = StateNotifierProvider<RideNotifier, RideState>((ref) {
  return RideNotifier();
});
