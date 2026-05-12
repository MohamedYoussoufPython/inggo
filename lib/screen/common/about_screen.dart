import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/constants.dart';
import '../../l10n/app_localizations.dart';
import '../../widget/widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: InggoAppBar(title: loc.about, showBack: true),
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
            Text(loc.appNameVtc, style: AppTextStyles.headline2),
            SizedBox(height: 4.h),
            Text('Version ${AppConstants.appVersion}',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
            SizedBox(height: 32.h),
            InggoCard(
              child: Column(
                children: [
                  _aboutRow(Icons.info_outline, loc.application,
                      loc.appDescription),
                  Divider(height: 24.h),
                  _aboutRow(Icons.location_city, loc.city, 'Djibouti'),
                  Divider(height: 24.h),
                  _aboutRow(Icons.phone_android, loc.contact,
                      '${AppConstants.countryCode} 77 78 06 06'),
                  Divider(height: 24.h),
                  _aboutRow(Icons.email_outlined, loc.email,
                      'admin@inngroupsarl.com'),
                  Divider(height: 24.h),
                  _aboutRow(Icons.language, loc.website, 'www.inggo.dj'),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              loc.aboutDescription,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            // Legal links
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => context.push('/privacy-policy'),
                  child: Text(loc.privacyPolicy,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary)),
                ),
              ],
            ),
            Text(
              '\u00a9 ${DateTime.now().year} Inggo VTC. ${loc.allRightsReserved}',
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
