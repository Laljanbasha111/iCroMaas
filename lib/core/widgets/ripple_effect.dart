import 'package:flutter/material.dart';

class RippleEffect extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? rippleColor;

  const RippleEffect({
    super.key,
    required this.child,
    this.onTap,
    this.rippleColor,
  });

  @override
  State<RippleEffect> createState() => _RippleEffectState();
}

class _RippleEffectState extends State<RippleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward(from: 0.0);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: RipplePainter(
                    progress: _animation.value,
                    color: widget.rippleColor ??
                        Theme.of(context).primaryColor.withValues(alpha: 0.3),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class RipplePainter extends CustomPainter {
  final double progress;
  final Color color;

  RipplePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: (1 - progress) * 0.3)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * progress;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(RipplePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}