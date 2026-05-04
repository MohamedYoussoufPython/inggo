import 'package:flutter/material.dart';

enum LegalType { cgu, privacy }

class LegalScreen extends StatelessWidget {
  final LegalType type;
  const LegalScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final isCgu = type == LegalType.cgu;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        shape: BoxShape.circle,
                        border: const Border.all(color: Color(0xFFDDDDDD)),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF121212),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    isCgu ? 'CGU' : 'Privacy Policy',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: isCgu ? _cguContent() : _privacyContent(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _cguContent() {
    return [
      _centered('Conditions Générales d\'Utilisation (CGU) – Inggo'),
      _sub('Dernière mise à jour : Mercredi 7 janvier'),
      const SizedBox(height: 16),
      _p(
        'Les présentes Conditions Générales d\'Utilisation (ci-après les « CGU ») régissent l\'accès et l\'utilisation de l\'application mobile Inggo, plateforme technologique de mise en relation entre utilisateurs et conducteurs privés indépendants sur moto.',
      ),
      _p(
        'L\'application Inggo est la propriété exclusive et est exploitée par la société InnGroup SARL, société de droit djiboutien, dont le siège social est situé à Gabode 5, République de Djibouti (ci-après la « Société »).',
      ),
      _p(
        'Toute utilisation de l\'application implique l\'acceptation pleine, entière et sans réserve des présentes CGU.',
      ),
      _h2('Article 1 – Définitions'),
      _bullet('Application : désigne l\'application mobile Inggo.'),
      _bullet(
        'Société : désigne InnGroup SARL, société établie en République de Djibouti, propriétaire et exploitante de l\'application Inggo.',
      ),
      _bullet(
        'Utilisateur : toute personne physique utilisant l\'application afin de solliciter un trajet.',
      ),
      _bullet(
        'Conducteur Partenaire : toute personne indépendante utilisant l\'application pour proposer un service de transport sur moto.',
      ),
      _bullet(
        'Service : service de mise en relation technologique fourni par l\'application Inggo.',
      ),
      _h2('Article 2 – Objet'),
      _p(
        'Les présentes CGU ont pour objet de définir les conditions d\'accès et d\'utilisation de l\'application Inggo.',
      ),
      _p('Inggo est une plateforme technologique de mise en relation.'),
      _p(
        'La Société n\'exerce aucune activité de transport, ne fournit aucun service de transport et n\'est partie à aucun contrat de transport conclu entre les Utilisateurs et les Conducteurs Partenaires.',
      ),
      _h2('Article 3 – Accès à l\'application'),
      _p(
        'L\'accès à l\'application Inggo est réservé aux personnes majeures et juridiquement capables.',
      ),
      _p('La création d\'un compte est obligatoire pour accéder aux services.'),
      _p(
        'L\'Utilisateur s\'engage à fournir des informations exactes, complètes et à jour.',
      ),
      _h2('Article 4 – Fonctionnement du service'),
      _p(
        'L\'application permet à un Utilisateur de solliciter un Conducteur Partenaire disponible à proximité.',
      ),
      _h2('Article 5 – Statut des Conducteurs Partenaires'),
      _p(
        'Les Conducteurs Partenaires exercent leur activité de manière totalement indépendante.',
      ),
      _p(
        'Ils ne sont ni salariés, ni agents, ni représentants de InnGroup SARL.',
      ),
      _h2('Article 6 – Responsabilité'),
      _p(
        'La Société ne saurait être tenue responsable des accidents, dommages, blessures, retards, litiges ou incidents survenus lors d\'un trajet.',
      ),
      _h2('Article 7 – Assurance'),
      _p(
        'Chaque Conducteur Partenaire est tenu de disposer d\'une assurance professionnelle valide couvrant son activité de transport sur moto.',
      ),
      _h2('Article 8 – Comportement des utilisateurs'),
      _p(
        'Les Utilisateurs s\'engagent à adopter un comportement respectueux, légal et non dangereux.',
      ),
      _h2('Article 9 – Paiement, commissions et flux financiers'),
      _p(
        'Le paiement des courses peut être effectué via l\'application Inggo ou directement auprès du Conducteur Partenaire.',
      ),
      _p(
        'InnGroup SARL perçoit une commission sur chaque course réalisée via l\'application.',
      ),
      _h2('Article 10 – Données personnelles'),
      _p(
        'La collecte et le traitement des données personnelles sont régis par la Politique de Confidentialité Inggo.',
      ),
      _h2('Article 11 – Suppression du compte'),
      _p(
        'Chaque Utilisateur ou Conducteur Partenaire peut demander la suppression de son compte via l\'application ou par email à admin@inngroupsarl.com.',
      ),
      _h2('Article 12 – Propriété intellectuelle'),
      _p(
        'L\'ensemble des éléments de l\'application Inggo est la propriété exclusive de InnGroup SARL.',
      ),
      _h2('Article 13 – Droit applicable'),
      _p(
        'Les présentes CGU sont régies par le droit en vigueur en République de Djibouti.',
      ),
    ];
  }

  List<Widget> _privacyContent() {
    return [
      _centered('Politique de Confidentialité – Inggo'),
      _sub('Dernière mise à jour : Mercredi 7 janvier'),
      const SizedBox(height: 16),
      _p(
        'InnGroup SARL, société de droit djiboutien (ci-après la « Société »), s\'engage à protéger les données personnelles de ses utilisateurs dans le cadre de l\'utilisation de l\'application mobile Inggo.',
      ),
      _h2('Article 1 – Responsable du traitement'),
      _p(
        'Le responsable du traitement des données est InnGroup SARL, dont le siège social est situé à Gabode 5, République de Djibouti.',
      ),
      _h2('Article 2 – Données collectées'),
      _bullet('Nom, prénom'),
      _bullet('Numéro de téléphone'),
      _bullet('Adresse email'),
      _bullet('Données de géolocalisation'),
      _bullet('Informations relatives au véhicule (Conducteurs Partenaires)'),
      _bullet('Historique des courses'),
      _h2('Article 3 – Finalités'),
      _p(
        'Les données personnelles sont collectées pour permettre le bon fonctionnement de la plateforme de mise en relation, assurer la sécurité des utilisateurs et améliorer le service.',
      ),
      _h2('Article 4 – Partage'),
      _p(
        'Les données ne sont en aucun cas vendues ou louées à des tiers. Elles peuvent être partagées avec des prestataires techniques nécessaires au fonctionnement du service.',
      ),
      _h2('Article 5 – Conservation'),
      _p(
        'Les données sont conservées pendant la durée strictement nécessaire aux finalités décrites, et en tout état de cause, conformément aux durées légales applicables.',
      ),
      _h2('Article 6 – Droits des utilisateurs'),
      _p(
        'Vous disposez d\'un droit d\'accès, de rectification, de suppression et de portabilité de vos données. Pour exercer ces droits, contactez-nous à admin@inngroupsarl.com.',
      ),
      _h2('Article 7 – Sécurité'),
      _p(
        'InnGroup SARL met en œuvre les mesures techniques et organisationnelles appropriées afin de garantir un niveau de sécurité adapté.',
      ),
      _h2('Article 8 – Contact'),
      _p(
        'Pour toute question relative à la présente politique, vous pouvez nous contacter à : admin@inngroupsarl.com',
      ),
    ];
  }

  static Widget _centered(String text) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
    );
  }

  static Widget _sub(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          text,
          style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
        ),
      ),
    );
  }

  static Widget _h2(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
      ),
    );
  }

  static Widget _p(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          height: 1.6,
          color: Color(0xFF333333),
        ),
      ),
    );
  }

  static Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: Color(0xFF757575)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
