import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/supabase.dart';
import '../../widget/inggo_button.dart';

class DriverPendingScreen extends StatelessWidget {
  const DriverPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône animée
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (_, v, child) =>
                    Transform.scale(scale: v, child: child),
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    shape: BoxShape.circle,
                    border: const Border.all(                      color: const Color(0xFFFFC107),
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.hourglass_top_rounded,
                    size: 52,
                    color: Color(0xFFFFC107),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Titre
              const Text(
                'Dossier en cours\nde vérification',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                  color: Color(0xFF121212),
                ),
              ),

              const SizedBox(height: 14),

              // Sous-titre
              Text(
                'Notre équipe examine votre dossier.\nVous serez notifié sous 24h.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 40),

              // Étapes de vérification
              _buildStepItem(
                icon: Icons.check_circle_outline,
                label: 'Dossier reçu',
                isDone: true,
              ),
              const SizedBox(height: 12),
              _buildStepItem(
                icon: Icons.manage_search_outlined,
                label: 'Vérification en cours',
                isActive: true,
              ),
              const SizedBox(height: 12),
              _buildStepItem(
                icon: Icons.verified_outlined,
                label: 'Validation finale',
              ),

              const SizedBox(height: 48),

              // Contact support
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16),
                  border: const Border.all(color: Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF121212),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.headset_mic_outlined,
                        color: Color(0xFFFFC107),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Besoin d\'aide ?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF121212),
                            ),
                          ),
                          Text(
                            'admin@inngroupsarl.com',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF757575),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Bouton déconnexion
              SizedBox(
                width: double.infinity,
                child: InggoButton(
                  label: 'Se déconnecter',
                  icon: Icons.logout_rounded,
                  onPressed: () async {
                    await SupabaseConfig.client.auth.signOut();
                    if (context.mounted) context.go('/login');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepItem({
    required IconData icon,
    required String label,
    bool isDone = false,
    bool isActive = false,
  }) {
    Color iconColor;
    Color bgColor;
    Color textColor;

    if (isDone) {
      iconColor = const Color(0xFF43A047);
      bgColor = const Color(0xFFE8F5E9);
      textColor = const Color(0xFF43A047);
    } else if (isActive) {
      iconColor = const Color(0xFFFFC107);
      bgColor = const Color(0xFFFFF8E1);
      textColor = const Color(0xFF121212);
    } else {
      iconColor = const Color(0xFFBBBBBB);
      bgColor = const Color(0xFFF5F5F5);
      textColor = const Color(0xFFBBBBBB);
    }

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: textColor,
          ),
        ),
        if (isActive) ...[
          const SizedBox(width: 8),
          _PulsingDot(),
        ],
      ],
    );
  }
}

// Point animé "en cours"
class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Color(0xFFFFC107),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
