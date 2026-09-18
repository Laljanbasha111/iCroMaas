import 'package:flutter/material.dart';

/// Enum representing the position of the toolbar (top or bottom).
enum ToolbarPosition { top, bottom }

/// Represents a single action in the toolbar.
class ToolbarAction {
  /// Icon for the action.
  final IconData icon;

  /// Optional label displayed below or beside the icon.
  final String? label;

  /// Callback executed when the action is pressed.
  final VoidCallback onPressed;

  /// Optional icon color.
  final Color? color;

  /// Whether the action is enabled.
  final bool isEnabled;

  /// Optional badge text (e.g., notification count).
  final String? badge;

  /// Optional tooltip text displayed on hover or long press.
  final String? tooltip;

  const ToolbarAction({
    required this.icon,
    required this.onPressed,
    this.label,
    this.color,
    this.isEnabled = true,
    this.badge,
    this.tooltip,
  });
}

/// A customizable toolbar widget for the Crop Analyzer app.
/// Supports icons, labels, badges, tooltips, and flexible positioning.
class Toolbar extends StatelessWidget {
  /// List of toolbar actions.
  final List<ToolbarAction> actions;

  /// Background color of the toolbar.
  final Color backgroundColor;

  /// Height of the toolbar.
  final double height;

  /// Elevation (shadow depth) of the toolbar.
  final double elevation;

  /// Padding around the toolbar content.
  final EdgeInsets padding;

  /// Spacing between action buttons.
  final double spacing;

  /// Position of the toolbar (top or bottom).
  final ToolbarPosition position;

  const Toolbar({
    Key? key,
    required this.actions,
    this.backgroundColor = Colors.white,
    this.height = 56.0,
    this.elevation = 4.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 8),
    this.spacing = 8.0,
    this.position = ToolbarPosition.bottom,
  }) : super(key: key);

  /// Builds a single toolbar action button with optional label, badge, and tooltip.
  Widget _buildAction(BuildContext context, ToolbarAction action) {
    final iconColor = action.isEnabled
        ? (action.color ?? Theme.of(context).iconTheme.color ?? Colors.black)
        : Colors.grey;

    final iconButton = Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(action.icon, color: iconColor),
          onPressed: action.isEnabled ? action.onPressed : null,
          tooltip: action.tooltip,
        ),
        if (action.badge != null && action.badge!.isNotEmpty)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                action.badge!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );

    if (action.label != null && action.label!.isNotEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconButton,
          Text(
            action.label!,
            style: TextStyle(
              fontSize: 12,
              color: action.isEnabled ? Colors.black87 : Colors.grey,
            ),
          ),
        ],
      );
    }

    return iconButton;
  }

  @override
  Widget build(BuildContext context) {
    final toolbarContent = Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: actions
            .map((action) => Flexible(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing / 2),
            child: _buildAction(context, action),
          ),
        ))
            .toList(),
      ),
    );

    final toolbar = Material(
      elevation: elevation,
      color: backgroundColor,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: SafeArea(
          top: position == ToolbarPosition.top,
          bottom: position == ToolbarPosition.bottom,
          child: toolbarContent,
        ),
      ),
    );

    return Align(
      alignment: position == ToolbarPosition.top
          ? Alignment.topCenter
          : Alignment.bottomCenter,
      child: toolbar,
    );
  }
}