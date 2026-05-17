import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/constants.dart';
import '../../widget/widgets.dart';
import '../../provider/auth_provider.dart';
import '../../l10n/app_localizations.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
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
              backgroundImage: user?.avatarUrl != null
                  ? NetworkImage(user!.avatarUrl!)
                  : null,
              child: user?.avatarUrl == null
                  ? Icon(Icons.person, size: 40.w, color: AppColors.primary)
                  : null,
            ),
            SizedBox(height: 16.h),
            Text(user?.fullName ?? loc.userFallback,
                style: AppTextStyles.headline3),
            SizedBox(height: 4.h),
            Text(user?.phone ?? '', style: AppTextStyles.bodyMedium),
            SizedBox(height: 4.h),
            Text(user?.email ?? '', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
            SizedBox(height: 32.h),
            _MenuTile(Icons.person_outline, loc.editProfile,
                () => context.push('/client/edit-profile')),
            _MenuTile(Icons.phone_android, loc.changePhone,
                () => context.push('/client/settings')),
            _MenuTile(Icons.language, loc.language,
                () => context.push('/client/settings')),
            _MenuTile(Icons.notifications_outlined, loc.notifications,
                () => context.push('/client/notifications')),
            _MenuTile(Icons.help_outline, loc.support,
                () => context.push('/client/support')),
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
                    content: Text(loc.logoutConfirm),
                    actions: [
                      InggoButton(
                          type: InggoButtonType.text,
                          label: loc.no,
                          onPressed: () => Navigator.pop(ctx)),
                      InggoButton(
                        type: InggoButtonType.text,
                        label: loc.yes,
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
      bottomNavigationBar: const InggoBottomNav(currentIndex: 3),
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
