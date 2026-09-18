import 'dart:io';
import 'dart:typed_data'; // ← ADD THIS LINE
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class CropData {
  final String cropName;
  final String cropType;
  final DateTime analysisDate;
  final String healthStatus;
  final String growthStage;
  final String recommendations;
  final List<File>? images;
  final Map<String, dynamic>? metrics;

  CropData({
    required this.cropName,
    required this.cropType,
    required this.analysisDate,
    required this.healthStatus,
    required this.growthStage,
    required this.recommendations,
    this.images,
    this.metrics,
  });
}

class DiseaseData {
  final String diseaseName;
  final String diseaseType;
  final DateTime detectionDate;
  final String severityLevel;
  final double affectedArea;
  final String treatment;
  final List<File>? images;
  final String preventionTips;

  DiseaseData({
    required this.diseaseName,
    required this.diseaseType,
    required this.detectionDate,
    required this.severityLevel,
    required this.affectedArea,
    required this.treatment,
    this.images,
    required this.preventionTips,
  });
}

class FieldData {
  final String fieldName;
  final String location;
  final double area;
  final String cropType;
  final DateTime plantingDate;
  final String weatherSummary;
  final String irrigationSchedule;
  final String fertilizerPlan;
  final String harvestPrediction;

  FieldData({
    required this.fieldName,
    required this.location,
    required this.area,
    required this.cropType,
    required this.plantingDate,
    required this.weatherSummary,
    required this.irrigationSchedule,
    required this.fertilizerPlan,
    required this.harvestPrediction,
  });
}

class PdfService {
  static final PdfService _instance = PdfService._internal();
  factory PdfService() => _instance;
  PdfService._internal();

  Future<pw.Font> _loadFont() async {
    final fontData = await rootBundle.load('assets/fonts/Poppins-Regular.ttf');
    return pw.Font.ttf(fontData);
  }

  Future<pw.Font> _loadBoldFont() async {
    final fontData = await rootBundle.load('assets/fonts/Poppins-Bold.ttf');
    return pw.Font.ttf(fontData);
  }

