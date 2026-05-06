import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import '../core/services/supabase_service.dart';
import '../core/services/location_service.dart';
import '../core/constants/app_constants.dart';
import '../model/driver_model.dart';
import '../model/ride_model.dart';

class DriverState {
  final bool isLoading;
  final DriverModel? driver;
  final bool isOnline;
  final double totalEarnings;
  final int totalRides;
  final String? error;
  final RideModel? pendingRide; // New ride request received from Realtime
  final String? currentRideId; // ID of the ride the driver accepted

  const DriverState({
    this.isLoading = false,
    this.driver,
    this.isOnline = false,
    this.totalEarnings = 0.0,
    this.totalRides = 0,
    this.error,
    this.pendingRide,
    this.currentRideId,
  });

  DriverState copyWith({
    bool? isLoading,
    DriverModel? driver,
    bool? isOnline,
    double? totalEarnings,
    int? totalRides,
    String? error,
    RideModel? pendingRide,
    String? currentRideId,
    bool clearPendingRide = false,
    bool clearCurrentRideId = false,
  }) {
    return DriverState(
      isLoading: isLoading ?? this.isLoading,
      driver: driver ?? this.driver,
      isOnline: isOnline ?? this.isOnline,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      totalRides: totalRides ?? this.totalRides,
      error: error,
      pendingRide: clearPendingRide ? null : (pendingRide ?? this.pendingRide),
      currentRideId: clearCurrentRideId ? null : (currentRideId ?? this.currentRideId),
    );
  }
}

class DriverNotifier extends StateNotifier<DriverState> {
  DriverNotifier() : super(const DriverState());

  static final _log = Logger();
  RealtimeChannel? _newRidesChannel;

  Future<void> loadDriver() async {
    state = state.copyWith(isLoading: true);
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) return;

      final data =
          await SupabaseService.instance.getById('drivers', userId);
      final driver = DriverModel.fromJson(data);
      state = state.copyWith(
        isLoading: false,
        driver: driver,
        isOnline: driver.isOnline,
        totalEarnings: driver.totalEarnings,
        totalRides: driver.totalRides,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> toggleOnline() async {
    final newOnline = !state.isOnline;
    state = state.copyWith(isLoading: true);
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) return;

      await SupabaseService.instance.update('drivers', userId, {
        'is_online': newOnline,
      });

      if (newOnline) {
        final position =
            await LocationService.instance.getCurrentPosition();
        if (position != null) {
          await SupabaseService.instance.update('drivers', userId, {
            'current_lat': position.latitude,
            'current_lng': position.longitude,
            'last_location_update': DateTime.now().toIso8601String(),
          });
        }
        LocationService.instance.startTracking(onPositionUpdate: (pos) {
          SupabaseService.instance.update('drivers', userId, {
            'current_lat': pos.latitude,
            'current_lng': pos.longitude,
            'last_location_update': DateTime.now().toIso8601String(),
          });
        });

        // Subscribe to new ride requests
        _subscribeToNewRides();
      } else {
        LocationService.instance.stopTracking();
        // Unsubscribe from new ride requests
        _stopNewRidesSubscription();
      }

      state = state.copyWith(isLoading: false, isOnline: newOnline);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Subscribe to Realtime updates on the rides table for new "searching" rides
  void _subscribeToNewRides() {
    _stopNewRidesSubscription(); // clean any previous subscription

    _log.i('Driver subscribing to new ride requests');

    _newRidesChannel = SupabaseService.instance.subscribeToTable(
      'rides',
      filterColumn: 'status',
      filterValue: 'searching',
      onChange: (payload) {
        // Only react to INSERT events (new ride created)
        if (payload.eventType == PostgresChangeEvent.insert) {
          _log.i('New ride request received: ${payload.newRecord['id']}');

          final ride = RideModel.fromJson(payload.newRecord);
          state = state.copyWith(pendingRide: ride);
        }
      },
    );
  }

  void _stopNewRidesSubscription() {
    if (_newRidesChannel != null) {
      SupabaseService.instance.unsubscribe(_newRidesChannel!);
      _newRidesChannel = null;
      _log.i('Unsubscribed from new ride requests');
    }
  }

  Future<void> acceptRide(String rideId) async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) return;

      await SupabaseService.instance.update('rides', rideId, {
        'driver_id': userId,
        'status': 'accepted',
        'accepted_at': DateTime.now().toIso8601String(),
      });

      // Store the current ride ID and clear pending
      state = state.copyWith(
        currentRideId: rideId,
        clearPendingRide: true,
      );

      // Stop listening for new rides while in a ride
      _stopNewRidesSubscription();

      _log.i('Ride $rideId accepted by driver $userId');
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> rejectRide() async {
    // Simply clear the pending ride — another driver can pick it up
    state = state.copyWith(clearPendingRide: true);
    _log.i('Ride rejected by driver');
  }

  Future<void> completeRide(String rideId) async {
    try {
      await SupabaseService.instance.update('rides', rideId, {
        'status': 'completed',
        'completed_at': DateTime.now().toIso8601String(),
      });

      final driver = state.driver;
      if (driver != null) {
        await SupabaseService.instance.update('drivers', driver.id, {
          'total_rides': driver.totalRides + 1,
          'total_earnings': driver.totalEarnings + AppConstants.driverEarning,
        });
        state = state.copyWith(
          totalRides: driver.totalRides + 1,
          totalEarnings: driver.totalEarnings + AppConstants.driverEarning,
          clearCurrentRideId: true,
        );
      }

      // Re-subscribe to new rides if still online
      if (state.isOnline) {
        _subscribeToNewRides();
      }

      _log.i('Ride $rideId completed');
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  @override
  void dispose() {
    _stopNewRidesSubscription();
    super.dispose();
  }
}

final driverProvider =
    StateNotifierProvider<DriverNotifier, DriverState>((ref) {
  return DriverNotifier();
});
