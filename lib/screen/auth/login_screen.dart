import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/constants.dart';
import '../../core/utils/validators.dart';
import '../../widget/widgets.dart';
import '../../provider/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    if (!_formKey.currentState!.validate()) return;
    final phone = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    ref.read(authProvider.notifier).sendOtp(phone);
    context.push('/otp?phone=$phone');
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 60.h),
                Icon(Icons.motorcycle, size: 60.w, color: AppColors.primary),
                SizedBox(height: 24.h),
                Text('Connexion', style: AppTextStyles.headline2),
                SizedBox(height: 8.h),
                Text(
                  'Entrez votre numéro de téléphone pour recevoir un code de vérification.',
                  style: AppTextStyles.bodyLarge
                      .copyWith(color: AppColors.textSecondary),
                ),
                SizedBox(height: 32.h),
                InggoPhoneInput(
                  controller: _phoneController,
                  validator: Validators.validatePhone,
                ),
                SizedBox(height: 24.h),
                InggoButton(
                  label: 'Envoyer le code',
                  isLoading: auth.isLoading,
                  onPressed: _sendOtp,
                ),
                if (auth.error != null) ...[
                  SizedBox(height: 16.h),
                  Text(auth.error!,
                      style:
                          AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
