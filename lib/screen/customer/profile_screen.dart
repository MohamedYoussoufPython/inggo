import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/constants.dart';
import '../../widget/widgets.dart';
import '../../provider/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;

    return Scaffold(
      appBar: const InggoAppBar(title: 'Profil'),
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
            Text(user?.fullName ?? 'Utilisateur',
                style: AppTextStyles.headline3),
            SizedBox(height: 4.h),
            Text(user?.phone ?? '', style: AppTextStyles.bodyMedium),
            SizedBox(height: 32.h),
            _MenuTile(Icons.person_outline, 'Modifier le profil',
                () => context.push('/client/edit-profile')),
            _MenuTile(Icons.phone_android, 'Changer le téléphone',
                () => context.push('/client/settings')),
            _MenuTile(Icons.language, 'Langue',
                () => context.push('/client/settings')),
            _MenuTile(Icons.notifications_outlined, 'Notifications',
                () => context.push('/client/notifications')),
            _MenuTile(Icons.help_outline, 'Support',
                () => context.push('/client/support')),
            _MenuTile(Icons.info_outline, 'À propos',
                () => context.push('/about')),
            SizedBox(height: 16.h),
            InggoButton(
              label: 'Déconnexion',
              type: InggoButtonType.danger,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Déconnexion'),
                    content: const Text('Voulez-vous vous déconnecter ?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Non')),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ref.read(authProvider.notifier).signOut();
                          context.go('/login');
                        },
                        child: const Text('Oui'),
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
