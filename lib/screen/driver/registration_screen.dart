import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase.dart';
import '../../widget/inggo_button.dart';
import '../../widget/inggo_input.dart';
import '../../widget/inggo_stepper.dart';

class DriverRegistrationScreen extends StatefulWidget {
  const DriverRegistrationScreen({super.key});

  @override
  State<DriverRegistrationScreen> createState() =>
      _DriverRegistrationScreenState();
}

class _DriverRegistrationScreenState extends State<DriverRegistrationScreen> {
  final _pageController = PageController();
  int _currentStep = 1;
  final int _totalSteps = 4;
  bool _isSubmitting = false;
  bool _showSuccess = false;

  // Step 1
  final _nomCtrl = TextEditingController();
  final _pereCtrl = TextEditingController();
  final _grandpereCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String _sexe = '';

  // Step 2
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  // Step 3 — Fichiers réels
  final Map<String, File?> _documentFiles = {
    'cni': null,
    'permis': null,
    'assurance': null,
    'moto': null,
  };

  // Step 4
  bool _cguChecked = false;
  bool _privacyChecked = false;

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
    super.dispose();
  }

  void _clearErrors() => setState(() => _errors.clear());
  void _setError(String field, String msg) =>
      setState(() => _errors[field] = msg);

  bool _validateStep() {
    _clearErrors();
    bool valid = true;
    final nameRegex = RegExp(r"^[a-zA-ZÀ-ÿ\s'-]+$");
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (_currentStep == 1) {
      if (_nomCtrl.text.trim().isEmpty) {
        _setError('nom', 'Requis');
        valid = false;
      } else if (!nameRegex.hasMatch(_nomCtrl.text.trim())) {
        _setError('nom', 'Format invalide');
        valid = false;
      }
      if (_pereCtrl.text.trim().isEmpty) {
        _setError('pere', 'Requis');
        valid = false;
      } else if (!nameRegex.hasMatch(_pereCtrl.text.trim())) {
        _setError('pere', 'Format invalide');
        valid = false;
      }
      if (_grandpereCtrl.text.trim().isEmpty) {
        _setError('grandpere', 'Requis');
        valid = false;
      } else if (!nameRegex.hasMatch(_grandpereCtrl.text.trim())) {
        _setError('grandpere', 'Format invalide');
        valid = false;
      }
      if (_sexe.isEmpty) {
        _setError('sexe', 'Sélectionnez un genre');
        valid = false;
      }
      if (_emailCtrl.text.trim().isEmpty) {
        _setError('email', 'Email requis');
        valid = false;
      } else if (!emailRegex.hasMatch(_emailCtrl.text.trim())) {
        _setError('email', 'Email invalide');
        valid = false;
      }
    } else if (_currentStep == 2) {
      if (_phoneCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().length < 6) {
        _setError('phone', 'Numéro invalide');
        valid = false;
      }
      if (_passwordCtrl.text.length < 6) {
        _setError('password', 'Min 6 caractères');
        valid = false;
      }
      if (_passwordCtrl.text != _confirmPasswordCtrl.text) {
        _setError('confirm', 'Mots de passe différents');
        valid = false;
      }
    } else if (_currentStep == 3) {
      final allFilled = _documentFiles.values.every((f) => f != null);
      if (!allFilled) {
        _setError('docs', 'Tous les documents sont requis');
        valid = false;
      }
    } else if (_currentStep == 4) {
      if (!_cguChecked || !_privacyChecked) {
        _setError('legal', 'Acceptez toutes les conditions');
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

  // ──────────────────────────────────────────────
  //  PICK DOCUMENT — Galerie / Caméra / Fichier
  // ──────────────────────────────────────────────
  Future<void> _pickDocument(String docKey) async {
    HapticFeedback.selectionClick();

    // Si déjà ajouté → proposer de retirer
    if (_documentFiles[docKey] != null) {
      await _showRemoveDialog(docKey);
      return;
    }

    // Afficher le bottom sheet de choix de source
    await _showSourceChooser(docKey);
  }

  Future<void> _showRemoveDialog(String docKey) async {
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
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Document déjà ajouté',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'Voulez-vous le remplacer ou le retirer ?',
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        setState(() => _documentFiles[docKey] = null);
                      },
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Retirer'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFD32F2F),
                        side: const BorderSide(color: Color(0xFFD32F2F)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showSourceChooser(docKey);
                      },
                      icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                      label: const Text('Remplacer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF121212),
                        foregroundColor: const Color(0xFFFFC107),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showSourceChooser(String docKey) async {
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
              // Handle
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Ajouter un document',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'Choisissez la source',
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
              const SizedBox(height: 24),

              // Galerie
              _SourceTile(
                icon: Icons.photo_library_rounded,
                iconColor: const Color(0xFF7C3AED),
                iconBg: const Color(0xFFF3E8FF),
                title: 'Galerie photos',
                subtitle: 'Choisir depuis vos photos',
                onTap: () async {
                  Navigator.pop(ctx);
                  await _pickFromGallery(docKey);
                },
              ),
              const SizedBox(height: 10),

              // Caméra
              _SourceTile(
                icon: Icons.camera_alt_rounded,
                iconColor: const Color(0xFF0284C7),
                iconBg: const Color(0xFFE0F2FE),
                title: 'Caméra',
                subtitle: 'Prendre une photo maintenant',
                onTap: () async {
                  Navigator.pop(ctx);
                  await _pickFromCamera(docKey);
                },
              ),
              const SizedBox(height: 10),

              // File manager
              _SourceTile(
                icon: Icons.folder_rounded,
                iconColor: const Color(0xFFD97706),
                iconBg: const Color(0xFFFEF3C7),
                title: 'Gestionnaire de fichiers',
                subtitle: 'PDF, JPG, PNG depuis vos fichiers',
                onTap: () async {
                  Navigator.pop(ctx);
                  await _pickFromFileManager(docKey);
                },
              ),

              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Annuler',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Galerie ──
  Future<void> _pickFromGallery(String docKey) async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked != null && mounted) {
        setState(() => _documentFiles[docKey] = File(picked.path));
        _showToast('Document ajouté ✓');
      }
    } catch (e) {
      _showToast('Erreur accès galerie');
    }
  }

  // ── Caméra ──
  Future<void> _pickFromCamera(String docKey) async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (picked != null && mounted) {
        setState(() => _documentFiles[docKey] = File(picked.path));
        _showToast('Photo prise ✓');
      }
    } catch (e) {
      _showToast('Erreur accès caméra');
    }
  }

  // ── File Manager (file_picker) ──
  Future<void> _pickFromFileManager(String docKey) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: false,
      );
      if (result != null && result.files.single.path != null && mounted) {
        setState(
            () => _documentFiles[docKey] = File(result.files.single.path!));
        _showToast('Fichier ajouté ✓');
      }
    } catch (e) {
      _showToast('Erreur accès fichiers');
    }
  }

  // ──────────────────────────────────────────────
  //  SUBMIT — Connexion Supabase complète
  // ──────────────────────────────────────────────
  Future<void> _submitForm() async {
    setState(() => _isSubmitting = true);

    try {
      // ── ÉTAPE 1 : Créer le compte auth Supabase ──
      final authResponse = await SupabaseConfig.client.auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        data: {
          'role': 'driver',
          'name': _nomCtrl.text.trim(),
          'father_name': _pereCtrl.text.trim(),
          'grand_father_name': _grandpereCtrl.text.trim(),
          'phone': '+253${_phoneCtrl.text.trim()}',
          'sexe': _sexe,
        },
      );

      final user = authResponse.user;
      if (user == null) throw Exception('Erreur lors de la création du compte');

      // ── ÉTAPE 2 : Insérer le profil conducteur ──
      await SupabaseConfig.client.from('profiles').upsert({
        'id': user.id,
        'name': _nomCtrl.text.trim(),
        'father_name': _pereCtrl.text.trim(),
        'grand_father_name': _grandpereCtrl.text.trim(),
        'phone': '+253${_phoneCtrl.text.trim()}',
        'sexe': _sexe,
        'role': 'driver',
        'status': 'pending',
      });

      // ── ÉTAPE 3 : Upload des documents dans Storage ──
      final Map<String, String?> uploadedUrls = {};

      for (final entry in _documentFiles.entries) {
        final file = entry.value;
        if (file == null) continue;

        final ext = file.path.split('.').last.toLowerCase();
        final storagePath = '${user.id}/${entry.key}.$ext';

        await SupabaseConfig.client.storage.from('driver-docs').upload(
              storagePath,
              file,
              fileOptions: const FileOptions(upsert: true),
            );

        // Récupère l'URL publique (le bucket est privé,
        // on stocke juste le path et on génère des URLs signées si besoin)
        uploadedUrls[entry.key] = storagePath;
      }

      // ── ÉTAPE 4 : Insérer les chemins dans driver_documents ──
      await SupabaseConfig.client.from('driver_documents').insert({
        'driver_id': user.id,
        'cni_url': uploadedUrls['cni'],
        'permis_url': uploadedUrls['permis'],
        'assurance_url': uploadedUrls['assurance'],
        'moto_url': uploadedUrls['moto'],
      });

      // ── ÉTAPE 5 : Succès ──
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _showSuccess = true;
        });
      }
    } on AuthException catch (e) {
      if (mounted) {
        String msg = 'Erreur d\'inscription';
        if (e.message.contains('already registered')) {
          msg = 'Cet email est déjà utilisé';
        } else if (e.message.contains('invalid email')) {
          msg = 'Email invalide';
        } else {
          msg = e.message;
        }
        _showToast(msg);
        setState(() => _isSubmitting = false);
      }
    } on PostgrestException catch (e) {
      if (mounted) {
        String msg = 'Erreur base de données';
        if (e.message.contains('profiles_phone_key') ||
            (e.details != null && e.details.toString().contains('phone'))) {
          msg = 'Ce numéro de téléphone est déjà utilisé';
        } else if (e.message.contains('profiles_pkey') ||
            e.message.contains('duplicate key')) {
          msg = 'Ce compte existe déjà';
        } else {
          msg = e.message;
        }
        _showToast(msg);
        setState(() => _isSubmitting = false);
      }
    } on StorageException catch (e) {
      if (mounted) {
        _showToast('Erreur upload document: ${e.message}');
        setState(() => _isSubmitting = false);
      }
    } catch (e) {
      if (mounted) {
        _showToast('Erreur: ${e.toString().replaceAll('Exception: ', '')}');
        setState(() => _isSubmitting = false);
      }
    }
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

  void _showLegalSheet(String title, String content) {
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
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800),
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

  // ──────────────────────────────────────────────
  //  BUILD
  // ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_showSuccess) return _buildSuccess();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            InggoStepper(
              currentStep: _currentStep,
              totalSteps: _totalSteps,
              variant: StepperVariant.linear,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                ],
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final stepLabels = ['Identité', 'Contact', 'Documents', 'Légal'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (_currentStep > 1) {
                    _prevStep();
                  } else {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/login');
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
                  child: const Icon(Icons.arrow_back,
                      size: 20, color: Color(0xFF121212)),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Inggo',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Étape $_currentStep/$_totalSteps · ${stepLabels[_currentStep - 1]}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF757575),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Qui\nêtes-vous ?',
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.w900, height: 1.1),
          ),
          const SizedBox(height: 6),
          const Text(
            'Informations personnelles du conducteur.',
            style: TextStyle(fontSize: 15, color: Color(0xFF757575)),
          ),
          const SizedBox(height: 30),
          InggoInput(
            label: 'NOM',
            placeholder: 'Votre nom de famille',
            controller: _nomCtrl,
            prefixIcon: Icons.person_outline,
            errorText: _errors['nom'],
            onChanged: (_) => _clearErrors(),
          ),
          const SizedBox(height: 16),
          InggoInput(
            label: 'NOM DU PÈRE',
            placeholder: 'Nom de votre père',
            controller: _pereCtrl,
            prefixIcon: Icons.account_tree_outlined,
            errorText: _errors['pere'],
            onChanged: (_) => _clearErrors(),
          ),
          const SizedBox(height: 16),
          InggoInput(
            label: 'NOM DU GRAND-PÈRE',
            placeholder: 'Nom de votre grand-père',
            controller: _grandpereCtrl,
            prefixIcon: Icons.elderly_outlined,
            errorText: _errors['grandpere'],
            onChanged: (_) => _clearErrors(),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'SEXE',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _GenderOption(
                  label: 'Homme',
                  icon: Icons.male,
                  isSelected: _sexe == 'H',
                  onTap: () {
                    setState(() => _sexe = 'H');
                    _clearErrors();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _GenderOption(
                  label: 'Femme',
                  icon: Icons.female,
                  isSelected: _sexe == 'F',
                  onTap: () {
                    setState(() => _sexe = 'F');
                    _clearErrors();
                  },
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
                    fontWeight: FontWeight.w700),
              ),
            ),
          const SizedBox(height: 16),
          InggoInput(
            label: 'EMAIL',
            placeholder: 'votre-email@gmail.com',
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
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vos\ncoordonnées',
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.w900, height: 1.1),
          ),
          const SizedBox(height: 6),
          const Text(
            'Numéro de téléphone et mot de passe.',
            style: TextStyle(fontSize: 15, color: Color(0xFF757575)),
          ),
          const SizedBox(height: 30),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'TÉLÉPHONE',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
          const SizedBox(height: 20),
          InggoInput(
            label: 'MOT DE PASSE',
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
            label: 'CONFIRMER',
            placeholder: 'Répétez le mot de passe',
            controller: _confirmPasswordCtrl,
            obscureText: true,
            showToggleVisibility: true,
            prefixIcon: Icons.lock_outline,
            errorText: _errors['confirm'],
            onChanged: (_) => _clearErrors(),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vos\ndocuments',
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.w900, height: 1.1),
          ),
          const SizedBox(height: 6),
          const Text(
            'Ajoutez les documents requis.',
            style: TextStyle(fontSize: 15, color: Color(0xFF757575)),
          ),
          const SizedBox(height: 30),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.0,
            children: [
              _UploadCard(
                icon: Icons.badge,
                label: "Carte d'identité",
                sub: 'Recto/Verso',
                isFilled: _documentFiles['cni'] != null,
                previewFile: _documentFiles['cni'],
                onTap: () => _pickDocument('cni'),
              ),
              _UploadCard(
                icon: Icons.drive_eta,
                label: 'Permis de conduire',
                sub: 'Moto valide',
                isFilled: _documentFiles['permis'] != null,
                previewFile: _documentFiles['permis'],
                onTap: () => _pickDocument('permis'),
              ),
              _UploadCard(
                icon: Icons.security,
                label: 'Assurance',
                sub: 'En cours',
                isFilled: _documentFiles['assurance'] != null,
                previewFile: _documentFiles['assurance'],
                onTap: () => _pickDocument('assurance'),
              ),
              _UploadCard(
                icon: Icons.two_wheeler,
                label: 'Photo moto',
                sub: 'Vue complète',
                isFilled: _documentFiles['moto'] != null,
                previewFile: _documentFiles['moto'],
                onTap: () => _pickDocument('moto'),
              ),
            ],
          ),
          if (_errors.containsKey('docs'))
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _errors['docs']!,
                style: const TextStyle(
                    color: Color(0xFFD32F2F),
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Conditions\nlégales',
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.w900, height: 1.1),
          ),
          const SizedBox(height: 6),
          const Text(
            "Acceptez les conditions d'utilisation.",
            style: TextStyle(fontSize: 15, color: Color(0xFF757575)),
          ),
          const SizedBox(height: 30),
          _LegalItem(
            label: "J'accepte les Conditions Générales d'Utilisation d'Inggo.",
            linkLabel: 'Lire les CGU',
            isChecked: _cguChecked,
            onTap: () {
              setState(() => _cguChecked = !_cguChecked);
              _clearErrors();
            },
            onLinkTap: () =>
                _showLegalSheet('Conditions Générales', _driverCguText),
          ),
          const SizedBox(height: 12),
          _LegalItem(
            label: "J'accepte la Politique de Confidentialité d'Inggo.",
            linkLabel: 'Lire la Politique',
            isChecked: _privacyChecked,
            onTap: () {
              setState(() => _privacyChecked = !_privacyChecked);
              _clearErrors();
            },
            onLinkTap: () => _showLegalSheet(
              'Politique de Confidentialité',
              _driverPrivacyText,
            ),
          ),
          if (_errors.containsKey('legal'))
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 10),
              child: Text(
                _errors['legal']!,
                style: const TextStyle(
                    color: Color(0xFFD32F2F),
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
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
        border: const Border(
          top: BorderSide(color: Color(0xFFF0F0F0), width: 1),
        ),
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
            const SizedBox(width: 15),
          ],
          Expanded(
            child: InggoButton(
              label: _currentStep == _totalSteps ? "S'inscrire" : 'Continuer',
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

  Widget _buildSuccess() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.elasticOut,
                  builder: (_, v, child) =>
                      Transform.scale(scale: v, child: child),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check,
                        size: 48, color: Color(0xFF43A047)),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Dossier envoyé !',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                Text(
                  'Votre dossier est en cours de vérification.\nVous recevrez une confirmation sous 24h.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 15, color: Colors.grey.shade600, height: 1.5),
                ),
                const SizedBox(height: 50),
                InggoButton(
                  label: "Retour à la connexion",
                  icon: Icons.login,
                  onPressed: () => context.go('/login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  Gender Option
// ─────────────────────────────────────────

class _GenderOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderOption({
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

// ─────────────────────────────────────────
//  Upload Card (avec preview image)
// ─────────────────────────────────────────

class _UploadCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final bool isFilled;
  final File? previewFile;
  final VoidCallback onTap;

  const _UploadCard({
    required this.icon,
    required this.label,
    required this.sub,
    required this.isFilled,
    required this.onTap,
    this.previewFile,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isFilled ? const Color(0xFFE8F5E9) : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isFilled ? const Color(0xFF43A047) : const Color(0xFFDDDDDD),
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        // LayoutBuilder donne les contraintes réelles du parent
        // nécessaire pour que Image.file puisse calculer sa taille [Fix image.dart:520]
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            return Stack(
              fit: StackFit.expand,
              children: [
                // Preview image si disponible — taille explicite via SizedBox [Fix image.dart:520]
                if (previewFile != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: w,
                      height: h,
                      child: Image.file(
                        previewFile!,
                        width: w,
                        height: h,
                        fit: BoxFit.cover,
                        color: Colors.black.withValues(alpha: 0.30),
                        colorBlendMode: BlendMode.darken,
                        // errorBuilder évite le crash si le fichier est corrompu
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFE8F5E9),
                          child: const Icon(Icons.broken_image_outlined,
                              color: Color(0xFF9CA3AF)),
                        ),
                      ),
                    ),
                  ),

                // Contenu centré — Padding évite le débordement [Fix overflow 20px]
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize
                        .min, // [Fix overflow] ne prend que ce qu'il faut
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isFilled ? Icons.check_circle : icon,
                          size: 22,
                          color: isFilled
                              ? const Color(0xFF43A047)
                              : const Color(0xFF121212),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis, // [Fix overflow]
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          color: previewFile != null
                              ? Colors.white
                              : const Color(0xFF121212),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isFilled ? 'Appuyer pour retirer' : sub,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis, // [Fix overflow]
                        style: TextStyle(
                          fontSize: 10,
                          color: previewFile != null
                              ? Colors.white70
                              : const Color(0xFF757575),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  Legal Checkbox Item
// ─────────────────────────────────────────

class _LegalItem extends StatelessWidget {
  final String label;
  final String linkLabel;
  final bool isChecked;
  final VoidCallback onTap;
  final VoidCallback onLinkTap;

  const _LegalItem({
    required this.label,
    required this.linkLabel,
    required this.isChecked,
    required this.onTap,
    required this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isChecked ? const Color(0xFFFFF8E1) : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isChecked ? const Color(0xFF121212) : Colors.transparent,
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
                color: isChecked ? const Color(0xFF121212) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isChecked
                      ? const Color(0xFF121212)
                      : const Color(0xFFCCCCCC),
                  width: 2,
                ),
              ),
              child: isChecked
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500, height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: onLinkTap,
                    child: Text(
                      linkLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF336D91),
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                      ),
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
}

// ─────────────────────────────────────────
//  Legal Texts
// ─────────────────────────────────────────

const _driverCguText = '''
Conditions Générales d'Utilisation (CGU) – Inggo
Dernière mise à jour : Mercredi 7 janvier

Les présentes CGU régissent l'accès et l'utilisation de l'application mobile Inggo par les Conducteurs Partenaires.

Inggo est une plateforme de mise en relation entre utilisateurs et conducteurs privés indépendants sur moto, exploitée par InnGroup SARL (Gabode 5, Djibouti).

Article 1 – Statut du Conducteur Partenaire
Le Conducteur Partenaire exerce son activité en totale indépendance. Aucune relation de subordination n'existe avec InnGroup SARL.

Article 2 – Obligations du Conducteur
• Permis de conduire valide
• Assurance professionnelle en cours
• Moto en parfait état de fonctionnement
• Comportement courtois et professionnel
• Casque passager fourni par InnGroup obligatoire
• Gilet haute visibilité aux couleurs Inggo

Article 3 – Rémunération
La rémunération dépend exclusivement des courses réalisées. InnGroup SARL perçoit une commission sur chaque course.

Article 4 – Suspension et résiliation
InnGroup SARL peut suspendre ou résilier l'accès en cas de manquement grave aux CGU.

Article 5 – Responsabilité
Le Conducteur est seul responsable des trajets, des passagers et de tout dommage survenu dans le cadre de son activité.

Droit applicable : République de Djibouti.
''';

const _driverPrivacyText = '''
Politique de Confidentialité – Inggo (Conducteurs)
InnGroup SARL – République de Djibouti

Données collectées :
• Nom complet, numéro de téléphone, email
• Photo de profil, pièce d'identité, permis de conduire
• Détails du véhicule, coordonnées bancaires
• Géolocalisation GPS (pendant les courses)

Finalité :
• Vérification d'identité et d'éligibilité
• Mise en relation avec les utilisateurs
• Gestion des paiements et commissions
• Envoi de notifications liées au service

Sécurité :
Chiffrement des données en transit et stockage sécurisé. Accès restreint au personnel autorisé.

Droits :
Accès, correction, suppression, opposition, portabilité.

Contact : admin@inngroupsarl.com
''';

// ─────────────────────────────────────────
//  Source Tile (bottom sheet choix source)
// ─────────────────────────────────────────

class _SourceTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SourceTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16),
          border: const Border.all(color: Color(0xFFE5E7EB), width: 1.5),
        ),
        child: Row(
          children: [
            // Icône
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            // Texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: Color(0xFFD1D5DB),
            ),
          ],
        ),
      ),
    );
  }
}
