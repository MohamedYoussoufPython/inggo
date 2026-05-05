import 'package:flutter/material.dart';
import '../theme/inggo_theme.dart';

enum InggoToastType { success, error, warning, info }

class InggoToast extends StatelessWidget {
  final String message;
  final InggoToastType type;
  final IconData? icon;

  const InggoToast({
    super.key,
    required this.message,
    this.type = InggoToastType.info,
    this.icon,
  });

  Color get _backgroundColor {
    switch (type) {
      case InggoToastType.success:
        return InggoColors.successLight;
      case InggoToastType.error:
        return InggoColors.errorLight;
      case InggoToastType.warning:
        return InggoColors.primaryLight;
      case InggoToastType.info:
        return InggoColors.text1;
    }
  }

  Color get _textColor {
    switch (type) {
      case InggoToastType.success:
        return InggoColors.successDark;
      case InggoToastType.error:
        return InggoColors.errorDark;
      case InggoToastType.warning:
        return InggoColors.primaryDark;
      case InggoToastType.info:
        return Colors.white;
    }
  }

  Color get _iconBackgroundColor {
    switch (type) {
      case InggoToastType.success:
        return InggoColors.success;
      case InggoToastType.error:
        return InggoColors.error;
      case InggoToastType.warning:
        return InggoColors.primary;
      case InggoToastType.info:
        return InggoColors.primary;
    }
  }

  IconData get _defaultIcon {
    switch (type) {
      case InggoToastType.success:
        return Icons.check;
      case InggoToastType.error:
        return Icons.close;
      case InggoToastType.warning:
        return Icons.warning_amber_rounded;
      case InggoToastType.info:
        return Icons.check;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(InggoSpacing.lg),
        border: type == InggoToastType.warning
            ? Border.all(color: InggoColors.primaryBorder)
            : (type == InggoToastType.success
                ? const Border.all(color: Color(0xFFbbf7d0))
                : (type == InggoToastType.error
                    ? const Border.all(color: Color(0xFFfecaca))
                    : null)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: _iconBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon ?? _defaultIcon,
                size: 14,
                color: type == InggoToastType.info
                    ? InggoColors.text1
                    : Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _textColor,
                fontFamily: InggoTextStyles.fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void showInggoToast(
  BuildContext context, {
  required String message,
  InggoToastType type = InggoToastType.info,
  IconData? icon,
  Duration duration = const Duration(seconds: 3),
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: InggoToast(
          message: message,
          type: type,
          icon: icon,
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(duration, () {
    overlayEntry.remove();
  });
}
