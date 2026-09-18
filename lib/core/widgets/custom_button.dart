import 'package:flutter/material.dart';

/// Enum representing the position of the icon in the button.
enum IconPosition { left, right }

/// A customizable button widget for the Crop Analyzer app.
/// Supports solid, outlined, and gradient styles with loading and icon support.
class CustomButton extends StatelessWidget {
  /// Button text.
  final String text;

  /// Callback when the button is pressed.
  final VoidCallback? onPressed;

  /// Optional icon displayed beside the text.
  final IconData? icon;

  /// Background color of the button.
  final Color? backgroundColor;

  /// Foreground color for text and icon.
  final Color? foregroundColor;

  /// Border color for outlined style.
  final Color? borderColor;

  /// Border width.
  final double borderWidth;

  /// Border radius.
  final double borderRadius;

  /// Padding inside the button.
  final EdgeInsets padding;

  /// Elevation (shadow depth).
  final double elevation;

  /// Button width (full width if null).
  final double? width;

  /// Button height.
  final double? height;

  /// Font size of the text.
  final double fontSize;

  /// Font weight of the text.
  final FontWeight fontWeight;

  /// Whether to show a loading indicator.
  final bool isLoading;

  /// Whether the button is outlined.
  final bool isOutlined;

  /// Whether the button is disabled.
  final bool isDisabled;

  /// Optional background gradient.
  final Gradient? gradient;

  /// Position of the icon (left or right).
  final IconPosition iconPosition;

  /// Color of the loading indicator.
  final Color? loadingColor;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth = 0,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    this.elevation = 2.0,
    this.width,
    this.height,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.w600,
    this.isLoading = false,
    this.isOutlined = false,
    this.isDisabled = false,
    this.gradient,
    this.iconPosition = IconPosition.left,
    this.loadingColor,
  }) : super(key: key);

  /// Builds the button content (icon + text or loading indicator).
  Widget _buildContent(BuildContext context) {
    final effectiveForegroundColor =
        foregroundColor ?? Theme.of(context).colorScheme.onPrimary;

    if (isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(
            loadingColor ?? effectiveForegroundColor,
          ),
        ),
      );
    }

    final textWidget = Text(
      text,
      style: TextStyle(
        color: effectiveForegroundColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
      overflow: TextOverflow.ellipsis,
    );

    if (icon == null) return textWidget;

    final iconWidget = Icon(
      icon,
      color: effectiveForegroundColor,
      size: fontSize + 2,
    );

    final children = iconPosition == IconPosition.left
        ? [iconWidget, const SizedBox(width: 8), textWidget]
        : [textWidget, const SizedBox(width: 8), iconWidget];

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  /// Builds the button style for solid or outlined mode.
  ButtonStyle _buildButtonStyle(BuildContext context) {
    final effectiveBackgroundColor =
        backgroundColor ?? Theme.of(context).primaryColor;
    final effectiveForegroundColor =
        foregroundColor ?? Theme.of(context).colorScheme.onPrimary;
    final effectiveBorderColor =
        borderColor ?? Theme.of(context).primaryColor;

    if (isOutlined) {
      return OutlinedButton.styleFrom(
        foregroundColor: effectiveForegroundColor,
        side: BorderSide(color: effectiveBorderColor, width: borderWidth),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: padding,
      );
    }

    return ElevatedButton.styleFrom(
      foregroundColor: effectiveForegroundColor,
      backgroundColor: gradient == null ? effectiveBackgroundColor : Colors.transparent,
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      padding: padding,
    );
  }

  /// Builds the gradient background if provided.
  Widget _buildGradientBackground(Widget child) {
    if (gradient == null) return child;

    return Ink(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed =
    (isDisabled || isLoading) ? null : onPressed;

    final buttonChild = _buildContent(context);

    final button = isOutlined
        ? OutlinedButton(
      onPressed: effectiveOnPressed,
      style: _buildButtonStyle(context),
      child: buttonChild,
    )
        : ElevatedButton(
      onPressed: effectiveOnPressed,
      style: _buildButtonStyle(context),
      child: buttonChild,
    );

    final decoratedButton = _buildGradientBackground(button);

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: Material(
        elevation: isOutlined ? 0 : elevation,
        borderRadius: BorderRadius.circular(borderRadius),
        color: Colors.transparent,
        child: decoratedButton,
      ),
    );
  }
}