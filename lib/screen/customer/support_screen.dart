import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/constants.dart';
import '../../widget/widgets.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  // Support phone number for Inggo VTC Djibouti
  static const String _supportPhone = '+25377000000';
  static const String _supportWhatsapp = '25377000000';

  Future<void> _makePhoneCall() async {
    final uri = Uri.parse('tel:$_supportPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // If phone call fails, show a SnackBar or fallback
      debugPrint('Could not launch phone call');
    }
  }

  Future<void> _sendMessage() async {
    // Try WhatsApp first, fallback to SMS
    final whatsappUri = Uri.parse('https://wa.me/$_supportWhatsapp?text=Bonjour%20Inggo%20Support%2C%20');
    final smsUri = Uri.parse('sms:$_supportPhone?body=Bonjour%20Inggo%20Support%2C%20');

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      debugPrint('Could not launch messaging app');
    }
  }

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
              answer:
                  'Chaque course coûte 250 FDJ, quel que soit le trajet dans Djibouti ville.',
            ),
            _FaqItem(
              question: 'Comment payer ?',
              answer:
                  'Pour le moment, seul le paiement en espèces est disponible. Les paiements mobiles arrivent bientôt.',
            ),
            _FaqItem(
              question: 'Comment devenir chauffeur ?',
              answer:
                  'Inscrivez-vous en tant que chauffeur, soumettez vos documents et attendez la vérification.',
            ),
            _FaqItem(
              question: 'Puis-je annuler une course ?',
              answer:
                  'Oui, vous pouvez annuler gratuitement dans les 2 premières minutes après la confirmation.',
            ),
            SizedBox(height: 24.h),
            Text('Nous contacter', style: AppTextStyles.labelLarge),
            SizedBox(height: 12.h),
            InggoButton(
              label: 'Nous appeler',
              icon: Icons.phone,
              type: InggoButtonType.outline,
              onPressed: _makePhoneCall,
            ),
            SizedBox(height: 12.h),
            InggoButton(
              label: 'Envoyer un message',
              icon: Icons.message,
              type: InggoButtonType.outline,
              onPressed: _sendMessage,
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
          child: Text(answer,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
        ),
      ],
    );
  }
}
