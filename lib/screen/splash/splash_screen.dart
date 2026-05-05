import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/constants.dart';
import '../provider/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final auth = ref.read(authProvider);
    if (auth.isAuthenticated && auth.user != null) {
      if (auth.user!.role.name == 'driver') {
        context.go('/driver/home');
      } else {
        context.go('/client/home');
      }
    } else if (auth.isOnboarded) {
      context.go('/login');
    } else {
      context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.motorcycle, size: 80.w, color: AppColors.secondary),
            SizedBox(height: 16.h),
            Text('INGGO',
                style: AppTextStyles.headline1
                    .copyWith(color: AppColors.secondary)),
            SizedBox(height: 8.h),
            Text('Votre moto-taxi à Djibouti',
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.secondary)),
          ],
        ),
      ),
    );
  }
}
