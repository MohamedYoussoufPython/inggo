import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/ride_model.dart';
import 'user_provider.dart';

final historyProvider = FutureProvider<List<RideModel>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final user = supabase.auth.currentUser;
  
  if (user == null) return [];

  final data = await supabase
      .from('rides')
      .select()
      .eq('user_id', user.id)
      .order('timestamp', ascending: false);

  return data.map((e) => RideModel(
    id: e['id'],
    date: e['date'],
    timestamp: e['timestamp'],
    price: e['price'],
    driver: e['driver_name'] ?? '',
    rating: (e['rating'] ?? 0).toDouble(),
    status: e['status'],
    pickup: e['pickup_address'],
    dropoff: e['dropoff_address'],
  )).toList();
});
