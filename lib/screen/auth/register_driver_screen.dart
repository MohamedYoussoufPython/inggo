import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/constants.dart';
import '../../core/services/supabase_service.dart';
import '../../core/router/app_router.dart';
import '../../widget/widgets.dart';
import '../../l10n/app_localizations.dart';

class RegisterDriverScreen extends StatefulWidget {
  const RegisterDriverScreen({super.key});

  @override
  State<RegisterDriverScreen> createState() => _RegisterDriverScreenState();
}

class _RegisterDriverScreenState extends State<RegisterDriverScreen> {
  final _pageController = PageController();
  int _currentStep = 1;
  final int _totalSteps = 4;
  bool _isSubmitting = false;
  bool _showSuccess = false;
  // Step 1 — Identité
  final _nomCtrl = TextEditingController();
  final _pereCtrl = TextEditingController();
  final _grandpereCtrl = TextEditingController();
  String _sexe = '';
  String _pays = 'Djibouti';

  // Step 2 — Coordonnées + Sécurité
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  // OTP state
  bool _otpSent = false;
  bool _otpSending = false;
  bool _phoneVerified = false;
  bool _otpVerifying = false;
  int _resendTimer = 0;
  Timer? _timer;
  Timer? _debounceTimer;
  String _lastSentPhone = '';

  // Step 3 — Véhicule + Documents
  final _plateCtrl = TextEditingController();
  final _vehicleColorCtrl = TextEditingController();
  final Map<String, File?> _documentFiles = {
    'cni': null,
    'permis': null,
    'assurance': null,
    'moto': null,
  };

  // Step 4 — Conditions
  bool _cguChecked = false;
  bool _privacyChecked = false;

  // Errors
  final Map<String, String> _errors = {};
  final _picker = ImagePicker();

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
    _plateCtrl.dispose();
    _vehicleColorCtrl.dispose();
    _timer?.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _clearErrors() => setState(() => _errors.clear());

  void _setError(String field, String msg) =>
      setState(() => _errors[field] = msg);

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
      _setError('phone', AppLocalizations.of(context).errorInvalidPhone);
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

