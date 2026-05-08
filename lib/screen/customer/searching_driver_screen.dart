import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/constants.dart';
import '../../widget/widgets.dart';
import '../../provider/ride_provider.dart';
import '../../model/ride_model.dart';

class SearchingDriverScreen extends ConsumerStatefulWidget {
  const SearchingDriverScreen({super.key});

  @override
  ConsumerState<SearchingDriverScreen> createState() =>
      _SearchingDriverScreenState();
}

class _SearchingDriverScreenState extends ConsumerState<SearchingDriverScreen> {
  int _elapsed = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startSearch();
  }

  void _startSearch() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _elapsed++);
      if (_elapsed >= AppConstants.searchDriverTimeoutSeconds) {
        timer.cancel();
        _showNoDriverDialog();
      }
    });

    // Listen for ride changes — now powered by Realtime Supabase
    // The RideNotifier subscribes to Realtime when createRide() is called,
    // so when the driver accepts, the state is updated automatically.
    ref.listenManual(rideProvider, (prev, next) {
      final status = next.currentRide?.status;

      if (status == RideStatus.accepted) {
        // Driver accepted the ride → navigate to trip in progress
        _timer?.cancel();
        context.go('/client/trip');
      } else if (status == RideStatus.cancelled) {
        // Ride was cancelled
        _timer?.cancel();
        context.go('/client/home');
      }
    });
  }

  void _showNoDriverDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Aucun chauffeur trouvé'),
        content: const Text(
            'Désolé, aucun chauffeur n\'est disponible pour le moment. Veuillez réessayer.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(rideProvider.notifier).reset();
              context.go('/client/home');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _cancelRide() async {
    _timer?.cancel();
    await ref.read(rideProvider.notifier).cancelRide('Client a annulé');
    ref.read(rideProvider.notifier).reset();
    if (mounted) context.go('/client/home');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated searching indicator
              SizedBox(
                width: 120.w,
                height: 120.w,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120.w,
                      height: 120.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                    Icon(Icons.motorcycle,
                        size: 48.w, color: AppColors.primary),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Text('Recherche d\'un chauffeur...',
                  style: AppTextStyles.headline3),
              SizedBox(height: 8.h),
              Text(
                'Veuillez patienter...',
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.textSecondary),
              ),
              SizedBox(height: 8.h),
              Text(
                '${_elapsed}s / ${AppConstants.searchDriverTimeoutSeconds}s',
                style: AppTextStyles.priceSmall,
              ),
              SizedBox(height: 40.h),
              InggoButton(
                label: 'Annuler',
                type: InggoButtonType.outline,
                onPressed: _cancelRide,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
