import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/constants.dart';
import '../../widget/widgets.dart';
import '../../provider/driver_provider.dart';

class DocumentsScreen extends ConsumerWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driver = ref.watch(driverProvider);
    final d = driver.driver;

    // Determine real upload/verification status for each document
    final idCardUploaded = d?.idCardUrl != null && d!.idCardUrl!.isNotEmpty;
    final licenseUploaded = d?.licenseUrl != null && d!.licenseUrl!.isNotEmpty;
    final vehiclePhotoUploaded =
        d?.vehiclePhotoUrl != null && d!.vehiclePhotoUrl!.isNotEmpty;
    final isVerified = d?.isVerified ?? false;

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
              isUploaded: idCardUploaded,
              isVerified: isVerified,
            ),
            _DocTile(
              icon: Icons.card_membership,
              label: 'Permis de conduire',
              isUploaded: licenseUploaded,
              isVerified: isVerified,
            ),
            _DocTile(
              icon: Icons.motorcycle,
              label: 'Photo du véhicule',
              isUploaded: vehiclePhotoUploaded,
              isVerified: isVerified,
            ),
            SizedBox(height: 24.h),
            Text('Statut du compte', style: AppTextStyles.labelLarge),
            SizedBox(height: 12.h),
            InggoCard(
              child: Row(
                children: [
                  Icon(
                    isVerified
                        ? Icons.verified
                        : (idCardUploaded && licenseUploaded && vehiclePhotoUploaded)
                            ? Icons.schedule
                            : Icons.warning_amber,
                    color: isVerified
                        ? AppColors.success
                        : (idCardUploaded && licenseUploaded && vehiclePhotoUploaded)
                            ? AppColors.warning
                            : AppColors.error,
                    size: 24.w,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isVerified
                              ? 'Vérifié'
                              : (idCardUploaded && licenseUploaded && vehiclePhotoUploaded)
                                  ? 'En cours de vérification'
                                  : 'Documents manquants',
                          style: AppTextStyles.labelMedium,
                        ),
                        Text(
                          isVerified
                              ? 'Votre compte est vérifié et actif'
                              : (idCardUploaded && licenseUploaded && vehiclePhotoUploaded)
                                  ? 'Vos documents sont en cours d\'examen par l\'équipe'
                                  : 'Veuillez soumettre tous les documents requis',
                          style: AppTextStyles.bodySmall,
                        ),
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
  final bool isUploaded;
  final bool isVerified;

  const _DocTile({
    required this.icon,
    required this.label,
    required this.isUploaded,
    required this.isVerified,
  });

  String get _status {
    if (!isUploaded) return 'Non soumis';
    if (isVerified) return 'Vérifié';
    return 'En attente de vérification';
  }

  @override
  Widget build(BuildContext context) {
    final hasStatus = isUploaded;
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: InggoCard(
        child: Row(
          children: [
            Icon(icon,
                color: hasStatus
                    ? (isVerified ? AppColors.success : AppColors.warning)
                    : AppColors.textHint,
                size: 24.w),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.bodyLarge),
                  Text(_status,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: hasStatus
                            ? (isVerified
                                ? AppColors.success
                                : AppColors.warning)
                            : AppColors.textHint,
                      )),
                ],
              ),
            ),
            Icon(
              hasStatus
                  ? (isVerified ? Icons.check_circle : Icons.schedule)
                  : Icons.upload_file,
              color: hasStatus
                  ? (isVerified ? AppColors.success : AppColors.warning)
                  : AppColors.textHint,
              size: 20.w,
            ),
          ],
        ),
      ),
    );
  }
}
