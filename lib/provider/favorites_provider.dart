import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/supabase_service.dart';
import '../model/favorite_model.dart';

class FavoritesState {
  final bool isLoading;
  final List<FavoriteModel> favorites;
  final String? error;

  const FavoritesState({
    this.isLoading = false,
    this.favorites = const [],
    this.error,
  });

  FavoritesState copyWith({
    bool? isLoading,
    List<FavoriteModel>? favorites,
    String? error,
  }) {
    return FavoritesState(
      isLoading: isLoading ?? this.isLoading,
      favorites: favorites ?? this.favorites,
      error: error,
    );
  }
}

class FavoritesNotifier extends StateNotifier<FavoritesState> {
  FavoritesNotifier() : super(const FavoritesState());

  Future<void> loadFavorites() async {
    state = state.copyWith(isLoading: true);
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) return;

      final data = await SupabaseService.instance.getAll(
        'favorites',
        query: {'user_id': userId},
        orderBy: 'created_at',
      );
      final favs = data.map((e) => FavoriteModel.fromJson(e)).toList();
      state = state.copyWith(isLoading: false, favorites: favs);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addFavorite({
    required String label,
    required String address,
    required double lat,
    required double lng,
  }) async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) return;

      final data = await SupabaseService.instance.insert('favorites', {
        'user_id': userId,
        'label': label,
        'address': address,
        'lat': lat,
        'lng': lng,
      });
      final fav = FavoriteModel.fromJson(data);
      state = state.copyWith(favorites: [...state.favorites, fav]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteFavorite(String id) async {
    try {
      await SupabaseService.instance.delete('favorites', id);
      state = state.copyWith(
        favorites: state.favorites.where((f) => f.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  return FavoritesNotifier();
});
