import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/constants/constants.dart';
import '../../core/services/location_service.dart';
import '../../widget/widgets.dart';
import '../../provider/favorites_provider.dart';
import '../../provider/ride_provider.dart';
import '../../l10n/app_localizations.dart';

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
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: InggoAppBar(title: loc.favorites),
      body: favs.isLoading
          ? const InggoLoading()
          : favs.favorites.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite_border, size: 64.w, color: AppColors.textHint),
                      SizedBox(height: 16.h),
                      Text(loc.noFavorites,
                          style: AppTextStyles.bodyLarge
                              .copyWith(color: AppColors.textSecondary)),
                      SizedBox(height: 8.h),
                      Text(loc.addFavoriteHint,
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
                          // Also set pickup from current GPS
                          _navigateToBooking(fav.address, fav.lat, fav.lng);
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
                              onPressed: () async {
                                final msg = AppLocalizations.of(context).favoriteDeleted;
                                await ref
                                    .read(favoritesProvider.notifier)
                                    .deleteFavorite(fav.id);
                                if (!context.mounted) return;
                                InggoToast.success(context, msg);
                              },
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

  /// Set pickup from GPS, then set dropoff from favorite, then navigate to booking
  Future<void> _navigateToBooking(String address, double lat, double lng) async {
    // Capture context-dependent values before the async gap
    final loc = AppLocalizations.of(context);
    final router = GoRouter.of(context);
    // Set pickup from current GPS position
    final position = await LocationService.instance.getCurrentPosition();
    if (position != null) {
      ref.read(rideProvider.notifier).setPickup(
            loc.currentPosition,
            position.latitude,
            position.longitude,
          );
    }
    // Set dropoff
    ref.read(rideProvider.notifier).setDropoff(address, lat, lng);
    router.push('/client/booking');
  }

  /// Show a dialog to add a new favorite destination
  void _showAddFavoriteDialog(BuildContext context) {
    final labelController = TextEditingController();
    final addressController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    double? selectedLat;
    double? selectedLng;
    final loc = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.addFavorite),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InggoInput(
                label: loc.favoriteLabel,
                hint: loc.favoriteLabelHint,
                controller: labelController,
                prefixIcon: Icons.label,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? loc.fieldRequired : null,
              ),
              SizedBox(height: 12.h),
              InggoInput(
                label: loc.address,
                hint: loc.addressHint,
                controller: addressController,
                prefixIcon: Icons.location_on,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? loc.fieldRequired : null,
              ),
              SizedBox(height: 12.h),
              InggoButton(
                type: InggoButtonType.outline,
                icon: Icons.map,
                label: loc.chooseOnMap,
                onPressed: () async {
                  // Close dialog temporarily and show map picker
                  Navigator.pop(ctx);
                  final result = await _showMapPicker();
                  if (result != null) {
                    selectedLat = result.latitude;
                    selectedLng = result.longitude;
                    if (addressController.text.trim().isEmpty) {
                      addressController.text = loc.selectedPosition;
                    }
                    // Re-show dialog with updated state
                    if (context.mounted) {
                      _showAddFavoriteDialogWithValues(
                        context,
                        labelController.text,
                        addressController.text,
                        selectedLat,
                        selectedLng,
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          InggoButton(
            type: InggoButtonType.text,
            label: loc.cancel,
            onPressed: () => Navigator.pop(ctx),
          ),
          InggoButton(
            label: loc.add,
            onPressed: () {
              if (!formKey.currentState!.validate()) return;

              // Use selected map position, or current GPS, or default Djibouti
              final position = LocationService.instance.currentPosition;
              final lat = selectedLat ?? position?.latitude ?? AppConstants.defaultLat;
              final lng = selectedLng ?? position?.longitude ?? AppConstants.defaultLng;

              ref.read(favoritesProvider.notifier).addFavorite(
                    label: labelController.text.trim(),
                    address: addressController.text.trim(),
                    lat: lat,
                    lng: lng,
                  );
              Navigator.pop(ctx);
              InggoToast.success(context, loc.favoriteAdded);
            },
          ),
        ],
      ),
    );
  }

  void _showAddFavoriteDialogWithValues(
    BuildContext context,
    String label,
    String address,
    double? lat,
    double? lng,
  ) {
    final labelController = TextEditingController(text: label);
    final addressController = TextEditingController(text: address);
    final formKey = GlobalKey<FormState>();
    final loc = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.addFavorite),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InggoInput(
                label: loc.favoriteLabel,
                hint: loc.favoriteLabelHint,
                controller: labelController,
                prefixIcon: Icons.label,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? loc.fieldRequired : null,
              ),
              SizedBox(height: 12.h),
              InggoInput(
                label: loc.address,
                hint: loc.addressHint,
                controller: addressController,
                prefixIcon: Icons.location_on,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? loc.fieldRequired : null,
              ),
              if (lat != null && lng != null) ...[
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Icons.check_circle, size: 16.w, color: AppColors.success),
                    SizedBox(width: 6.w),
                    Text(loc.positionSelectedOnMap,
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.success)),
                  ],
                ),
              ],
            ],
          ),
        ),
        actions: [
          InggoButton(
            type: InggoButtonType.text,
            label: loc.cancel,
            onPressed: () => Navigator.pop(ctx),
          ),
          InggoButton(
            label: loc.add,
            onPressed: () {
              if (!formKey.currentState!.validate()) return;

              final position = LocationService.instance.currentPosition;
              final favLat = lat ?? position?.latitude ?? AppConstants.defaultLat;
              final favLng = lng ?? position?.longitude ?? AppConstants.defaultLng;

              ref.read(favoritesProvider.notifier).addFavorite(
                    label: labelController.text.trim(),
                    address: addressController.text.trim(),
                    lat: favLat,
                    lng: favLng,
                  );
              Navigator.pop(ctx);
              InggoToast.success(context, loc.favoriteAdded);
            },
          ),
        ],
      ),
    );
  }

  Future<LatLng?> _showMapPicker() async {
    LatLng? selectedPos;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(ctx).size.height * 0.8,
        child: MapWidget(
          enableTap: true,
          onTapPosition: (pos) {
            selectedPos = pos;
            Navigator.pop(ctx);
          },
        ),
      ),
    );
    return selectedPos;
  }
}
