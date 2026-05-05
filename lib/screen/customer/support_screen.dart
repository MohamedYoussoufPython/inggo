import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/constants.dart';
import '../../widget/widgets.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const InggoAppBar(title: 'Support'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Questions fréquentes', style: AppTextStyles.labelLarge),
            SizedBox(height: 12.h),
            _FaqItem(
              question: 'Combien coûte une course ?',
              answer: 'Chaque course coûte 250 FDJ, quel que soit le trajet dans Djibouti ville.',
            ),
            _FaqItem(
              question: 'Comment payer ?',
              answer: 'Pour le moment, seul le paiement en espèces est disponible. Les paiements mobiles arrivent bientôt.',
            ),
            _FaqItem(
              question: 'Comment devenir chauffeur ?',
              answer: 'Inscrivez-vous en tant que chauffeur, soumettez vos documents et attendez la vérification.',
            ),
            _FaqItem(
              question: 'Puis-je annuler une course ?',
              answer: 'Oui, vous pouvez annuler gratuitement dans les 2 premières minutes après la confirmation.',
            ),
            SizedBox(height: 24.h),
            Text('Nous contacter', style: AppTextStyles.labelLarge),
            SizedBox(height: 12.h),
            InggoButton(
              label: 'Nous appeler',
              icon: Icons.phone,
              type: InggoButtonType.outline,
              onPressed: () {},
            ),
            SizedBox(height: 12.h),
            InggoButton(
              label: 'Envoyer un message',
              icon: Icons.message,
              type: InggoButtonType.outline,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(question, style: AppTextStyles.bodyLarge),
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Text(answer, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        ),
      ],
    );
  }
}
