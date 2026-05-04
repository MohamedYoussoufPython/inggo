import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/inggo_theme.dart';
import '../../widget/inggo_button.dart';
import '../../widget/inggo_toast.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        _emailController.text.trim(),
      );

      if (mounted) {
        showInggoToast(
          context: context,
          message: 'Lien de réinitialisation envoyé à ${_emailController.text.trim()} !',
          type: InggoToastType.success,
        );
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) context.pop();
        });
      }
    } on AuthException catch (e) {
      if (mounted) {
        showInggoToast(
          context: context,
          message: e.message,
          type: InggoToastType.error,
        );
      }
    } catch (e) {
      if (mounted) {
        showInggoToast(
          context: context,
          message: 'Une erreur est survenue. Veuillez réessayer.',
          type: InggoToastType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: InggoColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: InggoColors.text1),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(InggoSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Mot de passe oublié',
                  style: InggoTextStyles.h1,
                ),
                const SizedBox(height: InggoSpacing.md),
                Text(
                  'Entrez votre adresse email pour recevoir un lien de réinitialisation.',
                  style: InggoTextStyles.body.copyWith(color: InggoColors.text2),
                ),
                const SizedBox(height: InggoSpacing.xl),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez entrer votre email';
                    }
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value.trim())) {
                      return 'Veuillez entrer un email valide';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'votre.email@exemple.com',
                    prefixIcon: const Icon(Icons.email_outlined, color: InggoColors.text3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(InggoSpacing.sm),
                      borderSide: const BorderSide(color: InggoColors.border2, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(InggoSpacing.sm),
                      borderSide: const BorderSide(color: InggoColors.primary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: InggoSpacing.xl),
                InggoButton(
                  label: 'Envoyer le lien',
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _sendResetLink,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
