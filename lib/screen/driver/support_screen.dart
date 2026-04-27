import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'legal_screen.dart';

class DriverSupportScreen extends StatelessWidget {
  const DriverSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                child: Row(
                  children: [
                    _backBtn(context),
                    const SizedBox(width: 15),
                    const Text(
                      'Aide & Support',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),

              // Contact section
              _sectionTitle('Nous contacter'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF5F5F5)),
                  ),
                  child: Column(
                    children: [
                      _contactRow(
                        Icons.email,
                        'Envoyer un email',
                        'admin@inngroupsarl.com',
                        const Color(0xFFE3F2FD),
                        const Color(0xFF1976D2),
                      ),
                      _contactRow(
                        Icons.chat,
                        'WhatsApp Support',
                        '+253 77 35 54 52',
                        const Color(0xFFDCF8C6),
                        const Color(0xFF075E54),
                      ),
                      _contactRow(
                        Icons.place,
                        'Nos Bureaux',
                        'InnGroup SARL, Gabode 5',
                        const Color(0xFFE3F2FD),
                        const Color(0xFF1976D2),
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ),

              // FAQ section
              _sectionTitle('Questions Fréquentes'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF5F5F5)),
                  ),
                  child: const Column(
                    children: [
                      _FaqItem(
                        question: 'Comment changer de véhicule ?',
                        answer:
                            'Allez dans Mon Compte > Véhicule pour ajouter ou modifier votre moto. La validation prend 24h.',
                      ),
                      _FaqItem(
                        question: 'Problème avec un passager ?',
                        answer:
                            "Signalez tout incident immédiatement via le bouton d'urgence ou contactez le support.",
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ),

              // Legal links
              _sectionTitle('Informations Légales'),
              _legalLink(context, 'Conditions Générales (CGU)', LegalType.cgu),
              _legalLink(context, 'Privacy Policy', LegalType.privacy),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 20, 30, 10),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF757575),
          letterSpacing: 1,
        ),
      ),
    );
  }

  static Widget _contactRow(
    IconData icon,
    String title,
    String sub,
    Color bg,
    Color iconColor, {
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _legalLink(BuildContext context, String label, LegalType type) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: GestureDetector(
        onTap: () => context.push('/driver-legal', extra: type),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF5F5F5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFFCCCCCC),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _backBtn(BuildContext ctx) {
    return GestureDetector(
      onTap: () => Navigator.pop(ctx),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFDDDDDD)),
        ),
        child: const Icon(Icons.arrow_back, color: Color(0xFF121212), size: 20),
      ),
    );
  }
}

class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;
  final bool isLast;

  const _FaqItem({
    required this.question,
    required this.answer,
    this.isLast = false,
  });

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: widget.isLast
              ? null
              : const Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.question,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  color: const Color(0xFF999999),
                  size: 20,
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  widget.answer,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF757575),
                    height: 1.5,
                  ),
                ),
              ),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }
}
