import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../provider/user_provider.dart';
import '../../widget/inggo_modal.dart';
import '../shared/widgets/profile_scaffold.dart';

class EditPhoneScreen extends ConsumerStatefulWidget {
  const EditPhoneScreen({super.key});

  @override
  ConsumerState<EditPhoneScreen> createState() => _EditPhoneScreenState();
}

class _EditPhoneScreenState extends ConsumerState<EditPhoneScreen> {
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final userAsync = ref.read(userProvider);
    final currentPhone = userAsync.valueOrNull?.phone ?? '';
    // Retirer le +253 pour ne garder que la partie variable
    _phoneController = TextEditingController(
      text: currentPhone.replaceAll('+253', '').trim(),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProfileScaffold(
      title: 'Numéro de téléphone',
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Votre numéro de téléphone est utilisé pour vous connecter et pour que les chauffeurs puissent vous contacter. Un code de vérification vous sera envoyé.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF757575),
                height: 1.5,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'NUMÉRO DE MOBILE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF121212),
                letterSpacing: 0.5,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // Indicatif fixe +253
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Text('🇩🇯', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 8),
                      Text(
                        '+253',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF121212),
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Champ numéro
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style:
                          const TextStyle(fontSize: 16, fontFamily: 'Roboto'),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 15),
                        hintText: '77 XX XX XX',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Bouton Suivant
            GestureDetector(
              onTap: _onNext,
              child: Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFC107).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Suivant',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF121212),
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onNext() {
    final val = _phoneController.text.trim();
    if (val.isEmpty) return;

    final fullPhone = '+253 $val';
    _showVerificationModal(fullPhone);
  }

  void _showVerificationModal(String fullPhone) {
    final codeController = TextEditingController();

    showInggoModal(
      context: context,
      title: 'Vérification',
      content: Column(
        children: [
          Text(
            'Un code a été envoyé par SMS au $fullPhone',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF757575),
              height: 1.5,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 4,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 5,
                fontFamily: 'Roboto',
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 15),
                hintText: 'Ex: 1234',
                counterText: '',
              ),
            ),
          ),
        ],
      ),
      actions: [
        InggoModalButton(
          label: 'Annuler',
          isOutline: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
        InggoModalButton(
          label: 'Valider',
          backgroundColor: const Color(0xFFFFC107),
          textColor: Colors.black,
          onPressed: () {
            if (codeController.text == '1234') {
              ref.read(userProvider.notifier).updateProfile(phone: fullPhone);
              Navigator.of(context).pop(); // Fermer la modale
              Navigator.of(context).pop(); // Fermer la page edit-phone
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Téléphone vérifié et mis à jour'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Code incorrect. Code test: 1234'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Color(0xFFFF4D4D),
                ),
              );
            }
          },
        ),
      ],
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code envoyé'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
