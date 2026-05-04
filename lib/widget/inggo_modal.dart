import 'package:flutter/material.dart';
import '../theme/inggo_theme.dart';
import 'inggo_button.dart';

Future<T?> showInggoModal<T>({
  required BuildContext context,
  required String title,
  required Widget content,
  List<Widget>? actions,
  Color? titleColor,
  bool dismissible = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    barrierLabel: 'InggoModal',
    barrierColor: Colors.black.withValues(alpha: 0.08),
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (context, a1, a2, child) {
      return Transform.scale(
        scale: Curves.easeOutBack.transform(a1.value),
        child: Opacity(
          opacity: a1.value,
          child: child,
        ),
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: InggoColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(InggoSpacing.lg),
                topRight: Radius.circular(InggoSpacing.lg),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF1A1A1A),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: InggoColors.border1,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: InggoColors.text1,
                        fontFamily: InggoTextStyles.fontFamily,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: content,
                  ),
                  if (actions != null && actions.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: Row(
                        children: [
                          for (int i = 0; i < actions.length; i++) ...[
                            if (i > 0) const SizedBox(width: 10),
                            Expanded(child: actions[i]),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Future<T?> showInggoCenterModal<T>({
  required BuildContext context,
  required String title,
  required Widget content,
  List<Widget>? actions,
  Color? titleColor,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'InggoCenterModal',
    barrierColor: Colors.black.withValues(alpha: 0.7),
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (context, a1, a2, child) {
      return Transform.scale(
        scale: Curves.easeOutBack.transform(a1.value),
        child: Opacity(
          opacity: a1.value,
          child: child,
        ),
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            constraints: const BoxConstraints(maxWidth: 320),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            decoration: BoxDecoration(
              color: InggoColors.surface,
              borderRadius: BorderRadius.circular(InggoSpacing.lg),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: titleColor ?? InggoColors.text1,
                    fontFamily: InggoTextStyles.fontFamily,
                  ),
                ),
                const SizedBox(height: 16),
                content,
                if (actions != null && actions.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      for (int i = 0; i < actions.length; i++) ...[
                        if (i > 0) const SizedBox(width: 10),
                        Expanded(child: actions[i]),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    },
  );
}

class InggoModalButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isOutline;
  final bool isLoading;

  const InggoModalButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.isOutline = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InggoButton(
      label: label,
      onPressed: onPressed,
      fullWidth: true,
      size: InggoButtonSize.medium,
      isLoading: isLoading,
      variant: isOutline
          ? InggoButtonVariant.outline
          : (backgroundColor == InggoColors.errorLight
              ? InggoButtonVariant.danger
              : InggoButtonVariant.primary),
    );
  }
}
