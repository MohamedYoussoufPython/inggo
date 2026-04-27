import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/inggo_theme.dart';
import '../../widget/inggo_button.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

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
                keyboardType: TextInputType.emailAddress,
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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lien de réinitialisation envoyé !'),
                      backgroundColor: InggoColors.success,
                    ),
                  );
                  Future.delayed(const Duration(seconds: 2), () {
                    if (context.mounted) context.pop();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
