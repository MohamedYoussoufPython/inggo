import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/constants.dart';
import '../../core/services/supabase_service.dart';
import '../../model/user_model.dart';
import '../../widget/widgets.dart';
import '../../provider/auth_provider.dart';

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.fullName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) throw Exception('Non authentifié');

      final newName = _nameController.text.trim();

      await SupabaseService.instance.update('profiles', userId, {
        'full_name': newName,
      });

      // Refresh the auth state by re-fetching the profile
      final userData =
          await SupabaseService.instance.getById('profiles', userId);
      final updatedUser = UserModel.fromJson(userData);

      if (mounted) {
        // Update the auth state with the new user data
        final authState = ref.read(authProvider);
        ref.read(authProvider.notifier).updateUser(updatedUser);

        InggoToast.show(context,
            message: 'Profil mis à jour', type: InggoToastType.success);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        InggoToast.show(context,
            message: 'Erreur: $e', type: InggoToastType.error);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const InggoAppBar(title: 'Modifier le profil', showBack: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.screenPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              Center(
                child: CircleAvatar(
                  radius: 50.r,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  child:
                      Icon(Icons.person, size: 40.w, color: AppColors.primary),
                ),
              ),
              SizedBox(height: 32.h),
              Text('Informations personnelles',
                  style: AppTextStyles.labelLarge),
              SizedBox(height: 16.h),
              InggoInput(
                hint: 'Nom complet',
                controller: _nameController,
                prefixIcon: Icons.person_outline,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Champ requis' : null,
              ),
              SizedBox(height: 48.h),
              InggoButton(
                label: 'Enregistrer',
                onPressed: _isLoading ? null : _saveProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
