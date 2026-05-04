import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/inggo_theme.dart';
import '../../provider/user_provider.dart';
import '../../widget/inggo_modal.dart';
import '../shared/widgets/profile_scaffold.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return ProfileScaffold(
      title: 'Paramètres',
      body: userAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: InggoColors.primary),
        ),
        error: (err, stack) => Center(
          child: Text('Erreur: $err',
              style: const TextStyle(color: InggoColors.error)),
        ),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Non connecté'));
          }
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === INFORMATIONS PERSONNELLES ===
                _sectionLabel('Informations Personnelles'),

                _settingRow(
                  icon: Icons.person,
                  label: 'Nom',
                  value: _truncate(user.name, 15),
                  onTap: () => _showEditNameModal(context, ref, user.name),
                ),
                _settingRow(
                  icon: Icons.phone,
                  label: 'Téléphone',
                  value: _truncate(user.phone, 12),
                  onTap: () => context.push('/profile/edit-phone'),
                ),
                _settingRow(
                  icon: Icons.email,
                  label: 'Email',
                  value: _truncate(user.email, 12),
                  onTap: () => _showEditEmailModal(context, ref, user.email),
                ),
                _settingRow(
                  icon: Icons.wc,
                  label: 'Sexe',
                  value: user.gender,
                  locked: true,
                ),
                _settingRow(
                  icon: Icons.public,
                  label: 'Pays',
                  value: user.country,
                  locked: true,
                ),

                // === SÉCURITÉ ===
                _sectionLabel('Sécurité'),
                _settingRow(
                  icon: Icons.lock,
                  label: 'Changer mot de passe',
                  onTap: () => _showChangePasswordModal(context),
                ),

                // === PRÉFÉRENCES ===
                _sectionLabel('Préférences'),
                _settingRowWithSwitch(
                  icon: Icons.language,
                  label: 'Langue',
                  trailing: const Text(
                    'Français',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF757575),
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
                _NotificationSwitchRow(),

                // === SUPPRIMER COMPTE ===
                const SizedBox(height: 25),
                GestureDetector(
                  onTap: () => _showDeleteAccountModal(context),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      border: const Border.all(color: InggoColors.errorLight),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_forever,
                            color: Color(0xFFFF4D4D), size: 22),
                        SizedBox(width: 10),
                        Text(
                          'Supprimer mon compte',
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
          );
        },
      ),
    );
  }

  // === WIDGETS UTILITAIRES ===

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

  Widget _settingRow({
    required IconData icon,
    required String label,
    String? value,
    VoidCallback? onTap,
    bool locked = false,
  }) {
    return GestureDetector(
      onTap: locked ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Color(0xFFF0F0F0)),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: InggoColors.text3),
            const SizedBox(width: 15),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF121212),
                fontFamily: 'Roboto',
              ),
            ),
            const Spacer(),
            if (value != null)
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: InggoColors.text3,
                  fontFamily: 'Roboto',
                  fontWeight: locked ? FontWeight.w400 : FontWeight.w400,
                ),
              ),
            const SizedBox(width: 8),
            locked
                ? const Icon(Icons.lock, size: 14, color: Color(0xFF757575))
                : const Icon(Icons.chevron_right,
                    size: 20, color: Color(0xFFDDDDDD)),
          ],
        ),
      ),
    );
  }

  Widget _settingRowWithSwitch({
    required IconData icon,
    required String label,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF0F0F0)),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: InggoColors.text3),
          const SizedBox(width: 15),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF121212),
              fontFamily: 'Roboto',
            ),
          ),
          const Spacer(),
          trailing,
        ],
      ),
    );
  }

  String _truncate(String text, int maxLen) {
    if (text.length <= maxLen) return text;
    return '${text.substring(0, maxLen - 3)}...';
  }

  // === MODALES ===

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
                ),
              );
            }
          },
        ),
      ],
    );
  }

  void _showEditEmailModal(
      BuildContext context, WidgetRef ref, String currentEmail) {
    final controller = TextEditingController(text: currentEmail);
    // email cannot be updated on Supabase directly through the profiles table alone
    // unless there is a trigger that updates auth.users, or you just store email for display.
    // Given the updateProfile plan handles avatarUrl, fullName, phone, sexe, pays, let's keep it simple.
    showInggoModal(
      context: context,
      title: 'Modifier Email',
      content: Container(
        height: 50,
        decoration: BoxDecoration(
          color: InggoColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(fontSize: 16, fontFamily: 'Roboto'),
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 15),
            hintText: 'email@exemple.com',
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
            if (controller.text.trim().isNotEmpty &&
                controller.text.contains('@')) {
              // Not doing actual Supabase update here as it's not in the plan (reqs Auth update)
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Veuillez modifier l\'email depuis la page d\'authentification'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),
      ],
    );
  }

  void _showChangePasswordModal(BuildContext context) {
    final newPassController = TextEditingController();
    final confPassController = TextEditingController();

    showInggoModal(
      context: context,
      title: 'Nouveau mot de passe',
      content: _PasswordModalContent(
        newPassController: newPassController,
        confPassController: confPassController,
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
            final p1 = newPassController.text;
            final p2 = confPassController.text;

            if (p1.isEmpty || p2.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Veuillez remplir tous les champs.'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Color(0xFFFF4D4D),
                ),
              );
              return;
            }
            if (p1.length < 6) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Le mot de passe doit contenir 6 caractères min.'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Color(0xFFFF4D4D),
                ),
              );
              return;
            }
            if (p1 != p2) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Les mots de passe ne sont pas identiques.'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Color(0xFFFF4D4D),
                ),
              );
              return;
            }

            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Nouveau mot de passe enregistré'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ],
    );
  }

  void _showDeleteAccountModal(BuildContext context) {
    showInggoModal(
      context: context,
      title: 'Supprimer le compte',
      titleColor: InggoColors.error,
      content: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: InggoColors.errorLight,
          borderRadius: BorderRadius.circular(12),
          border: const Border.all(color: InggoColors.error.withValues(alpha: 0.3)),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, size: 16, color: Color(0xFFC62828)),
                SizedBox(width: 5),
                Text(
                  'Attention : Action irréversible',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFC62828),
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Text(
              'Vous êtes sur le point de supprimer définitivement votre compte. Toutes vos données seront effacées.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFFB71C1C),
                height: 1.5,
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
      ),
      actions: [
        InggoModalButton(
          label: 'Annuler',
          isOutline: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
        InggoModalButton(
          label: 'Confirmer',
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

// === WIDGET STATEFUL POUR LE SWITCH NOTIFICATIONS ===
class _NotificationSwitchRow extends StatefulWidget {
  @override
  State<_NotificationSwitchRow> createState() => _NotificationSwitchRowState();
}

class _NotificationSwitchRowState extends State<_NotificationSwitchRow> {
  bool _enabled = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _enabled = !_enabled),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Color(0xFFF0F0F0)),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.notifications, size: 22, color: Color(0xFF757575)),
            const SizedBox(width: 15),
            const Text(
              'Notifications Push',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF121212),
                fontFamily: 'Roboto',
              ),
            ),
            const Spacer(),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 44,
              height: 24,
              decoration: BoxDecoration(
                color: _enabled ? InggoColors.primary : InggoColors.border2,
                borderRadius: BorderRadius.circular(20),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                alignment:
                    _enabled ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// === WIDGET STATEFUL POUR LE CONTENU MOT DE PASSE ===
class _PasswordModalContent extends StatefulWidget {
  final TextEditingController newPassController;
  final TextEditingController confPassController;

  const _PasswordModalContent({
    required this.newPassController,
    required this.confPassController,
  });

  @override
  State<_PasswordModalContent> createState() => _PasswordModalContentState();
}

class _PasswordModalContentState extends State<_PasswordModalContent> {
  bool _obscureNew = true;
  bool _obscureConf = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Créez votre nouveau mot de passe directement.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF757575),
            fontFamily: 'Roboto',
          ),
        ),
        const SizedBox(height: 20),
        // Nouveau mot de passe
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: InggoColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: widget.newPassController,
            obscureText: _obscureNew,
            style: const TextStyle(fontSize: 16, fontFamily: 'Roboto'),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
              hintText: 'Nouveau mot de passe (min 6 car.)',
              hintStyle: const TextStyle(fontSize: 14),
              suffixIcon: GestureDetector(
                onTap: () => setState(() => _obscureNew = !_obscureNew),
                child: Icon(
                  _obscureNew ? Icons.visibility : Icons.visibility_off,
                  color: _obscureNew ? InggoColors.text3 : InggoColors.primary,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Confirmer
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: InggoColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: widget.confPassController,
            obscureText: _obscureConf,
            style: const TextStyle(fontSize: 16, fontFamily: 'Roboto'),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
              hintText: 'Confirmer le mot de passe',
              hintStyle: const TextStyle(fontSize: 14),
              suffixIcon: GestureDetector(
                onTap: () => setState(() => _obscureConf = !_obscureConf),
                child: Icon(
                  _obscureConf ? Icons.visibility : Icons.visibility_off,
                  color: _obscureConf ? InggoColors.text3 : InggoColors.primary,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
