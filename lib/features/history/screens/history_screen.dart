import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'All';
  String _selectedSort = 'Recent';
  String _searchQuery = '';

  // Real-time active data feed store
  final List<Map<String, dynamic>> _historyData = [
    {
      'id': '1',
      'cropType': 'Wheat',
      'healthStatus': 'Healthy',
      'confidence': 92.5,
      'date': DateTime(2026, 7, 20, 14, 30),
      'imagePath': null,
      'diseases': [],
      'location': 'Field A',
    },
    {
      'id': '2',
      'cropType': 'Rice',
      'healthStatus': 'Moderate',
      'confidence': 78.3,
      'date': DateTime(2026, 7, 19, 10, 15),
      'imagePath': null,
      'diseases': ['Leaf Blast'],
      'location': 'Field B',
    },
    {
      'id': '3',
      'cropType': 'Corn',
      'healthStatus': 'Poor',
      'confidence': 65.8,
      'date': DateTime(2026, 7, 18, 16, 45),
      'imagePath': null,
      'diseases': ['Rust', 'Blight'],
      'location': 'Field C',
    },
    {
      'id': '4',
      'cropType': 'Wheat',
      'healthStatus': 'Moderate',
      'confidence': 85.5,
      'date': DateTime(2026, 7, 17, 9, 20),
      'imagePath': null,
      'diseases': ['Leaf Rust'],
      'location': 'Field A',
    },
    {
      'id': '5',
      'cropType': 'Tomato',
      'healthStatus': 'Healthy',
      'confidence': 94.2,
      'date': DateTime(2026, 7, 16, 11, 30),
      'imagePath': null,
      'diseases': [],
      'location': 'Greenhouse 1',
    },
    {
      'id': '6',
      'cropType': 'Potato',
      'healthStatus': 'Poor',
      'confidence': 72.1,
      'date': DateTime(2026, 7, 15, 15, 10),
      'imagePath': null,
      'diseases': ['Late Blight', 'Early Blight'],
      'location': 'Field D',
    },
  ];

  Future<void> _loadHistory() async {
    // Refresh logic simulation for real-time pull-to-refresh
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {});
  }

  List<Map<String, dynamic>> get _filteredHistory {
    var filtered = List<Map<String, dynamic>>.from(_historyData);

    // Apply text search filter
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((item) {
        final crop = item['cropType'].toString().toLowerCase();
        final location = item['location'].toString().toLowerCase();
        return crop.contains(q) || location.contains(q);
      }).toList();
    }

    // Apply status filter
    if (_selectedFilter != 'All') {
      filtered = filtered.where((item) {
        return item['healthStatus'] == _selectedFilter;
      }).toList();
    }

    // Apply sort
    if (_selectedSort == 'Recent') {
      filtered.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    } else if (_selectedSort == 'Oldest') {
      filtered.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
    } else if (_selectedSort == 'Confidence') {
      filtered.sort((a, b) => (b['confidence'] as double).compareTo(a['confidence'] as double));
    }

    return filtered;
  }

  Color _getHealthColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'healthy':
      case 'good':
        return const Color(0xFF4CAF50);
      case 'moderate':
      case 'fair':
        return const Color(0xFFFFA726);
      case 'poor':
      case 'critical':
        return const Color(0xFFEF5350);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  IconData _getHealthIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'healthy':
      case 'good':
        return Icons.check_circle;
      case 'moderate':
      case 'fair':
        return Icons.warning;
      case 'poor':
      case 'critical':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredHistory = _filteredHistory;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Analysis History',
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
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showClearHistoryDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF2E7D32),
                  Color(0xFF66BB6A),
                ],
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      icon: Icons.analytics,
                      label: 'Total',
                      value: '${_historyData.length}',
                      color: Colors.white,
                    ),
                    _buildStatItem(
                      icon: Icons.check_circle,
                      label: 'Healthy',
                      value: '${_historyData.where((h) => h['healthStatus'] == 'Healthy').length}',
                      color: Colors.white,
                    ),
                    _buildStatItem(
                      icon: Icons.warning,
                      label: 'Issues',
                      value: '${_historyData.where((h) => h['healthStatus'] != 'Healthy').length}',
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filter and Sort Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildFilterChip(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSortChip(),
                ),
              ],
            ),
          ),

          // History List
          Expanded(
            child: filteredHistory.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No history found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start analyzing crops to see history',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadHistory,
              color: const Color(0xFF2E7D32),
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: filteredHistory.length,
                itemBuilder: (context, index) {
                  final item = filteredHistory[index];
                  return _buildHistoryCard(item);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip() {
    return PopupMenuButton<String>(
      initialValue: _selectedFilter,
      onSelected: (value) {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF2E7D32),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.filter_list, size: 18, color: Color(0xFF2E7D32)),
            const SizedBox(width: 8),
            Text(
              _selectedFilter,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'All', child: Text('All')),
        const PopupMenuItem(value: 'Healthy', child: Text('Healthy')),
        const PopupMenuItem(value: 'Moderate', child: Text('Moderate')),
        const PopupMenuItem(value: 'Poor', child: Text('Poor')),
      ],
    );
  }

  Widget _buildSortChip() {
    return PopupMenuButton<String>(
      initialValue: _selectedSort,
      onSelected: (value) {
        setState(() {
          _selectedSort = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF2E7D32),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sort, size: 18, color: Color(0xFF2E7D32)),
            const SizedBox(width: 8),
            Text(
              _selectedSort,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'Recent', child: Text('Most Recent')),
        const PopupMenuItem(value: 'Oldest', child: Text('Oldest First')),
        const PopupMenuItem(value: 'Confidence', child: Text('Highest Confidence')),
      ],
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    final cropType = item['cropType'] ?? 'Unknown';
    final healthStatus = item['healthStatus'] ?? 'Unknown';
    final confidence = item['confidence'] ?? 0.0;
    final date = item['date'] as DateTime;
    final diseases = (item['diseases'] as List<dynamic>?) ?? [];
    final location = item['location'] ?? 'Unknown';

    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return GestureDetector(
      onTap: () => _showDetailDialog(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Status Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getHealthColor(healthStatus).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getHealthIcon(healthStatus),
                  size: 32,
                  color: _getHealthColor(healthStatus),
                ),
              ),
              const SizedBox(width: 16),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            cropType,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getHealthColor(healthStatus).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            healthStatus,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _getHealthColor(healthStatus),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          location,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.speed, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${confidence.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          dateFormat.format(date),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          timeFormat.format(date),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    if (diseases.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.bug_report, size: 14, color: Colors.red[400]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              diseases.join(', '),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red[400],
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              _getHealthIcon(item['healthStatus']),
              color: _getHealthColor(item['healthStatus']),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item['cropType'] ?? 'Unknown',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Status', item['healthStatus'] ?? 'Unknown'),
              _buildDetailRow('Confidence', '${(item['confidence'] ?? 0).toStringAsFixed(1)}%'),
              _buildDetailRow('Location', item['location'] ?? 'Unknown'),
              _buildDetailRow('Date', DateFormat('MMM dd, yyyy - hh:mm a').format(item['date'] as DateTime)),
              if ((item['diseases'] as List).isNotEmpty)
                _buildDetailRow('Diseases', (item['diseases'] as List).join(', ')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // Action handler for viewing report details
            },
            icon: const Icon(Icons.visibility),
            label: const Text('View Full Report'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Search History'),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search by crop type, location...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
              });
              Navigator.pop(context);
            },
            child: const Text('Reset'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear History?'),
        content: const Text('Are you sure you want to delete all history? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _historyData.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('History cleared successfully'),
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
}