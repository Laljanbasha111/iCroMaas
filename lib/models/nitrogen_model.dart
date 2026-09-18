import 'package:flutter/material.dart';

/// Represents a nitrogen measurement record in the Crop Analyzer app.
/// Includes soil nitrogen data, environmental context, and fertilizer recommendations.
class NitrogenModel {
  /// Unique identifier for the nitrogen record.
  final String id;

  /// Reference to the crop this nitrogen measurement belongs to.
  final String cropId;

  /// Reference to the user who owns this record.
  final String userId;

  /// Nitrogen level in ppm or percentage.
  final double nitrogenLevel;

  /// Date and time when the measurement was taken.
  final DateTime measurementDate;

  /// How the measurement was taken (Soil test/Leaf analysis/Sensor).
  final String? measurementMethod;

  /// Soil depth in cm where measurement was taken.
  final double soilDepth;

  /// Status of nitrogen level (Deficient/Low/Optimal/High/Excess).
  final String status;

  /// Recommendation text based on nitrogen level.
  final String recommendation;

  /// Target nitrogen level for optimal growth.
  final double targetLevel;

  /// Deficiency amount if any.
  final double? currentDeficiency;

  /// Specific field location.
  final String? fieldLocation;

  /// GPS latitude.
  final double? latitude;

  /// GPS longitude.
  final double? longitude;

  /// Soil type.
  final String? soilType;

  /// Soil pH level.
  final double? soilPH;

  /// Soil moisture percentage.
  final double? soilMoisture;

  /// Soil temperature in Celsius.
  final double? temperature;

  /// Organic matter percentage.
  final double? organicMatter;

  /// Previous nitrogen level for comparison.
  final double? previousLevel;

  /// Trend direction (Increasing/Decreasing/Stable).
  final String? trendDirection;

  /// Specific fertilizer recommendation.
  final String? fertilizerRecommendation;

  /// Recommended fertilizer application rate in kg/ha.
  final double? applicationRate;

  /// When to test next.
  final DateTime? nextTestDate;

  /// Additional notes.
  final String? notes;

  /// Image of soil sample or test.
  final String? imageUrl;

  /// Testing laboratory name.
  final String? testLabName;

  /// Test report URL.
  final String? testReportUrl;

  /// Record creation timestamp.
  final DateTime createdAt;

  /// Last update timestamp.
  final DateTime? updatedAt;

