import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final double? borderRadius;
  final Color? color;
  final Gradient? gradient;
  final Border? border;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final Color? shadowColor;

  const AppCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.borderRadius,
    this.color,
    this.gradient,
    this.border,
    this.onTap,
    this.width,
    this.height,
    this.shadowColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double effectiveElevation = elevation ?? 4.0;
    final double effectiveRadius = borderRadius ?? 12.0;
    final EdgeInsetsGeometry effectivePadding = padding ?? const EdgeInsets.all(16);
    final EdgeInsetsGeometry effectiveMargin = margin ?? const EdgeInsets.all(8);
    final Color effectiveShadowColor = shadowColor ?? Colors.black.withOpacity(0.15);

    final cardContent = Container(
      width: width,
      height: height,
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? Colors.white) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(effectiveRadius),
        border: border,
        boxShadow: [
          BoxShadow(
            color: effectiveShadowColor,
            blurRadius: effectiveElevation * 2,
            spreadRadius: 0.5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );

    final card = ClipRRect(
      borderRadius: BorderRadius.circular(effectiveRadius),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: onTap != null ? Colors.black12 : Colors.transparent,
          highlightColor: onTap != null ? Colors.black.withOpacity(0.05) : Colors.transparent,
          child: cardContent,
        ),
      ),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: effectiveMargin,
      child: card,
    );
  }
}