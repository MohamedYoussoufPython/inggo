import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../model/ride_model.dart';
import 'user_provider.dart';

class DriverRideRequest {
  final int id;
  final String userId;
  final String pickupAddress;
  final String dropoffAddress;
  final double? pickupLat;
  final double? pickupLng;
  final double? dropoffLat;
  final double? dropoffLng;
  final int price;
  final String status;
  final String date;
  final int timestamp;
  final String? userName;
  final double? userRating;

  DriverRideRequest({
    required this.id,
    required this.userId,
    required this.pickupAddress,
    required this.dropoffAddress,
    this.pickupLat,
    this.pickupLng,
    this.dropoffLat,
    this.dropoffLng,
    required this.price,
    required this.status,
    required this.date,
    required this.timestamp,
    this.userName,
    this.userRating,
  });

  factory DriverRideRequest.fromMap(Map<String, dynamic> map, {String? userName, double? userRating}) {
    return DriverRideRequest(
      id: map['id'] as int,
      userId: map['user_id'] as String,
      pickupAddress: map['pickup_address'] as String? ?? '',
      dropoffAddress: map['dropoff_address'] as String? ?? '',
      pickupLat: map['pickup_lat'] as double?,
      pickupLng: map['pickup_lng'] as double?,
      dropoffLat: map['dropoff_lat'] as double?,
      dropoffLng: map['dropoff_lng'] as double?,
      price: map['price'] as int? ?? 0,
      status: map['status'] as String? ?? 'searching',
      date: map['date'] as String? ?? '',
      timestamp: map['timestamp'] as int? ?? 0,
      userName: userName,
      userRating: userRating,
    );
  }
}

class DriverRidesNotifier extends StateNotifier<AsyncValue<List<RideModel>>> {
  final SupabaseClient _supabase;
  StreamSubscription? _ridesSubscription;

  DriverRidesNotifier(this._supabase) : super(const AsyncValue.data([])) {
    _init();
  }

  Future<void> _init() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _loadRides();
  }

  Future<void> _loadRides() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final data = await _supabase
          .from('rides')
          .select()
          .eq('driver_id', user.id)
          .order('timestamp', ascending: false);

      final rides = data.map((e) => RideModel(
        id: e['id'] as int,
        date: e['date'] ?? (e['created_at'] != null ? e['created_at'].toString().split('T')[0] : ''),
        timestamp: e['timestamp'] ?? (e['created_at'] != null ? DateTime.parse(e['created_at'].toString()).millisecondsSinceEpoch : 0),
        price: e['price']?.toString() ?? e['fare']?.toString() ?? '',
        driver: '',
        rating: (e['rating'] ?? 0).toDouble(),
        status: e['status'] ?? 'completed',
        pickup: e['pickup_address'] ?? 'Point A',
        dropoff: e['dropoff_address'] ?? 'Point B',
      )).toList();

      state = AsyncValue.data(rides);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<bool> acceptRide(int rideId, String driverId) async {
    try {
      await _supabase.from('rides').update({
        'driver_id': driverId,
        'status': 'accepted',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', rideId);

      await _loadRides();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> declineRide(int rideId) async {
    try {
      await _supabase.from('rides').update({
        'status': 'declined',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', rideId);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateRideStatus(int rideId, String status) async {
    try {
      await _supabase.from('rides').update({
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', rideId);

      await _loadRides();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    _ridesSubscription?.cancel();
    super.dispose();
  }
}

final driverRidesProvider = StateNotifierProvider<DriverRidesNotifier, AsyncValue<List<RideModel>>>((ref) {
  return DriverRidesNotifier(ref.watch(supabaseProvider));
});

final currentRideRequestProvider = StreamProvider<DriverRideRequest?>((ref) {
  final supabase = ref.watch(supabaseProvider);
  
  return supabase
      .from('rides')
      .stream(primaryKey: ['id'])
      .eq('status', 'searching')
      .map((data) async {
        if (data.isEmpty) return null;
        
        final ride = data.first;
        String? userName;
        
        if (ride['user_id'] != null) {
          final profile = await supabase
              .from('profiles')
              .select('full_name')
              .eq('id', ride['user_id'])
              .maybeSingle();
          
          if (profile != null) {
            userName = profile['full_name'] as String?;
          }
        }
        
        return DriverRideRequest.fromMap(ride, userName: userName, userRating: 4.8);
      }).asyncMap((future) => future);
});
