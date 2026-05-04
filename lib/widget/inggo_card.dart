import 'package:flutter/material.dart';
import '../theme/inggo_theme.dart';

class InggoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool hasAccent;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const InggoCard({
    super.key,
    required this.child,
    this.padding,
    this.hasAccent = false,
    this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(InggoSpacing.lg),
        decoration: BoxDecoration(
          color: backgroundColor ?? InggoColors.surface,
          borderRadius: BorderRadius.circular(InggoSpacing.md),
          border: Border.all(
            color: hasAccent ? InggoColors.primary : InggoColors.border1,
            width: hasAccent ? 2 : 1,
          ),
          boxShadow: InggoShadows.level1,
        ),
        child: child,
      ),
    );
  }
}

class InggoIconCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconBackgroundColor;
  final VoidCallback? onTap;

  const InggoIconCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconBackgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InggoCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBackgroundColor ?? InggoColors.primaryLight,
              borderRadius: BorderRadius.circular(InggoSpacing.sm),
            ),
            child: Center(
              child: Icon(icon, size: 20, color: InggoColors.text1),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: InggoColors.text1,
              fontFamily: InggoTextStyles.fontFamily,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 3),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 13,
                color: InggoColors.text3,
                fontFamily: InggoTextStyles.fontFamily,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class InggoValueCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;
  final Color? valueColor;

  const InggoValueCard({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(InggoSpacing.lg),
      decoration: BoxDecoration(
        color: InggoColors.surface,
        borderRadius: BorderRadius.circular(InggoSpacing.md),
        border: const Border.all(color: InggoColors.border1),
      ),
      child: Column(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 24, color: valueColor ?? InggoColors.text1),
            const SizedBox(height: 8),
          ],
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: valueColor ?? InggoColors.text1,
              fontFamily: InggoTextStyles.fontFamily,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: InggoColors.text3,
              fontFamily: InggoTextStyles.fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}
