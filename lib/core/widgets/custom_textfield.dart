import 'package:flutter/material.dart';

/// CustomTextField widget for the Crop Analyzer app.
/// Provides a flexible, styled, and feature-rich text input field
/// with validation, icons, password toggle, and customization options.
class CustomTextField extends StatefulWidget {
  /// Text controller for managing input text.
  final TextEditingController? controller;

  /// Label text displayed above the field.
  final String? label;

  /// Hint text displayed inside the field.
  final String? hint;

  /// Prefix icon displayed at the start of the field.
  final IconData? prefixIcon;

  /// Suffix icon displayed at the end of the field.
  final IconData? suffixIcon;

  /// Callback when suffix icon is pressed.
  final VoidCallback? onSuffixIconPressed;

  /// Keyboard type for the input field.
  final TextInputType keyboardType;

  /// Whether to obscure text (for passwords).
  final bool obscureText;

  /// Whether the field is enabled.
  final bool enabled;

  /// Whether the field is read-only.
  final bool readOnly;

  /// Maximum number of lines.
  final int? maxLines;

  /// Minimum number of lines.
  final int? minLines;

  /// Maximum character length.
  final int? maxLength;

  /// Validation function for form validation.
  final String? Function(String?)? validator;

  /// Callback when text changes.
  final Function(String)? onChanged;

  /// Callback when text is submitted.
  final Function(String)? onSubmitted;

  /// Border radius of the field.
  final double borderRadius;

  /// Border color when not focused.
  final Color? borderColor;

  /// Border color when focused.
  final Color? focusedBorderColor;

  /// Border color when error occurs.
  final Color? errorBorderColor;

  /// Background fill color.
  final Color? fillColor;

  /// Text style for input text.
  final TextStyle? textStyle;

  /// Text style for label.
  final TextStyle? labelStyle;

  /// Text style for hint.
  final TextStyle? hintStyle;

  /// Padding inside the field.
  final EdgeInsets? contentPadding;

  /// Whether to show character counter.
  final bool showCounter;

  /// Whether to autofocus the field.
  final bool autofocus;

  /// Text capitalization behavior.
  final TextCapitalization textCapitalization;

  const CustomTextField({
    Key? key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.borderRadius = 8.0,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.fillColor,
    this.textStyle,
    this.labelStyle,
    this.hintStyle,
    this.contentPadding,
    this.showCounter = false,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  /// Toggles password visibility.
  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  /// Builds the suffix icon widget.
  Widget? _buildSuffixIcon() {
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: _focusNode.hasFocus
              ? (widget.focusedBorderColor ?? Theme.of(context).primaryColor)
              : Colors.grey,
        ),
        onPressed: _toggleObscureText,
      );
    }

    if (widget.suffixIcon != null) {
      return IconButton(
        icon: Icon(
          widget.suffixIcon,
          color: _focusNode.hasFocus
              ? (widget.focusedBorderColor ?? Theme.of(context).primaryColor)
              : Colors.grey,
        ),
        onPressed: widget.onSuffixIconPressed,
      );
    }

    return null;
  }

  /// Builds the prefix icon widget.
  Widget? _buildPrefixIcon() {
    if (widget.prefixIcon == null) return null;
    return Icon(
      widget.prefixIcon,
      color: _focusNode.hasFocus
          ? (widget.focusedBorderColor ?? Theme.of(context).primaryColor)
          : Colors.grey,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveBorderColor =
        widget.borderColor ?? Colors.grey.shade400;
    final effectiveFocusedBorderColor =
        widget.focusedBorderColor ?? theme.primaryColor;
    final effectiveErrorBorderColor =
        widget.errorBorderColor ?? Colors.red.shade600;
    final effectiveFillColor =
        widget.fillColor ?? Colors.grey.shade100;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      borderSide: BorderSide(color: effectiveBorderColor, width: 1.2),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      borderSide: BorderSide(color: effectiveFocusedBorderColor, width: 1.5),
    );

    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      borderSide: BorderSide(color: effectiveErrorBorderColor, width: 1.5),
    );

    return Focus(
      focusNode: _focusNode,
      onFocusChange: (_) => setState(() {}),
      child: TextFormField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        obscureText: _obscureText,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        maxLength: widget.maxLength,
        validator: widget.validator,
        onChanged: widget.onChanged,
        onFieldSubmitted: widget.onSubmitted,
        autofocus: widget.autofocus,
        textCapitalization: widget.textCapitalization,
        style: widget.textStyle ??
            TextStyle(
              fontSize: 16,
              color: widget.enabled ? Colors.black87 : Colors.grey,
            ),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          prefixIcon: _buildPrefixIcon(),
          suffixIcon: _buildSuffixIcon(),
          filled: true,
          fillColor: effectiveFillColor,
          labelStyle: widget.labelStyle ??
              TextStyle(
                color: _focusNode.hasFocus
                    ? effectiveFocusedBorderColor
                    : Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
          hintStyle: widget.hintStyle ??
              TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
          contentPadding: widget.contentPadding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: border,
          focusedBorder: focusedBorder,
          errorBorder: errorBorder,
          focusedErrorBorder: errorBorder,
          counterText: widget.showCounter ? null : '',
        ),
      ),
    );
  }
}

