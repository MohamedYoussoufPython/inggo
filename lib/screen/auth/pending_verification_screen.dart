import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/constants.dart';
import '../../l10n/app_localizations.dart';
import '../../provider/verification_provider.dart';
import '../../widget/widgets.dart';

class PendingVerificationScreen extends ConsumerStatefulWidget {
  const PendingVerificationScreen({super.key});

  @override
  ConsumerState<PendingVerificationScreen> createState() =>
      _PendingVerificationScreenState();
}

class _PendingVerificationScreenState
    extends ConsumerState<PendingVerificationScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    // Start the global verification listener (survives navigation)
    Future.microtask(() {
      ref.read(verificationProvider.notifier).startListening();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    // Listen for verification changes and auto-navigate
    ref.listen<VerificationState>(verificationProvider, (prev, next) {
      if (next.isVerified && mounted && !_navigated) {
        _navigated = true;
        // Stop listening since we're verified now
        ref.read(verificationProvider.notifier).stopListening();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.profileApproved),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
        context.go('/driver/home');
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hourglass_top,
                  size: 80.w, color: AppColors.primary),
              SizedBox(height: 24.h),
              Text(loc.awaitingVerification,
                  style: AppTextStyles.headline2,
                  textAlign: TextAlign.center),
              SizedBox(height: 12.h),
              Text(
                loc.verificationMessage,
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              Text(
                loc.verificationLogoutHint,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textHint),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              InggoButton(
                label: loc.understood,
                onPressed: () {
                  if (_navigated) return;
                  // Navigate to login screen. The verification subscription
                  // lives in the provider (not tied to this screen), so it
                  // continues listening in the background. When the driver
                  // logs back in after being verified, the splash screen
                  // redirect will send them to /driver/home.
                  //
                  // IMPORTANT: We do NOT call stopListening() here, so the
                  // Realtime subscription keeps running. If the driver is
                  // verified while on the login screen, the provider's state
                  // will update, and the next auth check will detect it.
                  context.go('/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
