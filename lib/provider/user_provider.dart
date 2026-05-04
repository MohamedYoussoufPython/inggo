import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../model/user_model.dart';
import '../supabase.dart';

final supabaseProvider = Provider<SupabaseClient>((ref) => SupabaseConfig.client);

class UserNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final SupabaseClient _supabase;
  
  UserNotifier(this._supabase) : super(const AsyncValue.loading()) {
    fetchUser();
  }

  Future<void> fetchUser() async {
    state = const AsyncValue.loading();
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        state = const AsyncValue.data(null);
        return;
      }
      
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      
      if (data == null) {
        // Créer profil si inexistant
        await _supabase.from('profiles').insert({
          'id': user.id,
          'email': user.email,
          'full_name': user.userMetadata?['full_name'] ?? '',
        });
        state = const AsyncValue.data(null);
        return;
      }
      
      state = AsyncValue.data(UserModel(
        name: data['full_name'] ?? '',
        phone: data['phone'] ?? '',
        email: data['email'] ?? '',
        gender: data['sexe'] == 'M' ? 'Homme' : (data['sexe'] == 'F' ? 'Femme' : ''),
        country: data['pays'] ?? 'Djibouti',
        avatarUrl: data['avatar_url'] ?? '',
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? phone,
    String? sexe,
    String? pays,
    String? avatarUrl,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase.from('profiles').update({
      if (fullName != null) 'full_name': fullName,
      if (phone != null) 'phone': phone,
      if (sexe != null) 'sexe': sexe,
      if (pays != null) 'pays': pays,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', user.id);

    await fetchUser();
  }
}

final userProvider = StateNotifierProvider<UserNotifier, AsyncValue<UserModel?>>((ref) {
  return UserNotifier(ref.watch(supabaseProvider));
});
