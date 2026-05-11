import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';

enum StepperVariant { circles, bars }

class InggoStepper extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final StepperVariant variant;

  const InggoStepper({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.variant = StepperVariant.circles,
  });

  @override
  Widget build(BuildContext context) {
    if (variant == StepperVariant.bars) return _buildBars();
    return _buildCircles();
  }

  Widget _buildCircles() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(totalSteps, (index) {
          final stepNumber = index + 1;
          final isActive = stepNumber <= currentStep;
          final isCurrent = stepNumber == currentStep;

          return Expanded(
            child: Row(
              children: [
                // Circle
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? AppColors.secondary : AppColors.border,
                    border: isCurrent
                        ? Border.all(color: AppColors.primary, width: 3)
                        : null,
                  ),
                  child: Center(
                    child: isActive
                        ? const Icon(Icons.check, size: 16, color: AppColors.primary)
                        : Text(
                            '$stepNumber',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textHint,
                            ),
                          ),
                  ),
                ),
                // Connector line
                if (index < totalSteps - 1)
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: stepNumber < currentStep
                            ? AppColors.secondary
                            : AppColors.border,
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(totalSteps, (index) {
          final stepNumber = index + 1;
          final isActive = stepNumber <= currentStep;

          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 3),
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
