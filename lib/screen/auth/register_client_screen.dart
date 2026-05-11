import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/constants.dart';
import '../../core/services/supabase_service.dart';
import '../../widget/widgets.dart';
import '../../widget/inggo_stepper.dart';

class RegisterClientScreen extends StatefulWidget {
  const RegisterClientScreen({super.key});

  @override
  State<RegisterClientScreen> createState() => _RegisterClientScreenState();
}

class _RegisterClientScreenState extends State<RegisterClientScreen> {
  final _pageController = PageController();
  int _currentStep = 1;
  final int _totalSteps = 3;
  bool _isSubmitting = false;
  bool _showSuccess = false;
  bool _isLegalChecked = false;

  // Step 1 — Identité
  final _nomCtrl = TextEditingController();
  final _pereCtrl = TextEditingController();
  final _grandpereCtrl = TextEditingController();
  String _sexe = '';
  String _pays = 'Djibouti';

  // Step 2 — Coordonnées
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  // OTP state
  bool _otpSent = false;
  bool _otpSending = false;
  bool _phoneVerified = false;
  bool _otpVerifying = false;
  String _otpCode = '';
  int _resendTimer = 0;
  Timer? _timer;
  Timer? _debounceTimer;
  String _lastSentPhone = '';

  // Step 3 — Sécurité
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  // Errors
  final Map<String, String> _errors = {};

