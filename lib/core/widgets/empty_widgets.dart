import 'package:flutter/material.dart';

class EmptyState extends StatefulWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double? iconSize;
  final Color? iconColor;
  final bool showAnimation;

  const EmptyState({
    Key? key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.iconSize,
    this.iconColor,
    this.showAnimation = true,
  }) : super(key: key);

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    if (widget.showAnimation) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.iconColor ?? Colors.grey.shade400;
    final iconSize = widget.iconSize ?? 80.0;
    final textTheme = Theme.of(context).textTheme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: iconSize, color: iconColor),
              const SizedBox(height: 20),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              if (widget.actionLabel != null && widget.onAction != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ElevatedButton.icon(
                    onPressed: widget.onAction,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: Text(widget.actionLabel!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
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

// Specific Empty State Widgets

class EmptyAnalysis extends StatelessWidget {
  final VoidCallback? onAction;
  const EmptyAnalysis({Key? key, this.onAction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.camera_alt_outlined,
      title: 'No Analyses Yet',
      message:
      'Start by analyzing your first crop image to detect health and diseases.',
      actionLabel: onAction != null ? 'Analyze Now' : null,
      onAction: onAction,
      iconColor: Colors.green.shade400,
    );
  }
}

class EmptyGallery extends StatelessWidget {
  final VoidCallback? onAction;
  const EmptyGallery({Key? key, this.onAction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.photo_library_outlined,
      title: 'Gallery is Empty',
      message:
      'No images found in your gallery. Capture or upload crop images to get started.',
      actionLabel: onAction != null ? 'Upload Image' : null,
      onAction: onAction,
      iconColor: Colors.blue.shade400,
    );
  }
}

class EmptyHistory extends StatelessWidget {
  final VoidCallback? onAction;
  const EmptyHistory({Key? key, this.onAction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.history,
      title: 'No History Records',
      message:
      'You haven’t performed any analyses yet. Your past analyses will appear here.',
      actionLabel: onAction != null ? 'Start Analysis' : null,
      onAction: onAction,
      iconColor: Colors.orange.shade400,
    );
  }
}

class EmptySearch extends StatelessWidget {
  final VoidCallback? onAction;
  const EmptySearch({Key? key, this.onAction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.search_off,
      title: 'No Results Found',
      message:
      'Try adjusting your search terms or filters to find what you’re looking for.',
      actionLabel: onAction != null ? 'Try Again' : null,
      onAction: onAction,
      iconColor: Colors.grey.shade500,
    );
  }
}

class EmptyNotifications extends StatelessWidget {
  final VoidCallback? onAction;
  const EmptyNotifications({Key? key, this.onAction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.notifications_none,
      title: 'No Notifications',
      message:
      'You’re all caught up! New notifications will appear here when available.',
      actionLabel: onAction != null ? 'Refresh' : null,
      onAction: onAction,
      iconColor: Colors.amber.shade600,
    );
  }
}

class EmptyReports extends StatelessWidget {
  final VoidCallback? onAction;
  const EmptyReports({Key? key, this.onAction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.insert_drive_file_outlined,
      title: 'No Reports Generated',
      message:
      'You haven’t generated any reports yet. Analyze crops to create detailed reports.',
      actionLabel: onAction != null ? 'Generate Report' : null,
      onAction: onAction,
      iconColor: Colors.indigo.shade400,
    );
  }
}

class EmptyFavorites extends StatelessWidget {
  final VoidCallback? onAction;
  const EmptyFavorites({Key? key, this.onAction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.star_border,
      title: 'No Favorites Yet',
      message:
      'You haven’t saved any favorites. Mark analyses or crops as favorites to access them quickly.',
      actionLabel: onAction != null ? 'Browse Crops' : null,
      onAction: onAction,
      iconColor: Colors.purple.shade400,
    );
  }
}