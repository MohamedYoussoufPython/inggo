import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/constants.dart';
import '../../core/services/supabase_service.dart';
import '../../widget/widgets.dart';
import '../../provider/driver_provider.dart';
import '../../l10n/app_localizations.dart';

class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  bool _isUploading = false;
  String? _uploadingField;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(driverProvider.notifier).loadDriver());
  }

  Future<void> _uploadDocument(String field, String bucketPath) async {
    // Capture context-dependent values before any async gap
    final loc = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (image == null) return;

    setState(() {
      _isUploading = true;
      _uploadingField = field;
    });

    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) throw Exception(loc.notAuthenticated);

      final bytes = await File(image.path).readAsBytes();
      final path = '$userId/$bucketPath/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final url = await SupabaseService.instance.uploadPrivateFile('driver-documents', path, bytes);

      // Update the driver record with the new document URL
      await SupabaseService.instance.update('drivers', userId, {field: url});

      // Refresh driver data
      await ref.read(driverProvider.notifier).loadDriver();

      if (mounted) {
        InggoToast.successMessenger(messenger, loc.uploadSuccess);
      }
    } catch (e) {
      if (mounted) {
        InggoToast.errorMessenger(messenger, '${loc.error}: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadingField = null;
        });
      }
    }
  }

  Future<void> _takePhoto(String field, String bucketPath) async {
    // Capture context-dependent values before any async gap
    final loc = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (image == null) return;

    setState(() {
      _isUploading = true;
      _uploadingField = field;
    });

    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) throw Exception(loc.notAuthenticated);

      final bytes = await File(image.path).readAsBytes();
      final path = '$userId/$bucketPath/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final url = await SupabaseService.instance.uploadPrivateFile('driver-documents', path, bytes);

      await SupabaseService.instance.update('drivers', userId, {field: url});
      await ref.read(driverProvider.notifier).loadDriver();

      if (mounted) {
        InggoToast.successMessenger(messenger, loc.uploadSuccess);
      }
    } catch (e) {
      if (mounted) {
        InggoToast.errorMessenger(messenger, '${loc.error}: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadingField = null;
        });
      }
    }
  }

  void _showUploadOptions(String field, String bucketPath, String label) {
    final loc = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${loc.submitColon} $label', style: AppTextStyles.labelLarge),
              SizedBox(height: 20.h),
              InggoButton(
                label: loc.takePhoto,
                icon: Icons.camera_alt,
                onPressed: () {
                  Navigator.pop(ctx);
                  _takePhoto(field, bucketPath);
                },
              ),
              SizedBox(height: 12.h),
              InggoButton(
                label: loc.chooseFromGallery,
                icon: Icons.photo_library,
                type: InggoButtonType.outline,
                onPressed: () {
                  Navigator.pop(ctx);
                  _uploadDocument(field, bucketPath);
                },
              ),
              SizedBox(height: 12.h),
              InggoButton(
                label: loc.cancel,
                type: InggoButtonType.text,
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final driver = ref.watch(driverProvider);
    final d = driver.driver;
    final loc = AppLocalizations.of(context);

    final idCardUploaded = d?.idCardUrl != null && d!.idCardUrl!.isNotEmpty;
    final licenseUploaded = d?.licenseUrl != null && d!.licenseUrl!.isNotEmpty;
    final insuranceUploaded = d?.insuranceUrl != null && d!.insuranceUrl!.isNotEmpty;
    final vehiclePhotoUploaded = d?.vehiclePhotoUrl != null && d!.vehiclePhotoUrl!.isNotEmpty;
    final isVerified = d?.isVerified ?? false;
    final allUploaded = idCardUploaded && licenseUploaded && insuranceUploaded && vehiclePhotoUploaded;

    return Scaffold(
      appBar: InggoAppBar(title: loc.documents),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.yourDocuments, style: AppTextStyles.labelLarge),
            SizedBox(height: 4.h),
            Text(
              loc.submitForVerification,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: 12.h),
            _DocTile(
              icon: Icons.badge,
              label: loc.idCard,
              isUploaded: idCardUploaded,
              isVerified: isVerified,
              isUploading: _isUploading && _uploadingField == 'id_card_url',
              onUpload: () => _showUploadOptions('id_card_url', 'id-card', loc.idCard),
            ),
            _DocTile(
              icon: Icons.card_membership,
              label: loc.driverLicense,
              isUploaded: licenseUploaded,
              isVerified: isVerified,
              isUploading: _isUploading && _uploadingField == 'license_url',
              onUpload: () => _showUploadOptions('license_url', 'license', loc.driverLicense),
            ),
            _DocTile(
              icon: Icons.shield,
              label: loc.insurance,
              isUploaded: insuranceUploaded,
              isVerified: isVerified,
              isUploading: _isUploading && _uploadingField == 'insurance_url',
              onUpload: () => _showUploadOptions('insurance_url', 'insurance', loc.insurance),
            ),
            _DocTile(
              icon: Icons.motorcycle,
              label: loc.vehiclePhoto,
              isUploaded: vehiclePhotoUploaded,
              isVerified: isVerified,
              isUploading: _isUploading && _uploadingField == 'vehicle_photo_url',
              onUpload: () => _showUploadOptions('vehicle_photo_url', 'vehicle', loc.vehiclePhoto),
            ),
            SizedBox(height: 24.h),
            Text(loc.accountStatus, style: AppTextStyles.labelLarge),
            SizedBox(height: 12.h),
            InggoCard(
              child: Row(
                children: [
                  Icon(
                    isVerified
                        ? Icons.verified
                        : allUploaded
                            ? Icons.schedule
                            : Icons.warning_amber,
                    color: isVerified
                        ? AppColors.success
                        : allUploaded
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
                              ? loc.verifiedLabel
                              : allUploaded
                                  ? loc.verificationInProgressLabel
                                  : loc.missingDocumentsLabel,
                          style: AppTextStyles.labelMedium,
                        ),
                        Text(
                          isVerified
                              ? loc.accountVerified
                              : allUploaded
                                  ? loc.underReview
                                  : loc.submitAllRequired,
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
  final bool isUploading;
  final VoidCallback? onUpload;

  const _DocTile({
    required this.icon,
    required this.label,
    required this.isUploaded,
    required this.isVerified,
    this.isUploading = false,
    this.onUpload,
  });

  String _status(BuildContext context) {
    final loc = AppLocalizations.of(context);
    if (isUploading) return loc.uploading;
    if (!isUploaded) return loc.notSubmitted;
    if (isVerified) return loc.verifiedLabel;
    return loc.pendingVerificationLabel;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: InggoCard(
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon,
                    color: isUploaded
                        ? (isVerified ? AppColors.success : AppColors.warning)
                        : AppColors.textHint,
                    size: 24.w),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: AppTextStyles.bodyLarge),
                      Text(_status(context),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isUploading
                                ? AppColors.info
                                : (isUploaded
                                    ? (isVerified
                                        ? AppColors.success
                                        : AppColors.warning)
                                    : AppColors.textHint),
                          )),
                    ],
                  ),
                ),
                isUploading
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        isUploaded
                            ? (isVerified ? Icons.check_circle : Icons.schedule)
                            : Icons.upload_file,
                        color: isUploaded
                            ? (isVerified ? AppColors.success : AppColors.warning)
                            : AppColors.textHint,
                        size: 20.w,
                      ),
              ],
            ),
            if (onUpload != null) ...[
              SizedBox(height: 8.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: isUploading ? null : onUpload,
                  icon: Icon(
                    isUploaded ? Icons.refresh : Icons.upload_file,
                    size: 16.w,
                  ),
                  label: Text(
                    isUploaded ? loc.replace : loc.submitDocument,
                    style: AppTextStyles.bodySmall,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
