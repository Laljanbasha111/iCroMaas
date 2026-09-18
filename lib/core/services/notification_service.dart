import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _allNotifications = [
    {
      'id': '1',
      'type': 'analysis',
      'icon': Icons.analytics,
      'color': Colors.blue,
      'title': 'Analysis Complete',
      'message': 'Your wheat crop analysis is ready. Health score: 85%',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
      'isRead': false,
      'action': 'View Results',
    },
    {
      'id': '2',
      'type': 'weather',
      'icon': Icons.wb_cloudy,
      'color': Colors.orange,
      'title': 'Weather Alert',
      'message': 'Heavy rainfall expected tomorrow. Consider postponing irrigation.',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'isRead': false,
      'action': 'View Weather',
    },
    {
      'id': '3',
      'type': 'disease',
      'icon': Icons.warning_amber,
      'color': Colors.red,
      'title': 'Disease Detected',
      'message': 'Leaf rust detected in your recent analysis. Immediate action recommended.',
      'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
      'isRead': true,
      'action': 'View Details',
    },
    {
      'id': '4',
      'type': 'tip',
      'icon': Icons.lightbulb,
      'color': Colors.amber,
      'title': 'Farming Tip',
      'message': 'Optimal conditions for fertilizer application detected for the next 3 days.',
      'timestamp': DateTime.now().subtract(const Duration(hours: 8)),
      'isRead': true,
      'action': 'Learn More',
    },
    {
      'id': '5',
      'type': 'reminder',
      'icon': Icons.notifications_active,
      'color': Colors.purple,
      'title': 'Irrigation Reminder',
      'message': 'Time to water your tomato crops. Last watered 3 days ago.',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      'isRead': true,
      'action': 'Mark Done',
    },
    {
      'id': '6',
      'type': 'update',
      'icon': Icons.system_update,
      'color': Colors.green,
      'title': 'App Update Available',
      'message': 'Version 1.1.0 is now available with new features and improvements.',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      'isRead': true,
      'action': 'Update Now',
    },
    {
      'id': '7',
      'type': 'analysis',
      'icon': Icons.analytics,
      'color': Colors.blue,
      'title': 'Weekly Report Ready',
      'message': 'Your weekly crop health report is available for download.',
      'timestamp': DateTime.now().subtract(const Duration(days: 2)),
      'isRead': true,
      'action': 'Download',
    },
    {
      'id': '8',
      'type': 'weather',
      'icon': Icons.wb_sunny,
      'color': Colors.orange,
      'title': 'Perfect Harvesting Weather',
      'message': 'Clear skies forecasted for the weekend. Ideal for harvesting.',
      'timestamp': DateTime.now().subtract(const Duration(days: 3)),
      'isRead': true,
      'action': 'View Forecast',
    },
    {
      'id': '9',
      'type': 'tip',
      'icon': Icons.lightbulb,
      'color': Colors.amber,
      'title': 'Pest Control Advice',
      'message': 'High humidity may increase pest activity. Monitor crops closely.',
      'timestamp': DateTime.now().subtract(const Duration(days: 4)),
      'isRead': true,
      'action': 'Read More',
    },
    {
      'id': '10',
      'type': 'achievement',
      'icon': Icons.emoji_events,
      'color': Colors.deepOrange,
      'title': 'Achievement Unlocked!',
      'message': 'You\'ve completed 50 crop analyses. Keep up the great work!',
      'timestamp': DateTime.now().subtract(const Duration(days: 5)),
      'isRead': true,
      'action': 'View Achievements',
    },
  ];

  List<Map<String, dynamic>> get _unreadNotifications =>
      _allNotifications.where((n) => !n['isRead']).toList();

  List<Map<String, dynamic>> get _readNotifications =>
      _allNotifications.where((n) => n['isRead']).toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _markAsRead(String id) {
    setState(() {
      final notification = _allNotifications.firstWhere((n) => n['id'] == id);
      notification['isRead'] = true;
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _allNotifications) {
        notification['isRead'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        backgroundColor: Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteNotification(String id) {
    setState(() {
      _allNotifications.removeWhere((n) => n['id'] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification deleted'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear All Notifications?'),
        content: const Text('This will permanently delete all notifications.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _allNotifications.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications cleared'),
                  backgroundColor: Color(0xFF4CAF50),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_unreadNotifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Mark all as read',
              onPressed: _markAllAsRead,
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'clear') {
                _clearAll();
              } else if (value == 'settings') {
                context.push('/settings');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Clear All'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: Color(0xFF2E7D32)),
                    SizedBox(width: 12),
                    Text('Notification Settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
          tabs: [
            Tab(
              text: 'All (${_allNotifications.length})',
            ),
            Tab(
              text: 'Unread (${_unreadNotifications.length})',
            ),
            Tab(
              text: 'Read (${_readNotifications.length})',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationList(_allNotifications),
          _buildNotificationList(_unreadNotifications),
          _buildNotificationList(_readNotifications),
        ],
      ),
    );
  }

  Widget _buildNotificationList(List<Map<String, dynamic>> notifications) {
    if (notifications.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isRead = notification['isRead'] as bool;
    final timestamp = notification['timestamp'] as DateTime;
    final timeAgo = _getTimeAgo(timestamp);

    return Dismissible(
      key: Key(notification['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      onDismissed: (direction) {
        _deleteNotification(notification['id']);
      },
      child: InkWell(
        onTap: () {
          if (!isRead) {
            _markAsRead(notification['id']);
          }
          _handleNotificationAction(notification);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isRead ? Colors.white : const Color(0xFF2E7D32).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isRead
                  ? Colors.grey.withValues(alpha: 0.2)
                  : const Color(0xFF2E7D32).withValues(alpha: 0.3),
              width: isRead ? 1 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (notification['color'] as Color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  notification['icon'],
                  color: notification['color'],
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2E7D32),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification['message'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              timeAgo,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () => _handleNotificationAction(notification),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            notification['action'],
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd').format(timestamp);
    }
  }

  void _handleNotificationAction(Map<String, dynamic> notification) {
    final type = notification['type'];

    switch (type) {
      case 'analysis':
        context.push('/result');
        break;
      case 'weather':
        context.push('/weather');
        break;
      case 'disease':
        context.push('/result');
        break;
      case 'tip':
        context.push('/chatbot');
        break;
      case 'reminder':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminder marked as done'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      case 'update':
        _showUpdateDialog();
        break;
      case 'achievement':
        _showAchievementDialog();
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${notification['action']} - Coming soon!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  void _showUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.system_update, color: Color(0xFF2E7D32)),
            SizedBox(width: 12),
            Text('Update Available'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version 1.1.0',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 12),
            Text('What\'s New:'),
            SizedBox(height: 8),
            Text('• Improved AI accuracy'),
            Text('• New crop varieties support'),
            Text('• Bug fixes and performance improvements'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Update feature coming soon!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
            child: const Text('Update Now'),
          ),
        ],
      ),
    );
  }

  void _showAchievementDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            Icon(Icons.emoji_events, color: Colors.amber, size: 64),
            SizedBox(height: 12),
            Text('Achievement Unlocked!'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '50 Analyses Complete',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              'You\'ve completed 50 crop analyses. Keep up the great work!',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }
}