  NitrogenModel({
    required this.id,
    required this.cropId,
    required this.userId,
    required this.nitrogenLevel,
    required this.measurementDate,
    this.measurementMethod,
    required this.soilDepth,
    required this.status,
    required this.recommendation,
    required this.targetLevel,
    this.currentDeficiency,
    this.fieldLocation,
    this.latitude,
    this.longitude,
    this.soilType,
    this.soilPH,
    this.soilMoisture,
    this.temperature,
    this.organicMatter,
    this.previousLevel,
    this.trendDirection,
    this.fertilizerRecommendation,
    this.applicationRate,
    this.nextTestDate,
    this.notes,
    this.imageUrl,
    this.testLabName,
    this.testReportUrl,
    required this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor for creating a [NitrogenModel] from JSON data.
  factory NitrogenModel.fromJson(Map<String, dynamic> json) {
    return NitrogenModel(
      id: json['id'] ?? '',
      cropId: json['cropId'] ?? '',
      userId: json['userId'] ?? '',
      nitrogenLevel: (json['nitrogenLevel'] ?? 0).toDouble(),
      measurementDate: DateTime.parse(json['measurementDate']),
      measurementMethod: json['measurementMethod'],
      soilDepth: (json['soilDepth'] ?? 0).toDouble(),
      status: json['status'] ?? 'Unknown',
      recommendation: json['recommendation'] ?? '',
      targetLevel: (json['targetLevel'] ?? 0).toDouble(),
      currentDeficiency: json['currentDeficiency'] != null
          ? (json['currentDeficiency'] as num).toDouble()
          : null,
      fieldLocation: json['fieldLocation'],
      latitude:
      json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      soilType: json['soilType'],
      soilPH:
      json['soilPH'] != null ? (json['soilPH'] as num).toDouble() : null,
      soilMoisture: json['soilMoisture'] != null
          ? (json['soilMoisture'] as num).toDouble()
          : null,
      temperature: json['temperature'] != null
          ? (json['temperature'] as num).toDouble()
          : null,
      organicMatter: json['organicMatter'] != null
          ? (json['organicMatter'] as num).toDouble()
          : null,
      previousLevel: json['previousLevel'] != null
          ? (json['previousLevel'] as num).toDouble()
          : null,
      trendDirection: json['trendDirection'],
      fertilizerRecommendation: json['fertilizerRecommendation'],
      applicationRate: json['applicationRate'] != null
          ? (json['applicationRate'] as num).toDouble()
          : null,
      nextTestDate: json['nextTestDate'] != null
          ? DateTime.parse(json['nextTestDate'])
          : null,
      notes: json['notes'],
      imageUrl: json['imageUrl'],
      testLabName: json['testLabName'],
      testReportUrl: json['testReportUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
      json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  /// Converts the [NitrogenModel] instance to a JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'cropId': cropId,
    'userId': userId,
    'nitrogenLevel': nitrogenLevel,
    'measurementDate': measurementDate.toIso8601String(),
    'measurementMethod': measurementMethod,
    'soilDepth': soilDepth,
    'status': status,
    'recommendation': recommendation,
    'targetLevel': targetLevel,
    'currentDeficiency': currentDeficiency,
    'fieldLocation': fieldLocation,
    'latitude': latitude,
    'longitude': longitude,
    'soilType': soilType,
    'soilPH': soilPH,
    'soilMoisture': soilMoisture,
    'temperature': temperature,
    'organicMatter': organicMatter,
    'previousLevel': previousLevel,
    'trendDirection': trendDirection,
    'fertilizerRecommendation': fertilizerRecommendation,
    'applicationRate': applicationRate,
    'nextTestDate': nextTestDate?.toIso8601String(),
    'notes': notes,
    'imageUrl': imageUrl,
    'testLabName': testLabName,
    'testReportUrl': testReportUrl,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  /// Creates a copy of this [NitrogenModel] with updated fields.
  NitrogenModel copyWith({
    String? id,
    String? cropId,
    String? userId,
    double? nitrogenLevel,
    DateTime? measurementDate,
    String? measurementMethod,
    double? soilDepth,
    String? status,
    String? recommendation,
    double? targetLevel,
    double? currentDeficiency,
    String? fieldLocation,
    double? latitude,
    double? longitude,
    String? soilType,
    double? soilPH,
    double? soilMoisture,
    double? temperature,
    double? organicMatter,
    double? previousLevel,
    String? trendDirection,
    String? fertilizerRecommendation,
    double? applicationRate,
    DateTime? nextTestDate,
    String? notes,
    String? imageUrl,
    String? testLabName,
    String? testReportUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NitrogenModel(
      id: id ?? this.id,
      cropId: cropId ?? this.cropId,
      userId: userId ?? this.userId,
      nitrogenLevel: nitrogenLevel ?? this.nitrogenLevel,
      measurementDate: measurementDate ?? this.measurementDate,
      measurementMethod: measurementMethod ?? this.measurementMethod,
      soilDepth: soilDepth ?? this.soilDepth,
      status: status ?? this.status,
      recommendation: recommendation ?? this.recommendation,
      targetLevel: targetLevel ?? this.targetLevel,
      currentDeficiency: currentDeficiency ?? this.currentDeficiency,
      fieldLocation: fieldLocation ?? this.fieldLocation,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      soilType: soilType ?? this.soilType,
      soilPH: soilPH ?? this.soilPH,
      soilMoisture: soilMoisture ?? this.soilMoisture,
      temperature: temperature ?? this.temperature,
      organicMatter: organicMatter ?? this.organicMatter,
      previousLevel: previousLevel ?? this.previousLevel,
      trendDirection: trendDirection ?? this.trendDirection,
      fertilizerRecommendation:
      fertilizerRecommendation ?? this.fertilizerRecommendation,
      applicationRate: applicationRate ?? this.applicationRate,
      nextTestDate: nextTestDate ?? this.nextTestDate,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
      testLabName: testLabName ?? this.testLabName,
      testReportUrl: testReportUrl ?? this.testReportUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Returns a color representing the nitrogen status.
  Color getStatusColor() {
    switch (status.toLowerCase()) {
      case 'deficient':
        return Colors.red;
      case 'low':
        return Colors.orange;
      case 'optimal':
        return Colors.green;
      case 'high':
        return Colors.blue;
      case 'excess':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  /// Returns an icon representing the nitrogen status.
  IconData getStatusIcon() {
    switch (status.toLowerCase()) {
      case 'deficient':
        return Icons.warning;
      case 'low':
        return Icons.trending_down;
      case 'optimal':
        return Icons.check_circle;
      case 'high':
        return Icons.trending_up;
      case 'excess':
        return Icons.error;
      default:
        return Icons.help_outline;
    }
  }

  /// Returns true if nitrogen level is deficient.
  bool isDeficient() => status.toLowerCase() == 'deficient' || status.toLowerCase() == 'low';

  /// Returns true if nitrogen level is optimal.
  bool isOptimal() => status.toLowerCase() == 'optimal';

  /// Returns true if nitrogen level is excessive.
  bool isExcess() => status.toLowerCase() == 'excess' || status.toLowerCase() == 'high';

  /// Returns deficiency percentage relative to target.
  double? getDeficiencyPercentage() {
    if (targetLevel <= 0) return null;
    if (nitrogenLevel >= targetLevel) return 0;
    return ((targetLevel - nitrogenLevel) / targetLevel) * 100;
  }

  /// Calculates required fertilizer amount based on deficiency.
  double? calculateRequiredFertilizer(double fertilizerEfficiency) {
    if (targetLevel <= 0 || fertilizerEfficiency <= 0) return null;
    final deficiency = targetLevel - nitrogenLevel;
    if (deficiency <= 0) return 0;
    return deficiency / (fertilizerEfficiency / 100);
  }

  /// Returns number of days since measurement.
  int getDaysSinceTest() {
    return DateTime.now().difference(measurementDate).inDays;
  }

  /// Returns number of days until next test.
  int? getDaysUntilNextTest() {
    if (nextTestDate == null) return null;
    return nextTestDate!.difference(DateTime.now()).inDays;
  }

  /// Returns an icon representing the nitrogen trend.
  IconData getTrendIcon() {
    switch (trendDirection?.toLowerCase()) {
      case 'increasing':
        return Icons.trending_up;
      case 'decreasing':
        return Icons.trending_down;
      case 'stable':
        return Icons.horizontal_rule;
      default:
        return Icons.show_chart;
    }
  }

  /// Returns a short summary of the nitrogen record.
  String getSummary() {
    return 'Status: $status | Level: ${nitrogenLevel.toStringAsFixed(1)} | Target: ${targetLevel.toStringAsFixed(1)}';
  }

  @override
  String toString() {
    return 'NitrogenModel(id: $id, cropId: $cropId, nitrogenLevel: $nitrogenLevel, status: $status, target: $targetLevel)';
  }

  // -----------------------------
  // Constants
  // -----------------------------

  static const List<String> statusLevels = [
    'Deficient',
    'Low',
    'Optimal',
    'High',
    'Excess',
  ];

  static const List<String> measurementMethods = [
    'Soil Test',
    'Leaf Analysis',
    'Sensor',
  ];

  static const List<String> trendDirections = [
    'Increasing',
    'Decreasing',
    'Stable',
  ];
}