import 'package:flutter/material.dart';

/// HealthCard widget for the Crop Analyzer app.
/// Displays crop health information with color-coded status, progress bar,
/// gradient background, and optional details.
class HealthCard extends StatelessWidget {
  /// Health status (Healthy, Moderate, Poor, Critical).
  final String healthStatus;

  /// Title of the card.
  final String title;

  /// Optional subtitle text.
  final String? subtitle;

  /// Optional health percentage (0.0 - 100.0).
  final double? percentage;

  /// Optional custom icon.
  final IconData? icon;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  /// Whether to show the progress bar.
  final bool showProgressBar;

  /// Whether to show the status icon.
  final bool showIcon;

  /// Card elevation.
  final double elevation;

  /// Border radius of the card.
  final double borderRadius;

  /// Padding inside the card.
  final EdgeInsets padding;

  /// Margin around the card.
  final EdgeInsets margin;

  /// Optional list of additional details.
  final List<String>? details;

  /// Whether to show the status badge.
  final bool showBadge;

  const HealthCard({
    Key? key,
    required this.healthStatus,
    required this.title,
    this.subtitle,
    this.percentage,
    this.icon,
    this.onTap,
    this.showProgressBar = true,
    this.showIcon = true,
    this.elevation = 2.0,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.all(8),
    this.details,
    this.showBadge = true,
  }) : super(key: key);

  /// Returns a color based on the health status.
  Color _getHealthColor() {
    switch (healthStatus.toLowerCase()) {
      case 'healthy':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'poor':
        return Colors.redAccent;
      case 'critical':
        return Colors.red.shade900;
      default:
        return Colors.grey;
    }
  }

  /// Returns an icon based on the health status.
  IconData _getHealthIcon() {
    switch (healthStatus.toLowerCase()) {
      case 'healthy':
        return Icons.eco;
      case 'moderate':
        return Icons.warning_amber_rounded;
      case 'poor':
        return Icons.error_outline;
      case 'critical':
        return Icons.dangerous;
      default:
        return Icons.help_outline;
    }
  }

  /// Returns a gradient based on the health status.
  Gradient _getHealthGradient() {
    switch (healthStatus.toLowerCase()) {
      case 'healthy':
        return LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'moderate':
        return LinearGradient(
          colors: [Colors.orange.shade400, Colors.deepOrange.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'poor':
        return LinearGradient(
          colors: [Colors.redAccent.shade200, Colors.red.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'critical':
        return LinearGradient(
          colors: [Colors.red.shade900, Colors.black87],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return LinearGradient(
          colors: [Colors.grey.shade400, Colors.grey.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  /// Builds the progress bar widget.
  Widget _buildProgressBar() {
    if (!showProgressBar || percentage == null) return const SizedBox.shrink();

    final progress = (percentage!.clamp(0, 100)) / 100;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LinearProgressIndicator(
          value: progress,
          minHeight: 8,
          backgroundColor: Colors.white.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(_getHealthColor()),
        ),
      ),
    );
  }

  /// Builds the status badge widget.
  Widget _buildStatusBadge() {
    if (!showBadge) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getHealthColor().withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getHealthColor(), width: 1),
      ),
      child: Text(
        healthStatus.toUpperCase(),
        style: TextStyle(
          color: _getHealthColor(),
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Builds the details list widget.
  Widget _buildDetails() {
    if (details == null || details!.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: details!
            .map(
              (detail) => Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                const Icon(Icons.circle, size: 6, color: Colors.white70),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    detail,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _getHealthGradient();
    final iconData = icon ?? _getHealthIcon();

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
          decoration: BoxDecoration(
            gradient: gradient,
          ),
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Icon + Title + Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (showIcon)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        iconData,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  if (showIcon) const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (showBadge) _buildStatusBadge(),
                ],
              ),

              // Progress Bar
              _buildProgressBar(),

              // Details List
              _buildDetails(),

              // Percentage Text
              if (percentage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${percentage!.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}