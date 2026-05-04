import 'package:flutter/material.dart';
import '../shared/widgets/profile_scaffold.dart';

class CguScreen extends StatelessWidget {
  const CguScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileScaffold(
      title: 'CGU',
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête centré
            const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    Text(
                      'Conditions Générales d\'Utilisation (CGU) – Inggo',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF121212),
                        fontFamily: 'Roboto',
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Dernière mise à jour : Mercredi 7 janvier',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF757575),
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            _p('Les présentes Conditions Générales d\'Utilisation (ci-après les « CGU ») régissent l\'accès et l\'utilisation de l\'application mobile Inggo, plateforme technologique de mise en relation entre utilisateurs et conducteurs privés indépendants sur moto.'),
            _p('L\'application Inggo est la propriété exclusive et est exploitée par la société InnGroup SARL, société de droit djiboutien, dont le siège social est situé à Gabode 5, République de Djibouti (ci-après la « Société »).'),
            _p('Toute utilisation de l\'application implique l\'acceptation pleine, entière et sans réserve des présentes CGU.'),

            _h2('Article 1 – Définitions'),
            _bullet('Application : désigne l\'application mobile Inggo.'),
            _bullet('Société : désigne InnGroup SARL, société de droit djiboutien.'),
            _bullet('Utilisateur : toute personne physique utilisant l\'application afin de solliciter un trajet.'),
            _bullet('Conducteur Partenaire : toute personne indépendante utilisant l\'application pour proposer un service de transport.'),
            _bullet('Service : service de mise en relation technologique fourni par l\'application Inggo.'),

            _h2('Article 2 – Objet'),
            _p('Les présentes CGU ont pour objet de définir les conditions d\'accès et d\'utilisation de l\'application Inggo.'),
            _p('La Société n\'exerce aucune activité de transport et n\'est partie à aucun contrat de transport.'),

            _h2('Article 3 – Accès à l\'application'),
            _p('L\'accès à l\'application Inggo est réservé aux personnes majeures et juridiquement capables. La création d\'un compte est obligatoire.'),

            _h2('Article 4 – Fonctionnement du service'),
            _p('L\'application permet à un Utilisateur de solliciter un Conducteur Partenaire disponible à proximité. Le paiement constitue exclusivement un service technique de facilitation.'),

            _h2('Article 5 – Statut des Conducteurs Partenaires'),
            _p('Les Conducteurs Partenaires exercent leur activité de manière totalement indépendante. Aucune relation de subordination n\'existe.'),

            _h2('Article 6 – Responsabilité'),
            _p('La Société ne saurait être tenue responsable des accidents, dommages, blessures, retards ou litiges survenus lors d\'un trajet.'),

            _h2('Article 7 – Assurance'),
            _p('Chaque Conducteur Partenaire est tenu de disposer d\'une assurance professionnelle valide.'),

            _h2('Article 8 – Comportement des utilisateurs'),
            _p('Les Utilisateurs s\'engagent à adopter un comportement respectueux, légal et non dangereux.'),

            _h2('Article 9 – Paiement, commissions et flux financiers'),
            _h3('9.1 Paiement des courses'),
            _p('Le paiement peut être effectué via l\'application ou directement auprès du Conducteur Partenaire.'),
            _h3('9.2 Commission d\'Inggo'),
            _p('InnGroup SARL perçoit une commission sur chaque course réalisée via l\'application.'),
            _h3('9.3 Reversement au Conducteur Partenaire'),
            _p('Le montant reversé correspond au prix de la course, déduction faite de la commission.'),

            _h2('Article 10 – Données personnelles'),
            _p('La collecte et le traitement des données personnelles sont régis par la Politique de Confidentialité Inggo.'),

            _h2('Article 11 – Suppression du compte'),
            _p('Chaque Utilisateur peut demander la suppression de son compte via l\'application ou par email à admin@inngroupsarl.com.'),

            _h2('Article 12 – Propriété intellectuelle'),
            _p('L\'ensemble des éléments de l\'application est la propriété exclusive de InnGroup SARL.'),

            _h2('Article 13 – Limitation de responsabilité'),
            _p('La responsabilité de InnGroup SARL est strictement limitée aux dommages directs et prouvés.'),

            _h2('Article 14 – Force majeure'),
            _p('InnGroup SARL ne pourra être tenue responsable en cas de force majeure.'),

            _h2('Article 15 – Résolution amiable et médiation'),
            _p('En cas de litige, les parties s\'engagent à rechercher une solution amiable.'),

            _h2('Article 16 – Interdiction de contournement'),
            _p('Il est strictement interdit de contourner la plateforme Inggo pour réaliser des trajets en dehors de l\'application.'),

            _h2('Article 17 – Modification des CGU'),
            _p('La Société se réserve le droit de modifier les présentes CGU à tout moment.'),

            _h2('Article 18 – Droit applicable'),
            _p('Les présentes CGU sont régies par le droit en vigueur en République de Djibouti.'),
          ],
        ),
      ),
    );
  }

  static Widget _h2(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 25, bottom: 10),
      child: Container(
        padding: const EdgeInsets.only(bottom: 5),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF121212),
            fontFamily: 'Roboto',
          ),
        ),
      ),
    );
  }

  static Widget _h3(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 5),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF121212),
          fontFamily: 'Roboto',
        ),
      ),
    );
  }

  static Widget _p(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        textAlign: TextAlign.justify,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF757575),
          height: 1.6,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }

  static Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Color(0xFF757575))),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF757575),
                height: 1.6,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
