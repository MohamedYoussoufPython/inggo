import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../model/favorite_model.dart';
import 'user_provider.dart';

class FavoritesNotifier extends StateNotifier<AsyncValue<List<FavoriteModel>>> {
  final SupabaseClient _supabase;
  
  FavoritesNotifier(this._supabase) : super(const AsyncValue.loading()) {
    fetchFavorites();
  }

  Future<void> fetchFavorites() async {
    state = const AsyncValue.loading();
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        state = const AsyncValue.data([]);
        return;
      }
      
      final data = await _supabase
          .from('favorites')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: true);
      
      state = AsyncValue.data(data.map((e) => FavoriteModel(
        id: e['id'],
        name: e['name'],
        address: e['address'],
        icon: _parseIcon(e['icon']),
        bgColor: const Color(0xFFF5F7FA),
        iconColor: const Color(0xFF121212),
      )).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  IconData _parseIcon(String? iconName) {
    switch (iconName) {
      case 'home': return Icons.home;
      case 'work': return Icons.work;
      case 'star': return Icons.star;
      default: return Icons.place;
    }
  }

  Future<void> addFavorite(String name, String address, {String icon = 'place'}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase.from('favorites').insert({
      'user_id': user.id,
      'name': name,
      'address': address,
      'icon': icon,
    });
    await fetchFavorites();
  }

  Future<void> removeFavorite(int id) async {
    await _supabase.from('favorites').delete().eq('id', id);
    state = state.whenData((favs) => favs.where((f) => f.id != id).toList());
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, AsyncValue<List<FavoriteModel>>>((ref) {
  return FavoritesNotifier(ref.watch(supabaseProvider));
});
