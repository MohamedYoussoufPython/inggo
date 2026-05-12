import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/constants.dart';
import '../../l10n/app_localizations.dart';
import '../../widget/widgets.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: InggoAppBar(title: loc.privacyPolicyTitle, showBack: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.privacyPolicyTitle, style: AppTextStyles.headline3),
            SizedBox(height: 4.h),
            Text(loc.lastUpdated,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
            SizedBox(height: 24.h),

            _section('1. Responsable du traitement',
                'InnGroup SARL, société immatriculée à Djibouti, est le responsable du traitement de vos données personnelles dans le cadre de l\'application Inggo VTC. Pour nous contacter : admin@inngroupsarl.com ou +253 77 78 06 06.'),

            _section('2. Données collectées',
                'Nous collectons les données suivantes lors de votre inscription et utilisation de l\'application : nom complet, numéro de téléphone, adresse e-mail, position géographique (en temps réel pendant l\'utilisation), photos de profil, et pour les chauffeurs : carte d\'identité, permis de conduire et photo du véhicule.'),

            _section('3. Finalité du traitement',
                'Vos données sont utilisées pour : la création et la gestion de votre compte, la mise en relation entre clients et chauffeurs, le suivi des courses en temps réel, la facturation et le paiement, la vérification d\'identité des chauffeurs, l\'amélioration de nos services, et les communications liées à votre compte.'),

            _section('4. Base légale',
                'Le traitement de vos données repose sur : l\'exécution du contrat de service de transport, votre consentement (notifications, géolocalisation), nos obligations légales, et notre intérêt légitime à améliorer nos services.'),

            _section('5. Partage des données',
                'Vos données ne sont pas vendues à des tiers. Elles peuvent être partagées avec : votre chauffeur/client (nom, note) dans le cadre de la course, nos prestataires techniques (Supabase pour l\'hébergement, Google Maps pour la cartographie), et les autorités compétentes si requis par la loi.'),

            _section('6. Géolocalisation',
                'La géolocalisation est essentielle au fonctionnement de l\'application. Pour les clients, elle permet de déterminer votre position de départ. Pour les chauffeurs, elle est transmise en temps réel au client pendant la course. Vous pouvez désactiver la géolocalisation dans les paramètres de votre appareil, mais cela empêchera l\'utilisation du service.'),

            _section('7. Conservation des données',
                'Vos données sont conservées aussi longtemps que votre compte est actif. Les données de course sont conservées pendant 5 ans à des fins comptables et légales. Vous pouvez demander la suppression de votre compte à tout moment en contactant notre support.'),

            _section('8. Sécurité',
                'Nous mettons en œuvre des mesures techniques et organisationnelles appropriées pour protéger vos données, notamment : chiffrement des données en transit (HTTPS/TLS), stockage sécurisé chez Supabase, contrôle d\'accès basé sur les rôles (RLS), et vérification d\'identité des chauffeurs.'),

            _section('9. Vos droits',
                'Conformément à la législation applicable, vous disposez d\'un droit d\'accès, de rectification, de suppression et de portabilité de vos données. Pour exercer ces droits, contactez-nous à admin@inngroupsarl.com.'),

            _section('10. Cookies et traceurs',
                'L\'application Inggo n\'utilise pas de cookies publicitaires. Nous utilisons uniquement les données techniques nécessaires au fonctionnement du service (jeton d\'authentification, préférences de langue et de notifications).'),

            _section('11. Modifications',
                'Nous nous réservons le droit de modifier cette politique. Toute modification substantielle vous sera notifiée via l\'application ou par e-mail. L\'utilisation continue du service après notification constitue votre acceptation des modifications.'),

            SizedBox(height: 24.h),
            Text(
              'Inggo VTC — InnGroup SARL\nDjibouti, République de Djibouti\nContact : admin@inngroupsarl.com | +253 77 78 06 06',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.labelLarge),
          SizedBox(height: 6.h),
          Text(content,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