  @override
  void dispose() {
    _pageController.dispose();
    _nomCtrl.dispose();
    _pereCtrl.dispose();
    _grandpereCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _timer?.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _clearErrors() => setState(() => _errors.clear());

  void _setError(String field, String message) {
    setState(() => _errors[field] = message);
  }

  String get _fullPhone => '+253${_phoneCtrl.text.trim().replaceAll(' ', '')}';

  // ─── OTP Logic ───

  bool _isPhoneValid() {
    final phone = _phoneCtrl.text.trim().replaceAll(' ', '');
    return phone.length >= 6;
  }

  void _onPhoneChanged(String value) {
    _clearErrors();
    // Reset OTP state if phone changes after verification
    if (_phoneVerified) {
      setState(() {
        _phoneVerified = false;
        _otpSent = false;
        _otpCode = '';
        _lastSentPhone = '';
      });
      return;
    }
    // Reset OTP state if phone changes while OTP was sent
    if (_otpSent) {
      final newPhone = _fullPhone;
      if (newPhone != _lastSentPhone) {
        setState(() {
          _otpSent = false;
          _otpCode = '';
          _lastSentPhone = '';
        });
      }
    }
    // Auto-send OTP when phone becomes valid (first time)
    _debounceTimer?.cancel();
    if (_isPhoneValid() && !_otpSent && !_otpSending) {
      _debounceTimer = Timer(const Duration(milliseconds: 800), () {
        if (mounted && _isPhoneValid() && !_otpSent && !_otpSending) {
          _sendOtp();
        }
      });
    }
  }

  Future<void> _sendOtp() async {
    final phone = _phoneCtrl.text.trim().replaceAll(' ', '');
    if (phone.isEmpty || phone.length < 6) {
      _setError('phone', 'Numéro invalide');
      return;
    }

    setState(() {
      _otpSending = true;
      _errors.remove('otp');
    });

    try {
      await SupabaseService.instance.signInWithOtp(_fullPhone);

      if (!mounted) return;
      setState(() {
        _otpSent = true;
        _otpSending = false;
        _phoneVerified = false;
        _otpCode = '';
        _lastSentPhone = _fullPhone;
        _resendTimer = 60;
      });
      _startTimer();
      HapticFeedback.mediumImpact();
      _showToast('Code envoyé au $_fullPhone');
    } catch (e) {
      if (!mounted) return;
      setState(() => _otpSending = false);
      _setError('otp', 'Erreur d\'envoi. Réessayez.');
      _showToast('Erreur: ${e.toString()}');
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _resendTimer--;
        if (_resendTimer <= 0) {
          timer.cancel();
        }
      });
    });
  }

  Future<void> _verifyOtp(String code) async {
    if (code.length < 6) return;

    setState(() {
      _otpVerifying = true;
      _errors.remove('otp');
    });

    try {
      await SupabaseService.instance.verifyOtp(_fullPhone, code);

      if (!mounted) return;

      // Sign out the temporary session created by OTP verification
      await Supabase.instance.client.auth.signOut();

      if (!mounted) return;
      setState(() {
        _phoneVerified = true;
        _otpVerifying = false;
      });
      HapticFeedback.heavyImpact();
      _showToast('Numéro vérifié !');
    } catch (e) {
      if (!mounted) return;
      setState(() => _otpVerifying = false);
      _setError('otp', 'Code invalide');
      _showToast('Code incorrect. Réessayez.');
    }
  }

  // ─── Validation ───

  bool _validateStep() {
    _clearErrors();
    bool valid = true;
    final nameRegex = RegExp(r"^[a-zA-ZÀ-ÿ\s'-]+$");
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (_currentStep == 1) {
      if (_nomCtrl.text.trim().isEmpty) {
        _setError('nom', 'Le nom est requis');
        valid = false;
      } else if (!nameRegex.hasMatch(_nomCtrl.text.trim())) {
        _setError('nom', 'Format invalide');
        valid = false;
      }
      if (_pereCtrl.text.trim().isEmpty) {
        _setError('pere', 'Requis');
        valid = false;
      }
      if (_grandpereCtrl.text.trim().isEmpty) {
        _setError('grandpere', 'Requis');
        valid = false;
      }
      if (_sexe.isEmpty) {
        _setError('sexe', 'Requis');
        valid = false;
      }
    } else if (_currentStep == 2) {
      if (_emailCtrl.text.trim().isEmpty) {
        _setError('email', 'Email requis');
        valid = false;
      } else if (!emailRegex.hasMatch(_emailCtrl.text.trim())) {
        _setError('email', 'Email invalide');
        valid = false;
      }
      if (_phoneCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().replaceAll(' ', '').length < 6) {
        _setError('phone', 'Numéro invalide');
        valid = false;
      }
      if (!_phoneVerified) {
        _setError('phone_verify', 'Vérifiez votre numéro');
        valid = false;
      }
    } else if (_currentStep == 3) {
      if (_passwordCtrl.text.length < 6) {
        _setError('password', 'Min 6 caractères');
        valid = false;
      }
      if (_passwordCtrl.text != _confirmPasswordCtrl.text) {
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

    if (_currentStep < _totalSteps) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep - 1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _submitForm();
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

  Future<void> _submitForm() async {
    setState(() => _isSubmitting = true);

    try {
      final fullName =
          '${_nomCtrl.text.trim()} ${_pereCtrl.text.trim()} ${_grandpereCtrl.text.trim()}';
      final phone = _fullPhone;

      final response = await Supabase.instance.client.auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        data: {
          'full_name': fullName,
          'phone': phone,
          'role': 'client',
          'sexe': _sexe,
          'pays': _pays,
        },
      );

      if (!mounted) return;

      // Insert profile (Supabase trigger should handle this,
      // but we keep it as fallback if trigger is not set up)
      final userId = response.user?.id;
      if (userId != null) {
        try {
          await Supabase.instance.client.from('profiles').insert({
            'id': userId,
            'full_name': fullName,
            'phone': phone,
            'email': _emailCtrl.text.trim(),
            'role': 'client',
            'sexe': _sexe,
            'pays': _pays,
            'phone_verified': true,
          });
        } catch (_) {
          // Profile may already exist via DB trigger
        }
      }

      setState(() {
        _isSubmitting = false;
        _showSuccess = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showToast('Erreur: ${e.toString()}');
    }
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: AppColors.secondary,
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
                  Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
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
                  style: const TextStyle(fontSize: 14, color: Color(0xFF444444), height: 1.6),
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
            InggoStepper(currentStep: _currentStep, totalSteps: _totalSteps),
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
                    context.go('/login');
                  }
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF121212)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Créer un compte',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF121212)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Rejoignez la communauté Inggo en 3 étapes.',
            style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
          ),
        ],
      ),
    );
  }

  // ─── STEP 1: Identité ───
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
            hint: 'Votre nom',
            controller: _nomCtrl,
            prefixIcon: Icons.person_outline,
            onChanged: (_) => _clearErrors(),
          ),
          if (_errors.containsKey('nom'))
            _errorText(_errors['nom']!),
          const SizedBox(height: 16),
          InggoInput(
            label: 'Nom du père',
            hint: 'Nom du père',
            controller: _pereCtrl,
            onChanged: (_) => _clearErrors(),
          ),
          if (_errors.containsKey('pere'))
            _errorText(_errors['pere']!),
          const SizedBox(height: 16),
          InggoInput(
            label: 'Nom du grand-père',
            hint: 'Nom du grand-père',
            controller: _grandpereCtrl,
            onChanged: (_) => _clearErrors(),
          ),
          if (_errors.containsKey('grandpere'))
            _errorText(_errors['grandpere']!),
          const SizedBox(height: 20),
          // Gender
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text('Sexe', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
          ),
          Row(
            children: [
              Expanded(
                child: _GenderCard(
                  label: 'Homme',
                  icon: Icons.male,
                  isSelected: _sexe == 'H',
                  onTap: () => setState(() { _sexe = 'H'; _clearErrors(); }),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _GenderCard(
                  label: 'Femme',
                  icon: Icons.female,
                  isSelected: _sexe == 'F',
                  onTap: () => setState(() { _sexe = 'F'; _clearErrors(); }),
                ),
              ),
            ],
          ),
          if (_errors.containsKey('sexe'))
            _errorText(_errors['sexe']!),
          const SizedBox(height: 20),
          // Pays
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text('Pays', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
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
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF121212)),
                items: ['Djibouti', 'Autre'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _pays = v ?? 'Djibouti'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── STEP 2: Coordonnées + OTP ───
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.contact_mail, 'Vos Coordonnées'),
          const SizedBox(height: 24),
          InggoInput(
            label: 'Email',
            hint: 'votre-nom@gmail.com',
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            onChanged: (_) => _clearErrors(),
          ),
          if (_errors.containsKey('email'))
            _errorText(_errors['email']!),
          const SizedBox(height: 20),
          // Phone with +253 prefix
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text('Numéro de téléphone', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
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
                      child: Text('🇩🇯 +253', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InggoInput(
                      hint: '77 XX XX XX',
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      onChanged: _onPhoneChanged,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (_errors.containsKey('phone'))
            _errorText(_errors['phone']!),
          const SizedBox(height: 16),

          // ─── Sending indicator / Resend button ───
          if (_otpSending) ...[
            SizedBox(
              width: double.infinity,
              height: 48,
              child: InggoButton(
                label: 'Envoi en cours...',
                icon: Icons.sms_outlined,
                isLoading: true,
                onPressed: null,
              ),
            ),
          ] else if (_otpSent && !_phoneVerified) ...[
            SizedBox(
              width: double.infinity,
              height: 48,
              child: InggoButton(
                label: _resendTimer > 0
                    ? 'Renvoyer le code (${_resendTimer}s)'
                    : 'Renvoyer le code',
                icon: Icons.refresh,
                onPressed: _resendTimer > 0 ? null : _sendOtp,
              ),
            ),
          ] else if (!_phoneVerified && !_otpSent) ...[
            // Hint while typing
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 4),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Un code sera envoyé automatiquement.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Phone verified badge
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified, color: AppColors.success, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Numéro vérifié : $_fullPhone',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ─── OTP Input (visible after sending) ───
          if (_otpSent && !_phoneVerified) ...[
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 10),
              child: Text(
                'Entrez le code de vérification',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF444444)),
              ),
            ),
            Center(
              child: InggoOtpInput(
                onCompleted: (code) {
                  _otpCode = code;
                  _verifyOtp(code);
                },
                onChanged: (code) {
                  _otpCode = code;
                  _clearErrors();
                },
              ),
            ),
            if (_otpVerifying) ...[
              const SizedBox(height: 12),
              const Center(child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primary,
                ),
              )),
            ],
            if (_errors.containsKey('otp'))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _errorText(_errors['otp']!),
              ),
          ],

          if (_errors.containsKey('phone_verify'))
            _errorText(_errors['phone_verify']!),
        ],
      ),
    );
  }

  // ─── STEP 3: Sécurité ───
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
            hint: 'Au moins 6 caractères',
            controller: _passwordCtrl,
            obscureText: true,
            prefixIcon: Icons.lock_outline,
            suffixIcon: Icons.visibility_outlined,
            onChanged: (_) => _clearErrors(),
          ),
          if (_errors.containsKey('password'))
            _errorText(_errors['password']!),
          const SizedBox(height: 16),
          InggoInput(
            label: 'Confirmer le mot de passe',
            hint: 'Répétez le mot de passe',
            controller: _confirmPasswordCtrl,
            obscureText: true,
            prefixIcon: Icons.lock_outline,
            suffixIcon: Icons.visibility_outlined,
            onChanged: (_) => _clearErrors(),
          ),
          if (_errors.containsKey('confirm'))
            _errorText(_errors['confirm']!),
          const SizedBox(height: 24),
          // CGU checkbox
          GestureDetector(
            onTap: () {
              setState(() => _isLegalChecked = !_isLegalChecked);
              _clearErrors();
              HapticFeedback.selectionClick();
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isLegalChecked ? AppColors.primaryLight.withValues(alpha: 0.3) : const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isLegalChecked
                      ? AppColors.secondary
                      : _errors.containsKey('legal')
                          ? AppColors.error
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
                      color: _isLegalChecked ? AppColors.secondary : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isLegalChecked ? AppColors.secondary : const Color(0xFFCCCCCC),
                        width: 2,
                      ),
                    ),
                    child: _isLegalChecked
                        ? const Icon(Icons.check, size: 14, color: AppColors.primary)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: "Je reconnais avoir lu et accepté les ",
                        style: const TextStyle(fontSize: 13, color: Color(0xFF121212), height: 1.5),
                        children: [
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () => _showLegalModal('Conditions Générales', _cguText),
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
                              onTap: () => _showLegalModal('Politique de Confidentialité', _privacyText),
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
            _errorText(_errors['legal']!),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              label: _currentStep == _totalSteps ? 'Créer mon compte' : 'Suivant',
              icon: _currentStep == _totalSteps ? Icons.check : Icons.arrow_forward,
              isLoading: _isSubmitting,
              onPressed: _isSubmitting ? null : _nextStep,
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
                builder: (_, value, child) => Transform.scale(scale: value, child: child),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle),
                  child: const Icon(Icons.check, size: 48, color: Color(0xFF43A047)),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Bienvenue !', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF121212))),
              const SizedBox(height: 10),
              Text('Votre compte Inggo a été créé avec succès.', style: TextStyle(fontSize: 15, color: Colors.grey.shade600)),
              const SizedBox(height: 60),
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  context.go('/login');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Commencer', style: TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w900)),
                      const SizedBox(width: 12),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_forward, color: AppColors.secondary, size: 24),
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
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF121212))),
      ],
    );
  }

  Widget _errorText(String msg) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 6),
      child: Text(msg, style: const TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}

