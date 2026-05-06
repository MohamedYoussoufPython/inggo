import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
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

  static final _log = Logger();
  RealtimeChannel? _rideChannel;

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

      // Start listening for ride updates (driver accepts, etc.)
      _subscribeToRideUpdates(ride.id);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Subscribe to Realtime updates on the current ride
  void _subscribeToRideUpdates(String rideId) {
    _stopRideSubscription(); // clean any previous subscription

    _log.i('Subscribing to ride updates for $rideId');

    _rideChannel = SupabaseService.instance.subscribeToTable(
      'rides',
      filterColumn: 'id',
      filterValue: rideId,
      onChange: (payload) {
        _log.i('Ride update: ${payload.eventType} — new status: ${payload.newRecord['status']}');

        final newStatus = payload.newRecord['status'] as String?;
        if (newStatus == null) return;

        final currentRide = state.currentRide;
        if (currentRide == null) return;

        final updatedRide = currentRide.copyWith(
          status: RideModel.parseRideStatus(newStatus),
          driverId: payload.newRecord['driver_id'] as String?,
          acceptedAt: payload.newRecord['accepted_at'] != null
              ? DateTime.parse(payload.newRecord['accepted_at'] as String)
              : null,
          completedAt: payload.newRecord['completed_at'] != null
              ? DateTime.parse(payload.newRecord['completed_at'] as String)
              : null,
          cancelReason: payload.newRecord['cancel_reason'] as String?,
        );

        state = state.copyWith(currentRide: updatedRide);
      },
    );
  }

  void _stopRideSubscription() {
    if (_rideChannel != null) {
      SupabaseService.instance.unsubscribe(_rideChannel!);
      _rideChannel = null;
      _log.i('Unsubscribed from ride updates');
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
      _stopRideSubscription();
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
    _stopRideSubscription();
    state = const RideState();
  }

  @override
  void dispose() {
    _stopRideSubscription();
    super.dispose();
  }
}

final rideProvider = StateNotifierProvider<RideNotifier, RideState>((ref) {
  return RideNotifier();
});
