import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ComparisonScreen extends StatefulWidget {
  const ComparisonScreen({super.key});

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  final List<Map<String, dynamic>> _selectedAnalyses = [];
  final int _maxComparisons = 3;

  // Mock data - Replace with actual data from HistoryProvider
  final List<Map<String, dynamic>> _mockAnalyses = [
    {
      'id': '1',
      'cropType': 'Wheat',
      'healthStatus': 'Healthy',
      'confidence': 92.5,
      'date': '2026-07-20',
      'imagePath': null,
      'diseases': 0,
    },
    {
      'id': '2',
      'cropType': 'Rice',
      'healthStatus': 'Moderate',
      'confidence': 78.3,
      'date': '2026-07-19',
      'imagePath': null,
      'diseases': 1,
    },
    {
      'id': '3',
      'cropType': 'Corn',
      'healthStatus': 'Poor',
      'confidence': 65.8,
      'date': '2026-07-18',
      'imagePath': null,
      'diseases': 2,
    },
    {
      'id': '4',
      'cropType': 'Wheat',
      'healthStatus': 'Moderate',
      'confidence': 85.5,
      'date': '2026-07-17',
      'imagePath': null,
      'diseases': 1,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadAnalyses();
  }

  Future<void> _loadAnalyses() async {
    setState(() {
      // Use mock data for now
    });
  }

  void _toggleSelection(Map<String, dynamic> analysis) {
    setState(() {
      final index = _selectedAnalyses.indexWhere((a) => a['id'] == analysis['id']);
      if (index != -1) {
        _selectedAnalyses.removeAt(index);
      } else {
        if (_selectedAnalyses.length < _maxComparisons) {
          _selectedAnalyses.add(analysis);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You can only compare up to $_maxComparisons analyses'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    });
  }

  bool _isSelected(Map<String, dynamic> analysis) {
    return _selectedAnalyses.any((a) => a['id'] == analysis['id']);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Compare Analyses',
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
          if (_selectedAnalyses.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedAnalyses.clear();
                });
              },
              icon: const Icon(Icons.clear_all, color: Colors.white),
              label: const Text(
                'Clear',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Selection Info Header
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
                Text(
                  'Select up to $_maxComparisons analyses to compare',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_maxComparisons, (index) {
                    final isSelected = index < _selectedAnalyses.length;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: isSelected
                            ? const Icon(Icons.check, color: Color(0xFF2E7D32))
                            : Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // Analysis List
          Expanded(
            child: _mockAnalyses.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.compare_arrows,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No analyses available',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Perform some analyses first',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _mockAnalyses.length,
              itemBuilder: (context, index) {
                final analysis = _mockAnalyses[index];
                final isSelected = _isSelected(analysis);
                return _buildAnalysisCard(analysis, isSelected);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _selectedAnalyses.length >= 2
          ? Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () => _showComparisonResults(),
          icon: const Icon(Icons.compare),
          label: Text(
            'Compare ${_selectedAnalyses.length} Analyses',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
        ),
      )
          : null,
    );
  }

  Widget _buildAnalysisCard(Map<String, dynamic> analysis, bool isSelected) {
    final cropType = analysis['cropType'] ?? 'Unknown';
    final healthStatus = analysis['healthStatus'] ?? 'Unknown';
    final confidence = analysis['confidence'] ?? 0.0;
    final date = analysis['date'] ?? '';
    final diseases = analysis['diseases'] ?? 0;

    return GestureDetector(
      onTap: () => _toggleSelection(analysis),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF2E7D32) : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _getHealthColor(healthStatus).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.agriculture,
                      size: 40,
                      color: _getHealthColor(healthStatus),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cropType,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
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
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _getHealthColor(healthStatus),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
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
                              date,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.bug_report, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              '$diseases disease${diseases != 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
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
            if (isSelected)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2E7D32),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showComparisonResults() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const Text(
                        'Comparison Results',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildComparisonTable(),
                        const SizedBox(height: 24),
                        _buildComparisonCharts(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildComparisonTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Property',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                ...List.generate(_selectedAnalyses.length, (index) {
                  return Expanded(
                    child: Text(
                      'Analysis ${index + 1}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }),
              ],
            ),
          ),
          _buildComparisonRow('Crop Type', _selectedAnalyses.map<String>((a) => (a['cropType'] ?? 'N/A').toString()).toList()),
          _buildComparisonRow('Health', _selectedAnalyses.map<String>((a) => (a['healthStatus'] ?? 'N/A').toString()).toList()),
          _buildComparisonRow('Confidence', _selectedAnalyses.map<String>((a) => '${(a['confidence'] ?? 0).toStringAsFixed(1)}%').toList()),
          _buildComparisonRow('Diseases', _selectedAnalyses.map<String>((a) => (a['diseases'] ?? 0).toString()).toList()),
          _buildComparisonRow('Date', _selectedAnalyses.map<String>((a) => (a['date'] ?? 'N/A').toString()).toList()),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String label, List<String> values) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          ...values.map((value) {
            return Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildComparisonCharts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Visual Comparison',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildBarChart(
          'Confidence Score',
          _selectedAnalyses
              .map<double>((a) => ((a['confidence'] ?? 0) as num).toDouble())
              .toList(),
          const Color(0xFF2E7D32),
        ),
        const SizedBox(height: 16),
        _buildBarChart(
          'Disease Count',
          _selectedAnalyses
              .map<double>((a) => ((a['diseases'] ?? 0) as num).toDouble())
              .toList(),
          const Color(0xFFEF5350),
        ),
      ],
    );
  }

  Widget _buildBarChart(String title, List<double> values, Color color) {
    final maxValue = values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 1.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(values.length, (index) {
              final value = values[index];
              final height = maxValue > 0 ? (value / maxValue) * 100 : 0.0;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      Text(
                        value.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: height.clamp(20, 100),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'A${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}