import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/constants/constants.dart';
import '../../core/services/location_service.dart';
import '../../core/services/supabase_service.dart';
import '../../l10n/app_localizations.dart';
import '../../widget/widgets.dart';
import '../../provider/ride_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _landmarks = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _setPickupFromGps();
    _loadLandmarks();
  }

  /// Set the pickup point from the client's current GPS position
  /// so that createRide() uses the real location instead of a fallback.
  Future<void> _setPickupFromGps() async {
    // Capture context-dependent value before the async gap
    final loc = AppLocalizations.of(context);
    final position = await LocationService.instance.getCurrentPosition();
    if (position != null) {
      ref.read(rideProvider.notifier).setPickup(
            loc.currentPosition,
            position.latitude,
            position.longitude,
          );
    }
  }

  Future<void> _loadLandmarks() async {
    try {
      final data = await SupabaseService.instance.getAll(
        'landmarks',
        orderBy: 'name_fr',
      );
      setState(() {
        _landmarks = data;
        _filtered = data.where((l) => l['is_popular'] == true).toList();
      });
    } catch (e) {
      if (mounted) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.profileUpdateError),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _onSearch(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      _filtered = query.isEmpty
          ? _landmarks.where((l) => l['is_popular'] == true).toList()
          : _landmarks
              .where((l) =>
                  (l['name_fr'] as String? ?? '')
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  (l['name_en'] as String? ?? '')
                      .toLowerCase()
                      .contains(query.toLowerCase()))
              .toList();
    });
  }

  /// Get the landmark name in the current locale, with null-safe fallback.
  /// If the localized name is missing, falls back to the other language,
  /// then to 'Destination'.
  String _getLandmarkName(Map<String, dynamic> landmark) {
    final locale = Localizations.localeOf(context).languageCode;
    final loc = AppLocalizations.of(context);
    if (locale == 'en') {
      return (landmark['name_en'] as String?)?.isNotEmpty == true
          ? landmark['name_en'] as String
          : (landmark['name_fr'] as String?) ?? loc.destinationFallback;
    } else {
      return (landmark['name_fr'] as String?)?.isNotEmpty == true
          ? landmark['name_fr'] as String
          : (landmark['name_en'] as String?) ?? loc.destinationFallback;
    }
  }

  void _selectLandmark(Map<String, dynamic> landmark) {
    final name = _getLandmarkName(landmark);
    ref.read(rideProvider.notifier).setDropoff(
          name,
          (landmark['lat'] as num?)?.toDouble() ?? AppConstants.defaultLat,
          (landmark['lng'] as num?)?.toDouble() ?? AppConstants.defaultLng,
        );
    context.push('/client/booking');
  }

  void _selectOnMap(LatLng pos) {
    final loc = AppLocalizations.of(context);
    ref.read(rideProvider.notifier).setDropoff(
          loc.selectedPosition,
          pos.latitude,
          pos.longitude,
        );
    context.push('/client/booking');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: InggoAppBar(title: loc.searchDestination, showBack: true),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding, vertical: 8.h),
            child: InggoInput(
              hint: loc.searchDestination,
              controller: _searchController,
              onChanged: _onSearch,
              prefixIcon: Icons.search,
              suffixIcon: Icons.map,
              onSuffixTap: () {
                _showMapPicker();
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding),
            child: GestureDetector(
              onTap: _showMapPicker,
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Row(
                  children: [
                    Icon(Icons.pin_drop, color: AppColors.primary, size: 20.w),
                    SizedBox(width: 8.w),
                    Text(loc.selectOnMap,
                        style: AppTextStyles.labelMedium
                            .copyWith(color: AppColors.primary)),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding),
            child: Text(
              _isSearching ? loc.noResults : loc.popularPlaces,
              style: AppTextStyles.labelLarge,
            ),
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Text(loc.noResults,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textHint)))
                : ListView.builder(
                    padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenPadding),
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      final lm = _filtered[index];
                      return _LandmarkTile(
                        name: _getLandmarkName(lm),
                        category: lm['category'] as String? ?? loc.categoryOther,
                        onTap: () => _selectLandmark(lm),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showMapPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(ctx).size.height * 0.8,
        child: MapWidget(
          enableTap: true,
          onTapPosition: (pos) {
            Navigator.pop(ctx);
            _selectOnMap(pos);
          },
        ),
      ),
    );
  }
}

class _LandmarkTile extends StatelessWidget {
  final String name;
  final String category;
  final VoidCallback onTap;

  const _LandmarkTile({
    required this.name,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(_categoryIcon(), color: AppColors.primary, size: 24.w),
      title: Text(name, style: AppTextStyles.bodyLarge),
      subtitle: Text(category, style: AppTextStyles.bodySmall),
      onTap: onTap,
    );
  }

  IconData _categoryIcon() {
    switch (category) {
      case 'hopital':
        return Icons.local_hospital;
      case 'mosquee':
        return Icons.mosque;
      case 'marche':
        return Icons.store;
      case 'gare':
        return Icons.train;
      case 'ecole':
        return Icons.school;
      case 'hotel':
        return Icons.hotel;
      case 'restaurant':
        return Icons.restaurant;
      default:
        return Icons.location_on;
    }
  }
}
