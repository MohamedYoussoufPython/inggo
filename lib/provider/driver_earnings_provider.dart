import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/earning_model.dart';
import 'user_provider.dart';

final driverEarningsProvider = FutureProvider<List<EarningModel>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final user = supabase.auth.currentUser;
  
  if (user == null) return [];

  final data = await supabase
      .from('driver_earnings')
      .select()
      .eq('driver_id', user.id)
      .order('earned_at', ascending: false);

  return data.map((e) => EarningModel.fromJson(e)).toList();
});

// Helper provider for today's earnings
final todayEarningsProvider = Provider<int>((ref) {
  final earningsAsync = ref.watch(driverEarningsProvider);
  final earnings = earningsAsync.value ?? [];
  final today = DateTime.now();
  
  int total = 0;
  for (final e in earnings) {
    if (e.earnedAt.year == today.year && 
        e.earnedAt.month == today.month && 
        e.earnedAt.day == today.day) {
      total += e.netAmount;
    }
  }
  return total;
});
