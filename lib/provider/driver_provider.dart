import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import '../core/services/supabase_service.dart';
import '../core/services/notification_service.dart';
import '../core/services/location_service.dart';
import '../model/driver_model.dart';
import '../model/ride_model.dart';

class DriverState {
  final bool isLoading;
  final DriverModel? driver;
  final bool isOnline;
  final double totalEarnings;
  final int totalRides;
  final String? error;
  final RideModel? pendingRide; // Ride received from Realtime, awaiting driver action
  final RideModel? currentRide; // Ride the driver accepted (full data from DB)

  const DriverState({
    this.isLoading = false,
    this.driver,
    this.isOnline = false,
    this.totalEarnings = 0.0,
    this.totalRides = 0,
    this.error,
    this.pendingRide,
    this.currentRide,
  });

  DriverState copyWith({
    bool? isLoading,
    DriverModel? driver,
    bool? isOnline,
    double? totalEarnings,
    int? totalRides,
    String? error,
    RideModel? pendingRide,
    RideModel? currentRide,
    bool clearPendingRide = false,
    bool clearCurrentRide = false,
    bool clearError = false,
  }) {
    return DriverState(
      isLoading: isLoading ?? this.isLoading,
      driver: driver ?? this.driver,
      isOnline: isOnline ?? this.isOnline,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      totalRides: totalRides ?? this.totalRides,
      error: clearError ? null : (error ?? this.error),
      pendingRide:
          clearPendingRide ? null : (pendingRide ?? this.pendingRide),
      currentRide:
          clearCurrentRide ? null : (currentRide ?? this.currentRide),
    );
  }
}

class DriverNotifier extends StateNotifier<DriverState> {
  DriverNotifier() : super(const DriverState());

  static final _log = Logger();
  RealtimeChannel? _newRidesChannel;