  String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  Future<pw.Widget> buildHeader(String title) async {
    try {
      final logo = await imageFromAssetBundle('assets/images/logo.png');
      return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Image(logo, width: 50, height: 50),
          pw.Text(title,
              style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green)),
          pw.Text(formatDate(DateTime.now()),
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
        ],
      );
    } catch (e) {
      // If logo not found, return header without logo
      return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(title,
              style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green)),
          pw.Text(formatDate(DateTime.now()),
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
        ],
      );
    }
  }

  pw.Widget buildFooter(int pageNumber, int totalPages) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text('Page $pageNumber of $totalPages',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
    );
  }

  pw.Widget buildTextSection(String title, String content) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title,
            style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.green)),
        pw.SizedBox(height: 4),
        pw.Text(content, style: const pw.TextStyle(fontSize: 12)),
        pw.SizedBox(height: 10),
      ],
    );
  }

  pw.Widget buildTable(List<List<String>> data) {
    return pw.TableHelper.fromTextArray(
      headers: data.first,
      data: data.sublist(1),
      headerStyle: pw.TextStyle(
          fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 12),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.green),
      cellStyle: const pw.TextStyle(fontSize: 11),
      cellAlignment: pw.Alignment.centerLeft,
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
    );
  }

  pw.Widget buildImageSection(Uint8List imageBytes, String caption) {
    try {
      final imageWidget = pw.MemoryImage(imageBytes);
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Image(imageWidget, width: 200, height: 150, fit: pw.BoxFit.cover),
          pw.SizedBox(height: 4),
          pw.Text(caption,
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
        ],
      );
    } catch (_) {
      return pw.Text('Error loading image: $caption',
          style: const pw.TextStyle(color: PdfColors.red));
    }
  }

  Future<pw.Document> generateCropAnalysisReport(CropData data) async {
    final pdf = pw.Document();
    final font = await _loadFont();
    final boldFont = await _loadBoldFont();
    final header = await buildHeader('Crop Analysis Report');

    // Pre-load images
    final List<Uint8List> imageBytesList = [];
    if (data.images != null) {
      for (var img in data.images!) {
        try {
          imageBytesList.add(await img.readAsBytes());
        } catch (e) {
          // Silently skip failed images
        }
      }
    }

    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          header,
          pw.SizedBox(height: 20),
          buildTextSection('Crop Name', data.cropName),
          buildTextSection('Crop Type', data.cropType),
          buildTextSection('Analysis Date', formatDate(data.analysisDate)),
          buildTextSection('Health Status', data.healthStatus),
          buildTextSection('Growth Stage', data.growthStage),
          buildTextSection('Recommendations', data.recommendations),
          if (data.metrics != null && data.metrics!.isNotEmpty)
            buildTable([
              ['Metric', 'Value'],
              ...data.metrics!.entries.map((e) => [e.key, e.value.toString()]),
            ]),
          if (imageBytesList.isNotEmpty)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Images',
                    style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green)),
                pw.SizedBox(height: 10),
                pw.Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (var imgBytes in imageBytesList)
                      buildImageSection(imgBytes, 'Crop Image'),
                  ],
                ),
              ],
            ),
        ],
        footer: (context) => buildFooter(context.pageNumber, context.pagesCount),
      ),
    );
    return pdf;
  }

  Future<pw.Document> generateDiseaseReport(DiseaseData data) async {
    final pdf = pw.Document();
    final font = await _loadFont();
    final boldFont = await _loadBoldFont();
    final header = await buildHeader('Disease Detection Report');

    // Pre-load images
    final List<Uint8List> imageBytesList = [];
    if (data.images != null) {
      for (var img in data.images!) {
        try {
          imageBytesList.add(await img.readAsBytes());
        } catch (e) {
          // Silently skip failed images
        }
      }
    }

    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          header,
          pw.SizedBox(height: 20),
          buildTextSection('Disease Name', data.diseaseName),
          buildTextSection('Disease Type', data.diseaseType),
          buildTextSection('Detection Date', formatDate(data.detectionDate)),
          buildTextSection('Severity Level', data.severityLevel),
          buildTextSection(
              'Affected Area', '${data.affectedArea.toStringAsFixed(2)}%'),
          buildTextSection('Treatment Recommendations', data.treatment),
          buildTextSection('Prevention Tips', data.preventionTips),
          if (imageBytesList.isNotEmpty)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Images',
                    style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green)),
                pw.SizedBox(height: 10),
                pw.Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (var imgBytes in imageBytesList)
                      buildImageSection(imgBytes, 'Disease Image'),
                  ],
                ),
              ],
            ),
        ],
        footer: (context) => buildFooter(context.pageNumber, context.pagesCount),
      ),
    );
    return pdf;
  }

  Future<pw.Document> generateFieldReport(FieldData data) async {
    final pdf = pw.Document();
    final font = await _loadFont();
    final boldFont = await _loadBoldFont();
    final header = await buildHeader('Field Management Report');

    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          header,
          pw.SizedBox(height: 20),
          buildTextSection('Field Name', data.fieldName),
          buildTextSection('Location', data.location),
          buildTextSection('Area', '${data.area.toStringAsFixed(2)} acres'),
          buildTextSection('Crop Type', data.cropType),
          buildTextSection('Planting Date', formatDate(data.plantingDate)),
          buildTextSection('Weather Summary', data.weatherSummary),
          buildTextSection('Irrigation Schedule', data.irrigationSchedule),
          buildTextSection('Fertilizer Plan', data.fertilizerPlan),
          buildTextSection('Harvest Prediction', data.harvestPrediction),
        ],
        footer: (context) => buildFooter(context.pageNumber, context.pagesCount),
      ),
    );
    return pdf;
  }

  Future<pw.Document> generateSummaryReport(List<dynamic> dataList) async {
    final pdf = pw.Document();
    final font = await _loadFont();
    final boldFont = await _loadBoldFont();
    final header = await buildHeader('Summary Report');

    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          header,
          pw.SizedBox(height: 20),
          buildTable([
            ['Type', 'Name', 'Date', 'Details'],
            ...dataList.map((data) {
              if (data is CropData) {
                return [
                  'Crop',
                  data.cropName,
                  formatDate(data.analysisDate),
                  data.healthStatus
                ];
              } else if (data is DiseaseData) {
                return [
                  'Disease',
                  data.diseaseName,
                  formatDate(data.detectionDate),
                  data.severityLevel
                ];
              } else if (data is FieldData) {
                return [
                  'Field',
                  data.fieldName,
                  formatDate(data.plantingDate),
                  data.cropType
                ];
              } else {
                return ['Unknown', '-', '-', '-'];
              }
            }),
          ]),
        ],
        footer: (context) => buildFooter(context.pageNumber, context.pagesCount),
      ),
    );
    return pdf;
  }

  Future<File> savePdf(pw.Document pdf, String filename) async {
    try {
      final bytes = await pdf.save();
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$filename.pdf');
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      throw Exception('Error saving PDF: $e');
    }
  }

  Future<void> sharePdf(pw.Document pdf, String filename) async {
    try {
      final file = await savePdf(pdf, filename);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Crop Analyzer Report',
      );
    } catch (e) {
      throw Exception('Error sharing PDF: $e');
    }
  }

  Future<void> previewPdf(pw.Document pdf) async {
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

  Future<void> printPdf(pw.Document pdf) async {
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }
}