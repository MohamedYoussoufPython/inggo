import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/constants.dart';
import '../../widget/widgets.dart';
import '../../l10n/app_localizations.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  // Support phone number for Inggo VTC Djibouti
  static const String _supportPhone = '+2537780606';
  static const String _supportWhatsapp = '2537780606';

  Future<void> _makePhoneCall() async {
    final loc = AppLocalizations.of(context);
    final uri = Uri.parse('tel:$_supportPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        InggoToast.error(context, loc.unableToMakePhoneCall);
      }
    }
  }

  Future<void> _sendMessage() async {
    final loc = AppLocalizations.of(context);
    // Try WhatsApp first, fallback to SMS
    final message = Uri.encodeComponent(loc.supportWhatsappMessage);
    final whatsappUri = Uri.parse('https://wa.me/$_supportWhatsapp?text=$message');
    final smsUri = Uri.parse('sms:$_supportPhone?body=$message');

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      if (mounted) {
        InggoToast.error(context, loc.noMessagingApp);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: InggoAppBar(title: loc.support),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.faq, style: AppTextStyles.labelLarge),
            SizedBox(height: 12.h),
            _FaqItem(
              question: loc.faqPriceQuestion,
              answer: loc.faqPriceAnswer,
            ),
            _FaqItem(
              question: loc.faqPaymentQuestion,
              answer: loc.faqPaymentAnswer,
            ),
            _FaqItem(
              question: loc.faqDriverQuestion,
              answer: loc.faqDriverAnswer,
            ),
            _FaqItem(
              question: loc.faqCancelQuestion,
              answer: loc.faqCancelAnswer,
            ),
            SizedBox(height: 24.h),
            Text(loc.contactUs, style: AppTextStyles.labelLarge),
            SizedBox(height: 12.h),
            InggoButton(
              label: loc.callUs,
              icon: Icons.phone,
              type: InggoButtonType.outline,
              onPressed: _makePhoneCall,
            ),
            SizedBox(height: 12.h),
            InggoButton(
              label: loc.sendMessage,
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
