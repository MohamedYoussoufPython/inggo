import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/constants.dart';
import '../../widget/widgets.dart';
import '../../provider/favorites_provider.dart';

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
                      Text('Aucun favori', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
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
                          // Navigate with this as destination
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
                                  Text(fav.address, style: AppTextStyles.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline, color: AppColors.error, size: 20.w),
                              onPressed: () => ref.read(favoritesProvider.notifier).deleteFavorite(fav.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: const InggoBottomNav(currentIndex: 2),
    );
  }
}
