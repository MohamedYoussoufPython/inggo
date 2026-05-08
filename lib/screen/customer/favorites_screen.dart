import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/constants.dart';
import '../../core/services/location_service.dart';
import '../../widget/widgets.dart';
import '../../provider/favorites_provider.dart';
import '../../provider/ride_provider.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(favoritesProvider.notifier).loadFavorites());
  }

  @override
  Widget build(BuildContext context) {
    final favs = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: const InggoAppBar(title: 'Favoris'),
      body: favs.isLoading
          ? const InggoLoading()
          : favs.favorites.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite_border, size: 64.w, color: AppColors.textHint),
                      SizedBox(height: 16.h),
                      Text('Aucun favori',
                          style: AppTextStyles.bodyLarge
                              .copyWith(color: AppColors.textSecondary)),
                      SizedBox(height: 8.h),
                      Text('Appuyez sur + pour ajouter un lieu favori',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textHint)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(AppSpacing.screenPadding),
                  itemCount: favs.favorites.length,
                  itemBuilder: (context, index) {
                    final fav = favs.favorites[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: InggoCard(
                        onTap: () {
                          // Set the dropoff point from the favorite and navigate to booking
                          ref.read(rideProvider.notifier).setDropoff(
                                fav.address,
                                fav.lat,
                                fav.lng,
                              );
                          context.push('/client/booking');
                        },
                        child: Row(
                          children: [
                            Icon(Icons.favorite, color: AppColors.error, size: 24.w),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(fav.label, style: AppTextStyles.labelMedium),
                                  Text(fav.address,
                                      style: AppTextStyles.bodySmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline,
                                  color: AppColors.error, size: 20.w),
                              onPressed: () => ref
                                  .read(favoritesProvider.notifier)
                                  .deleteFavorite(fav.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addFavorite',
        backgroundColor: AppColors.primary,
        child: Icon(Icons.add, color: AppColors.secondary),
        onPressed: () => _showAddFavoriteDialog(context),
      ),
      bottomNavigationBar: const InggoBottomNav(currentIndex: 2),
    );
  }

  /// Show a dialog to add a new favorite destination
  void _showAddFavoriteDialog(BuildContext context) {
    final labelController = TextEditingController();
    final addressController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ajouter un favori'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: labelController,
                decoration: const InputDecoration(
                  labelText: 'Nom du lieu',
                  hintText: 'Ex: Maison, Travail...',
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Champ requis' : null,
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Adresse',
                  hintText: 'Ex: Quartier Haramous...',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Champ requis' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx);
              // Use current GPS position as coordinates, fallback to default Djibouti
              final position = LocationService.instance.currentPosition;
              ref.read(favoritesProvider.notifier).addFavorite(
                    label: labelController.text.trim(),
                    address: addressController.text.trim(),
                    lat: position?.latitude ?? AppConstants.defaultLat,
                    lng: position?.longitude ?? AppConstants.defaultLng,
                  );
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}
