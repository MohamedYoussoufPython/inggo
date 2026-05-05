import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/constants.dart';
import '../../widget/widgets.dart';
import '../../provider/auth_provider.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Column(
            children: [
              SizedBox(height: 40.h),
              // Language selector
              LanguageSelector(
                currentLanguage: ref.watch(authProvider).locale.languageCode,
                onLanguageChanged: (code) =>
                    ref.read(authProvider.notifier).setLanguage(code),
              ),
              const Spacer(),
              // Logo
              Icon(Icons.motorcycle, size: 100.w, color: AppColors.primary),
              SizedBox(height: 24.h),
              Text('Bienvenue sur INGGO',
                  style: AppTextStyles.headline2, textAlign: TextAlign.center),
              SizedBox(height: 12.h),
              Text(
                'Le premier VTC moto-taxi à Djibouti. Réservez une course en un clic.',
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              // Buttons
              InggoButton(
                label: 'Commencer',
                onPressed: () {
                  ref.read(authProvider.notifier).setOnboarded();
                  context.go('/login');
                },
              ),
              SizedBox(height: 16.h),
              Text(
                'En continuant, vous acceptez nos conditions d\'utilisation',
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}
