import 'package:flutter/material.dart';

/// A custom stepper widget with two variants:
/// - `circles`: Numbered circles connected by a line (register_custom style)
/// - `linear`: A simple progress bar (register_driver style)
enum StepperVariant { circles, linear }

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
    if (variant == StepperVariant.linear) {
      return _buildLinear();
    }
    return _buildCircles();
  }

  Widget _buildLinear() {
    final progress = currentStep / totalSteps;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: SizedBox(
              height: 4,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return LinearProgressIndicator(
                    value: value,
                    backgroundColor: const Color(0xFFF0F0F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFFFC107),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircles() {
    final progressPercent =
        totalSteps > 1 ? (currentStep - 1) / (totalSteps - 1) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: SizedBox(
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background line
            Positioned(
              left: 30,
              right: 30,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ),
            // Active line (animated)
            Positioned(
              left: 30,
              right: 30,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progressPercent),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return Container(
                          height: 3,
                          width: constraints.maxWidth * value,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC107),
                            borderRadius: BorderRadius.circular(1.5),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            // Step circles
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(totalSteps, (index) {
                final stepNum = index + 1;
                final isActive = stepNum == currentStep;
                final isCompleted = stepNum < currentStep;
                return _StepCircle(
                  number: stepNum,
                  isActive: isActive,
                  isCompleted: isCompleted,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  final int number;
  final bool isActive;
  final bool isCompleted;

  const _StepCircle({
    required this.number,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Widget child;

    if (isCompleted) {
      bgColor = const Color(0xFFFFC107);
      textColor = Colors.white;
      child = const Icon(Icons.check, color: Colors.white, size: 16);
    } else if (isActive) {
      bgColor = const Color(0xFF121212);
      textColor = Colors.white;
      child = Text(
        '$number',
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w800,
          fontFamily: 'Roboto',
        ),
      );
    } else {
      bgColor = const Color(0xFFF0F0F0);
      textColor = const Color(0xFF757575);
      child = Text(
        '$number',
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          fontFamily: 'Roboto',
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Center(child: child),
    );
  }
}
