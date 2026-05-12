import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/constants/constants.dart';
import '../../core/services/supabase_service.dart';
import '../../model/user_model.dart';
import '../../widget/widgets.dart';
import '../../provider/auth_provider.dart';
import '../../l10n/app_localizations.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  /// If true, this is the driver editing their profile
  final bool isDriver;
  const EditProfileScreen({super.key, this.isDriver = false});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  bool _isLoading = false;
  File? _selectedImage;
  String? _currentAvatarUrl;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _currentAvatarUrl = user?.avatarUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) throw Exception(AppLocalizations.of(context).notAuthenticated);

      final newName = _nameController.text.trim();
      final newPhone = _phoneController.text.trim();

      // Upload avatar if changed
      String? avatarUrl = _currentAvatarUrl;
      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        final path = 'avatars/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
        avatarUrl = await SupabaseService.instance.uploadFile('avatars', path, bytes);
      }

      await SupabaseService.instance.update('profiles', userId, {
        'full_name': newName,
        'phone': newPhone,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      });

      // Refresh the auth state by re-fetching the profile
      final userData =
          await SupabaseService.instance.getById('profiles', userId);
      final updatedUser = UserModel.fromJson(userData);

      if (mounted) {
        // Update the auth state with the new user data
        ref.read(authProvider.notifier).updateUser(updatedUser);

        InggoToast.success(context, AppLocalizations.of(context).profileUpdated);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        InggoToast.error(context, '${loc.error}: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: InggoAppBar(title: loc.editProfile, showBack: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.screenPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              // Avatar with edit
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50.r,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : (_currentAvatarUrl != null
                                ? NetworkImage(_currentAvatarUrl!) as ImageProvider
                                : null),
                        child: _selectedImage == null && _currentAvatarUrl == null
                            ? Icon(Icons.person, size: 40.w, color: AppColors.primary)
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 32.w,
                          height: 32.w,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.surface, width: 2),
                          ),
                          child: Icon(Icons.camera_alt, size: 16.w, color: AppColors.secondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Center(
                child: Text(loc.changePhoto,
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary)),
              ),
              SizedBox(height: 32.h),
              Text(loc.personalInfo,
                  style: AppTextStyles.labelLarge),
              SizedBox(height: 16.h),
              InggoInput(
                label: loc.fullName,
                hint: loc.fullNameHint,
                controller: _nameController,
                prefixIcon: Icons.person_outline,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? loc.fieldRequired : null,
              ),
              SizedBox(height: 16.h),
              InggoInput(
                label: loc.phone,
                hint: '+253 77 XX XX XX',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_android,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? loc.fieldRequired : null,
              ),
              SizedBox(height: 48.h),
              InggoButton(
                label: loc.save,
                onPressed: _isLoading ? null : _saveProfile,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
