import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/constants.dart';
import '../../widget/widgets.dart';
import '../../provider/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: const InggoAppBar(title: 'Paramètres'),
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Langue', style: AppTextStyles.labelLarge),
            SizedBox(height: 12.h),
            LanguageSelector(
              currentLanguage: auth.locale.languageCode,
              onLanguageChanged: (code) =>
                  ref.read(authProvider.notifier).setLanguage(code),
            ),
            SizedBox(height: 24.h),
            SwitchListTile(
              title: Text('Notifications', style: AppTextStyles.bodyLarge),
              subtitle: Text('Recevoir les notifications push',
                  style: AppTextStyles.bodySmall),
              value: _notificationsEnabled,
              activeColor: AppColors.primary,
              onChanged: (val) => setState(() => _notificationsEnabled = val),
            ),
            SizedBox(height: 24.h),
            Text('À propos', style: AppTextStyles.labelLarge),
            SizedBox(height: 12.h),
            _aboutRow('Version', '1.0.0'),
            _aboutRow('Application', 'Inggo VTC'),
            _aboutRow('Ville', 'Djibouti'),
          ],
        ),
      ),
    );
  }

  Widget _aboutRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Text(value, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