        _lastSentPhone = _fullPhone;
        _resendTimer = 60;
      });
      _startTimer();
      HapticFeedback.mediumImpact();
      _showToast('${AppLocalizations.of(context).otpSentTo} $_fullPhone');
    } catch (e) {
      if (!mounted) return;
      setState(() => _otpSending = false);
      _setError('otp', AppLocalizations.of(context).otpSendError);
      _showToast('${AppLocalizations.of(context).errorWithDetail}: ${e.toString()}');
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
      // Flag OTP verification to prevent GoRouter redirect
      // from the temporary session created by verifyOtp()
      AppRouter.setOtpVerifying(true);
      await SupabaseService.instance.verifyOtp(_fullPhone, code);

      if (!mounted) return;

      // Sign out the temporary session created by OTP verification
      await Supabase.instance.client.auth.signOut();
      AppRouter.setOtpVerifying(false);

      if (!mounted) return;
      setState(() {
        _phoneVerified = true;
        _otpVerifying = false;
      });
      HapticFeedback.heavyImpact();
      _showToast(AppLocalizations.of(context).phoneVerified);
    } catch (e) {
      if (!mounted) return;
      AppRouter.setOtpVerifying(false);
      setState(() => _otpVerifying = false);
      _setError('otp', AppLocalizations.of(context).invalidOtp);
      _showToast(AppLocalizations.of(context).otpIncorrect);
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
    final loc = AppLocalizations.of(context);

    if (_currentStep == 1) {
      if (_nomCtrl.text.trim().isEmpty) {
        _setError('nom', loc.fieldRequired);
        valid = false;
      } else if (!nameRegex.hasMatch(_nomCtrl.text.trim())) {
        _setError('nom', loc.errorInvalidFormat);
        valid = false;
      }
      if (_pereCtrl.text.trim().isEmpty) {
        _setError('pere', loc.fieldRequired);
        valid = false;
      }
      if (_grandpereCtrl.text.trim().isEmpty) {
        _setError('grandpere', loc.fieldRequired);
        valid = false;
      }
      if (_sexe.isEmpty) {
        _setError('sexe', loc.selectGender);
        valid = false;
      }
    } else if (_currentStep == 2) {
      if (_emailCtrl.text.trim().isEmpty) {
        _setError('email', loc.errorEmailRequired);
        valid = false;
      } else if (!emailRegex.hasMatch(_emailCtrl.text.trim())) {
        _setError('email', loc.errorEmailInvalidFormat);
        valid = false;
      }
      if (_phoneCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().replaceAll(' ', '').length < 6) {
        _setError('phone', loc.errorInvalidPhone);
        valid = false;
      }
      if (!_phoneVerified) {
        _setError('phone_verify', loc.verifyYourNumber);
        valid = false;
      }
      if (_passwordCtrl.text.length < 6) {
        _setError('password', loc.errorPasswordMinLength);
        valid = false;
      }
      if (_passwordCtrl.text != _confirmPasswordCtrl.text) {
        _setError('confirm', loc.passwordsDiffer);
        valid = false;
      }
    } else if (_currentStep == 3) {
      if (_plateCtrl.text.trim().isEmpty) {
        _setError('plate', loc.plateNumberRequired);
        valid = false;
      }
      final allFilled = _documentFiles.values.every((f) => f != null);
      if (!allFilled) {
        _setError('docs', loc.allDocsRequired);
        valid = false;
      }
    } else if (_currentStep == 4) {
      if (!_cguChecked || !_privacyChecked) {
        _setError('legal', loc.acceptAllTerms);
        valid = false;
      }
    }

    if (!valid) {
      HapticFeedback.mediumImpact();
      _showToast(loc.pleaseCorrectErrors);
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

  // ─── Document Picker ───

  Future<void> _pickDocument(String docKey) async {
    HapticFeedback.selectionClick();

    if (_documentFiles[docKey] != null) {
      _showRemoveDialog(docKey);
      return;
    }

    await _showSourceChooser(docKey);
  }

  Future<void> _showSourceChooser(String docKey) async {
    final loc = AppLocalizations.of(context);
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(loc.uploadDocument,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: Text(loc.takePhoto),
                onTap: () async {
                  Navigator.pop(ctx);
                  final image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                  if (image != null) {
                    setState(() => _documentFiles[docKey] = File(image.path));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primary),
                title: Text(loc.chooseFromGallery),
                onTap: () async {
                  Navigator.pop(ctx);
                  final image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                  if (image != null) {
                    setState(() => _documentFiles[docKey] = File(image.path));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showRemoveDialog(String docKey) async {
    final loc = AppLocalizations.of(context);
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(loc.documentAlreadyAdded,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              InggoButton(
                label: loc.deleteAndRetry,
                type: InggoButtonType.danger,
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() => _documentFiles[docKey] = null);
                },
              ),
              const SizedBox(height: 8),
              InggoButton(
                label: loc.keep,
                type: InggoButtonType.text,
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Submit ───

  Future<void> _submitForm() async {
    setState(() => _isSubmitting = true);

    try {
      final fullName =
          '${_nomCtrl.text.trim()} ${_pereCtrl.text.trim()} ${_grandpereCtrl.text.trim()}';
      final phone = _fullPhone;

      // 1. Sign up with Supabase Auth
      final response = await Supabase.instance.client.auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        data: {
          'full_name': fullName,
          'phone': phone,
          'role': 'driver',
          'sexe': _sexe,
          'pays': _pays,
        },
      );

      if (!mounted) return;
      final userId = response.user?.id;
      if (userId == null) throw Exception(AppLocalizations.of(context).accountCreationError);

      // 2. Insert profile (trigger fallback)
      try {
        await SupabaseService.instance.upsert('profiles', {
          'id': userId,
          'full_name': fullName,
          'phone': phone,
          'email': _emailCtrl.text.trim(),
          'role': 'driver',
          'sexe': _sexe,
          'pays': _pays,
          'phone_verified': true,
        });
      } catch (_) {
        // Profile may already exist via DB trigger — safe to ignore
      }

      // 3. Upload documents to Supabase Storage (private bucket — use signed URLs)
      final docUrls = <String, String?>{};
      for (final entry in _documentFiles.entries) {
        if (entry.value != null) {
          final bytes = await entry.value!.readAsBytes();
          final filePath = '$userId/${entry.key}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          docUrls[entry.key] = await SupabaseService.instance.uploadPrivateFile('driver-documents', filePath, bytes);
        }
      }

      // 4. Insert driver (upsert in case of re-registration)
      await SupabaseService.instance.upsert('drivers', {
        'id': userId,
        'vehicle_type': 'moto',
        'plate_number': _plateCtrl.text.trim(),
        'vehicle_color': _vehicleColorCtrl.text.trim().isEmpty ? null : _vehicleColorCtrl.text.trim(),
        'is_verified': false,
        'id_card_url': docUrls['cni'],
        'license_url': docUrls['permis'],
        'insurance_url': docUrls['assurance'],
        'vehicle_photo_url': docUrls['moto'],
      });

      setState(() {
        _isSubmitting = false;
        _showSuccess = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showToast('${AppLocalizations.of(context).errorWithDetail}: ${e.toString()}');
    }
  }

  // ─── Toast ───

  void _showToast(String msg) {
    InggoToast.success(context, msg);
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
                child: Text(content, style: const TextStyle(fontSize: 14, color: Color(0xFF444444), height: 1.6)),
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
                children: [_buildStep1(), _buildStep2(), _buildStep3(), _buildStep4()],
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final loc = AppLocalizations.of(context);
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
          Text(loc.becomeDriver, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF121212))),
          const SizedBox(height: 4),
          Text(loc.joinFleet4Steps, style: const TextStyle(fontSize: 14, color: Color(0xFF757575))),
        ],
      ),
    );
  }

  // ─── STEP 1: Identité ───
  Widget _buildStep1() {
    final loc = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.person, loc.whoAreYou),
          const SizedBox(height: 24),
          InggoInput(label: loc.yourName, hint: loc.yourNameHint, controller: _nomCtrl, prefixIcon: Icons.person_outline, onChanged: (_) => _clearErrors()),
          if (_errors.containsKey('nom')) _errorText(_errors['nom']!),
          const SizedBox(height: 16),
          InggoInput(label: loc.fatherName, hint: loc.fatherName, controller: _pereCtrl, onChanged: (_) => _clearErrors()),
          if (_errors.containsKey('pere')) _errorText(_errors['pere']!),
          const SizedBox(height: 16),
          InggoInput(label: loc.grandfatherName, hint: loc.grandfatherName, controller: _grandpereCtrl, onChanged: (_) => _clearErrors()),
          if (_errors.containsKey('grandpere')) _errorText(_errors['grandpere']!),
          const SizedBox(height: 20),
          // Gender
          Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Text(loc.gender, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5))),
          Row(
            children: [
              Expanded(child: _GenderCard(label: loc.male, icon: Icons.male, isSelected: _sexe == 'H', onTap: () => setState(() { _sexe = 'H'; _clearErrors(); }))),
              const SizedBox(width: 10),
              Expanded(child: _GenderCard(label: loc.female, icon: Icons.female, isSelected: _sexe == 'F', onTap: () => setState(() { _sexe = 'F'; _clearErrors(); }))),
            ],
          ),
          if (_errors.containsKey('sexe')) _errorText(_errors['sexe']!),
          const SizedBox(height: 20),
          // Pays
          Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Text(loc.country, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5))),
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(16)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _pays,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF121212)),
                items: [('Djibouti', 'Djibouti'), ('Autre', loc.other)].map((e) => DropdownMenuItem(value: e.$1, child: Text(e.$2))).toList(),
                onChanged: (v) => setState(() => _pays = v ?? 'Djibouti'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── STEP 2: Coordonnées + Sécurité + OTP ───
  Widget _buildStep2() {
    final loc = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.contact_mail, loc.contactAndSecurity),
          const SizedBox(height: 24),
          // Email
          InggoInput(label: loc.email, hint: loc.emailHint, controller: _emailCtrl, keyboardType: TextInputType.emailAddress, prefixIcon: Icons.email_outlined, onChanged: (_) => _clearErrors()),
          if (_errors.containsKey('email')) _errorText(_errors['email']!),
          const SizedBox(height: 20),
          // Phone
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Text(loc.phoneNumber, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5))),
              Row(
                children: [
                  Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(16)),
                    child: const Center(child: Text('🇩🇯 +253', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: InggoInput(
                    hint: loc.phoneHintFormat,
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    onChanged: _onPhoneChanged,
                  )),
                ],
              ),
            ],
          ),
          if (_errors.containsKey('phone')) _errorText(_errors['phone']!),
          const SizedBox(height: 16),

          // ─── Sending indicator / Resend button ───
          if (_otpSending) ...[
            SizedBox(
              width: double.infinity,
              height: 48,
              child: InggoButton(
                label: loc.uploading,
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
                    ? '${loc.resendOtp} (${_resendTimer}s)'
                    : loc.resendOtp,
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
                    loc.otpAutoSend,
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
                    '${loc.phoneVerifiedWith} $_fullPhone',
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
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 10),
              child: Text(
                loc.enterVerificationCode,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF444444)),
              ),
            ),
            Center(
              child: InggoOtpInput(
                onCompleted: (code) {
                  _verifyOtp(code);
                },
                onChanged: (code) {
                  _clearErrors();
                },
              ),
            ),
            if (_otpVerifying) ...[
              const SizedBox(height: 12),
              const Center(child: InggoLoading()),
            ],
            if (_errors.containsKey('otp'))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _errorText(_errors['otp']!),
              ),
          ],

          if (_errors.containsKey('phone_verify'))
            _errorText(_errors['phone_verify']!),
          const SizedBox(height: 20),

          // Password fields (always visible)
          InggoInput(label: loc.password, hint: loc.atLeast6Chars, controller: _passwordCtrl, obscureText: true, prefixIcon: Icons.lock_outline, onChanged: (_) => _clearErrors()),
          if (_errors.containsKey('password')) _errorText(_errors['password']!),
          const SizedBox(height: 16),
          InggoInput(label: loc.confirmPassword, hint: loc.repeatPasswordHint, controller: _confirmPasswordCtrl, obscureText: true, prefixIcon: Icons.lock_outline, onChanged: (_) => _clearErrors()),
          if (_errors.containsKey('confirm')) _errorText(_errors['confirm']!),
        ],
      ),
    );
  }

  // ─── STEP 3: Véhicule + Documents ───
  Widget _buildStep3() {
    final loc = AppLocalizations.of(context);
    final docLabels = {
      'cni': {'label': loc.idCard, 'icon': Icons.badge},
      'permis': {'label': loc.driverLicense, 'icon': Icons.drive_eta},
      'assurance': {'label': loc.insurance, 'icon': Icons.security},
      'moto': {'label': loc.motorcyclePhoto, 'icon': Icons.two_wheeler},
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.two_wheeler, loc.yourMotorcycle),
          const SizedBox(height: 8),
          Text(loc.vehicleInfoHint, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          const SizedBox(height: 20),
          // Plaque
          InggoInput(
            label: loc.plateNumber,
            hint: loc.plateNumberHint,
            controller: _plateCtrl,
            prefixIcon: Icons.pin,
            onChanged: (_) => _clearErrors(),
          ),
          if (_errors.containsKey('plate')) _errorText(_errors['plate']!),
          const SizedBox(height: 16),
          // Couleur
          InggoInput(
            label: loc.vehicleColor,
            hint: loc.vehicleColorHint,
            controller: _vehicleColorCtrl,
            prefixIcon: Icons.palette,
            onChanged: (_) => _clearErrors(),
          ),
          const SizedBox(height: 24),
          // Documents section
          _sectionTitle(Icons.folder, loc.yourDocumentsCap),
          const SizedBox(height: 8),
          Text(loc.allDocsRequiredHint, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          const SizedBox(height: 20),
          ...docLabels.entries.map((entry) {
            final key = entry.key;
            final info = entry.value;
            final file = _documentFiles[key];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => _pickDocument(key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: file != null ? AppColors.success.withValues(alpha: 0.05) : const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: file != null ? AppColors.success : AppColors.border,
                      width: file != null ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: file != null ? AppColors.success.withValues(alpha: 0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: file != null
                            ? const Icon(Icons.check_circle, color: AppColors.success, size: 24)
                            : Icon(info['icon'] as IconData, color: AppColors.textSecondary, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              info['label'] as String,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: file != null ? AppColors.success : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              file != null ? loc.documentAdded : loc.tapToAdd,
                              style: TextStyle(fontSize: 12, color: file != null ? AppColors.success : Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        file != null ? Icons.edit : Icons.add_circle_outline,
                        color: file != null ? AppColors.success : AppColors.textHint,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          if (_errors.containsKey('docs')) _errorText(_errors['docs']!),
        ],
      ),
    );
  }

  // ─── STEP 4: Conditions ───
  Widget _buildStep4() {
    final loc = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.gavel, loc.conditions),
          const SizedBox(height: 24),
          // CGU
          GestureDetector(
            onTap: () => setState(() { _cguChecked = !_cguChecked; _clearErrors(); }),
            child: _LegalCheckbox(
              checked: _cguChecked,
              label: loc.iAcceptThe,
              linkLabel: loc.termsOfUse,
              onLinkTap: () => _showLegalModal(loc.termsOfUse, _getCguText(loc)),
            ),
          ),
          const SizedBox(height: 16),
          // Privacy
          GestureDetector(
            onTap: () => setState(() { _privacyChecked = !_privacyChecked; _clearErrors(); }),
            child: _LegalCheckbox(
              checked: _privacyChecked,
              label: loc.iAcceptTheFem,
              linkLabel: loc.privacyPolicy,
              onLinkTap: () => _showLegalModal(loc.privacyPolicy, _getPrivacyText(loc)),
            ),
          ),
          if (_errors.containsKey('legal')) _errorText(_errors['legal']!),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.primaryDark, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    loc.dossierUnderReview,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final loc = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Warning if phone not verified on step 2
          if (_currentStep == 2 && !_phoneVerified) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline, size: 16, color: AppColors.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _otpSent
                          ? loc.verifyNumberToContinue
                          : loc.enterAndVerifyNumber,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.warning),
                    ),
                  ),
                ],
              ),
            ),
          ],
          Row(
            children: [
              if (_currentStep > 1) ...[
                GestureDetector(
                  onTap: _prevStep,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.arrow_back, color: Color(0xFF121212)),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: InggoButton(
                  label: _currentStep == _totalSteps ? loc.submitMyDossier : loc.next,
                  icon: _currentStep == _totalSteps ? Icons.send : Icons.arrow_forward,
                  isLoading: _isSubmitting,
                  onPressed: (_isSubmitting || (_currentStep == 2 && !_phoneVerified))
                      ? null
                      : _nextStep,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessScreen() {
    final loc = AppLocalizations.of(context);
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
                  decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                  child: const Icon(Icons.check, size: 48, color: AppColors.secondary),
                ),
              ),
              const SizedBox(height: 24),
              Text(loc.dossierSubmitted, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF121212))),
              const SizedBox(height: 10),
              Text(loc.dossierVerificationPending,
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.grey.shade600)),
              const SizedBox(height: 60),
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  context.go('/pending-verification');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                  decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(50)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(loc.understood, style: const TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w900)),
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
            Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isSelected ? AppColors.secondary : const Color(0xFF757575))),
          ],
        ),
      ),
    );
  }
}