// ─── Gender Card ───

class _GenderCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderCard({required this.label, required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight.withValues(alpha: 0.3) : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: isSelected ? AppColors.secondary : const Color(0xFF757575)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isSelected ? AppColors.secondary : const Color(0xFF757575)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Legal Texts ───

const String _cguText = '''
Conditions Générales d'Utilisation (CGU) – Inggo
Dernière mise à jour : Mercredi 7 janvier

Les présentes Conditions Générales d'Utilisation régissent l'accès et l'utilisation de l'application mobile Inggo, plateforme technologique de mise en relation entre utilisateurs et conducteurs privés indépendants sur moto.

L'application Inggo est la propriété exclusive et est exploitée par la société InnGroup SARL, société de droit djiboutien, dont le siège social est situé à Gabode 5, République de Djibouti.

Article 1 – Définitions
• Application : désigne l'application mobile Inggo.
• Société : désigne InnGroup SARL.
• Utilisateur : toute personne physique utilisant l'application afin de solliciter un trajet.
• Conducteur Partenaire : toute personne indépendante utilisant l'application pour proposer un service de transport sur moto.
• Service : service de mise en relation technologique fourni par l'application Inggo.

Article 2 – Objet
Les présentes CGU ont pour objet de définir les conditions d'accès et d'utilisation de l'application Inggo.

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

Cette Politique de Confidentialité décrit comment InnGroup SARL collecte, utilise, traite, stocke, protège et divulgue les données personnelles des Utilisateurs et des Conducteurs Partenaires.

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

3. Partage des données
InnGroup SARL ne vend pas les données personnelles à des tiers.

4. Sécurité
Chiffrement des données en transit et au repos. Communications HTTPS sécurisées.

5. Droits des utilisateurs
Accès, correction, suppression, opposition, portabilité des données.

Contact : admin@inngroupsarl.com
''';
