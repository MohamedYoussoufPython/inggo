import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/constants.dart';

enum StepperVariant { circles, bars }

/// InggoStepper — aligné sur le Design System
/// Circles: step number/✓ + label + connector line (done=yellow, active=yellow+glow, idle=grey)
/// Bars: segment bars (done=yellow, idle=grey)
class InggoStepper extends StatelessWidget {
  final int currentStep; // 1-based
  final int totalSteps;
  final StepperVariant variant;
  final List<String>? stepLabels;

  const InggoStepper({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.variant = StepperVariant.circles,
    this.stepLabels,
  });

  @override
  Widget build(BuildContext context) {
    if (variant == StepperVariant.bars) return _buildBars();
    return _buildCircles();
  }

  Widget _buildCircles() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Row(
        children: List.generate(totalSteps, (index) {
          final stepNumber = index + 1;
          final isDone = stepNumber < currentStep;
          final isActive = stepNumber == currentStep;
          final isIdle = stepNumber > currentStep;
          final label = stepLabels != null && index < stepLabels!.length
              ? stepLabels![index]
              : null;

          return Expanded(
            child: Row(
              children: [
                // Step item (circle + label)
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Circle
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone || isActive
                              ? AppColors.primary
                              : const Color(0xFFF0F0F0),
                          border: isIdle
                              ? Border.all(color: AppColors.border, width: 1.5)
                              : null,
                          boxShadow: isDone
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.2),
                                    blurRadius: 0,
                                    spreadRadius: 3,
                                  )
                                ]
                              : isActive
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primaryLight,
                                        blurRadius: 0,
                                        spreadRadius: 5,
                                      )
                                    ]
                                  : null,
                        ),
                        child: Center(
                          child: isDone
                              ? const Icon(Icons.check,
                                  size: 14, color: AppColors.textPrimary)
                              : Text(
                                  '$stepNumber',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: isIdle
                                        ? AppColors.textHint
                                        : AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                        ),
                      ),
                      // Label
                      if (label != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          label,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isActive
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontWeight:
                                isActive ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                // Connector line
                if (index < totalSteps - 1)
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 1.5,
                      margin: EdgeInsets.symmetric(horizontal: 10.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: isDone ? AppColors.primary : AppColors.border,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBars() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Row(
        children: List.generate(totalSteps, (index) {
          final stepNumber = index + 1;
          final isActive = stepNumber <= currentStep;

          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 6,
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: isActive ? AppColors.primary : AppColors.border,
              ),
            ),
          );
        }),
      ),
    );
  }
}
