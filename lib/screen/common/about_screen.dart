import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/constants.dart';
import '../../widget/widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const InggoAppBar(title: 'À propos', showBack: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          children: [
            SizedBox(height: 32.h),
            // App Logo / Icon
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              ),
              child: Center(
                child: Icon(Icons.motorcycle,
                    size: 48.w, color: AppColors.primary),
              ),
            ),
            SizedBox(height: 24.h),
            Text('Inggo VTC', style: AppTextStyles.headline2),
            SizedBox(height: 4.h),
            Text('Version ${AppConstants.appVersion}',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
            SizedBox(height: 32.h),
            InggoCard(
              child: Column(
                children: [
                  _aboutRow(Icons.info_outline, 'Application',
                      'Moto-taxi à Djibouti'),
                  Divider(height: 24.h),
                  _aboutRow(Icons.location_city, 'Ville', 'Djibouti'),
                  Divider(height: 24.h),
                  _aboutRow(Icons.phone_android, 'Contact',
                      AppConstants.countryCode + ' 77 00 00 00'),
                  Divider(height: 24.h),
                  _aboutRow(Icons.email_outlined, 'Email',
                      'contact@inggo.dj'),
                  Divider(height: 24.h),
                  _aboutRow(Icons.language, 'Site web', 'www.inggo.dj'),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Inggo est le premier service de moto-taxi en République de Djibouti. '
              'Nous offrons des courses sûres, abordables et rapides dans toute la ville de Djibouti. '
              'Notre mission est de faciliter vos déplacements quotidiens avec des chauffeurs vérifiés '
              'et des prix transparents.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            Text(
              '\u00a9 ${DateTime.now().year} Inggo VTC. Tous droits réservés.',
              style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _aboutRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22.w),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodySmall),
              Text(value, style: AppTextStyles.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}
