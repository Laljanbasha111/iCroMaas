import 'package:flutter/material.dart';

class ChartCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget chart;
  final bool isLoading;
  final bool isEmpty;
  final bool hasError;
  final String? errorMessage;
  final String? emptyMessage;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final double? height;
  final VoidCallback? onRefresh;

  const ChartCard({
    super.key,
    required this.title,
    required this.chart,
    this.subtitle,
    this.icon,
    this.isLoading = false,
    this.isEmpty = false,
    this.hasError = false,
    this.errorMessage,
    this.emptyMessage,
    this.actions,
    this.padding,
    this.margin,
    this.elevation,
    this.height,
    this.onRefresh,
  });

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        if (icon != null)
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.green, size: 20),
          ),
        if (icon != null) const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
        ),
        if (actions != null && actions!.isNotEmpty)
          Row(children: actions!),
      ],
    );
  }

  Widget _buildChartArea(BuildContext context) {
    if (isLoading) return _buildLoadingState();
    if (hasError) return _buildErrorState();
    if (isEmpty) return _buildEmptyState();
    return SizedBox(
      height: height ?? 220,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: chart,
      ),
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: height ?? 220,
      child: const Center(
        child: CircularProgressIndicator(color: Colors.green),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: height ?? 220,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insert_chart_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              emptyMessage ?? 'No data available',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            if (onRefresh != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh, color: Colors.green),
                label: const Text('Refresh', style: TextStyle(color: Colors.green)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return SizedBox(
      height: height ?? 220,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'Something went wrong',
              style: TextStyle(color: Colors.red.shade400),
            ),
            if (onRefresh != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh, color: Colors.green),
                label: const Text('Retry', style: TextStyle(color: Colors.green)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry effectivePadding = padding ?? const EdgeInsets.all(16);
    final EdgeInsetsGeometry effectiveMargin = margin ?? const EdgeInsets.symmetric(vertical: 8, horizontal: 12);
    final double effectiveElevation = elevation ?? 4.0;

    return Card(
      elevation: effectiveElevation,
      margin: effectiveMargin,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: effectivePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 12),
            _buildChartArea(context),
          ],
        ),
      ),
    );
  }
}