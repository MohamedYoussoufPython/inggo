import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/constants.dart';
import '../../widget/widgets.dart';
import '../../provider/auth_provider.dart';

class DriverSettingsScreen extends ConsumerStatefulWidget {
  const DriverSettingsScreen({super.key});

  @override
  ConsumerState<DriverSettingsScreen> createState() =>
      _DriverSettingsScreenState();
}

class _DriverSettingsScreenState extends ConsumerState<DriverSettingsScreen> {
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
              subtitle: Text('Nouvelles demandes de course',
                  style: AppTextStyles.bodySmall),
              value: _notificationsEnabled,
              activeThumbColor: AppColors.primary,
              onChanged: (val) => setState(() => _notificationsEnabled = val),
            ),
          ],
        ),
      ),
    );
  }
}
