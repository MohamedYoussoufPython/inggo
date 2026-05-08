import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool _prefsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
        _prefsLoaded = true;
      });
    }
  }

  Future<void> _onNotificationChanged(bool val) async {
    setState(() => _notificationsEnabled = val);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', val);
  }

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
              activeThumbColor: AppColors.primary,
              onChanged: _prefsLoaded ? _onNotificationChanged : null,
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
          Text(value,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
