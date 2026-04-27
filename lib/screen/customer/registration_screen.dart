import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/supabase.dart';
import '../../widget/inggo_button.dart';
import '../../widget/inggo_input.dart';
import '../../widget/inggo_stepper.dart';

class CustomerRegistrationScreen extends StatefulWidget {
  const CustomerRegistrationScreen({super.key});

  @override
  State<CustomerRegistrationScreen> createState() =>
      _CustomerRegistrationScreenState();
}

class _CustomerRegistrationScreenState
    extends State<CustomerRegistrationScreen> {
  final _pageController = PageController();
  int _currentStep = 1;
  final int _totalSteps = 3;
  bool _isSubmitting = false;
  bool _showSuccess = false;
  bool _isPhoneVerified = false;
  bool _isLegalChecked = false;

  // Step 1 controllers
  final _nomCtrl = TextEditingController();
  final _pereCtrl = TextEditingController();
  final _grandpereCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  // Step 2 controllers
  final _phoneCtrl = TextEditingController();
  final _adresseCtrl = TextEditingController();
  String _sexe = '';
  String _pays = 'Djibouti';

  // Step 3 controllers
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  // SMS verification
  final _smsCodeCtrl = TextEditingController();

  // Error messages
  final Map<String, String> _errors = {};

  @override
  void dispose() {
    _pageController.dispose();
    _nomCtrl.dispose();
    _pereCtrl.dispose();
    _grandpereCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _adresseCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _smsCodeCtrl.dispose();
    super.dispose();
  }

  void _clearErrors() => setState(() => _errors.clear());

  void _setError(String field, String message) {
    setState(() => _errors[field] = message);
  }

  bool _validateStep() {
    _clearErrors();
    bool valid = true;
    final nameRegex = RegExp(r"^[a-zA-ZÀ-ÿ\s'-]+$");
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (_currentStep == 1) {
      final nom = _nomCtrl.text.trim();
      final pere = _pereCtrl.text.trim();
      final grandpere = _grandpereCtrl.text.trim();
      final email = _emailCtrl.text.trim();

      if (nom.isEmpty) {
        _setError('nom', 'Le nom est requis');
        valid = false;
      } else if (!nameRegex.hasMatch(nom)) {
        _setError('nom', 'Format invalide');
        valid = false;
      }
      if (pere.isEmpty) {
        _setError('pere', 'Requis');
        valid = false;
      }
      if (grandpere.isEmpty) {
        _setError('grandpere', 'Requis');
        valid = false;
      }
      if (email.isEmpty) {
        _setError('email', 'Email requis');
        valid = false;
      } else if (!emailRegex.hasMatch(email)) {
        _setError('email', 'Email invalide');
        valid = false;
      }
    } else if (_currentStep == 2) {
      final phone = _phoneCtrl.text.trim();
      final adresse = _adresseCtrl.text.trim();

      if (phone.isEmpty || phone.length < 6) {
        _setError('phone', 'Numéro invalide');
        valid = false;
      }
      if (adresse.isEmpty) {
        _setError('adresse', 'Requis');
        valid = false;
      }
      if (_sexe.isEmpty) {
        _setError('sexe', 'Requis');
        valid = false;
      }
    } else if (_currentStep == 3) {
      final p1 = _passwordCtrl.text;
      final p2 = _confirmPasswordCtrl.text;

      if (p1.isEmpty || p1.length < 6) {
        _setError('password', 'Min 6 caractères');
        valid = false;
      }
      if (p1 != p2) {
        _setError('confirm', 'Les mots de passe sont différents');
        valid = false;
      }
      if (!_isLegalChecked) {
        _setError('legal', 'Acceptez les conditions');
        valid = false;
      }
    }

    if (!valid) {
      HapticFeedback.mediumImpact();
      _showToast('Veuillez corriger les erreurs.');
    }
    return valid;
  }

  void _nextStep() {
    if (!_validateStep()) return;

    if (_currentStep == 2 && !_isPhoneVerified) {
      _showSmsVerificationDialog();
      return;
    }

    if (_currentStep < _totalSteps) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep - 1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _submitFormWithSupabase();
    }
  }

  void _prevStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep - 1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _submitFormWithSupabase() async {
    setState(() => _isSubmitting = true);

    try {
      final fullName =
          '${_nomCtrl.text.trim()} ${_pereCtrl.text.trim()} ${_grandpereCtrl.text.trim()}';

      final response = await SupabaseConfig.client.auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        data: {
          'name': _nomCtrl.text.trim(),
          'father_name': _pereCtrl.text.trim(),
          'grand_father_name': _grandpereCtrl.text.trim(),
          'full_name': fullName,
          'phone': '+253 ${_phoneCtrl.text.trim()}',
          'role': 'client',
          'sexe': _sexe,
          'pays': _pays,
          'adresse': _adresseCtrl.text.trim(),
        },
      );

      if (!mounted) return;

      if (response.session != null || response.user != null) {
        setState(() {
          _isSubmitting = false;
          _showSuccess = true;
        });
        if (response.session == null) {
          _showToast('Compte créé ! Vérifiez votre email.');
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showToast('Erreur: ${e.toString()}');
    }
  }

  void _showSmsVerificationDialog() {
    _smsCodeCtrl.clear();
    _showToast('Code SMS envoyé !');
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (ctx) => _SmsVerificationDialog(
        phone: '+253 ${_phoneCtrl.text}',
        controller: _smsCodeCtrl,
        onVerify: () {
          if (_smsCodeCtrl.text.trim().length == 4) {
            Navigator.pop(ctx);
            setState(() => _isPhoneVerified = true);
            _showToast('Numéro vérifié ✓');
            setState(() => _currentStep++);
            _pageController.animateToPage(
              _currentStep - 1,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
            );
          } else {
            HapticFeedback.heavyImpact();
          }
        },
        onCancel: () => Navigator.pop(ctx),
      ),
    );
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: Colors.black,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.only(bottom: 20, left: 40, right: 40),
      ),
    );
  }

  void _showLegalModal(String title, String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (ctx, scrollCtrl) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.close, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollCtrl,
                padding: const EdgeInsets.all(20),
                child: Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF444444),
                    height: 1.6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showSuccess) return _buildSuccessScreen();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            InggoStepper(
              currentStep: _currentStep,
              totalSteps: _totalSteps,
              variant: StepperVariant.circles,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [_buildStep1(), _buildStep2(), _buildStep3()],
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (_currentStep > 1) {
                    _prevStep();
                  } else {
                    // Vérifier s'il y a une page précédente
                    if (context.canPop()) {
                      context.pop(); // Retour à la page précédente
                    } else {
                      context.go('/login'); // Redirection vers login
                    }
                  }
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    size: 20,
                    color: Color(0xFF121212),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Créer un compte',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Color(0xFF121212),
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Rejoignez la communauté Inggo en 3 étapes.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF757575),
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.person, 'Qui êtes-vous ?'),
          const SizedBox(height: 24),
          InggoInput(
            label: 'Votre Nom',
            placeholder: 'Votre nom',
            controller: _nomCtrl,
            prefixIcon: Icons.person_outline,
            errorText: _errors['nom'],
            onChanged: (_) => _clearErrors(),
          ),
          const SizedBox(height: 16),
          InggoInput(
            label: 'Nom du père',
            placeholder: 'Nom du père',
            controller: _pereCtrl,
            errorText: _errors['pere'],
            onChanged: (_) => _clearErrors(),
          ),
          const SizedBox(height: 16),
          InggoInput(
            label: 'Nom du grand-père',
            placeholder: 'Nom du grand-père',
            controller: _grandpereCtrl,
            errorText: _errors['grandpere'],
            onChanged: (_) => _clearErrors(),
          ),
          const SizedBox(height: 16),
          InggoInput(
            label: 'Email',
            placeholder: 'votre-nom@gmail.com',
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            errorText: _errors['email'],
            onChanged: (_) => _clearErrors(),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.contact_mail, 'Vos Coordonnées'),
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'Numéro de téléphone',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        '🇩🇯 +253',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InggoInput(
                      placeholder: '77 XX XX XX',
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      maxLength: 8,
                      errorText: _errors['phone'],
                      onChanged: (_) => _clearErrors(),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4, top: 8),
                child: Row(
                  children: [
                    const Icon(Icons.sms, size: 14, color: Color(0xFFFFC107)),
                    const SizedBox(width: 6),
                    Text(
                      'Un code sera envoyé pour vérification.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          InggoInput(
            label: 'Adresse de votre maison',
            placeholder: 'Quartier, Rue...',
            controller: _adresseCtrl,
            prefixIcon: Icons.home_outlined,
            errorText: _errors['adresse'],
            onChanged: (_) => _clearErrors(),
          ),
          const SizedBox(height: 20),
          // Gender selector
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Sexe',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _GenderCard(
                  label: 'Homme',
                  icon: Icons.male,
                  isSelected: _sexe == 'H',
                  onTap: () => setState(() {
                    _sexe = 'H';
                    _clearErrors();
                  }),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _GenderCard(
                  label: 'Femme',
                  icon: Icons.female,
                  isSelected: _sexe == 'F',
                  onTap: () => setState(() {
                    _sexe = 'F';
                    _clearErrors();
                  }),
                ),
              ),
            ],
          ),
          if (_errors.containsKey('sexe'))
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 6),
              child: Text(
                _errors['sexe']!,
                style: const TextStyle(
                  color: Color(0xFFD32F2F),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Pays',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _pays,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF121212),
                  fontFamily: 'Roboto',
                ),
                items: ['Djibouti', 'Autre']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _pays = v ?? 'Djibouti'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.lock, 'Sécurité'),
          const SizedBox(height: 24),
          InggoInput(
            label: 'Mot de passe',
            placeholder: 'Au moins 6 caractères',
            controller: _passwordCtrl,
            obscureText: true,
            showToggleVisibility: true,
            prefixIcon: Icons.lock_outline,
            errorText: _errors['password'],
            onChanged: (_) => _clearErrors(),
          ),
          const SizedBox(height: 16),
          InggoInput(
            label: 'Confirmer le mot de passe',
            placeholder: 'Répétez le mot de passe',
            controller: _confirmPasswordCtrl,
            obscureText: true,
            showToggleVisibility: true,
            prefixIcon: Icons.lock_outline,
            errorText: _errors['confirm'],
            onChanged: (_) => _clearErrors(),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              setState(() => _isLegalChecked = !_isLegalChecked);
              _clearErrors();
              HapticFeedback.selectionClick();
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isLegalChecked
                    ? const Color(0xFFFFF8E1)
                    : const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isLegalChecked
                      ? const Color(0xFF121212)
                      : _errors.containsKey('legal')
                          ? const Color(0xFFD32F2F)
                          : Colors.transparent,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _isLegalChecked
                          ? const Color(0xFF121212)
                          : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isLegalChecked
                            ? const Color(0xFF121212)
                            : const Color(0xFFCCCCCC),
                        width: 2,
                      ),
                    ),
                    child: _isLegalChecked
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: "Je reconnais avoir lu et accepté les ",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF121212),
                          height: 1.5,
                        ),
                        children: [
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () => _showLegalModal(
                                'Conditions Générales',
                                _cguText,
                              ),
                              child: const Text(
                                'CGU',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF336D91),
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          const TextSpan(text: ' et la '),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () => _showLegalModal(
                                'Politique de Confidentialité',
                                _privacyText,
                              ),
                              child: const Text(
                                'Politique de Confidentialité',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF336D91),
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          const TextSpan(text: " d'Inggo."),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_errors.containsKey('legal'))
            Padding(
              padding: const EdgeInsets.only(left: 40, top: 6),
              child: Text(
                _errors['legal']!,
                style: const TextStyle(
                  color: Color(0xFFD32F2F),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 1) ...[
            GestureDetector(
              onTap: _prevStep,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.arrow_back, color: Color(0xFF121212)),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: InggoButton(
              label:
                  _currentStep == _totalSteps ? 'Créer mon compte' : 'Suivant',
              trailingIcon: _currentStep == _totalSteps
                  ? Icons.check
                  : Icons.arrow_forward,
              isLoading: _isSubmitting,
              onPressed: _isSubmitting ? null : _nextStep,
              height: 50,
              borderRadius: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 500),
                curve: Curves.elasticOut,
                builder: (_, value, child) =>
                    Transform.scale(scale: value, child: child),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 48,
                    color: Color(0xFF43A047),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Bienvenue !',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF121212),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Votre compte Inggo a été créé avec succès.',
                style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 60),
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  context.go('/login');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF121212),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Commencer',
                        style: TextStyle(
                          color: Color(0xFFFFC107),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFC107),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Color(0xFF121212),
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFFC107), size: 28),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFF121212),
          ),
        ),
      ],
    );
  }
}

