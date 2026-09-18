import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // ✅ Added for PointerEnterEvent and PointerExitEvent

/// AnimatedCard widget for the Crop Analyzer app.
/// Provides smooth scale, hover, and ripple animations with customizable styling.
class AnimatedCard extends StatefulWidget {
  /// The content inside the card.
  final Widget child;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  /// Card elevation.
  final double elevation;

  /// Border radius of the card.
  final double borderRadius;

  /// Padding inside the card.
  final EdgeInsets padding;

  /// Margin around the card.
  final EdgeInsets margin;

  /// Background color of the card.
  final Color? backgroundColor;

  /// Shadow color of the card.
  final Color? shadowColor;

  /// Duration of the animation.
  final Duration animationDuration;

  /// Curve of the animation.
  final Curve animationCurve;

  /// Scale factor when tapped.
  final double scaleOnTap;

  /// Enables hover effect (for desktop/web).
  final bool enableHoverEffect;

  /// Enables tap animation.
  final bool enableTapAnimation;

  /// Optional background gradient.
  final Gradient? gradient;

  /// Optional border.
  final Border? border;

  const AnimatedCard({
    super.key, // ✅ Fixed: Changed from Key? key to super.key
    required this.child,
    this.onTap,
    this.elevation = 2.0,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.all(8),
    this.backgroundColor,
    this.shadowColor,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
    this.scaleOnTap = 0.95,
    this.enableHoverEffect = true,
    this.enableTapAnimation = true,
    this.gradient,
    this.border,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
      value: 1.0,
      lowerBound: widget.scaleOnTap,
      upperBound: 1.0,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Handles tap down event.
  void _handleTapDown(TapDownDetails details) {
    if (!widget.enableTapAnimation) return;
    _animationController.reverse();
  }

  /// Handles tap up event.
  void _handleTapUp(TapUpDetails details) {
    if (!widget.enableTapAnimation) return;
    _animationController.forward();
    widget.onTap?.call();
  }

  /// Handles tap cancel event.
  void _handleTapCancel() {
    if (!widget.enableTapAnimation) return;
    _animationController.forward();
  }

  /// Handles hover enter event.
  void _handleHoverEnter(PointerEnterEvent event) {
    if (!widget.enableHoverEffect) return;
    if (mounted) setState(() => _isHovered = true);
  }

  /// Handles hover exit event.
  void _handleHoverExit(PointerExitEvent event) {
    if (!widget.enableHoverEffect) return;
    if (mounted) setState(() => _isHovered = false);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveElevation =
    _isHovered ? widget.elevation * 1.5 : widget.elevation;

    final effectiveShadowColor =
        widget.shadowColor ?? Colors.black.withValues(alpha: 0.2); // ✅ Fixed: withValues

    final cardDecoration = BoxDecoration(
      color: widget.gradient == null
          ? (widget.backgroundColor ?? Theme.of(context).cardColor)
          : null,
      gradient: widget.gradient,
      borderRadius: BorderRadius.circular(widget.borderRadius),
      border: widget.border,
      boxShadow: [
        BoxShadow(
          color: effectiveShadowColor,
          blurRadius: effectiveElevation * 2,
          offset: Offset(0, effectiveElevation),
        ),
      ],
    );

    return MouseRegion(
      onEnter: _handleHoverEnter,
      onExit: _handleHoverExit,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: widget.animationDuration,
                curve: widget.animationCurve,
                margin: widget.margin,
                decoration: cardDecoration,
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    onTap: widget.onTap,
                    splashColor: Theme.of(context)
                        .primaryColor
                        .withValues(alpha: 0.1), // ✅ Fixed: withValues
                    highlightColor: Theme.of(context)
                        .primaryColor
                        .withValues(alpha: 0.05), // ✅ Fixed: withValues
                    child: Padding(
                      padding: widget.padding,
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}