import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/constants.dart';
import '../../widget/widgets.dart';
import '../../provider/auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phone;

  const OtpScreen({super.key, required this.phone});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  int _countdown = AppConstants.otpTimeoutSeconds;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _canResend = false;
    _countdown = AppConstants.otpTimeoutSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
        if (_countdown <= 0) {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  void _resendOtp() {
    if (!_canResend) return;
    ref.read(authProvider.notifier).sendOtp(widget.phone);
    _startTimer();
  }

  void _onOtpCompleted(String otp) {
    ref.read(authProvider.notifier).verifyOtp(widget.phone, otp);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.isAuthenticated && prev?.isAuthenticated != true) {
        if (next.user != null) {
          if (next.user!.role.name == 'driver') {
            context.go('/driver/home');
          } else {
            context.go('/client/home');
          }
        } else {
          context.go('/role-selection');
        }
      }
      if (next.error != null && prev?.error != next.error) {
        InggoToast.error(context, next.error!);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 60.h),
              Text('Vérification', style: AppTextStyles.headline2),
              SizedBox(height: 8.h),
              Text(
                'Entrez le code envoyé au +253 ${widget.phone}',
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.textSecondary),
              ),
              SizedBox(height: 40.h),
              Center(
                child: InggoOtpInput(
                  onCompleted: _onOtpCompleted,
                ),
              ),
              SizedBox(height: 24.h),
              Center(
                child: _canResend
                    ? TextButton(
                        onPressed: _resendOtp,
                        child: Text('Renvoyer le code',
                            style: AppTextStyles.labelMedium
                                .copyWith(color: AppColors.primary)),
                      )
                    : Text(
                        'Renvoyer dans ${_countdown}s',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textHint),
                      ),
              ),
              SizedBox(height: 24.h),
              if (auth.isLoading) const Center(child: InggoLoading()),
            ],
          ),
        ),
      ),
    );
  }
}
