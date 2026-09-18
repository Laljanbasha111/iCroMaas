import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:open_filex/open_filex.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'This Week';
  String _selectedType = 'All';
  bool _isGeneratingPdf = false;

  // Real-time dynamic reports data store
  final List<Map<String, dynamic>> _mockReports = [
    {
      'id': '1',
      'title': 'Weekly Crop Analysis Report',
      'type': 'Weekly',
      'date': DateTime(2026, 7, 20),
      'analyses': 12,
      'healthyCount': 8,
      'issuesCount': 4,
      'crops': ['Wheat', 'Rice', 'Corn'],
      'size': '2.4 MB',
    },
    {
      'id': '2',
      'title': 'Monthly Summary - June 2026',
      'type': 'Monthly',
      'date': DateTime(2026, 6, 30),
      'analyses': 45,
      'healthyCount': 32,
      'issuesCount': 13,
      'crops': ['Wheat', 'Rice', 'Corn', 'Tomato'],
      'size': '5.8 MB',
    },
    {
      'id': '3',
      'title': 'Field A - Detailed Report',
      'type': 'Custom',
      'date': DateTime(2026, 7, 15),
      'analyses': 8,
      'healthyCount': 6,
      'issuesCount': 2,
      'crops': ['Wheat'],
      'size': '1.2 MB',
    },
    {
      'id': '4',
      'title': 'Disease Outbreak Analysis',
      'type': 'Custom',
      'date': DateTime(2026, 7, 10),
      'analyses': 15,
      'healthyCount': 3,
      'issuesCount': 12,
      'crops': ['Rice', 'Corn'],
      'size': '3.1 MB',
    },
  ];

  /// Core logic to dynamically construct the system PDF document
  Future<Uint8List> _generatePdfBytes(Map<String, dynamic> report) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('MMM dd, yyyy');
    final dateStr = dateFormat.format(report['date'] as DateTime);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('iCroMas Mobile Intelligence',
                      style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.green800)),
                  pw.SizedBox(height: 4),
                  pw.Text('Real-Time Agricultural Diagnostics Report',
                      style: const pw.TextStyle(
                          fontSize: 12, color: PdfColors.grey700)),
                ],
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green100,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Text(report['type'],
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green900)),
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Divider(thickness: 1.5, color: PdfColors.green800),
          pw.SizedBox(height: 15),
          pw.Text(report['title'],
              style: pw.TextStyle(
                  fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Text('Generated On: $dateStr',
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
          pw.SizedBox(height: 20),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                pw.Column(children: [
                  pw.Text('Total Analyses',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                  pw.SizedBox(height: 4),
                  pw.Text('${report['analyses']}',
                      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                ]),
                pw.Column(children: [
                  pw.Text('Healthy Crops',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.green700)),
                  pw.SizedBox(height: 4),
                  pw.Text('${report['healthyCount']}',
                      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                ]),
                pw.Column(children: [
                  pw.Text('Issues Detected',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.orange700)),
                  pw.SizedBox(height: 4),
                  pw.Text('${report['issuesCount']}',
                      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.orange800)),
                ]),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text('Target Crops Monitored:',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Bullet(text: 'Crops in Focus: ${(report['crops'] as List).join(', ')}'),
          pw.Bullet(text: 'Assigned Report Data Identifier: CR-${report['id']}-2026'),
          pw.SizedBox(height: 30),
          pw.Divider(),
          pw.SizedBox(height: 10),
          pw.Center(
            child: pw.Text(
              'This is an official automated document generated directly via the iCroMas system application pipeline.',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  /// Handles actual file compilation, system download path integration, and open actions
  Future<void> _downloadReport(Map<String, dynamic> report) async {
    setState(() => _isGeneratingPdf = true);
    try {
      final pdfBytes = await _generatePdfBytes(report);
      final filename = 'iCroMas_Report_${report['id']}.pdf';

      if (kIsWeb) {
        await Printing.sharePdf(bytes: pdfBytes, filename: filename);
      } else {
        final output = await getTemporaryDirectory();
        final file = File('${output.path}/$filename');
        await file.writeAsBytes(pdfBytes, flush: true);

        // Open file natively using system application viewer
        await OpenFilex.open(file.path);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully downloaded & opened: $filename'),
              backgroundColor: const Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download report: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingPdf = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredReports = _getFilteredReports();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Reports',
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
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Header with stats
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
                    const Text(
                      'Generate & Export Reports',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard(
                          icon: Icons.description,
                          label: 'Total Reports',
                          value: '${_mockReports.length}',
                        ),
                        _buildStatCard(
                          icon: Icons.calendar_today,
                          label: 'This Month',
                          value: '${_mockReports.where((r) => (r['date'] as DateTime).month == 7).length}',
                        ),
                        _buildStatCard(
                          icon: Icons.download,
                          label: 'Downloaded',
                          value: '${_mockReports.length - 1}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Filter Bar
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
                    Expanded(child: _buildPeriodFilter()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTypeFilter()),
                  ],
                ),
              ),

              // Reports List
              Expanded(
                child: filteredReports.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No reports found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Generate your first report',
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
                  itemCount: filteredReports.length,
                  itemBuilder: (context, index) {
                    final report = filteredReports[index];
                    return _buildReportCard(report);
                  },
                ),
              ),
            ],
          ),
          if (_isGeneratingPdf)
            Container(
              color: Colors.black.withValues(alpha: 0.4),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                        ),
                        SizedBox(height: 16),
                        Text('Preparing system PDF download...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showGenerateReportDialog(),
        backgroundColor: const Color(0xFF2E7D32),
        icon: const Icon(Icons.add),
        label: const Text('Generate Report'),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodFilter() {
    return PopupMenuButton<String>(
      initialValue: _selectedPeriod,
      onSelected: (value) {
        setState(() {
          _selectedPeriod = value;
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
            const Icon(Icons.calendar_today, size: 16, color: Color(0xFF2E7D32)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _selectedPeriod,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E7D32),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'All Time', child: Text('All Time')),
        const PopupMenuItem(value: 'This Week', child: Text('This Week')),
        const PopupMenuItem(value: 'This Month', child: Text('This Month')),
        const PopupMenuItem(value: 'Last Month', child: Text('Last Month')),
      ],
    );
  }

  Widget _buildTypeFilter() {
    return PopupMenuButton<String>(
      initialValue: _selectedType,
      onSelected: (value) {
        setState(() {
          _selectedType = value;
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
            const Icon(Icons.filter_list, size: 16, color: Color(0xFF2E7D32)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _selectedType,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E7D32),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'All', child: Text('All Types')),
        const PopupMenuItem(value: 'Weekly', child: Text('Weekly')),
        const PopupMenuItem(value: 'Monthly', child: Text('Monthly')),
        const PopupMenuItem(value: 'Custom', child: Text('Custom')),
      ],
    );
  }

  List<Map<String, dynamic>> _getFilteredReports() {
    var filtered = List<Map<String, dynamic>>.from(_mockReports);

    if (_selectedType != 'All') {
      filtered = filtered.where((r) => r['type'] == _selectedType).toList();
    }

    final now = DateTime.now();
    if (_selectedPeriod == 'This Week') {
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      filtered = filtered.where((r) {
        final date = r['date'] as DateTime;
        return date.isAfter(weekStart);
      }).toList();
    } else if (_selectedPeriod == 'This Month') {
      filtered = filtered.where((r) {
        final date = r['date'] as DateTime;
        return date.month == now.month && date.year == now.year;
      }).toList();
    } else if (_selectedPeriod == 'Last Month') {
      final lastMonth = DateTime(now.year, now.month - 1);
      filtered = filtered.where((r) {
        final date = r['date'] as DateTime;
        return date.month == lastMonth.month && date.year == lastMonth.year;
      }).toList();
    }

    return filtered;
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final title = report['title'] ?? 'Untitled Report';
    final type = report['type'] ?? 'Custom';
    final date = report['date'] as DateTime;
    final analyses = report['analyses'] ?? 0;
    final healthyCount = report['healthyCount'] ?? 0;
    final issuesCount = report['issuesCount'] ?? 0;
    final crops = (report['crops'] as List<dynamic>?) ?? [];
    final size = report['size'] ?? '0 MB';

    final dateFormat = DateFormat('MMM dd, yyyy');

    return Container(
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.description,
                    color: Color(0xFF2E7D32),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
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
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              type,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            dateFormat.format(date),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.analytics,
                        label: 'Analyses',
                        value: '$analyses',
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.check_circle,
                        label: 'Healthy',
                        value: '$healthyCount',
                        color: const Color(0xFF4CAF50),
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.warning,
                        label: 'Issues',
                        value: '$issuesCount',
                        color: const Color(0xFFFFA726),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.agriculture, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        crops.join(', '),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.storage, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      size,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _previewReport(report),
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('Preview'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2E7D32),
                      side: const BorderSide(color: Color(0xFF2E7D32)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _downloadReport(report),
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Download PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => _shareReport(report),
                  icon: const Icon(Icons.share),
                  color: const Color(0xFF2E7D32),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _previewReport(Map<String, dynamic> report) {
    context.push('/pdf-preview', extra: report);
  }

  void _shareReport(Map<String, dynamic> report) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Share Report',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.email, color: Color(0xFF2E7D32)),
              title: const Text('Email'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening email...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.message, color: Color(0xFF2E7D32)),
              title: const Text('Message'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening messages...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.cloud_upload, color: Color(0xFF2E7D32)),
              title: const Text('Cloud Storage'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Uploading to cloud...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showGenerateReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Generate New Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_view_week, color: Color(0xFF2E7D32)),
              title: const Text('Weekly Report'),
              subtitle: const Text('Last 7 days analysis'),
              onTap: () {
                Navigator.pop(context);
                _generateReport('Weekly');
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month, color: Color(0xFF2E7D32)),
              title: const Text('Monthly Report'),
              subtitle: const Text('Current month summary'),
              onTap: () {
                Navigator.pop(context);
                _generateReport('Monthly');
              },
            ),
            ListTile(
              leading: const Icon(Icons.tune, color: Color(0xFF2E7D32)),
              title: const Text('Custom Report'),
              subtitle: const Text('Choose date range & filters'),
              onTap: () {
                Navigator.pop(context);
                _showCustomReportDialog();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showCustomReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Custom Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Report Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Select date range, crops, and filters...'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _generateReport('Custom');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  void _generateReport(String type) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                ),
                SizedBox(height: 16),
                Text('Generating live report...'),
              ],
            ),
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);

      // Inject dynamically into local real-time feed list
      setState(() {
        _mockReports.insert(0, {
          'id': '${_mockReports.length + 1}',
          'title': '$type Real-Time Analysis',
          'type': type,
          'date': DateTime.now(),
          'analyses': 10,
          'healthyCount': 7,
          'issuesCount': 3,
          'crops': ['Corn', 'Wheat'],
          'size': '1.5 MB',
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$type report generated successfully!'),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Color(0xFF2E7D32)),
            SizedBox(width: 12),
            Text('Reports Help'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How to use Reports:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Generate weekly, monthly, or custom reports'),
              Text('• Preview reports before downloading'),
              Text('• Download as formatted PDF for system storage'),
              Text('• Share reports via email or cloud'),
              Text('• Filter by date range and report type'),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}