// --- Gender Selection Card ---

class _GenderCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF8E1) : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFC107) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? const Color(0xFF121212)
                  : const Color(0xFF757575),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? const Color(0xFF121212)
                    : const Color(0xFF757575),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- SMS Verification Dialog ---

class _SmsVerificationDialog extends StatelessWidget {
  final String phone;
  final TextEditingController controller;
  final VoidCallback onVerify;
  final VoidCallback onCancel;

  const _SmsVerificationDialog({
    required this.phone,
    required this.controller,
    required this.onVerify,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF8E1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.sms, color: Color(0xFFFFC107), size: 28),
            ),
            const SizedBox(height: 16),
            const Text(
              'Vérification Mobile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                text: 'Un code à 4 chiffres a été envoyé au\n',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                children: [
                  TextSpan(
                    text: phone,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF121212),
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                letterSpacing: 8,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: '0 0 0 0',
                hintStyle: TextStyle(color: Colors.grey.shade300),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFFFFC107),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            InggoButton(label: 'Valider', onPressed: onVerify, height: 48),
            const SizedBox(height: 8),
            InggoButton(
              label: 'Annuler',
              variant: InggoButtonVariant.ghost,
              onPressed: onCancel,
              height: 44,
            ),
          ],
        ),
      ),
    );
  }
}

