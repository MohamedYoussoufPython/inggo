import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/inggo_theme.dart';
import '../../provider/user_provider.dart';
import '../../widget/inggo_modal.dart';
import '../../widget/avatar_picker.dart';

class ProfilScreen extends ConsumerWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: InggoColors.background,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 15,
              left: InggoSpacing.lg,
              right: InggoSpacing.lg,
              bottom: InggoSpacing.md,
            ),
            color: InggoColors.background,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: InggoColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: InggoColors.border1,
                      ),
                      boxShadow: InggoShadows.level1,
                    ),
                    child: const Icon(Icons.arrow_back,
                        size: 20, color: InggoColors.text1),
                  ),
                ),
                const SizedBox(width: 15),
                Text(
                  'Mon Profil',
                  style: InggoTextStyles.h2,
                ),
              ],
            ),
          ),

          // Contenu scrollable
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // === PROFILE HERO (AsyncValue) ===
                  userAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child:
                          CircularProgressIndicator(color: InggoColors.primary),
                    ),
                    error: (err, stack) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Text('Erreur: $err',
                          style: const TextStyle(color: InggoColors.error)),
                    ),
                    data: (user) {
                      if (user == null) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Text('Non connecté'),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 30),
                        child: Column(
                          children: [
                            // Avatar
                            GestureDetector(
                              onTap: () => showAvatarOptions(context, ref),
                              child: Stack(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 4),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.05),
                                          blurRadius: 20,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: user.avatarUrl.isNotEmpty
                                          ? Image.network(
                                              user.avatarUrl,
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  _defaultAvatar(),
                                            )
                                          : _defaultAvatar(),
                                    ),
                                  ),
                                  // Badge caméra
                                  Positioned(
                                    bottom: 5,
                                    right: 5,
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: InggoColors.text1,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white, width: 3),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withValues(alpha: 0.2),
                                            blurRadius: 5,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(Icons.photo_camera,
                                          size: 16, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                            // Nom + icône edit
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  user.name.isEmpty ? 'Utilisateur' : user.name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF121212),
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => _showEditNameModal(
                                      context, ref, user.name),
                                  child: const Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: Color(0xFFFFC107),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            // Téléphone
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                user.phone.isEmpty
                                    ? 'Aucun numéro'
                                    : user.phone,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF757575),
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // === MENU GROUP ===
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          icon: Icons.place,
                          title: 'Adresses favorites',
                          subtitle: 'Gérer vos lieux enregistrés',
                          onTap: () => context.push('/profile/favorites'),
                        ),
                        _buildMenuItem(
                          icon: Icons.history,
                          title: 'Historique des courses',
                          subtitle: 'Vos trajets récents',
                          onTap: () => context.push('/profile/history'),
                        ),
                        _buildMenuItem(
                          icon: Icons.help_outline,
                          title: 'Aide & Support',
                          subtitle: 'FAQ et contact',
                          onTap: () => context.push('/profile/support'),
                        ),
                        _buildMenuItem(
                          icon: Icons.settings,
                          title: 'Paramètres',
                          subtitle: 'Compte et préférences',
                          onTap: () => context.push('/profile/settings'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // === BOUTON DECONNEXION ===
                  GestureDetector(
                    onTap: () => _showLogoutModal(context),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: InggoColors.errorLight,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout,
                              color: Color(0xFFFF4D4D), size: 22),
                          SizedBox(width: 10),
                          Text(
                            'Déconnexion',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFF4D4D),
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon,
                size: 24, color: InggoColors.text1.withValues(alpha: 0.8)),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF121212),
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF757575),
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFDDDDDD), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(Icons.person, size: 50, color: Colors.grey),
    );
  }

  void _showEditNameModal(
      BuildContext context, WidgetRef ref, String currentName) {
    final controller = TextEditingController(text: currentName);

    showInggoModal(
      context: context,
      title: 'Modifier le nom',
      content: Container(
        height: 50,
        decoration: BoxDecoration(
          color: InggoColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: controller,
          style: const TextStyle(fontSize: 16, fontFamily: 'Roboto'),
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 15),
            hintText: 'Votre nom complet',
          ),
        ),
      ),
      actions: [
        InggoModalButton(
          label: 'Annuler',
          isOutline: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
        InggoModalButton(
          label: 'Valider',
          backgroundColor: InggoColors.primary,
          textColor: Colors.black,
          onPressed: () {
            if (controller.text.trim().isNotEmpty) {
              ref
                  .read(userProvider.notifier)
                  .updateProfile(fullName: controller.text.trim());
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Nom mis à jour'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
        ),
      ],
    );
  }

  void _showLogoutModal(BuildContext context) {
    showInggoModal(
      context: context,
      title: 'Déconnexion',
      content: const Text(
        'Voulez-vous vraiment vous déconnecter ?',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF757575),
          height: 1.5,
          fontFamily: 'Roboto',
        ),
      ),
      actions: [
        InggoModalButton(
          label: 'Annuler',
          isOutline: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
        InggoModalButton(
          label: 'Déconnexion',
          backgroundColor: InggoColors.error,
          onPressed: () {
            Navigator.of(context).pop();
            context.go('/login');
          },
        ),
      ],
    );
  }
}
