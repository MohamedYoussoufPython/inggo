import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/constants.dart';
import '../../widget/widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late FocusNode _emailFocusNode;
  late FocusNode _passwordFocusNode;

  bool _obscurePassword = true;
  bool _loading = false;
  bool _rememberMe = false;

  String? _emailError;
  String? _passwordError;
  bool _emailValid = false;
  bool _passwordValid = false;
  bool _emailTouched = false;
  bool _passwordTouched = false;

  int _loginAttempts = 0;
  static const int _maxLoginAttempts = 5;

  @override
  void initState() {
    super.initState();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _emailFocusNode.addListener(_onEmailFocusChange);
    _passwordFocusNode.addListener(_onPasswordFocusChange);
  }

  void _onEmailFocusChange() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_emailFocusNode.hasFocus && _emailTouched) {
        _validateEmail(_emailController.text);
      } else {
        setState(() {});
      }
    });
  }

  void _onPasswordFocusChange() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_passwordFocusNode.hasFocus && _passwordTouched) {
        _validatePassword(_passwordController.text);
      } else {
        setState(() {});
      }
    });
  }

  bool _isValidEmail(String email) {
    if (email.isEmpty) return false;
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  void _validateEmail(String value) {
    setState(() {
      _emailTouched = true;
      if (value.isEmpty) {
        _emailError = 'Email requis';
        _emailValid = false;
      } else if (!_isValidEmail(value)) {
        _emailError = 'Format email invalide';
        _emailValid = false;
      } else {
        _emailError = null;
        _emailValid = true;
      }
    });
  }

  void _validatePassword(String value) {
    setState(() {
      _passwordTouched = true;
      if (value.isEmpty) {
        _passwordError = 'Mot de passe requis';
        _passwordValid = false;
      } else if (value.length < 6) {
        _passwordError = 'Minimum 6 caractères';
        _passwordValid = false;
      } else {
        _passwordError = null;
        _passwordValid = true;
      }
    });
  }

  Color _getBorderColor({
    required bool touched,
    required bool valid,
    required bool hasFocus,
    required String? error,
  }) {
    if (hasFocus) return AppColors.primary;
    if (touched && error != null) return AppColors.error;
    if (valid) return AppColors.success;
    return AppColors.border;
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_loginAttempts >= _maxLoginAttempts) {
      _showSnackBar(
        'Trop de tentatives. Réessayez plus tard.',
        AppColors.error,
      );
      return;
    }
    if (!_emailValid || !_passwordValid) {
      _showSnackBar('Corrigez les erreurs avant de continuer', AppColors.warning);
      return;
    }

    setState(() => _loading = true);
    _loginAttempts++;

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      if (response.session == null) throw Exception('Identifiants incorrects');

      final user = response.user;

      // Get profile for role
      final profileData = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', user!.id)
          .maybeSingle();

      if (!mounted) return;

      final role = profileData?['role'] ?? 'client';

      _showSnackBar('Connexion réussie !', AppColors.success);
      await Future.delayed(const Duration(milliseconds: 400));

      if (!mounted) return;

      if (role == 'driver') {
        // Check if verified
        final driverData = await Supabase.instance.client
            .from('drivers')
            .select('is_verified')
            .eq('id', user.id)
            .maybeSingle();

        if (!mounted) return;
        if (driverData?['is_verified'] == true) {
          context.go('/driver/home');
        } else {
          context.go('/pending-verification');
        }
      } else {
        context.go('/client/home');
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      String errorMessage = 'Erreur de connexion';
      if (e.message.contains('Invalid login credentials')) {
        errorMessage = 'Email ou mot de passe incorrect';
      } else if (e.message.contains('Email not confirmed')) {
        errorMessage = 'Confirmez votre email avant de vous connecter';
      } else {
        errorMessage = e.message;
      }
      _showSnackBar(errorMessage, AppColors.error);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Erreur: ${e.toString().replaceAll('Exception: ', '')}', AppColors.error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showRegisterModal() {
    HapticFeedback.mediumImpact();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Fermer',
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 280),
      transitionBuilder: (context, anim1, anim2, child) {
        final curved = CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: Tween<double>(begin: 0.88, end: 1.0).animate(curved),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
      pageBuilder: (context, anim1, anim2) {
        return const _RegisterRoleModal();
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.removeListener(_onEmailFocusChange);
    _passwordFocusNode.removeListener(_onPasswordFocusChange);
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                _buildHeader(),
                const SizedBox(height: 48),
                _buildEmailField(),
                const SizedBox(height: 16),
                _buildPasswordField(),
                const SizedBox(height: 12),
                _buildRememberMe(),
                const SizedBox(height: 20),
                _buildLoginButton(),
                const SizedBox(height: 12),
                _buildForgotPasswordLink(),
                const SizedBox(height: 20),
                _buildDivider(),
                const SizedBox(height: 20),
                _buildSignUpSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Connexion', style: AppTextStyles.headline1),
        const SizedBox(height: 8),
        Text(
          'Connectez-vous pour continuer',
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Email', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          focusNode: _emailFocusNode,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onChanged: _validateEmail,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(
            hintText: 'votre.email@exemple.com',
            hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.textHint),
            prefixIcon: Icon(
              Icons.email_outlined,
              color: _emailFocusNode.hasFocus ? AppColors.primary : AppColors.textSecondary,
            ),
            suffixIcon: _emailTouched
                ? Icon(
                    _emailValid ? Icons.check_circle : Icons.error,
                    color: _emailValid ? AppColors.success : AppColors.error,
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: BorderSide(
                color: _getBorderColor(
                  touched: _emailTouched,
                  valid: _emailValid,
                  hasFocus: _emailFocusNode.hasFocus,
                  error: _emailError,
                ),
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: BorderSide(
                color: _getBorderColor(
                  touched: _emailTouched,
                  valid: _emailValid,
                  hasFocus: false,
                  error: _emailError,
                ),
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: _emailError != null && _emailTouched,
            fillColor: AppColors.error.withValues(alpha: 0.05),
          ),
        ),
        if (_emailTouched) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                _emailValid ? Icons.check_circle : Icons.error,
                size: 16,
                color: _emailValid ? AppColors.success : AppColors.error,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _emailError ?? 'Adresse email valide',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _emailValid ? AppColors.success : AppColors.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mot de passe', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          focusNode: _passwordFocusNode,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          onChanged: _validatePassword,
          onFieldSubmitted: (_) => _handleLogin(),
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Entrez votre mot de passe',
            hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.textHint),
            prefixIcon: Icon(
              Icons.lock_outlined,
              color: _passwordFocusNode.hasFocus ? AppColors.primary : AppColors.textSecondary,
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_passwordTouched)
                  Icon(
                    _passwordValid ? Icons.check_circle : Icons.error,
                    color: _passwordValid ? AppColors.success : AppColors.error,
                    size: 20,
                  ),
                IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ],
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: BorderSide(
                color: _getBorderColor(
                  touched: _passwordTouched,
                  valid: _passwordValid,
                  hasFocus: _passwordFocusNode.hasFocus,
                  error: _passwordError,
                ),
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: BorderSide(
                color: _getBorderColor(
                  touched: _passwordTouched,
                  valid: _passwordValid,
                  hasFocus: false,
                  error: _passwordError,
                ),
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: _passwordError != null && _passwordTouched,
            fillColor: AppColors.error.withValues(alpha: 0.05),
          ),
        ),
        if (_passwordTouched) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                _passwordValid ? Icons.check_circle : Icons.error,
                size: 16,
                color: _passwordValid ? AppColors.success : AppColors.error,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _passwordError ?? 'Mot de passe conforme',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _passwordValid ? AppColors.success : AppColors.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildRememberMe() {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _rememberMe,
            onChanged: (value) => setState(() => _rememberMe = value ?? false),
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Se souvenir de moi',
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    final canLogin = _emailValid && _passwordValid && !_loading;
    return InggoButton(
      label: 'Se connecter',
      onPressed: canLogin ? _handleLogin : null,
      isLoading: _loading,
    );
  }

  Widget _buildForgotPasswordLink() {
    return Center(
      child: TextButton(
        onPressed: () {
          // TODO: Forgot password flow
        },
        child: Text(
          'Mot de passe oublié ?',
          style: AppTextStyles.button.copyWith(color: AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OU',
            style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }

  Widget _buildSignUpSection() {
    return Column(
      children: [
        Text(
          "Vous n'avez pas de compte ?",
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        InggoButton(
          label: 'Créer un compte',
          onPressed: _showRegisterModal,
          type: InggoButtonType.outline,
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════
//  MODAL GLASSMORPHISM — Choix du type de compte
// ══════════════════════════════════════════════════════════

class _RegisterRoleModal extends StatelessWidget {
  const _RegisterRoleModal();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.8),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 40,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
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
                Text('Créer un compte', style: AppTextStyles.headline3),
                const SizedBox(height: 6),
                Text('Choisissez votre profil', style: AppTextStyles.bodySmall),
                const SizedBox(height: 24),
                // Passager
                _RoleOption(
                  icon: Icons.person_rounded,
                  iconBg: AppColors.background,
                  iconColor: AppColors.textSecondary,
                  title: 'Passager',
                  subtitle: 'Commandez une course',
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).pop();
                    context.go('/register-client');
                  },
                ),
                const SizedBox(height: 12),
                // Conducteur
                _RoleOption(
                  icon: Icons.two_wheeler_rounded,
                  iconBg: AppColors.primaryLight,
                  iconColor: AppColors.primaryDark,
                  title: 'Conducteur',
                  subtitle: 'Rejoignez la flotte Inggo',
                  highlightBorder: true,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).pop();
                    context.go('/register-driver');
                  },
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Text(
                    'Annuler',
                    style: AppTextStyles.button.copyWith(color: AppColors.textHint),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleOption extends StatefulWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool highlightBorder;
  final VoidCallback onTap;

  const _RoleOption({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.highlightBorder = false,
  });

  @override
  State<_RoleOption> createState() => _RoleOptionState();
}

class _RoleOptionState extends State<_RoleOption> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: widget.highlightBorder ? AppColors.primary : AppColors.border,
              width: widget.highlightBorder ? 2.0 : 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: widget.iconBg,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(widget.icon, color: widget.iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(widget.subtitle, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: widget.highlightBorder ? AppColors.primary : AppColors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
