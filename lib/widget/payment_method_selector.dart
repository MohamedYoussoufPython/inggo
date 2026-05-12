import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/constants/constants.dart';
import '../l10n/app_localizations.dart';
import '../core/services/payment_service.dart';

class PaymentMethodSelector extends StatefulWidget {
  final String selectedMethod;
  final ValueChanged<String> onMethodSelected;

  const PaymentMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onMethodSelected,
  });

  @override
  State<PaymentMethodSelector> createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends State<PaymentMethodSelector> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final methods = PaymentService.instance.getPaymentMethods(loc);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(loc.paymentMethod, style: AppTextStyles.labelLarge),
        SizedBox(height: 12.h),
        ...methods.map((m) => _PaymentItem(
              method: m,
              isSelected: widget.selectedMethod == m['id'],
              onTap: () {
                if (m['available'] == true) {
                  widget.onMethodSelected(m['id'] as String);
                }
              },
            )),
      ],
    );
  }
}

class _PaymentItem extends StatelessWidget {
  final Map<String, dynamic> method;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentItem({
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final available = method['available'] == true;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(method['icon'] as String, style: const TextStyle(fontSize: 24)),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method['name'] as String,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: available
                            ? AppColors.textPrimary
                            : AppColors.textHint,
                      )),
                  if (!available)
                    Text(loc.comingSoon, style: AppTextStyles.caption),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.primary, size: 24.w)
            else if (!available)
              Icon(Icons.lock_outline, color: AppColors.textHint, size: 20.w),
          ],
        ),
      ),
    );
  }
}
