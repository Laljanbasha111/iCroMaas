import 'package:flutter/material.dart';

/// Enum representing the trend direction for the InfoCard.
enum Trend { up, down, neutral }

/// InfoCard widget for the Crop Analyzer app.
/// Displays key metrics such as temperature, yield, or soil data
/// with optional trend indicators, units, and gradient backgrounds.
class InfoCard extends StatelessWidget {
  /// Title of the card (e.g., "Soil Moisture").
  final String title;

  /// Main value to display (e.g., "78").
  final String value;

  /// Icon representing the metric.
  final IconData icon;

  /// Optional subtitle text (e.g., "Optimal range").
  final String? subtitle;

  /// Optional unit text (e.g., "%", "°C").
  final String? unit;

  /// Primary color for the icon and accents.
  final Color? color;

  /// Background color of the card.
  final Color? backgroundColor;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  /// Elevation (shadow depth) of the card.
  final double elevation;

  /// Border radius of the card.
  final double borderRadius;

  /// Padding inside the card.
  final EdgeInsets padding;

  /// Margin around the card.
  final EdgeInsets margin;

  /// Whether to show a colored border.
  final bool showBorder;

  /// Border width.
  final double borderWidth;

  /// Icon size.
  final double iconSize;

  /// Custom text style for the value.
  final TextStyle? valueStyle;

  /// Custom text style for the title.
  final TextStyle? titleStyle;

  /// Optional background gradient.
  final Gradient? gradient;

  /// Optional trend indicator (up, down, neutral).
  final Trend? trend;

  /// Optional trend value text (e.g., "+5%", "-2.3%").
  final String? trendValue;

  const InfoCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.unit,
    this.color,
    this.backgroundColor,
    this.onTap,
    this.elevation = 2.0,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.all(8),
    this.showBorder = false,
    this.borderWidth = 2.0,
    this.iconSize = 32.0,
    this.valueStyle,
    this.titleStyle,
    this.gradient,
    this.trend,
    this.trendValue,
  }) : super(key: key);

  /// Returns the icon representing the trend direction.
  IconData _getTrendIcon() {
    switch (trend) {
      case Trend.up:
        return Icons.arrow_upward_rounded;
      case Trend.down:
        return Icons.arrow_downward_rounded;
      case Trend.neutral:
      default:
        return Icons.remove_rounded;
    }
  }

  /// Returns the color representing the trend direction.
  Color _getTrendColor() {
    switch (trend) {
      case Trend.up:
        return Colors.green;
      case Trend.down:
        return Colors.red;
      case Trend.neutral:
      default:
        return Colors.grey;
    }
  }

  /// Builds the trend indicator widget.
  Widget _buildTrendIndicator() {
    if (trend == null) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _getTrendIcon(),
          color: _getTrendColor(),
          size: 18,
        ),
        if (trendValue != null)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              trendValue!,
              style: TextStyle(
                color: _getTrendColor(),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).primaryColor;
    final effectiveBackgroundColor =
        backgroundColor ?? Theme.of(context).cardColor;

    final cardDecoration = BoxDecoration(
      color: gradient == null ? effectiveBackgroundColor : null,
      gradient: gradient,
      borderRadius: BorderRadius.circular(borderRadius),
      border: showBorder
          ? Border.all(color: effectiveColor, width: borderWidth)
          : null,
    );

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: elevation,
        margin: margin,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: cardDecoration,
          padding: padding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon Section
              Container(
                decoration: BoxDecoration(
                  color: effectiveColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(10),
                child: Icon(
                  icon,
                  color: effectiveColor,
                  size: iconSize,
                ),
              ),
              const SizedBox(width: 16),

              // Text Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: titleStyle ??
                          TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Subtitle (optional)
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    const SizedBox(height: 8),

                    // Value + Unit + Trend
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          value,
                          style: valueStyle ??
                              TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: effectiveColor,
                              ),
                        ),
                        if (unit != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 2),
                            child: Text(
                              unit!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        const Spacer(),
                        _buildTrendIndicator(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}