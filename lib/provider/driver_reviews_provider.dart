import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/review_model.dart';
import 'user_provider.dart';

final driverReviewsProvider = FutureProvider<List<ReviewModel>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final user = supabase.auth.currentUser;
  
  if (user == null) return [];

  final data = await supabase
      .from('reviews')
      .select('*, profiles:reviewer_id(full_name)')
      .eq('reviewed_id', user.id)
      .order('created_at', ascending: false);

  return data.map((e) {
    return ReviewModel(
      id: e['id'] as int,
      rideId: e['ride_id'] as int?,
      reviewerId: e['reviewer_id'] as String,
      reviewedId: e['reviewed_id'] as String,
      rating: (e['rating'] as num).toDouble(),
      comment: e['comment'] as String?,
      createdAt: DateTime.parse(e['created_at'] as String),
      reviewerName: e['profiles'] != null ? e['profiles']['full_name'] as String? : null,
    );
  }).toList();
});
