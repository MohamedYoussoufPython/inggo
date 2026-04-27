import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/inggo_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  Future<void> _navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: InggoColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png', width: 140, height: 140),
            const SizedBox(height: InggoSpacing.lg),
            Text(
              'Inggo',
              style: InggoTextStyles.h1.copyWith(
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