// --- Legal Texts ---

const String _cguText = '''
Conditions Générales d'Utilisation (CGU) – Inggo
Dernière mise à jour : Mercredi 7 janvier

Les présentes Conditions Générales d'Utilisation (ci-après les « CGU ») régissent l'accès et l'utilisation de l'application mobile Inggo, plateforme technologique de mise en relation entre utilisateurs et conducteurs privés indépendants sur moto.

L'application Inggo est la propriété exclusive et est exploitée par la société InnGroup SARL, société de droit djiboutien, dont le siège social est situé à Gabode 5, République de Djibouti.

Article 1 – Définitions
• Application : désigne l'application mobile Inggo.
• Société : désigne InnGroup SARL.
• Utilisateur : toute personne physique utilisant l'application afin de solliciter un trajet.
• Conducteur Partenaire : toute personne indépendante utilisant l'application pour proposer un service de transport sur moto.
• Service : service de mise en relation technologique fourni par l'application Inggo.

Article 2 – Objet
Les présentes CGU ont pour objet de définir les conditions d'accès et d'utilisation de l'application Inggo. Inggo est une plateforme technologique de mise en relation.

Article 3 – Accès à l'application
L'accès à l'application Inggo est réservé aux personnes majeures et juridiquement capables. La création d'un compte est obligatoire pour accéder aux services.

Article 4 – Fonctionnement du service
L'application permet à un Utilisateur de solliciter un Conducteur Partenaire disponible à proximité.

Article 5 – Statut des Conducteurs Partenaires
Les Conducteurs Partenaires exercent leur activité de manière totalement indépendante. Ils ne sont ni salariés, ni agents, ni représentants de InnGroup SARL.

Article 6 – Responsabilité
La Société ne saurait être tenue responsable des accidents, dommages, blessures, retards, litiges ou incidents survenus lors d'un trajet.

Article 7 – Données personnelles
La collecte et le traitement des données personnelles sont régis par la Politique de Confidentialité Inggo.

Article 8 – Droit applicable
Les présentes CGU sont régies par le droit en vigueur en République de Djibouti.
''';

