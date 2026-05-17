import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/constants/constants.dart';

/// Inggo VTC Design System — Sélecteur de genre v2.0
/// ♂ Homme / ♀ Femme · Actif = fond jaune + bordure jaune
class InggoGenderSelector extends StatefulWidget {
  final String? initialGender;
  final ValueChanged<String> onChanged;

  const InggoGenderSelector({
    super.key,
    this.initialGender,
    required this.onChanged,
  });

  @override
  State<InggoGenderSelector> createState() => _InggoGenderSelectorState();
}

class _InggoGenderSelectorState extends State<InggoGenderSelector> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialGender;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GenderOption(
            label: '♂ Homme',
            value: 'male',
            isSelected: _selected == 'male',
            onTap: () {
              setState(() => _selected = 'male');
              widget.onChanged('male');
            },
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _GenderOption(
            label: '♀ Femme',
            value: 'female',
            isSelected: _selected == 'female',
            onTap: () {
              setState(() => _selected = 'female');
              widget.onChanged('female');
            },
          ),
        ),
      ],
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderOption({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.headline4.copyWith(
              color: isSelected ? AppColors.textPrimary : AppColors.textHint,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
