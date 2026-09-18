import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../providers/history_provider.dart';
import '../../../models/analysis_model.dart';
import 'screens/pdf_preview_screen.dart';

class ReportHistory extends StatefulWidget {
  const ReportHistory({super.key});

  @override
  State<ReportHistory> createState() => _ReportHistoryState();
}

class _ReportHistoryState extends State<ReportHistory> {
  final Map<String, bool> _expandedSections = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HistoryProvider>(context, listen: false).loadCachedHistory();
    });
  }

  Map<String, List<AnalysisModel>> _groupReportsByDate(List<AnalysisModel> reports) {
    final Map<String, List<AnalysisModel>> grouped = {
      'Today': [],
      'Yesterday': [],
      'This Week': [],
      'This Month': [],
      'Older': [],
    };

    final now = DateTime.now();
    for (var report in reports) {
      final date = report.date;
      final difference = now.difference(date).inDays;

      if (difference == 0) {
        grouped['Today']!.add(report);
      } else if (difference == 1) {
        grouped['Yesterday']!.add(report);
      } else if (difference <= 7) {
        grouped['This Week']!.add(report);
      } else if (difference <= 30) {
        grouped['This Month']!.add(report);
      } else {
        grouped['Older']!.add(report);
      }
    }

    grouped.removeWhere((key, value) => value.isEmpty);
    return grouped;
  }

  String _formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  Color _getHealthColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  IconData _getCropIcon(String cropType) {
    switch (cropType.toLowerCase()) {
      case 'wheat':
        return Icons.grass;
      case 'rice':
        return Icons.rice_bowl;
      case 'corn':
      case 'maize':
        return Icons.eco;
      case 'soybean':
        return Icons.spa;
      case 'cotton':
        return Icons.local_florist;
      default:
        return Icons.agriculture;
    }
  }

  void _openReport(AnalysisModel report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfPreviewScreen(reportData: report.toMap()),
      ),
    );
  }

  void _showReportOptions(AnalysisModel report) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('View Report'),
              onTap: () {
                Navigator.pop(context);
                _openReport(report);
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Generate PDF'),
              onTap: () {
                Navigator.pop(context);
                _openReport(report);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Report', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                await Provider.of<HistoryProvider>(context, listen: false)
                    .deleteFromHistory(report.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineNode(Color color) {
    return Column(
      children: [
        Container(width: 2, height: 12, color: Colors.grey.shade400),
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
        Container(width: 2, height: 12, color: Colors.grey.shade400),
      ],
    );
  }

  Widget _buildReportCard(AnalysisModel report) {
    final color = _getHealthColor(report.healthScore);
    final icon = _getCropIcon(report.cropType);

    return GestureDetector(
      onTap: () => _openReport(report),
      onLongPress: () => _showReportOptions(report),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.2),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.cropType,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${DateFormat('MMM d, yyyy').format(report.date)} • ${_formatTime(report.date)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    if (report.location != null)
                      Text(
                        report.location!,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color),
                ),
                child: Text(
                  '${report.healthScore.toInt()}%',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSection(String label, List<AnalysisModel> reports) {
    final expanded = _expandedSections[label] ?? true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _expandedSections[label] = !expanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              children: [
                Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Column(
              children: reports.asMap().entries.map((entry) {
                final index = entry.key;
                final report = entry.value;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        if (index == 0)
                          Container(width: 2, height: 8, color: Colors.transparent)
                        else
                          Container(width: 2, height: 8, color: Colors.grey.shade400),
                        _buildTimelineNode(_getHealthColor(report.healthScore)),
                        if (index == reports.length - 1)
                          Container(width: 2, height: 8, color: Colors.transparent)
                        else
                          Container(width: 2, height: 8, color: Colors.grey.shade400),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: _buildReportCard(report)),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final historyProvider = Provider.of<HistoryProvider>(context);
    final reports = historyProvider.historyList;
    final groupedReports = _groupReportsByDate(reports);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report History'),
      ),
      body: historyProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : reports.isEmpty
          ? const Center(
        child: Text(
          'No reports available',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      )
          : RefreshIndicator(
        onRefresh: () async {
          await historyProvider.loadCachedHistory();
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: groupedReports.entries
              .map((entry) => _buildDateSection(entry.key, entry.value))
              .toList(),
        ),
      ),
    );
  }
}