import 'package:flutter/material.dart';

enum TrendType { up, down, neutral }

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final Gradient? gradient;
  final TrendType? trend;
  final String? trendValue;
  final String? subtitle;
  final VoidCallback? onTap;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final double? iconSize;

  const StatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.gradient,
    this.trend,
    this.trendValue,
    this.subtitle,
    this.onTap,
    this.elevation,
    this.padding,
    this.iconSize,
  }) : super(key: key);

  Color _getTrendColor() {
    switch (trend) {
      case TrendType.up:
        return Colors.green;
      case TrendType.down:
        return Colors.red;
      case TrendType.neutral:
      default:
        return Colors.grey;
    }
  }

  IconData _getTrendIcon() {
    switch (trend) {
      case TrendType.up:
        return Icons.arrow_upward;
      case TrendType.down:
        return Icons.arrow_downward;
      case TrendType.neutral:
      default:
        return Icons.remove;
    }
  }

  Widget _buildIcon() {
    final Color baseColor = color ?? Colors.green;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: baseColor.withOpacity(0.15),
      ),
      child: Icon(
        icon,
        color: baseColor,
        size: iconSize ?? 28,
      ),
    );
  }

  Widget _buildValue(BuildContext context) {
    return Text(
      value,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Colors.grey.shade700,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTrend() {
    if (trend == null || trendValue == null) return const SizedBox.shrink();
    final trendColor = _getTrendColor();
    final trendIcon = _getTrendIcon();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(trendIcon, color: trendColor, size: 16),
        const SizedBox(width: 4),
        Text(
          trendValue!,
          style: TextStyle(
            color: trendColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color baseColor = color ?? Colors.green;
    final double cardElevation = elevation ?? 4.0;
    final EdgeInsetsGeometry cardPadding =
        padding ?? const EdgeInsets.all(16.0);

    final cardContent = Container(
      padding: cardPadding,
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? Colors.white : null,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildIcon(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildValue(context),
                const SizedBox(height: 4),
                _buildTitle(context),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          _buildTrend(),
        ],
      ),
    );

    return Material(
      color: Colors.transparent,
      elevation: cardElevation,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        splashColor: baseColor.withOpacity(0.1),
        highlightColor: baseColor.withOpacity(0.05),
        child: cardContent,
      ),
    );
  }
}