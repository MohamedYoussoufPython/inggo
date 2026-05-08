import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/constants/constants.dart';

class LanguageSelector extends StatelessWidget {
  final String currentLanguage;
  final ValueChanged<String> onLanguageChanged;

  const LanguageSelector({
    super.key,
    required this.currentLanguage,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _option('Français', 'fr', currentLanguage == 'fr', onLanguageChanged),
        SizedBox(width: 12.w),
        _option('English', 'en', currentLanguage == 'en', onLanguageChanged),
      ],
    );
  }

  Widget _option(
      String label, String code, bool selected, ValueChanged<String> onChanged) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(code),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: selected ? AppColors.secondary : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