  // ─── Load driver profile ───
  Future<void> loadDriver() async {
    state = state.copyWith(isLoading: true);
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final data = await SupabaseService.instance.getById('drivers', userId);
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

  // ─── Toggle online/offline ───
  Future<void> toggleOnline() async {
    final newOnline = !state.isOnline;
    state = state.copyWith(isLoading: true);
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) return;

      if (newOnline) {
        // Get current position first, then send a single update with all fields
        final position = await LocationService.instance.getCurrentPosition();
        final updateData = <String, dynamic>{
          'is_online': true,
          'last_location_update': DateTime.now().toIso8601String(),
        };
        if (position != null) {
          updateData['current_lat'] = position.latitude;
          updateData['current_lng'] = position.longitude;
        }
        await SupabaseService.instance.update('drivers', userId, updateData);

        // Start tracking location
        LocationService.instance.startTracking(onPositionUpdate: (pos) {
          SupabaseService.instance.update('drivers', userId, {
            'current_lat': pos.latitude,
            'current_lng': pos.longitude,
            'last_location_update': DateTime.now().toIso8601String(),
          });
        });
        // Start listening for new ride requests
        _subscribeToNewRides();
      } else {
        await SupabaseService.instance.update('drivers', userId, {
          'is_online': false,
        });
        LocationService.instance.stopTracking();
        _stopNewRidesSubscription();
      }

      state = state.copyWith(isLoading: false, isOnline: newOnline);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ─── Realtime: Listen for new searching rides ───
  void _subscribeToNewRides() {
    _stopNewRidesSubscription();
    _log.i('Driver subscribing to new ride requests');

    _newRidesChannel = SupabaseService.instance.subscribeToTable(
      'rides',
      filterColumn: 'status',
      filterValue: 'searching',
      onChange: (payload) {
        if (payload.eventType == PostgresChangeEvent.insert) {
          _log.i('New ride request: ${payload.newRecord['id']}');
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

  // ─── Accept a ride ───
  // Returns true on success, false on failure.
  // Uses an atomic UPDATE with WHERE status = 'searching' to prevent
  // race conditions where two drivers try to accept the same ride.
  // On success, currentRide is populated with full data from DB
  // and the client receives a push notification.
  Future<bool> acceptRide(String rideId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) {
        state = state.copyWith(isLoading: false, error: 'Not authenticated'); // TODO: i18n — no BuildContext in provider
        return false;
      }

      // 1. Atomic UPDATE: only succeed if ride is still 'searching'
      // This prevents two drivers from accepting the same ride.
      final updateData = {
        'driver_id': userId,
        'status': 'accepted',
        'accepted_at': DateTime.now().toIso8601String(),
      };

      List<Map<String, dynamic>> result;
      try {
        result = List<Map<String, dynamic>>.from(
          await SupabaseService.client
              .from('rides')
              .update(updateData)
              .eq('id', rideId)
              .eq('status', 'searching') // ← atomic guard
              .select(),
        );
      } catch (e) {
        // DB trigger or constraint violation = another driver already accepted
        _log.w('Ride $rideId accept failed (DB constraint): $e');
        state = state.copyWith(
          isLoading: false,
          clearPendingRide: true,
          error: 'This ride has already been accepted by another driver.', // TODO: i18n
        );
        return false;
      }

      // 2. If no rows were updated, another driver beat us to it
      if (result.isEmpty) {
        _log.w('Ride $rideId was no longer searching — another driver accepted');
        state = state.copyWith(
          isLoading: false,
          clearPendingRide: true,
          error: 'This ride has already been accepted by another driver.', // TODO: i18n
        );
        return false;
      }

      // 3. Fetch the complete ride from DB (guaranteed to have all fields)
      final rideData = await SupabaseService.instance.getById('rides', rideId);
      final acceptedRide = RideModel.fromJson(rideData);

      // 4. Store currentRide and clear pendingRide
      state = state.copyWith(
        isLoading: false,
        currentRide: acceptedRide,
        clearPendingRide: true,
      );

      // 5. Stop listening for new rides while in a ride
      _stopNewRidesSubscription();

      // 6. Notify the client that their ride was accepted
      try {
        await NotificationService.instance.sendNotification(
          userId: acceptedRide.clientId,
          title: 'Driver found!', // TODO: i18n — push notification
          body: 'A driver has accepted your ride. They are on their way...', // TODO: i18n
          type: 'ride_accepted',
          data: {'ride_id': rideId},
        );
      } catch (e) {
        _log.w('Failed to send acceptance notification: $e');
      }

      _log.i('Ride $rideId accepted by driver $userId');
      return true;
    } catch (e) {
      _log.e('Failed to accept ride $rideId: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // ─── Update ride status (e.g. to in_progress) ───
  /// Updates the ride status in DB and in local state.
  /// This ensures both the client (via Realtime) and the driver see the change.
  Future<bool> updateRideStatus(RideStatus newStatus) async {
    final ride = state.currentRide;
    if (ride == null) return false;

    try {
      await SupabaseService.instance.update('rides', ride.id, {
        'status': newStatus.toSupabase(),
      });

      // Update local state
      state = state.copyWith(
        currentRide: ride.copyWith(status: newStatus),
      );

      _log.i('Ride ${ride.id} status updated to ${newStatus.toSupabase()}');
      return true;
    } catch (e) {
      _log.e('Failed to update ride status: $e');
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // ─── Reject a ride (just clear pending) ───
  void rejectRide() {
    state = state.copyWith(clearPendingRide: true);
    _log.i('Ride rejected by driver');
  }

  // ─── Complete a ride ───
  // Does NOT clear currentRide — the EndRideScreen still needs it to display
  // the real price/commission. Call clearCompletedRide() when the driver
  // leaves the EndRideScreen.
  Future<bool> completeRide() async {
    final ride = state.currentRide;
    if (ride == null) return false;

    try {
      // 1. Update ride status in DB
      await SupabaseService.instance.update('rides', ride.id, {
        'status': 'completed',
        'completed_at': DateTime.now().toIso8601String(),
      });

      // 2. Update local ride status (keep data for EndRideScreen)
      state = state.copyWith(
        currentRide: ride.copyWith(status: RideStatus.completed),
      );

      // 3. Driver stats are updated by the SQL trigger (update_driver_stats)
      // No need to update total_rides/total_earnings here — avoids double counting.
      // Just refresh the driver data from DB to get the new stats.
      try {
        final driverId = ride.driverId;
        if (driverId != null) {
          final driverData = await SupabaseService.instance.getById('drivers', driverId);
          final updatedDriver = DriverModel.fromJson(driverData);
          state = state.copyWith(
            driver: updatedDriver,
            totalRides: updatedDriver.totalRides,
            totalEarnings: updatedDriver.totalEarnings,
          );
        } else {
          // Fallback: refresh from current user ID
          final userId = SupabaseService.instance.currentUserId;
          if (userId != null) {
            final driverData = await SupabaseService.instance.getById('drivers', userId);
            final updatedDriver = DriverModel.fromJson(driverData);
            state = state.copyWith(
              driver: updatedDriver,
              totalRides: updatedDriver.totalRides,
              totalEarnings: updatedDriver.totalEarnings,
            );
          }
        }
      } catch (e) {
        _log.w('Failed to refresh driver stats: $e');
      }

      // 4. Re-subscribe to new rides if still online
      if (state.isOnline) {
        _subscribeToNewRides();
      }

      // 5. Notify the client that the ride is completed
      try {
        await NotificationService.instance.sendNotification(
          userId: ride.clientId,
          title: 'Ride completed', // TODO: i18n — push notification
          body: 'Your ride is complete. Thank you for using Inggo!', // TODO: i18n
          type: 'ride_completed',
          data: {'ride_id': ride.id},
        );
      } catch (e) {
        _log.w('Failed to send completion notification: $e');
      }

      _log.i('Ride ${ride.id} completed');
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // ─── Clear the completed ride after the driver leaves EndRideScreen ───
  void clearCompletedRide() {
    state = state.copyWith(clearCurrentRide: true);
    _log.i('Completed ride cleared from state');
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
