import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/constants.dart';
import '../../core/utils/formatters.dart';
import '../../widget/widgets.dart';

class EndRideScreen extends StatelessWidget {
  const EndRideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 64.w, color: AppColors.success),
              SizedBox(height: 16.h),
              Text('Course terminée !', style: AppTextStyles.headline2),
              SizedBox(height: 24.h),
              InggoCard(
                child: Column(
                  children: [
                    _row('Prix total', Formatters.formatPrice(250)),
                    _row('Votre gain', Formatters.formatPrice(125)),
                    _row('Commission', Formatters.formatPrice(125)),
                    _row('Paiement', 'Espèces'),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'N\'oubliez pas de collecter les 250 FDJ du client.',
                style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.warning),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              InggoButton(
                label: 'Retour à l\'accueil',
                onPressed: () => context.go('/driver/home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Text(value, style: AppTextStyles.labelMedium),
        ],
      ),
    );
  }
}
