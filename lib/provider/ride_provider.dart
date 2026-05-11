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

  // Driver info — fetched from Supabase when a driver accepts the ride
  final String? driverName;
  final String? driverPhone;
  final String? driverPlateNumber;
  final double driverRating;
  final int driverTotalRides;
  final String? driverAvatarUrl;

  // Driver live position — updated via Realtime subscription on drivers table
  final double? driverLat;
  final double? driverLng;

  // Calculated price based on distance
  final double? calculatedPrice;

  // Pagination — track how many pages have been loaded
  final int historyPage;
  final bool hasMoreHistory;

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
    this.driverName,
    this.driverPhone,
    this.driverPlateNumber,
    this.driverRating = 5.0,
    this.driverTotalRides = 0,
    this.driverAvatarUrl,
    this.driverLat,
    this.driverLng,
    this.calculatedPrice,
    this.historyPage = 0,
    this.hasMoreHistory = true,
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
    String? driverName,
    String? driverPhone,
    String? driverPlateNumber,
    double? driverRating,
    int? driverTotalRides,
    String? driverAvatarUrl,
    double? driverLat,
    double? driverLng,
    double? calculatedPrice,
    int? historyPage,
    bool? hasMoreHistory,
    bool clearDriverInfo = false,
    bool clearError = false,
  }) {
    return RideState(
      isLoading: isLoading ?? this.isLoading,
      currentRide: currentRide ?? this.currentRide,
      rideHistory: rideHistory ?? this.rideHistory,
      error: clearError ? null : (error ?? this.error),
      selectedPaymentMethod:
          selectedPaymentMethod ?? this.selectedPaymentMethod,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      dropoffLat: dropoffLat ?? this.dropoffLat,
      dropoffLng: dropoffLng ?? this.dropoffLng,
      driverName: clearDriverInfo ? null : (driverName ?? this.driverName),
      driverPhone: clearDriverInfo ? null : (driverPhone ?? this.driverPhone),
      driverPlateNumber: clearDriverInfo
          ? null
          : (driverPlateNumber ?? this.driverPlateNumber),
      driverRating:
          clearDriverInfo ? 5.0 : (driverRating ?? this.driverRating),
      driverTotalRides:
          clearDriverInfo ? 0 : (driverTotalRides ?? this.driverTotalRides),
      driverAvatarUrl:
          clearDriverInfo ? null : (driverAvatarUrl ?? this.driverAvatarUrl),
      driverLat: clearDriverInfo ? null : (driverLat ?? this.driverLat),
      driverLng: clearDriverInfo ? null : (driverLng ?? this.driverLng),
      calculatedPrice: calculatedPrice ?? this.calculatedPrice,
      historyPage: historyPage ?? this.historyPage,
      hasMoreHistory: hasMoreHistory ?? this.hasMoreHistory,
    );
  }
}

class RideNotifier extends StateNotifier<RideState> {
  RideNotifier() : super(const RideState());

  static final _log = Logger();
  RealtimeChannel? _rideChannel;
  RealtimeChannel? _driverLocationChannel;

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

  void setCalculatedPrice(double price) {
    state = state.copyWith(calculatedPrice: price);
  }

