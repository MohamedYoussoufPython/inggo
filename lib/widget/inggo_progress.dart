import 'package:flutter/material.dart';
import '../core/theme/inggo_theme.dart';

class InggoProgressBar extends StatelessWidget {
  final double value;
  final String? label;
  final String? valueLabel;
  final Color? color;
  final bool showPercentage;

  const InggoProgressBar({
    super.key,
    required this.value,
    this.label,
    this.valueLabel,
    this.color,
    this.showPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (value * 100).clamp(0, 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null || valueLabel != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (label != null)
                  Text(
                    label!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: InggoColors.text2,
                      fontFamily: InggoTextStyles.fontFamily,
                    ),
                  ),
                if (valueLabel != null)
                  Text(
                    valueLabel!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: InggoColors.text1,
                      fontFamily: InggoTextStyles.fontFamily,
                    ),
                  )
                else if (showPercentage)
                  Text(
                    '${percentage.toInt()}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: InggoColors.text1,
                      fontFamily: InggoTextStyles.fontFamily,
                    ),
                  ),
              ],
            ),
          ),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: InggoColors.border1,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value.clamp(0, 1),
            child: Container(
              decoration: BoxDecoration(
                color: color ?? InggoColors.primary,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class InggoLinearProgress extends StatelessWidget {
  final double value;
  final Color? color;
  final Color? backgroundColor;
  final double height;

  const InggoLinearProgress({
    super.key,
    required this.value,
    this.color,
    this.backgroundColor,
    this.height = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? InggoColors.border1,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value.clamp(0, 1),
        child: Container(
          decoration: BoxDecoration(
            color: color ?? InggoColors.primary,
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }
}
