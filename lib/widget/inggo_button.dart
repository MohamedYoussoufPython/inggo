import 'package:flutter/material.dart';
import '../theme/inggo_theme.dart';

enum InggoButtonVariant { primary, primaryLight, outline, ghost, danger }

enum InggoButtonSize { small, medium, large }

class InggoButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final InggoButtonVariant variant;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool fullWidth;
  final InggoButtonSize size;
  final double? height;
  final double? borderRadius;

  const InggoButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = InggoButtonVariant.primary,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.fullWidth = true,
    this.size = InggoButtonSize.medium,
    this.height,
    this.borderRadius,
  });

  double get _height {
    if (height != null) return height!;
    switch (size) {
      case InggoButtonSize.small:
        return 34;
      case InggoButtonSize.medium:
        return 44;
      case InggoButtonSize.large:
        return 52;
    }
  }

  double get _fontSize {
    if (height != null) return 14;
    switch (size) {
      case InggoButtonSize.small:
        return 13;
      case InggoButtonSize.medium:
        return 14;
      case InggoButtonSize.large:
        return 16;
    }
  }

  double get _borderRadiusValue {
    if (borderRadius != null) return borderRadius!;
    switch (size) {
      case InggoButtonSize.small:
        return InggoSpacing.xs;
      case InggoButtonSize.medium:
        return InggoSpacing.sm;
      case InggoButtonSize.large:
        return InggoSpacing.md;
    }
  }

  @override
  State<InggoButton> createState() => _InggoButtonState();
}

class _InggoButtonState extends State<InggoButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Color _bgColor() {
    final isDisabled = widget.onPressed == null;
    switch (widget.variant) {
      case InggoButtonVariant.primary:
        return isDisabled
            ? InggoColors.primary.withValues(alpha: 0.5)
            : InggoColors.primary;
      case InggoButtonVariant.primaryLight:
        return isDisabled
            ? InggoColors.primaryLight.withValues(alpha: 0.5)
            : InggoColors.primaryLight;
      case InggoButtonVariant.outline:
        return isDisabled
            ? InggoColors.border1.withValues(alpha: 0.5)
            : InggoColors.surface;
      case InggoButtonVariant.ghost:
        return Colors.transparent;
      case InggoButtonVariant.danger:
        return isDisabled
            ? InggoColors.errorLight.withValues(alpha: 0.5)
            : InggoColors.errorLight;
    }
  }

  Color _textColor() {
    switch (widget.variant) {
      case InggoButtonVariant.primary:
        return InggoColors.text1;
      case InggoButtonVariant.primaryLight:
        return InggoColors.primaryDark;
      case InggoButtonVariant.outline:
        return InggoColors.text1;
      case InggoButtonVariant.ghost:
        return InggoColors.text2;
      case InggoButtonVariant.danger:
        return InggoColors.error;
    }
  }

  BoxBorder? _border() {
    switch (widget.variant) {
      case InggoButtonVariant.primary:
        return null;
      case InggoButtonVariant.primaryLight:
        return Border.all(color: InggoColors.primaryBorder, width: 1.5);
      case InggoButtonVariant.outline:
        return Border.all(color: InggoColors.border2, width: 1.5);
      case InggoButtonVariant.ghost:
        return null;
      case InggoButtonVariant.danger:
        return Border.all(color: Color(0xFFfecaca), width: 1);
    }
  }

  List<BoxShadow>? _shadow() {
    if (widget.variant == InggoButtonVariant.primary &&
        widget.onPressed != null) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 3,
          offset: const Offset(0, 1),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown:
            widget.onPressed != null ? (_) => _scaleController.forward() : null,
        onTapUp: widget.onPressed != null
            ? (_) {
                _scaleController.reverse();
                widget.onPressed?.call();
              }
            : null,
        onTapCancel:
            widget.onPressed != null ? () => _scaleController.reverse() : null,
        child: Container(
          width: widget.fullWidth ? double.infinity : null,
          height: widget._height,
          padding: EdgeInsets.symmetric(
            horizontal: widget.icon != null ? InggoSpacing.lg : InggoSpacing.xl,
          ),
          decoration: BoxDecoration(
            color: _bgColor(),
            borderRadius: BorderRadius.circular(widget._borderRadiusValue),
            border: _border(),
            boxShadow: _shadow(),
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _textColor(),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: _textColor(), size: 18),
                        const SizedBox(width: 7),
                      ],
                      Text(
                        widget.label,
                        style: TextStyle(
                          color: _textColor(),
                          fontSize: widget._fontSize,
                          fontWeight: FontWeight.w500,
                          fontFamily: InggoTextStyles.fontFamily,
                        ),
                      ),
                      if (widget.trailingIcon != null) ...[
                        const SizedBox(width: 7),
                        Icon(widget.trailingIcon,
                            color: _textColor(), size: 18),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class InggoIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final bool isOutlined;

  const InggoIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 44,
    this.isOutlined = false,
  });

  @override
  State<InggoIconButton> createState() => _InggoIconButtonState();
}

class _InggoIconButtonState extends State<InggoIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown:
            widget.onPressed != null ? (_) => _scaleController.forward() : null,
        onTapUp: widget.onPressed != null
            ? (_) {
                _scaleController.reverse();
                widget.onPressed?.call();
              }
            : null,
        onTapCancel:
            widget.onPressed != null ? () => _scaleController.reverse() : null,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.isOutlined
                ? InggoColors.surface
                : (widget.backgroundColor ?? InggoColors.primaryLight),
            borderRadius: BorderRadius.circular(InggoSpacing.sm),
            border: widget.isOutlined
                ? Border.all(color: InggoColors.primaryBorder, width: 1.5)
                : null,
          ),
          child: Center(
            child: Icon(
              widget.icon,
              color: widget.iconColor ?? InggoColors.text1,
              size: widget.size * 0.45,
            ),
          ),
        ),
      ),
    );
  }
}