// ─── Legal Checkbox ───

class _LegalCheckbox extends StatelessWidget {
  final bool checked;
  final String label;
  final String linkLabel;
  final VoidCallback onLinkTap;

  const _LegalCheckbox({required this.checked, required this.label, required this.linkLabel, required this.onLinkTap});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: checked ? AppColors.primaryLight.withValues(alpha: 0.3) : const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: checked ? AppColors.secondary : Colors.transparent),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: checked ? AppColors.secondary : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: checked ? AppColors.secondary : const Color(0xFFCCCCCC), width: 2),
            ),
            child: checked ? const Icon(Icons.check, size: 14, color: AppColors.primary) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: label,
                style: const TextStyle(fontSize: 13, color: Color(0xFF121212), height: 1.5),
                children: [
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: onLinkTap,
                      child: Text(
                        linkLabel,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF336D91), fontWeight: FontWeight.w700, decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                  TextSpan(text: loc.ofInggo),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Legal Texts ───

String _getCguText(AppLocalizations loc) {
  return '${loc.cguTitle}\n'
      '${loc.cguLastUpdated}\n\n'
      '${loc.cguPreamble}\n\n'
      '${loc.cguOwnership}\n\n'
      '${loc.cguArticle1Title}\n'
      '${loc.cguArticle1Content}\n\n'
      '${loc.cguArticle2Title}\n'
      '${loc.cguArticle2Content}\n\n'
      '${loc.cguArticle3Title}\n'
      '${loc.cguArticle3Content}\n\n'
      '${loc.cguArticle4Title}\n'
      '${loc.cguArticle4Content}\n\n'
      '${loc.cguArticle5Title}\n'
      '${loc.cguArticle5Content}\n\n'
      '${loc.cguArticle6Title}\n'
      '${loc.cguArticle6Content}\n\n'
      '${loc.cguArticle7Title}\n'
      '${loc.cguArticle7Content}\n\n'
      '${loc.cguArticle8Title}\n'
      '${loc.cguArticle8Content}';
}

String _getPrivacyText(AppLocalizations loc) {
  return '${loc.privacyRegTitle}\n'
      '${loc.privacyRegOwner}\n'
      '${loc.privacyRegCountry}\n'
      '${loc.privacyRegLastUpdated}\n\n'
      '${loc.privacyRegIntro}\n\n'
      '${loc.privacyRegDataTitle}\n'
      '${loc.privacyRegDataContent}\n\n'
      '${loc.privacyRegPurposeTitle}\n'
      '${loc.privacyRegPurposeContent}\n\n'
      '${loc.privacyRegSharingTitle}\n'
      '${loc.privacyRegSharingContent}\n\n'
      '${loc.privacyRegSecurityTitle}\n'
      '${loc.privacyRegSecurityContent}\n\n'
      '${loc.privacyRegRightsTitle}\n'
      '${loc.privacyRegRightsContent}\n\n'
      '${loc.privacyRegContact}';
}