  Future<void> createRide() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) throw Exception('Non authentifié');

      final position = await LocationService.instance.getCurrentPosition();
      final pickupLat =
          state.pickupLat ?? position?.latitude ?? AppConstants.defaultLat;
      final pickupLng =
          state.pickupLng ?? position?.longitude ?? AppConstants.defaultLng;

      final data = await SupabaseService.instance.insert('rides', {
        'client_id': userId,
        'pickup_address': state.pickupAddress ?? 'Position actuelle',
        'pickup_lat': pickupLat,
        'pickup_lng': pickupLng,
        'dropoff_address': state.dropoffAddress ?? '',
        'dropoff_lat': state.dropoffLat ?? 0.0,
        'dropoff_lng': state.dropoffLng ?? 0.0,
        'price': state.calculatedPrice ?? AppConstants.ridePrice,
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
    _stopRideSubscription();

    _log.i('Subscribing to ride updates for $rideId');

    _rideChannel = SupabaseService.instance.subscribeToTable(
      'rides',
      filterColumn: 'id',
      filterValue: rideId,
      onChange: (payload) {
        _log.i(
            'Ride update: ${payload.eventType} — new status: ${payload.newRecord['status']}');

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

        // When a driver accepts the ride, fetch their profile + start tracking
        final newDriverId = payload.newRecord['driver_id'] as String?;
        if (newDriverId != null && currentRide.driverId == null) {
          _fetchDriverInfo(newDriverId);
          _subscribeToDriverLocation(newDriverId);
        }
      },
    );
  }

  /// Subscribe to Realtime updates on the driver's location
  /// so the client can see the driver moving on the map
  void _subscribeToDriverLocation(String driverId) {
    _stopDriverLocationSubscription();

    _log.i('Subscribing to driver location for $driverId');

    _driverLocationChannel = SupabaseService.instance.subscribeToTable(
      'drivers',
      filterColumn: 'id',
      filterValue: driverId,
      onChange: (payload) {
        final newLat = (payload.newRecord['current_lat'] as num?)?.toDouble();
        final newLng = (payload.newRecord['current_lng'] as num?)?.toDouble();

        if (newLat != null && newLng != null) {
          state = state.copyWith(driverLat: newLat, driverLng: newLng);
        }
      },
    );
  }

  void _stopDriverLocationSubscription() {
    if (_driverLocationChannel != null) {
      SupabaseService.instance.unsubscribe(_driverLocationChannel!);
      _driverLocationChannel = null;
      _log.i('Unsubscribed from driver location');
    }
  }

  /// Fetch driver profile and vehicle info from Supabase
  Future<void> _fetchDriverInfo(String driverId) async {
    try {
      _log.i('Fetching driver info for $driverId');

      final results = await Future.wait([
        SupabaseService.instance.getById('profiles', driverId),
        SupabaseService.instance.getById('drivers', driverId),
      ]);

      final profile = results[0];
      final driver = results[1];

      state = state.copyWith(
        driverName: profile['full_name'] as String?,
        driverPhone: profile['phone'] as String?,
        driverAvatarUrl: profile['avatar_url'] as String?,
        driverPlateNumber: driver['plate_number'] as String?,
        driverRating: (driver['rating'] as num?)?.toDouble() ?? 5.0,
        driverTotalRides: driver['total_rides'] as int? ?? 0,
        driverLat: (driver['current_lat'] as num?)?.toDouble(),
        driverLng: (driver['current_lng'] as num?)?.toDouble(),
      );

      _log.i('Driver info loaded: ${state.driverName}');
    } catch (e) {
      _log.e('Failed to fetch driver info: $e');
    }
  }

  void _stopRideSubscription() {
    if (_rideChannel != null) {
      SupabaseService.instance.unsubscribe(_rideChannel!);
      _rideChannel = null;
      _log.i('Unsubscribed from ride updates');
    }
    _stopDriverLocationSubscription();
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
        currentRide:
            state.currentRide!.copyWith(rating: rating, review: review),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Load the first page of ride history (resets pagination)
  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true, historyPage: 0, hasMoreHistory: true);
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) return;

      final data = await SupabaseService.instance.getAll(
        'rides',
        query: {'client_id': userId},
        orderBy: 'created_at',
        ascending: false,
        limit: AppConstants.pageSize,
      );
      final rides = data.map((e) => RideModel.fromJson(e)).toList();
      state = state.copyWith(
        isLoading: false,
        rideHistory: rides,
        historyPage: 1,
        hasMoreHistory: rides.length >= AppConstants.pageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Load the next page of ride history and append to existing list
  Future<void> loadMoreHistory() async {
    if (!state.hasMoreHistory || state.isLoading) return;

    state = state.copyWith(isLoading: true);
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) return;

      final offset = state.historyPage * AppConstants.pageSize;
      final data = await SupabaseService.instance.getAllPaginated(
        'rides',
        query: {'client_id': userId},
        orderBy: 'created_at',
        ascending: false,
        limit: AppConstants.pageSize,
        offset: offset,
      );
      final newRides = data.map((e) => RideModel.fromJson(e)).toList();
      state = state.copyWith(
        isLoading: false,
        rideHistory: [...state.rideHistory, ...newRides],
        historyPage: state.historyPage + 1,
        hasMoreHistory: newRides.length >= AppConstants.pageSize,
      );
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
