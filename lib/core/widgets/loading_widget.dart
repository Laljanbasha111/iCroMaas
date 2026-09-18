import 'package:flutter/material.dart';

/// Enum representing different loading indicator types.
enum LoadingType {
  circular,
  linear,
  dots,
  custom,
}

/// A versatile loading widget for the Crop Analyzer app.
/// Supports circular, linear, and animated dots loaders with optional message
/// and full-screen overlay mode.
class LoadingWidget extends StatelessWidget {
  /// Optional loading message displayed below the loader.
  final String? message;

  /// Size of the loader (applies to circular and dots types).
  final double size;

  /// Color of the loader.
  final Color? color;

  /// Background color (used for full-screen overlay).
  final Color? backgroundColor;

  /// Stroke width for circular loader.
  final double strokeWidth;

  /// Whether to show the message text.
  final bool showMessage;

  /// Text style for the message.
  final TextStyle? messageStyle;

  /// Type of loading indicator.
  final LoadingType type;

  /// Whether to display as a full-screen overlay.
  final bool fullScreen;

  /// Background opacity for full-screen overlay.
  final double opacity;

  const LoadingWidget({
    Key? key,
    this.message,
    this.size = 40.0,
    this.color,
    this.backgroundColor,
    this.strokeWidth = 4.0,
    this.showMessage = true,
    this.messageStyle,
    this.type = LoadingType.circular,
    this.fullScreen = false,
    this.opacity = 0.7,
  }) : super(key: key);

  /// Builds a circular progress indicator.
  Widget _buildCircularLoader(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  /// Builds a linear progress indicator.
  Widget _buildLinearLoader(BuildContext context) {
    return SizedBox(
      width: size * 2,
      child: LinearProgressIndicator(
        minHeight: strokeWidth,
        backgroundColor: Colors.grey.shade200,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  /// Builds an animated dots loader.
  Widget _buildDotsLoader(BuildContext context) {
    final dotColor = color ?? Theme.of(context).primaryColor;
    return SizedBox(
      width: size,
      height: size / 2,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return AnimatedDot(
              delay: Duration(milliseconds: index * 200),
              color: dotColor,
              size: size / 6,
            );
          }),
        ),
      ),
    );
  }

  /// Builds the appropriate loader based on the selected type.
  Widget _buildLoader(BuildContext context) {
    switch (type) {
      case LoadingType.circular:
        return _buildCircularLoader(context);
      case LoadingType.linear:
        return _buildLinearLoader(context);
      case LoadingType.dots:
        return _buildDotsLoader(context);
      case LoadingType.custom:
        return _buildCircularLoader(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loader = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLoader(context),
        if (showMessage && message != null && message!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              message!,
              style: messageStyle ??
                  TextStyle(
                    color: color ?? Theme.of(context).primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );

    if (fullScreen) {
      return Container(
        color: (backgroundColor ?? Colors.black).withOpacity(opacity),
        width: double.infinity,
        height: double.infinity,
        child: Center(child: loader),
      );
    }

    return Center(child: loader);
  }
}

/// AnimatedDot widget used for the dots loading animation.
class AnimatedDot extends StatefulWidget {
  final Duration delay;
  final Color color;
  final double size;

  const AnimatedDot({
    Key? key,
    required this.delay,
    required this.color,
    required this.size,
  }) : super(key: key);

  @override
  State<AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<AnimatedDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}