import 'package:flutter/material.dart';

/// CustomAppBar widget for the Crop Analyzer app.
/// Provides a flexible, gradient-supported, and customizable AppBar
/// with title, subtitle, actions, and optional back button.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Main title text.
  final String title;

  /// Optional subtitle text displayed below the title.
  final String? subtitle;

  /// Optional leading widget (e.g., back button, menu icon).
  final Widget? leading;

  /// Optional list of action widgets displayed on the right side.
  final List<Widget>? actions;

  /// Background color of the AppBar.
  final Color? backgroundColor;

  /// Foreground color for text and icons.
  final Color? foregroundColor;

  /// Elevation (shadow depth) of the AppBar.
  final double elevation;

  /// Whether to center the title.
  final bool centerTitle;

  /// Whether to show a back button.
  final bool showBackButton;

  /// Callback when the back button is pressed.
  final VoidCallback? onBackPressed;

  /// Optional background gradient.
  final Gradient? gradient;

  /// Height of the AppBar.
  final double height;

  /// Whether to show a bottom border.
  final bool showBottomBorder;

  /// Color of the bottom border.
  final Color? borderColor;

  /// Custom text style for the title.
  final TextStyle? titleStyle;

  /// Custom text style for the subtitle.
  final TextStyle? subtitleStyle;

  /// Optional flexible space widget (e.g., background image or animation).
  final Widget? flexibleSpace;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 4.0,
    this.centerTitle = true,
    this.showBackButton = true,
    this.onBackPressed,
    this.gradient,
    this.height = 56.0,
    this.showBottomBorder = false,
    this.borderColor,
    this.titleStyle,
    this.subtitleStyle,
    this.flexibleSpace,
  }) : super(key: key);

  /// Returns the preferred size of the AppBar.
  @override
  Size get preferredSize => Size.fromHeight(height);

  /// Builds the title widget with optional subtitle.
  Widget _buildTitle(BuildContext context) {
    final effectiveForegroundColor =
        foregroundColor ?? Theme.of(context).appBarTheme.foregroundColor ?? Colors.white;

    final defaultTitleStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: effectiveForegroundColor,
    );

    final defaultSubtitleStyle = TextStyle(
      fontSize: 14,
      color: effectiveForegroundColor.withOpacity(0.8),
    );

    if (subtitle == null || subtitle!.isEmpty) {
      return Text(
        title,
        style: titleStyle ?? defaultTitleStyle,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Column(
      crossAxisAlignment:
      centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: titleStyle ?? defaultTitleStyle,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          subtitle!,
          style: subtitleStyle ?? defaultSubtitleStyle,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// Builds the leading widget (custom or back button).
  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;

    if (!showBackButton) return null;

    return IconButton(
      icon: Icon(Icons.arrow_back,
          color: foregroundColor ??
              Theme.of(context).appBarTheme.foregroundColor ??
              Colors.white),
      onPressed: onBackPressed ?? () => Navigator.of(context).maybePop(),
      tooltip: 'Back',
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor =
        backgroundColor ?? Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).primaryColor;

    final borderSide = showBottomBorder
        ? BorderSide(color: borderColor ?? Colors.grey.shade300, width: 1)
        : BorderSide.none;

    final appBarContent = AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: gradient == null ? effectiveBackgroundColor : Colors.transparent,
      elevation: elevation,
      centerTitle: centerTitle,
      leading: _buildLeading(context),
      title: _buildTitle(context),
      actions: actions,
      flexibleSpace: gradient != null
          ? Container(
        decoration: BoxDecoration(
          gradient: gradient,
          border: Border(bottom: borderSide),
        ),
      )
          : flexibleSpace ??
          Container(
            decoration: BoxDecoration(
              color: effectiveBackgroundColor,
              border: Border(bottom: borderSide),
            ),
          ),
    );

    return SizedBox(
      height: height,
      child: Material(
        elevation: elevation,
        shadowColor: Colors.black.withOpacity(0.2),
        child: appBarContent,
      ),
    );
  }
}