import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/constants/constants.dart';
import '../../core/services/location_service.dart';
import '../../core/services/supabase_service.dart';
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
  LatLng? _selectedPosition;

  @override
  void initState() {
    super.initState();
    _setPickupFromGps();
    _loadLandmarks();
  }

  /// Set the pickup point from the client's current GPS position
  /// so that createRide() uses the real location instead of a fallback.
  Future<void> _setPickupFromGps() async {
    final position = await LocationService.instance.getCurrentPosition();
    if (position != null) {
      ref.read(rideProvider.notifier).setPickup(
            'Position actuelle',
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossible de charger les lieux. Tirez vers le bas pour réessayer.'),
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
                  (l['name_fr'] as String)
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  (l['name_en'] as String)
                      .toLowerCase()
                      .contains(query.toLowerCase()))
              .toList();
    });
  }

  void _selectLandmark(Map<String, dynamic> landmark) {
    ref.read(rideProvider.notifier).setDropoff(
          landmark['name_fr'] as String,
          (landmark['lat'] as num).toDouble(),
          (landmark['lng'] as num).toDouble(),
        );
    context.push('/client/booking');
  }

  void _selectOnMap(LatLng pos) {
    setState(() => _selectedPosition = pos);
    ref.read(rideProvider.notifier).setDropoff(
          'Position sélectionnée',
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
    return Scaffold(
      appBar: InggoAppBar(title: 'Destination', showBack: true),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding, vertical: 8.h),
            child: InggoInput(
              hint: 'Rechercher une destination...',
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
                    Text('Sélectionner sur la carte',
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
              _isSearching ? 'Résultats' : 'Lieux populaires',
              style: AppTextStyles.labelLarge,
            ),
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Text('Aucun résultat',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textHint)))
                : ListView.builder(
                    padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenPadding),
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      final lm = _filtered[index];
                      return _LandmarkTile(
                        name: lm['name_fr'] as String,
                        category: lm['category'] as String,
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
