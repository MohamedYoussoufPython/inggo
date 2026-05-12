import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/constants.dart';
import '../../core/services/supabase_service.dart';
import '../../core/services/notification_service.dart';
import '../../widget/widgets.dart';

class PendingVerificationScreen extends StatefulWidget {
  const PendingVerificationScreen({super.key});

  @override
  State<PendingVerificationScreen> createState() =>
      _PendingVerificationScreenState();
}

class _PendingVerificationScreenState extends State<PendingVerificationScreen> {
  RealtimeChannel? _verificationChannel;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _subscribeToVerification();
  }

  /// Subscribe to Realtime changes on the drivers table for this user.
  /// When is_verified flips to true, auto-navigate to /driver/home.
  void _subscribeToVerification() {
    final userId = SupabaseService.instance.currentUserId;
    if (userId == null) return;

    _verificationChannel = SupabaseService.instance.subscribeToTable(
      'drivers',
      filterColumn: 'id',
      filterValue: userId,
      onChange: (payload) {
        final isVerified = payload.newRecord['is_verified'] as bool?;
        if (isVerified == true && mounted && !_navigated) {
          _navigated = true;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Votre profil a été approuvé ! Bienvenue.'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 3),
            ),
          );
          context.go('/driver/home');
        }
      },
    );
  }

  @override
  void dispose() {
    // Only unsubscribe if we navigated away (verification succeeded)
    // or if the widget is truly being destroyed.
    // If the user pressed "Compris" and went to /login, the subscription
    // stays alive in the background via the NotificationService pattern.
    // However, GoRouter disposes this widget when navigating away,
    // so we must clean up here. The verification will be checked
    // on the next login via the splash screen's role-based redirect.
    if (_verificationChannel != null) {
      SupabaseService.instance.unsubscribe(_verificationChannel!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              Text('En attente de vérification',
                  style: AppTextStyles.headline2,
                  textAlign: TextAlign.center),
              SizedBox(height: 12.h),
              Text(
                'Votre profil est en cours de vérification. Vous serez redirigé automatiquement une fois approuvé par notre équipe.',
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              Text(
                'Vous pouvez également vous déconnecter et attendre la vérification. Vous serez redirigé automatiquement à votre prochaine connexion.',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textHint),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              InggoButton(
                label: 'Compris',
                onPressed: () {
                  if (_navigated) return;
                  // Navigate to login screen. The Realtime subscription
                  // will be cleaned up in dispose(), but the verification
                  // status will be checked again on next login.
                  // The driver's is_verified status is checked in the
                  // splash screen redirect logic.
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
