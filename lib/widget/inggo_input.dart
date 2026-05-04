import 'package:flutter/material.dart';
import '../theme/inggo_theme.dart';

class InggoInput extends StatefulWidget {
  final String? label;
  final String placeholder;
  final TextEditingController? controller;
  final String? errorText;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscureText;
  final bool showToggleVisibility;
  final TextInputType keyboardType;
  final int? maxLength;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final bool enabled;

  const InggoInput({
    super.key,
    this.label,
    required this.placeholder,
    this.controller,
    this.errorText,
    this.hintText,
    this.prefixIcon,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.showToggleVisibility = false,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.readOnly = false,
    this.onChanged,
    this.validator,
    this.enabled = true,
  });

  @override
  State<InggoInput> createState() => _InggoInputState();
}

class _InggoInputState extends State<InggoInput> {
  bool _obscured = true;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              widget.label!.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: InggoColors.text2,
                letterSpacing: 0.04,
                fontFamily: InggoTextStyles.fontFamily,
              ),
            ),
          ),
        ],
        Focus(
          onFocusChange: (focused) => setState(() => _focused = focused),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: hasError
                  ? const Color(0xFFfff8f8)
                  : _focused
                      ? InggoColors.surface
                      : InggoColors.surface,
              borderRadius: BorderRadius.circular(InggoSpacing.sm),
              border: Border.all(
                color: hasError
                    ? InggoColors.error
                    : _focused
                        ? InggoColors.primary
                        : InggoColors.border1,
                width: hasError ? 1.5 : 1,
              ),
              boxShadow: _focused && !hasError
                  ? [
                      BoxShadow(
                        color: InggoColors.primary.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 0),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                if (widget.prefix != null) widget.prefix!,
                if (widget.prefixIcon != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Icon(
                      widget.prefixIcon,
                      color: InggoColors.text3,
                      size: 20,
                    ),
                  ),
                Expanded(
                  child: TextFormField(
                    controller: widget.controller,
                    obscureText: widget.showToggleVisibility
                        ? _obscured
                        : widget.obscureText,
                    keyboardType: widget.keyboardType,
                    maxLength: widget.maxLength,
                    readOnly: widget.readOnly,
                    onChanged: widget.onChanged,
                    validator: widget.validator,
                    enabled: widget.enabled,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: InggoColors.text1,
                      fontFamily: InggoTextStyles.fontFamily,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.placeholder,
                      hintStyle: TextStyle(
                        color: InggoColors.text3,
                        fontWeight: FontWeight.w400,
                        fontFamily: InggoTextStyles.fontFamily,
                      ),
                      prefixIcon: widget.prefixIcon != null ? null : null,
                      suffixIcon: widget.suffix ??
                          (widget.showToggleVisibility
                              ? GestureDetector(
                                  onTap: () =>
                                      setState(() => _obscured = !_obscured),
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 14),
                                    child: Icon(
                                      _obscured
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: InggoColors.text3,
                                      size: 20,
                                    ),
                                  ),
                                )
                              : null),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal:
                            widget.prefixIcon != null || widget.prefix != null
                                ? 0
                                : 14,
                        vertical: 14,
                      ),
                      counterText: '',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (hasError) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 6),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: InggoColors.error,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.errorText!,
                  style: TextStyle(
                    color: InggoColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: InggoTextStyles.fontFamily,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (widget.hintText != null && !hasError) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 6),
            child: Text(
              widget.hintText!,
              style: TextStyle(
                color: InggoColors.text3,
                fontSize: 12,
                fontFamily: InggoTextStyles.fontFamily,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class InggoPhoneInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final String countryCode;
  final String countryFlag;

  const InggoPhoneInput({
    super.key,
    this.controller,
    this.errorText,
    this.onChanged,
    this.countryCode = '+253',
    this.countryFlag = '🇩🇯',
  });

  @override
  Widget build(BuildContext context) {
    return InggoInput(
      label: 'Téléphone',
      placeholder: '77 XX XX XX',
      controller: controller,
      errorText: errorText,
      onChanged: onChanged,
      keyboardType: TextInputType.phone,
      maxLength: 8,
      prefix: Container(
        padding: const EdgeInsets.only(left: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              countryFlag,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 8),
            Text(
              countryCode,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: InggoColors.text1,
              ),
            ),
            Container(
              width: 1,
              height: 20,
              color: InggoColors.border1,
              margin: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ],
        ),
      ),
    );
  }
}
