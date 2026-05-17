import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/constants.dart';
import '../../widget/widgets.dart';
import '../../provider/auth_provider.dart';
import '../../provider/driver_provider.dart';
import '../../l10n/app_localizations.dart';

class DriverProfileScreen extends ConsumerWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final driver = ref.watch(driverProvider);
    final user = auth.user;
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: InggoAppBar(title: loc.profile),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            CircleAvatar(
              radius: 50.r,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              backgroundImage: auth.user?.avatarUrl != null
                  ? NetworkImage(auth.user!.avatarUrl!)
                  : null,
              child: auth.user?.avatarUrl == null
                  ? Icon(Icons.person, size: 40.w, color: AppColors.primary)
                  : null,
            ),
            SizedBox(height: 16.h),
            Text(user?.fullName ?? loc.driver, style: AppTextStyles.headline3),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: AppColors.primary, size: 16.w),
                SizedBox(width: 4.w),
                Text('${driver.driver?.rating ?? 5.0}',
                    style: AppTextStyles.bodyMedium),
                SizedBox(width: 8.w),
                Text('(${driver.totalRides} ${loc.ridesCount})',
                    style: AppTextStyles.bodySmall),
              ],
            ),
            SizedBox(height: 32.h),
            _MenuTile(Icons.person_outline, loc.editProfile,
                () => context.push('/driver/edit-profile')),
            _MenuTile(Icons.notifications_outlined, loc.notifications,
                () => context.push('/driver/notifications')),
            _MenuTile(Icons.language, loc.language,
                () => context.push('/driver/settings')),
            _MenuTile(Icons.help_outline, loc.support,
                () => context.push('/support')),
            _MenuTile(Icons.info_outline, loc.about,
                () => context.push('/about')),
            _MenuTile(Icons.privacy_tip_outlined, loc.privacyPolicy,
                () => context.push('/privacy-policy')),
            SizedBox(height: 16.h),
            InggoButton(
              label: loc.logout,
              type: InggoButtonType.danger,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(loc.logout),
                    content: Text(loc.logoutMessage),
                    actions: [
                      InggoButton(
                        type: InggoButtonType.text,
                        label: loc.cancel,
                        onPressed: () => Navigator.pop(ctx),
                      ),
                      InggoButton(
                        type: InggoButtonType.text,
                        label: loc.logout,
                        onPressed: () {
                          Navigator.pop(ctx);
                          ref.read(authProvider.notifier).signOut();
                          context.go('/login');
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: InggoBottomNav(currentIndex: 3, isDriver: true),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuTile(this.icon, this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(label, style: AppTextStyles.bodyLarge),
      trailing: Icon(Icons.chevron_right, color: AppColors.textHint),
      onTap: onTap,
    );
  }
}
