import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/constants.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/supabase_service.dart';
import '../../widget/widgets.dart';
import '../../provider/auth_provider.dart';
import '../../l10n/app_localizations.dart';

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

    // Actually start/stop notification listening based on the toggle
    if (val) {
      final userId = SupabaseService.instance.currentUserId;
      if (userId != null) {
        NotificationService.instance.startListening(userId);
      }
    } else {
      NotificationService.instance.stopListening();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: InggoAppBar(title: loc.settings),
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.language, style: AppTextStyles.labelLarge),
            SizedBox(height: 12.h),
            LanguageSelector(
              currentLanguage: auth.locale.languageCode,
              onLanguageChanged: (code) =>
                  ref.read(authProvider.notifier).setLanguage(code),
            ),
            SizedBox(height: 24.h),
            SwitchListTile(
              title: Text(loc.notifications, style: AppTextStyles.bodyLarge),
              subtitle: Text(loc.pushNotifications,
                  style: AppTextStyles.bodySmall),
              value: _notificationsEnabled,
              activeColor: AppColors.primary,
              onChanged: _prefsLoaded ? _onNotificationChanged : null,
            ),
            SizedBox(height: 24.h),
            Text(loc.about, style: AppTextStyles.labelLarge),
            SizedBox(height: 12.h),
            _aboutRow(loc.version, AppConstants.appVersion),
            _aboutRow(loc.application, loc.appNameVtc),
            _aboutRow(loc.city, 'Djibouti'),
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
          Flexible(child: Text(label, style: AppTextStyles.bodyMedium)),
          Text(value,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
