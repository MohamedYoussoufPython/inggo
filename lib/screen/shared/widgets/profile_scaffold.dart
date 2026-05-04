import 'package:flutter/material.dart';

/// Layout commun pour les écrans profil : header sticky + bouton retour + titre.
class ProfileScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? floatingActionButton;

  const ProfileScaffold({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      floatingActionButton: floatingActionButton,
      body: Column(
        children: [
          // Header sticky
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 15,
              left: 20,
              right: 20,
              bottom: 15,
            ),
            color: const Color(0xFFF5F7FA),
            child: Row(
              children: [
                // Bouton retour circulaire
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: const Border.all(                        color: Colors.black.withValues(alpha: 0.05),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      size: 20,
                      color: Color(0xFF121212),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                // Titre
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF121212),
                    letterSpacing: -0.5,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ),
          // Corps scrollable
          Expanded(child: body),
        ],
      ),
    );
  }
}
