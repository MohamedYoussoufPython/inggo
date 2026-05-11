import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      // User is logged in — check role and redirect
      try {
        final profileData = await Supabase.instance.client
            .from('profiles')
            .select('role')
            .eq('id', session.user.id)
            .maybeSingle();

        if (!mounted) return;
        final role = profileData?['role'] ?? 'client';

        if (role == 'driver') {
          // Check if verified
          final driverData = await Supabase.instance.client
              .from('drivers')
              .select('is_verified')
              .eq('id', session.user.id)
              .maybeSingle();

          if (!mounted) return;
          if (driverData?['is_verified'] == true) {
            context.go('/driver/home');
          } else {
            context.go('/pending-verification');
          }
        } else {
          context.go('/client/home');
        }
      } catch (e) {
        if (!mounted) return;
        context.go('/login');
      }
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // App logo
            Image.asset(
              'assets/images/logo.png',
              width: 140,
              height: 140,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.motorcycle,
                size: 80,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Inggo',
              style: AppTextStyles.headline1.copyWith(
                color: AppColors.primary,
                fontSize: 42,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
