import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_provider.dart';

/// Manages ride lifecycle: creation, cancellation, review submission.
class RideNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final SupabaseClient _supabase;

  RideNotifier(this._supabase) : super(const AsyncValue.data(null));

  /// Create a new ride and return the ride ID
  Future<int?> createRide({
    required String pickupAddress,
    required String dropoffAddress,
    double? pickupLat,
    double? pickupLng,
    double? dropoffLat,
    double? dropoffLng,
    int price = 250,
    String paymentMethod = 'cash',
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('Utilisateur non connecté');

      final now = DateTime.now();
      final response = await _supabase.from('rides').insert({
        'user_id': user.id,
        'pickup_address': pickupAddress,
        'dropoff_address': dropoffAddress,
        'pickup_lat': pickupLat,
        'pickup_lng': pickupLng,
        'dropoff_lat': dropoffLat,
        'dropoff_lng': dropoffLng,
        'price': price,
        'fare': price,
        'status': 'searching',
        'payment_method': paymentMethod,
        'date': '${now.day}/${now.month}/${now.year}',
        'timestamp': now.millisecondsSinceEpoch,
      }).select().single();

      state = AsyncValue.data(response);
      return response['id'] as int;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Cancel the current ride
  Future<void> cancelRide(int rideId) async {
    try {
      await _supabase.from('rides').update({
        'status': 'cancelled',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', rideId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Submit a review after a completed ride
  Future<void> submitReview({
    required int rideId,
    required String driverUserId,
    required int rating,
    String? comment,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('reviews').insert({
        'ride_id': rideId,
        'reviewer_id': user.id,
        'reviewed_id': driverUserId,
        'rating': rating.toDouble(),
        'comment': comment,
      });

      // Also update ride rating
      await _supabase.from('rides').update({
        'rating': rating.toDouble(),
      }).eq('id', rideId);
    } catch (e) {
      rethrow;
    }
  }

  /// Listen for ride status changes (polling-based for simplicity)
  Stream<Map<String, dynamic>?> watchRide(int rideId) {
    return _supabase
        .from('rides')
        .stream(primaryKey: ['id'])
        .eq('id', rideId)
        .map((list) => list.isNotEmpty ? list.first : null);
  }

  /// Clear active ride state
  void clearRide() {
    state = const AsyncValue.data(null);
  }
}

final rideProvider =
    StateNotifierProvider<RideNotifier, AsyncValue<Map<String, dynamic>?>>(
        (ref) {
  return RideNotifier(ref.watch(supabaseProvider));
});
