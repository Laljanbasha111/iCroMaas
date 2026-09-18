import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../providers/analytics_provider.dart';  // ✅ FIXED: Removed 'core/'

class AnalyticsDashboard extends StatefulWidget {
  const AnalyticsDashboard({super.key});

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard> {
  bool _isLoading = false;
  String _selectedPeriod = 'Last 30 Days';
  DateTimeRange? _customRange;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<AnalyticsProvider>(context, listen: false);
    await provider.fetchAnalyticsData(period: _selectedPeriod, range: _customRange);
    setState(() => _isLoading = false);
  }

  Future<void> _filterByPeriod(String period) async {
    setState(() => _selectedPeriod = period);
    if (period == 'Custom Range') {
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2023),
        lastDate: DateTime.now(),
      );
      if (picked != null) {
        setState(() => _customRange = picked);
      }
    }
    await _loadAnalytics();
  }

  Future<void> _exportData() async {
    final provider = Provider.of<AnalyticsProvider>(context, listen: false);
    await provider.exportAnalyticsData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Analytics data exported successfully')),
      );
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.8), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(height: 8),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(title,
                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLineChart(List<FlSpot> spots) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Health Score Trend',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(Map<String, double> data) {
    final colors = [Colors.green, Colors.blue, Colors.orange, Colors.red, Colors.purple];
    int index = 0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Crop Type Distribution',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: data.entries.map((entry) {
                    final color = colors[index % colors.length];
                    index++;
                    return PieChartSectionData(
                      value: entry.value,
                      title: '${entry.value.toInt()}%',
                      color: color,
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: data.entries.map((entry) {
                final color = colors[(data.keys.toList().indexOf(entry.key)) % colors.length];
                return Chip(
                  avatar: CircleAvatar(backgroundColor: color),
                  label: Text(entry.key),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(Map<String, double> data, String title) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: data.entries.map((entry) {
                    final index = data.keys.toList().indexOf(entry.key);
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value,
                          color: Colors.green,
                          width: 20,
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final keys = data.keys.toList();
                          if (value.toInt() < keys.length) {
                            return Text(keys[value.toInt()], style: const TextStyle(fontSize: 10));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final analytics = Provider.of<AnalyticsProvider>(context);
    final stats = analytics.stats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAnalytics),
          IconButton(icon: const Icon(Icons.download), onPressed: _exportData),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: _filterByPeriod,
            itemBuilder: (context) => [
              'Last 7 Days',
              'Last 30 Days',
              'Last 3 Months',
              'Last Year',
              'All Time',
              'Custom Range'
            ]
                .map((e) => PopupMenuItem<String>(
              value: e,
              child: Text(e),
            ))
                .toList(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadAnalytics,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Statistics Overview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: [
                  _buildStatCard('Total Analyses', '${stats.totalAnalyses}', Icons.analytics,
                      Colors.green, () {}),
                  _buildStatCard('Healthy Crops', '${stats.healthyPercentage}%',
                      Icons.eco, Colors.blue, () {}),
                  _buildStatCard('Diseases Detected', '${stats.diseasesDetected}',
                      Icons.bug_report, Colors.red, () {}),
                  _buildStatCard('Avg Health Score', '${stats.averageHealthScore}%',
                      Icons.favorite, Colors.orange, () {}),
                  _buildStatCard('Most Analyzed Crop', stats.mostAnalyzedCrop ?? 'N/A',
                      Icons.agriculture, Colors.teal, () {}),
                  _buildStatCard('Recent Activity', stats.recentActivity ?? 'N/A',
                      Icons.history, Colors.purple, () {}),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Charts & Trends',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildLineChart(analytics.healthScoreTrend),
              const SizedBox(height: 8),
              _buildPieChart(analytics.cropDistribution),
              const SizedBox(height: 8),
              _buildBarChart(analytics.diseaseFrequency, 'Disease Frequency'),
              const SizedBox(height: 8),
              _buildBarChart(analytics.monthlyAnalysisCount, 'Monthly Analysis Count'),
              const SizedBox(height: 8),
              _buildBarChart(analytics.healthScoreDistribution, 'Health Score Distribution'),
              const SizedBox(height: 16),
              const Text('Trend Analysis',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    analytics.trendSummary ??
                        'No significant trends detected in the selected period.',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _exportData,
                  icon: const Icon(Icons.download),
                  label: const Text('Export Analytics Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}