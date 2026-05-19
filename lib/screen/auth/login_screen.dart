import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/constants.dart';
import '../../core/router/app_router.dart';
import '../../l10n/app_localizations.dart';
import '../../widget/widgets.dart';
import '../../provider/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late FocusNode _emailFocusNode;
  late FocusNode _passwordFocusNode;

  bool _obscurePassword = true;
  bool _loading = false;

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
    final loc = AppLocalizations.of(context);
    setState(() {
      _emailTouched = true;
      if (value.isEmpty) {
        _emailError = loc.errorEmailRequired;
        _emailValid = false;
      } else if (!_isValidEmail(value)) {
        _emailError = loc.errorEmailInvalidFormat;
        _emailValid = false;
      } else {
        _emailError = null;
        _emailValid = true;
      }
    });
  }

  void _validatePassword(String value) {
    final loc = AppLocalizations.of(context);
    setState(() {
      _passwordTouched = true;
      if (value.isEmpty) {
        _passwordError = loc.errorPasswordRequired;
        _passwordValid = false;
      } else if (value.length < 6) {
        _passwordError = loc.errorPasswordMinLength;
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
    final variant = backgroundColor == AppColors.error ? ToastVariant.error
        : backgroundColor == AppColors.success ? ToastVariant.success
        : backgroundColor == AppColors.warning ? ToastVariant.warning
        : ToastVariant.dark;
    InggoToast.show(context, message, variant: variant);
  }

  Future<void> _handleLogin() async {
    final loc = AppLocalizations.of(context);
    if (_loginAttempts >= _maxLoginAttempts) {
      _showSnackBar(
        loc.tooManyAttempts,
        AppColors.error,
      );
      return;
    }
    if (!_emailValid || !_passwordValid) {
      _showSnackBar(loc.fixErrorsFirst, AppColors.warning);
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
      if (response.session == null) throw Exception(loc.incorrectCredentials);

      final user = response.user;

      // Refresh AuthProvider so the whole app knows about the logged-in user
      await ref.read(authProvider.notifier).refreshAfterLogin();

      if (!mounted) return;

      // Get profile for role
      final profileData = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', user!.id)
          .maybeSingle();

      if (!mounted) return;

      final role = profileData?['role'] ?? 'client';

      // Cache the role for the router's redirect logic
      AppRouter.setCachedRole(role);

      _showSnackBar(loc.loginSuccess, AppColors.success);
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
      String errorMessage = loc.loginError;
      if (e.message.contains('Invalid login credentials')) {
        errorMessage = loc.invalidEmailOrPassword;
      } else if (e.message.contains('Email not confirmed')) {
        errorMessage = loc.confirmEmailFirst;
      } else {
        errorMessage = e.message;
      }
      _showSnackBar(errorMessage, AppColors.error);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('${loc.error}: ${e.toString().replaceAll('Exception: ', '')}', AppColors.error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showRegisterModal() {
    final loc = AppLocalizations.of(context);
    HapticFeedback.mediumImpact();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: loc.close,
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
    final loc = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(loc.loginTitle, style: AppTextStyles.headline1),
        const SizedBox(height: 8),
        Text(
          loc.loginSubtitle,
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    final loc = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(loc.email, style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          focusNode: _emailFocusNode,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onChanged: _validateEmail,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(
            hintText: loc.emailHint,
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
                  _emailError ?? loc.emailValid,
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
    final loc = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(loc.password, style: AppTextStyles.labelMedium),
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
            hintText: loc.passwordHint,
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
                  _passwordError ?? loc.passwordValid,
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

  Widget _buildLoginButton() {
    final loc = AppLocalizations.of(context);
    final canLogin = _emailValid && _passwordValid && !_loading;
    return InggoButton(
      label: loc.loginButton,
      onPressed: canLogin ? _handleLogin : null,
      isLoading: _loading,
    );
  }

  Widget _buildForgotPasswordLink() {
    final loc = AppLocalizations.of(context);
    return Center(
      child: InggoButton(
        label: loc.forgotPassword,
        type: InggoButtonType.text,
        onPressed: () {
          _showForgotPasswordDialog();
        },
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    bool isSending = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final loc = AppLocalizations.of(ctx);
          return AlertDialog(
            title: Text(loc.forgotPasswordTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  loc.forgotPasswordMessage,
                  style: const TextStyle(fontSize: 14, color: AppColors.greyMedium),
                ),
                const SizedBox(height: 16),
                InggoInput(
                  hint: loc.emailHint,
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                ),
              ],
            ),
            actions: [
              InggoButton(
                label: loc.cancel,
                type: InggoButtonType.ghost,
                onPressed: () => Navigator.pop(ctx),
              ),
              InggoButton(
                label: loc.send,
                type: InggoButtonType.primary,
                isLoading: isSending,
                onPressed: isSending
                    ? null
                    : () async {
                        final email = emailController.text.trim();
                        if (email.isEmpty || !_isValidEmail(email)) {
                          return;
                        }
                        setDialogState(() => isSending = true);
                        try {
                          await Supabase.instance.client.auth.resetPasswordForEmail(email);
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            _showSnackBar(
                              loc.resetEmailSent,
                              AppColors.success,
                            );
                          }
                        } catch (e) {
                          if (ctx.mounted) {
                            setDialogState(() => isSending = false);
                            Navigator.pop(ctx);
                            _showSnackBar(
                            '${loc.error}: ${e.toString()}',
                              AppColors.error,
                            );
                          }
                        }
                      },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDivider() {
    final loc = AppLocalizations.of(context);
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            loc.or,
            style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }

  Widget _buildSignUpSection() {
    final loc = AppLocalizations.of(context);
    return Column(
      children: [
        Text(
          loc.noAccount,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        InggoButton(
          label: loc.createAccount,
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
    final loc = AppLocalizations.of(context);
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
                Text(loc.createAccount, style: AppTextStyles.headline3),
                const SizedBox(height: 6),
                Text(loc.chooseRole, style: AppTextStyles.bodySmall),
                const SizedBox(height: 24),
                // Passager
                _RoleOption(
                  icon: Icons.person_rounded,
                  iconBg: AppColors.background,
                  iconColor: AppColors.textSecondary,
                  title: loc.passenger,
                  subtitle: loc.orderRide,
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
                  title: loc.conductor,
                  subtitle: loc.joinFleet,
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
                    loc.cancel,
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
