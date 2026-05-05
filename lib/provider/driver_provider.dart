import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/supabase_service.dart';
import '../core/services/location_service.dart';
import '../core/constants/app_constants.dart';
import '../model/driver_model.dart';

class DriverState {
  final bool isLoading;
  final DriverModel? driver;
  final bool isOnline;
  final double totalEarnings;
  final int totalRides;
  final String? error;

  const DriverState({
    this.isLoading = false,
    this.driver,
    this.isOnline = false,
    this.totalEarnings = 0.0,
    this.totalRides = 0,
    this.error,
  });

  DriverState copyWith({
    bool? isLoading,
    DriverModel? driver,
    bool? isOnline,
    double? totalEarnings,
    int? totalRides,
    String? error,
  }) {
    return DriverState(
      isLoading: isLoading ?? this.isLoading,
      driver: driver ?? this.driver,
      isOnline: isOnline ?? this.isOnline,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      totalRides: totalRides ?? this.totalRides,
      error: error,
    );
  }
}

class DriverNotifier extends StateNotifier<DriverState> {
  DriverNotifier() : super(const DriverState());

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
      } else {
        LocationService.instance.stopTracking();
      }

      state = state.copyWith(isLoading: false, isOnline: newOnline);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
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
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
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
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final driverProvider =
    StateNotifierProvider<DriverNotifier, DriverState>((ref) {
  return DriverNotifier();
});
