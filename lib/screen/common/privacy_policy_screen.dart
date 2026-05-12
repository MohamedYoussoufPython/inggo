import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/constants.dart';
import '../../l10n/app_localizations.dart';
import '../../widget/widgets.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: InggoAppBar(title: loc.privacyPolicyTitle, showBack: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.privacyPolicyTitle, style: AppTextStyles.headline3),
            SizedBox(height: 4.h),
            Text(loc.lastUpdated,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
            SizedBox(height: 24.h),

            _section(loc.privacySection1Title, loc.privacySection1Content),

            _section(loc.privacySection2Title, loc.privacySection2Content),

            _section(loc.privacySection3Title, loc.privacySection3Content),

            _section(loc.privacySection4Title, loc.privacySection4Content),

            _section(loc.privacySection5Title, loc.privacySection5Content),

            _section(loc.privacySection6Title, loc.privacySection6Content),

            _section(loc.privacySection7Title, loc.privacySection7Content),

            _section(loc.privacySection8Title, loc.privacySection8Content),

            _section(loc.privacySection9Title, loc.privacySection9Content),

            _section(loc.privacySection10Title, loc.privacySection10Content),

            _section(loc.privacySection11Title, loc.privacySection11Content),

            SizedBox(height: 24.h),
            Text(
              loc.privacyFooter,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.labelLarge),
          SizedBox(height: 6.h),
          Text(content,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
