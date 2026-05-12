import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/constants.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/supabase_service.dart';
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
        _notificationsEnabled = prefs.getBool('driver_notifications_enabled') ?? true;
        _prefsLoaded = true;
      });
    }
  }

  Future<void> _onNotificationChanged(bool val) async {
    setState(() => _notificationsEnabled = val);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('driver_notifications_enabled', val);

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
              onChanged: _prefsLoaded ? _onNotificationChanged : null,
            ),
          ],
        ),
      ),
      bottomNavigationBar: const InggoBottomNav(currentIndex: 2, isDriver: true),
    );
  }
}
