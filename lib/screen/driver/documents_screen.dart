import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/constants.dart';
import '../../widget/widgets.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const InggoAppBar(title: 'Documents'),
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vos documents', style: AppTextStyles.labelLarge),
            SizedBox(height: 12.h),
            _DocTile(
              icon: Icons.badge,
              label: 'Carte d\'identité',
              status: 'Enregistré',
              isUploaded: true,
            ),
            _DocTile(
              icon: Icons.card_membership,
              label: 'Permis de conduire',
              status: 'Enregistré',
              isUploaded: true,
            ),
            _DocTile(
              icon: Icons.motorcycle,
              label: 'Photo du véhicule',
              status: 'Enregistré',
              isUploaded: true,
            ),
            SizedBox(height: 24.h),
            Text('Statut du compte', style: AppTextStyles.labelLarge),
            SizedBox(height: 12.h),
            InggoCard(
              child: Row(
                children: [
                  Icon(Icons.verified, color: AppColors.success, size: 24.w),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Vérifié', style: AppTextStyles.labelMedium),
                        Text('Votre compte est vérifié et actif',
                            style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: InggoBottomNav(currentIndex: 2, isDriver: true),
    );
  }
}

class _DocTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String status;
  final bool isUploaded;

  const _DocTile({
    required this.icon,
    required this.label,
    required this.status,
    required this.isUploaded,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: InggoCard(
        child: Row(
          children: [
            Icon(icon, color: isUploaded ? AppColors.success : AppColors.warning, size: 24.w),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.bodyLarge),
                  Text(status, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            Icon(Icons.check_circle, color: isUploaded ? AppColors.success : AppColors.warning, size: 20.w),
          ],
        ),
      ),
    );
  }
}
