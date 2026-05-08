import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/constants.dart';
import '../../core/utils/validators.dart';
import '../../core/services/supabase_service.dart';
import '../../widget/widgets.dart';
import '../../provider/auth_provider.dart';

class RegisterDriverScreen extends ConsumerStatefulWidget {
  const RegisterDriverScreen({super.key});

  @override
  ConsumerState<RegisterDriverScreen> createState() =>
      _RegisterDriverScreenState();
}

class _RegisterDriverScreenState extends ConsumerState<RegisterDriverScreen> {
  final _nameController = TextEditingController();
  final _plateController = TextEditingController();
  final _colorController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _idCardUrl;
  String? _licenseUrl;
  String? _vehiclePhotoUrl;

  @override
  void dispose() {
    _nameController.dispose();
    _plateController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String type) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      imageQuality: 80,
    );
    if (image == null) return;

    try {
      final bytes = await image.readAsBytes();
      final path = 'drivers/${SupabaseService.instance.currentUserId}/$type/${image.name}';
      final url = await SupabaseService.instance.uploadFile('driver-documents', path, bytes);
      setState(() {
        switch (type) {
          case 'id_card':
            _idCardUrl = url;
            break;
          case 'license':
            _licenseUrl = url;
            break;
          case 'vehicle':
            _vehiclePhotoUrl = url;
            break;
        }
      });
    } catch (e) {
      if (mounted) InggoToast.error(context, 'Erreur d\'upload: $e');
    }
  }

  void _register() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authProvider.notifier).registerDriver(
          fullName: _nameController.text.trim(),
          plateNumber: _plateController.text.trim(),
          vehicleColor: _colorController.text.trim().isEmpty
              ? null
              : _colorController.text.trim(),
          idCardUrl: _idCardUrl,
          licenseUrl: _licenseUrl,
          vehiclePhotoUrl: _vehiclePhotoUrl,
        );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.user != null && next.user!.role.name == 'driver') {
        context.go('/pending-verification');
      }
      if (next.error != null && prev?.error != next.error) {
        InggoToast.error(context, next.error!);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40.h),
                Text('Inscription chauffeur',
                    style: AppTextStyles.headline2),
                SizedBox(height: 8.h),
                Text(
                  'Remplissez vos informations pour commencer.',
                  style: AppTextStyles.bodyLarge
                      .copyWith(color: AppColors.textSecondary),
                ),
                SizedBox(height: 24.h),
                InggoInput(
                  label: 'Nom complet',
                  hint: 'Ahmed Mohamed',
                  controller: _nameController,
                  validator: Validators.validateName,
                  prefixIcon: Icons.person_outline,
                ),
                SizedBox(height: 16.h),
                InggoInput(
                  label: 'Numéro de plaque',
                  hint: 'DJ 1234 A',
                  controller: _plateController,
                  validator: Validators.validatePlateNumber,
                  prefixIcon: Icons.directions_car,
                ),
                SizedBox(height: 16.h),
                InggoInput(
                  label: 'Couleur du véhicule',
                  hint: 'Noir, Blanc, Rouge...',
                  controller: _colorController,
                  prefixIcon: Icons.color_lens,
                ),
                SizedBox(height: 24.h),
                Text('Documents', style: AppTextStyles.labelLarge),
                SizedBox(height: 12.h),
                _DocUploadTile(
                  label: 'Carte d\'identité',
                  icon: Icons.badge,
                  isUploaded: _idCardUrl != null,
                  onTap: () => _pickImage('id_card'),
                ),
                _DocUploadTile(
                  label: 'Permis de conduire',
                  icon: Icons.card_membership,
                  isUploaded: _licenseUrl != null,
                  onTap: () => _pickImage('license'),
                ),
                _DocUploadTile(
                  label: 'Photo du véhicule',
                  icon: Icons.motorcycle,
                  isUploaded: _vehiclePhotoUrl != null,
                  onTap: () => _pickImage('vehicle'),
                ),
                SizedBox(height: 24.h),
                InggoButton(
                  label: 'Soumettre l\'inscription',
                  isLoading: auth.isLoading,
                  onPressed: _register,
                ),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DocUploadTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isUploaded;
  final VoidCallback onTap;

  const _DocUploadTile({
    required this.label,
    required this.icon,
    required this.isUploaded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isUploaded
              ? AppColors.success.withValues(alpha: 0.1)
              : AppColors.background,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isUploaded ? AppColors.success : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isUploaded ? AppColors.success : AppColors.textSecondary,
                size: 24.w),
            SizedBox(width: 12.w),
            Expanded(child: Text(label, style: AppTextStyles.bodyLarge)),
            Icon(
              isUploaded ? Icons.check_circle : Icons.camera_alt,
              color: isUploaded ? AppColors.success : AppColors.primary,
              size: 24.w,
            ),
          ],
        ),
      ),
    );
  }
}