const String _privacyText = '''
Inggo – Politique de Confidentialité
Propriétaire : InnGroup SARL
Pays : République de Djibouti
Dernière mise à jour : Mercredi 7 janvier

Cette Politique de Confidentialité décrit comment InnGroup SARL collecte, utilise, traite, stocke, protège et divulgue les données personnelles des Utilisateurs et des Conducteurs Partenaires qui utilisent l'application mobile Inggo.

1. Données collectées
• Nom complet, numéro de téléphone, adresse email
• Photo de profil (optionnelle)
• Données de géolocalisation GPS (pendant les courses actives)
• Adresse IP et identifiants d'appareil
• Données d'utilisation de l'application

2. Finalité du traitement
• Mise en relation des Utilisateurs avec les Conducteurs Partenaires
• Calcul des tarifs
• Gestion des paiements et commissions
• Envoi de communications liées au service
• Amélioration de la performance de l'application

3. Partage des données
InnGroup SARL ne vend pas les données personnelles à des tiers. Les données peuvent être partagées avec des prestataires techniques de confiance.

4. Sécurité
Chiffrement des données en transit et au repos. Communications HTTPS sécurisées. Restrictions d'accès limitées au personnel autorisé.

5. Droits des utilisateurs
Accès, correction, suppression, opposition, portabilité des données.

Contact : admin@inngroupsarl.com
''';
