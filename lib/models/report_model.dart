import 'package:flutter/material.dart';

/// Represents a comprehensive report in the Crop Analyzer app.
/// Includes analytical, financial, and agronomic summaries for crops.
class ReportModel {
  /// Unique identifier for the report.
  final String id;

  /// Reference to the user who generated the report.
  final String userId;

  /// Report title.
  final String title;

  /// Report type (Analysis/Harvest/Season/Custom/Monthly/Yearly).
  final String reportType;

  /// Date when the report was generated.
  final DateTime generatedDate;

  /// Start date of the report period.
  final DateTime startDate;

  /// End date of the report period.
  final DateTime endDate;

  /// List of crop IDs included in the report.
  final List<String> cropIds;

  /// List of crop names (optional).
  final List<String>? cropNames;

  /// Executive summary of the report.
  final String summary;

  /// Total number of analyses included.
  final int totalAnalyses;

  /// Number of healthy analyses.
  final int healthyCount;

  /// Number of moderate analyses.
  final int moderateCount;

  /// Number of poor analyses.
  final int poorCount;

  /// Number of critical analyses (optional).
  final int? criticalCount;

  /// List of recommendations.
  final List<String> recommendations;

  /// Key findings (optional).
  final List<String>? keyFindings;

  /// Diseases detected (optional).
  final List<String>? diseaseDetected;

  /// Pests detected (optional).
  final List<String>? pestsDetected;

  /// Total field area in hectares (optional).
  final double? totalFieldArea;

  /// Total yield in kilograms (optional).
  final double? totalYield;

  /// Average yield per hectare (optional).
  final double? averageYield;

  /// Total investment (optional).
  final double? totalInvestment;

  /// Total revenue (optional).
  final double? totalRevenue;

  /// Profit or loss (optional).
  final double? profitLoss;

  /// Return on investment percentage (optional).
  final double? roi;

  /// Weather summary (optional).
  final String? weatherSummary;

  /// Overall nitrogen status (optional).
  final String? nitrogenStatus;

  /// Fertilizers used (optional).
  final List<String>? fertilizerUsed;

  /// Pesticides used (optional).
  final List<String>? pesticidesUsed;

  /// Chart data (optional).
  final List<Map<String, dynamic>>? charts;

  /// Image URLs (optional).
  final List<String>? images;

  /// Generated PDF URL (optional).
  final String? pdfUrl;

  /// Report status (Draft/Final/Archived).
  final String status;

  /// User IDs the report is shared with (optional).
  final List<String>? sharedWith;

  /// Additional notes (optional).
  final String? notes;

  /// Record creation timestamp.
  final DateTime createdAt;

  /// Last update timestamp (optional).
  final DateTime? updatedAt;

  ReportModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.reportType,
    required this.generatedDate,
    required this.startDate,
    required this.endDate,
    required this.cropIds,
    this.cropNames,
    required this.summary,
    required this.totalAnalyses,
    required this.healthyCount,
    required this.moderateCount,
    required this.poorCount,
    this.criticalCount,
    required this.recommendations,
    this.keyFindings,
    this.diseaseDetected,
    this.pestsDetected,
    this.totalFieldArea,
    this.totalYield,
    this.averageYield,
    this.totalInvestment,
    this.totalRevenue,
    this.profitLoss,
    this.roi,
    this.weatherSummary,
    this.nitrogenStatus,
    this.fertilizerUsed,
    this.pesticidesUsed,
    this.charts,
    this.images,
    this.pdfUrl,
    required this.status,
    this.sharedWith,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor for creating a [ReportModel] from JSON data.
  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      reportType: json['reportType'] ?? 'Custom',
      generatedDate: DateTime.parse(json['generatedDate']),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      cropIds: List<String>.from(json['cropIds'] ?? []),
      cropNames: json['cropNames'] != null
          ? List<String>.from(json['cropNames'])
          : null,
      summary: json['summary'] ?? '',
      totalAnalyses: json['totalAnalyses'] ?? 0,
      healthyCount: json['healthyCount'] ?? 0,
      moderateCount: json['moderateCount'] ?? 0,
      poorCount: json['poorCount'] ?? 0,
      criticalCount: json['criticalCount'],
      recommendations: List<String>.from(json['recommendations'] ?? []),
      keyFindings: json['keyFindings'] != null
          ? List<String>.from(json['keyFindings'])
          : null,
      diseaseDetected: json['diseaseDetected'] != null
          ? List<String>.from(json['diseaseDetected'])
          : null,
      pestsDetected: json['pestsDetected'] != null
          ? List<String>.from(json['pestsDetected'])
          : null,
      totalFieldArea: (json['totalFieldArea'] != null)
          ? (json['totalFieldArea'] as num).toDouble()
          : null,
      totalYield: (json['totalYield'] != null)
          ? (json['totalYield'] as num).toDouble()
          : null,
      averageYield: (json['averageYield'] != null)
          ? (json['averageYield'] as num).toDouble()
          : null,
      totalInvestment: (json['totalInvestment'] != null)
          ? (json['totalInvestment'] as num).toDouble()
          : null,
      totalRevenue: (json['totalRevenue'] != null)
          ? (json['totalRevenue'] as num).toDouble()
          : null,
      profitLoss: (json['profitLoss'] != null)
          ? (json['profitLoss'] as num).toDouble()
          : null,
      roi: (json['roi'] != null) ? (json['roi'] as num).toDouble() : null,
      weatherSummary: json['weatherSummary'],
      nitrogenStatus: json['nitrogenStatus'],
      fertilizerUsed: json['fertilizerUsed'] != null
          ? List<String>.from(json['fertilizerUsed'])
          : null,
      pesticidesUsed: json['pesticidesUsed'] != null
          ? List<String>.from(json['pesticidesUsed'])
          : null,
      charts: json['charts'] != null
          ? List<Map<String, dynamic>>.from(json['charts'])
          : null,
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : null,
      pdfUrl: json['pdfUrl'],
      status: json['status'] ?? 'Draft',
      sharedWith: json['sharedWith'] != null
          ? List<String>.from(json['sharedWith'])
          : null,
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
      json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  /// Converts the [ReportModel] instance to a JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'title': title,
    'reportType': reportType,
    'generatedDate': generatedDate.toIso8601String(),
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'cropIds': cropIds,
    'cropNames': cropNames,
    'summary': summary,
    'totalAnalyses': totalAnalyses,
    'healthyCount': healthyCount,
    'moderateCount': moderateCount,
    'poorCount': poorCount,
    'criticalCount': criticalCount,
    'recommendations': recommendations,
    'keyFindings': keyFindings,
    'diseaseDetected': diseaseDetected,
    'pestsDetected': pestsDetected,
    'totalFieldArea': totalFieldArea,
    'totalYield': totalYield,
    'averageYield': averageYield,
    'totalInvestment': totalInvestment,
    'totalRevenue': totalRevenue,
    'profitLoss': profitLoss,
    'roi': roi,
    'weatherSummary': weatherSummary,
    'nitrogenStatus': nitrogenStatus,
    'fertilizerUsed': fertilizerUsed,
    'pesticidesUsed': pesticidesUsed,
    'charts': charts,
    'images': images,
    'pdfUrl': pdfUrl,
    'status': status,
    'sharedWith': sharedWith,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  /// Creates a copy of this [ReportModel] with updated fields.
  ReportModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? reportType,
    DateTime? generatedDate,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? cropIds,
    List<String>? cropNames,
    String? summary,
    int? totalAnalyses,
    int? healthyCount,
    int? moderateCount,
    int? poorCount,
    int? criticalCount,
    List<String>? recommendations,
    List<String>? keyFindings,
    List<String>? diseaseDetected,
    List<String>? pestsDetected,
    double? totalFieldArea,
    double? totalYield,
    double? averageYield,
    double? totalInvestment,
    double? totalRevenue,
    double? profitLoss,
    double? roi,
    String? weatherSummary,
    String? nitrogenStatus,
    List<String>? fertilizerUsed,
    List<String>? pesticidesUsed,
    List<Map<String, dynamic>>? charts,
    List<String>? images,
    String? pdfUrl,
    String? status,
    List<String>? sharedWith,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReportModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      reportType: reportType ?? this.reportType,
      generatedDate: generatedDate ?? this.generatedDate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      cropIds: cropIds ?? this.cropIds,
      cropNames: cropNames ?? this.cropNames,
      summary: summary ?? this.summary,
      totalAnalyses: totalAnalyses ?? this.totalAnalyses,
      healthyCount: healthyCount ?? this.healthyCount,
      moderateCount: moderateCount ?? this.moderateCount,
      poorCount: poorCount ?? this.poorCount,
      criticalCount: criticalCount ?? this.criticalCount,
      recommendations: recommendations ?? this.recommendations,
      keyFindings: keyFindings ?? this.keyFindings,
      diseaseDetected: diseaseDetected ?? this.diseaseDetected,
      pestsDetected: pestsDetected ?? this.pestsDetected,
      totalFieldArea: totalFieldArea ?? this.totalFieldArea,
      totalYield: totalYield ?? this.totalYield,
      averageYield: averageYield ?? this.averageYield,
      totalInvestment: totalInvestment ?? this.totalInvestment,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      profitLoss: profitLoss ?? this.profitLoss,
      roi: roi ?? this.roi,
      weatherSummary: weatherSummary ?? this.weatherSummary,
      nitrogenStatus: nitrogenStatus ?? this.nitrogenStatus,
      fertilizerUsed: fertilizerUsed ?? this.fertilizerUsed,
      pesticidesUsed: pesticidesUsed ?? this.pesticidesUsed,
      charts: charts ?? this.charts,
      images: images ?? this.images,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      status: status ?? this.status,
      sharedWith: sharedWith ?? this.sharedWith,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Returns a color representing the report type.
  Color getReportTypeColor() {
    switch (reportType.toLowerCase()) {
      case 'analysis':
        return Colors.blue;
      case 'harvest':
        return Colors.green;
      case 'season':
        return Colors.orange;
      case 'custom':
        return Colors.purple;
      case 'monthly':
        return Colors.teal;
      case 'yearly':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  /// Returns an icon representing the report type.
  IconData getReportTypeIcon() {
    switch (reportType.toLowerCase()) {
      case 'analysis':
        return Icons.analytics;
      case 'harvest':
        return Icons.agriculture;
      case 'season':
        return Icons.calendar_month;
      case 'custom':
        return Icons.tune;
      case 'monthly':
        return Icons.date_range;
      case 'yearly':
        return Icons.timeline;
      default:
        return Icons.insert_drive_file;
    }
  }

  /// Returns the percentage of healthy analyses.
  double getHealthPercentage() {
    if (totalAnalyses == 0) return 0;
    return (healthyCount / totalAnalyses) * 100;
  }

  /// Returns a color representing the report status.
  Color getStatusColor() {
    switch (status.toLowerCase()) {
      case 'draft':
        return Colors.orange;
      case 'final':
        return Colors.green;
      case 'archived':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  /// Returns an icon representing the report status.
  IconData getStatusIcon() {
    switch (status.toLowerCase()) {
      case 'draft':
        return Icons.edit;
      case 'final':
        return Icons.check_circle;
      case 'archived':
        return Icons.archive;
      default:
        return Icons.description;
    }
  }

  /// Returns true if the report is a draft.
  bool isDraft() => status.toLowerCase() == 'draft';

  /// Returns true if the report is final.
  bool isFinal() => status.toLowerCase() == 'final';

  /// Calculates an overall health score (0–100).
  double calculateHealthScore() {
    if (totalAnalyses == 0) return 0;
    final weighted = (healthyCount * 1.0) +
        (moderateCount * 0.7) +
        (poorCount * 0.4) +
        ((criticalCount ?? 0) * 0.2);
    return (weighted / totalAnalyses) * 100;
  }

  /// Returns the duration of the report period in days.
  int getPeriodDuration() => endDate.difference(startDate).inDays;

  /// Returns a short summary string.
  String getSummaryText() =>
      '$title (${reportType.toUpperCase()}) - ${getPeriodDuration()} days | Health: ${getHealthPercentage().toStringAsFixed(1)}%';

  /// Returns true if financial data is available.
  bool hasFinancialData() =>
      totalInvestment != null &&
          totalRevenue != null &&
          profitLoss != null &&
          roi != null;

  /// Returns ROI status (Profitable/Loss/Neutral).
  String getROIStatus() {
    if (roi == null) return 'Unknown';
    if (roi! > 0) return 'Profitable';
    if (roi! < 0) return 'Loss';
    return 'Neutral';
  }

  @override
  String toString() =>
      'ReportModel(id: $id, title: $title, type: $reportType, status: $status, ROI: $roi)';

  // -----------------------------
  // Constants
  // -----------------------------

  static const List<String> reportTypes = [
    'Analysis',
    'Harvest',
    'Season',
    'Custom',
    'Monthly',
    'Yearly',
  ];

  static const List<String> statusLevels = [
    'Draft',
    'Final',
    'Archived',
  ];
}