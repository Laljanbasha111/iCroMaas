import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Utility class for generating reports in multiple formats.
class ReportGenerator {
  /// Generates a professional PDF report from analysis data.
  static Future<File?> generatePdfReport(Map<String, dynamic> data) async {
    try {
      final pdf = pw.Document();
      final logo = await imageFromAssetBundle('assets/images/app_logo.png');
      final cropImagePath = data['cropImagePath'] as String?;
      pw.ImageProvider? cropImage;
      if (cropImagePath != null && File(cropImagePath).existsSync()) {
        cropImage = pw.MemoryImage(File(cropImagePath).readAsBytesSync());
      }

      pdf.addPage(
        pw.MultiPage(
          pageTheme: pw.PageTheme(
            margin: const pw.EdgeInsets.all(24),
            theme: pw.ThemeData.withFont(
              base: await PdfGoogleFonts.robotoRegular(),
              bold: await PdfGoogleFonts.robotoBold(),
            ),
          ),
          build: (context) => [
            _buildPdfHeader(logo),
            pw.SizedBox(height: 16),
            _buildCoverPage(data),
            pw.SizedBox(height: 16),
            _buildExecutiveSummary(data),
            pw.SizedBox(height: 16),
            _buildDetailedAnalysis(data),
            pw.SizedBox(height: 16),
            _buildVisualData(data),
            pw.SizedBox(height: 16),
            _buildRecommendations(data),
            pw.SizedBox(height: 16),
            _buildAppendix(data, cropImage),
            pw.SizedBox(height: 24),
            _buildPdfFooter(),
          ],
          footer: (context) => pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
          ),
        ),
      );

      final bytes = await pdf.save();
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/crop_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      debugPrint('Error generating PDF: $e');
      return null;
    }
  }

  /// Generates a plain text report.
  static Future<File?> generateTextReport(Map<String, dynamic> data) async {
    try {
      final buffer = StringBuffer();
      buffer.writeln('CROP ANALYZER REPORT');
      buffer.writeln('====================');
      buffer.writeln('Date: ${_formatDate(DateTime.now())}');
      buffer.writeln('Crop Type: ${data['cropType'] ?? 'N/A'}');
      buffer.writeln('Health Score: ${data['healthScore'] ?? 'N/A'}%');
      buffer.writeln('\n--- Disease Detection ---');
      final detections = data['detections'] as List<dynamic>? ?? [];
      for (var d in detections) {
        buffer.writeln('${d['name']} - Confidence: ${d['confidence']}%');
      }
      buffer.writeln('\n--- Recommendations ---');
      final recs = data['recommendations'] as List<dynamic>? ?? [];
      for (var r in recs) {
        buffer.writeln('- $r');
      }

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/crop_report_${DateTime.now().millisecondsSinceEpoch}.txt');
      await file.writeAsString(buffer.toString());
      return file;
    } catch (e) {
      debugPrint('Error generating text report: $e');
      return null;
    }
  }

  /// Generates a JSON report.
  static Future<File?> generateJsonReport(Map<String, dynamic> data) async {
    try {
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/crop_report_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonString);
      return file;
    } catch (e) {
      debugPrint('Error generating JSON report: $e');
      return null;
    }
  }

  /// Generates a CSV report.
  static Future<File?> generateCsvReport(Map<String, dynamic> data) async {
    try {
      final buffer = StringBuffer();
      buffer.writeln('Field,Value');
      buffer.writeln('Date,${_formatDate(DateTime.now())}');
      buffer.writeln('Crop Type,${data['cropType'] ?? 'N/A'}');
      buffer.writeln('Health Score,${data['healthScore'] ?? 'N/A'}');
      buffer.writeln('\nDisease,Pest Detection');
      final detections = data['detections'] as List<dynamic>? ?? [];
      for (var d in detections) {
        buffer.writeln('${d['name']},${d['confidence']}%');
      }
      buffer.writeln('\nRecommendations');
      final recs = data['recommendations'] as List<dynamic>? ?? [];
      for (var r in recs) {
        buffer.writeln(r);
      }

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/crop_report_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(buffer.toString());
      return file;
    } catch (e) {
      debugPrint('Error generating CSV report: $e');
      return null;
    }
  }

  /// Builds the PDF header.
  static pw.Widget _buildPdfHeader(pw.ImageProvider logo) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Row(
          children: [
            pw.Image(logo, width: 50, height: 50),
            pw.SizedBox(width: 12),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Crop Analyzer Report',
                    style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.Text('AI-Powered Crop Health Analysis',
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
              ],
            ),
          ],
        ),
        pw.Text(
          _formatDate(DateTime.now()),
          style: const pw.TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  /// Builds the cover page.
  static pw.Widget _buildCoverPage(Map<String, dynamic> data) {
    return pw.Center(
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text('Crop Analyzer Report',
              style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),
          pw.Text('Generated on ${_formatDate(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
          pw.SizedBox(height: 24),
          pw.Text('Crop Type: ${data['cropType'] ?? 'N/A'}',
              style: const pw.TextStyle(fontSize: 16)),
          pw.SizedBox(height: 8),
          pw.Text('Location: ${data['location'] ?? 'Unknown'}',
              style: const pw.TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  /// Builds the executive summary section.
  static pw.Widget _buildExecutiveSummary(Map<String, dynamic> data) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.green100,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Executive Summary',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text(
            'This report provides an AI-driven analysis of crop health, identifying potential diseases, pests, and providing actionable recommendations for improved yield and sustainability.',
            style: const pw.TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// Builds the detailed analysis section.
  static pw.Widget _buildDetailedAnalysis(Map<String, dynamic> data) {
    final detections = data['detections'] as List<dynamic>? ?? [];
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Detailed Analysis',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          _buildTable([
            ['Crop Type', data['cropType'] ?? 'N/A'],
            ['Variety', data['variety'] ?? 'N/A'],
            ['Growth Stage', data['growthStage'] ?? 'N/A'],
            ['Health Score', '${data['healthScore'] ?? 'N/A'}%'],
          ]),
          pw.SizedBox(height: 12),
          pw.Text('Detected Issues:',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          detections.isEmpty
              ? pw.Text('No diseases or pests detected.')
              : _buildTable([
            ['Name', 'Confidence'],
            ...detections.map((d) => [d['name'], '${d['confidence']}%']),
          ]),
        ],
      ),
    );
  }

  /// Builds the visual data section (charts and graphs).
  static pw.Widget _buildVisualData(Map<String, dynamic> data) {
    final score = (data['healthScore'] ?? 0).toDouble();
    final color = _getHealthColor(score);
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue100,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Visual Data',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          _buildChart(score, color),
        ],
      ),
    );
  }

  /// Builds the recommendations section.
  static pw.Widget _buildRecommendations(Map<String, dynamic> data) {
    final recs = data['recommendations'] as List<dynamic>? ?? [];
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.amber100,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Recommendations',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          recs.isEmpty
              ? pw.Text('No specific recommendations available.')
              : pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: recs.map((r) => pw.Bullet(text: r.toString())).toList(),
          ),
        ],
      ),
    );
  }

  /// Builds the appendix section with images.
  static pw.Widget _buildAppendix(Map<String, dynamic> data, pw.ImageProvider? cropImage) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Appendix',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          if (cropImage != null)
            pw.Center(
              child: pw.Image(cropImage, width: 300, height: 200, fit: pw.BoxFit.cover),
            )
          else
            pw.Text('No crop image available.'),
        ],
      ),
    );
  }

  /// Builds the PDF footer.
  static pw.Widget _buildPdfFooter() {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.SizedBox(height: 8),
        pw.Text('Crop Analyzer © ${DateTime.now().year}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
        pw.Text('Empowering farmers with AI-driven insights',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
      ],
    );
  }

  /// Builds a table widget.
  static pw.Widget _buildTable(List<List<String>> rows) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: rows
          .map(
            (r) => pw.TableRow(
          children: r
              .map(
                (cell) => pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text(cell, style: const pw.TextStyle(fontSize: 12)),
            ),
          )
              .toList(),
        ),
      )
          .toList(),
    );
  }

  /// Builds a simple health score chart.
  static pw.Widget _buildChart(double score, PdfColor color) {
    return pw.Container(
      height: 100,
      child: pw.Stack(
        alignment: pw.Alignment.centerLeft,
        children: [
          pw.Container(
            width: 300,
            height: 20,
            decoration: pw.BoxDecoration(
              color: PdfColors.grey300,
              borderRadius: pw.BorderRadius.circular(10),
            ),
          ),
          pw.Container(
            width: 3 * score,
            height: 20,
            decoration: pw.BoxDecoration(
              color: color,
              borderRadius: pw.BorderRadius.circular(10),
            ),
          ),
          pw.Positioned(
            left: 310,
            child: pw.Text('${score.toStringAsFixed(1)}%',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: color)),
          ),
        ],
      ),
    );
  }

  /// Formats a date.
  static String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  /// Returns a color based on health score.
  static PdfColor _getHealthColor(double score) {
    if (score >= 80) return PdfColors.green;
    if (score >= 50) return PdfColors.orange;
    return PdfColors.red;
  }
}

