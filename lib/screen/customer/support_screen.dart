import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../shared/widgets/profile_scaffold.dart';
import '../shared/widgets/faq_accordion.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileScaffold(
      title: 'Aide & Support',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('Nous contacter'),

            // Téléphone
            _supportCard(
              icon: Icons.headset_mic,
              bgColor: const Color(0xFFFFF9E6),
              iconColor: const Color(0xFFFFC107),
              label: 'Service Client',
              value: '+253 77 00 00 00',
              onTap: () {},
            ),
            // WhatsApp
            _supportCard(
              icon: Icons.chat,
              bgColor: const Color(0xFFDCF8C6),
              iconColor: const Color(0xFF075E54),
              label: 'WhatsApp Support',
              value: '+253 77 35 54 52',
              onTap: () {},
            ),
            // Email
            _supportCard(
              icon: Icons.email,
              bgColor: const Color(0xFFE3F2FD),
              iconColor: const Color(0xFF1976D2),
              label: 'Email',
              value: 'admin@inngroupsarl.com',
              onTap: () {},
            ),
            // Bureaux
            _supportCard(
              icon: Icons.place,
              bgColor: const Color(0xFFF3E5F5),
              iconColor: const Color(0xFF7B1FA2),
              label: 'Nos Bureaux',
              value: 'InnGroup SARL, Gabode 5',
            ),

            _sectionLabel('Questions Fréquentes'),

            // FAQ Container
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const FaqAccordion(
                    question: "J'ai oublié un objet",
                    answer:
                        'Contactez immédiatement notre service client ou envoyez un message WhatsApp avec les détails de votre course (date, heure).',
                  ),
                  Divider(height: 1, color: Colors.grey.shade100),
                  const FaqAccordion(
                    question: 'Mode de paiement',
                    answer:
                        'Nous acceptons le cash mais aussi mobile money D-Money Waafi Cac Pay et Saba Pay.',
                  ),
                  Divider(height: 1, color: Colors.grey.shade100),
                  const FaqAccordion(
                    question: 'Sécurité à bord',
                    answer:
                        'Tous nos chauffeurs sont vérifiés. Le port du casque est obligatoire pour votre sécurité.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            _sectionLabel('Informations Légales'),

            // CGU
            _legalCard(
              label: 'Conditions Générales (CGU)',
              onTap: () => context.push('/profile/cgu'),
            ),
            // Privacy
            _legalCard(
              label: 'Politique de Confidentialité',
              onTap: () => context.push('/profile/privacy'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 25, 25, 10),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFF757575),
          letterSpacing: 1,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }

  Widget _supportCard({
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icône box
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 24, color: iconColor),
            ),
            const SizedBox(width: 20),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF757575),
                      letterSpacing: 0.5,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF121212),
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legalCard({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF121212),
                  fontFamily: 'Roboto',
                ),
              ),
            ),
            const Icon(Icons.chevron_right,
                color: Color(0xFFCCCCCC), size: 20),
          ],
        ),
      ),
    );
  }
}
