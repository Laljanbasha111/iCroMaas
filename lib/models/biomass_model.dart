import 'package:flutter/material.dart';

/// Represents a biomass measurement record for a specific crop in the Crop Analyzer app.
/// Includes detailed agronomic parameters, environmental context, and quality indicators.
class BiomassModel {
  /// Unique identifier for the biomass record.
  final String id;

  /// Reference to the crop this biomass measurement belongs to.
  final String cropId;

  /// Reference to the user who owns this record.
  final String userId;

  /// Biomass measurement in kilograms per hectare.
  final double biomassValue;

  /// Date and time when the measurement was taken.
  final DateTime measurementDate;

  /// Current growth stage of the crop.
  final String growthStage;

  /// Estimated yield in kilograms per hectare.
  final double estimatedYield;

  /// Quality score (0–100).
  final double qualityScore;

  /// Leaf Area Index (optional).
  final double? leafAreaIndex;

  /// Average plant height in centimeters (optional).
  final double? plantHeight;

  /// Canopy coverage percentage (optional).
  final double? canopyCover;

  /// Chlorophyll content measurement (optional).
  final double? chlorophyllContent;

  /// Moisture percentage (optional).
  final double? moistureContent;

  /// Dry matter percentage (optional).
  final double? dryMatterContent;

  /// Image URL of the crop during measurement (optional).
  final String? imageUrl;

  /// Field location (optional).
  final String? location;

  /// Weather conditions during measurement (optional).
  final String? weatherConditions;

  /// Additional notes (optional).
  final String? notes;

  /// Record creation timestamp.
  final DateTime createdAt;

  /// Last update timestamp (optional).
  final DateTime? updatedAt;

  BiomassModel({
    required this.id,
    required this.cropId,
    required this.userId,
    required this.biomassValue,
    required this.measurementDate,
    required this.growthStage,
    required this.estimatedYield,
    required this.qualityScore,
    this.leafAreaIndex,
    this.plantHeight,
    this.canopyCover,
    this.chlorophyllContent,
    this.moistureContent,
    this.dryMatterContent,
    this.imageUrl,
    this.location,
    this.weatherConditions,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor for creating a [BiomassModel] from JSON data.
  factory BiomassModel.fromJson(Map<String, dynamic> json) {
    return BiomassModel(
      id: json['id'] ?? '',
      cropId: json['cropId'] ?? '',
      userId: json['userId'] ?? '',
      biomassValue: (json['biomassValue'] ?? 0).toDouble(),
      measurementDate: DateTime.parse(json['measurementDate']),
      growthStage: json['growthStage'] ?? 'Unknown',
      estimatedYield: (json['estimatedYield'] ?? 0).toDouble(),
      qualityScore: (json['qualityScore'] ?? 0).toDouble(),
      leafAreaIndex: (json['leafAreaIndex'] != null)
          ? (json['leafAreaIndex'] as num).toDouble()
          : null,
      plantHeight: (json['plantHeight'] != null)
          ? (json['plantHeight'] as num).toDouble()
          : null,
      canopyCover: (json['canopyCover'] != null)
          ? (json['canopyCover'] as num).toDouble()
          : null,
      chlorophyllContent: (json['chlorophyllContent'] != null)
          ? (json['chlorophyllContent'] as num).toDouble()
          : null,
      moistureContent: (json['moistureContent'] != null)
          ? (json['moistureContent'] as num).toDouble()
          : null,
      dryMatterContent: (json['dryMatterContent'] != null)
          ? (json['dryMatterContent'] as num).toDouble()
          : null,
      imageUrl: json['imageUrl'],
      location: json['location'],
      weatherConditions: json['weatherConditions'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
      json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  /// Converts the [BiomassModel] instance to a JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'cropId': cropId,
    'userId': userId,
    'biomassValue': biomassValue,
    'measurementDate': measurementDate.toIso8601String(),
    'growthStage': growthStage,
    'estimatedYield': estimatedYield,
    'qualityScore': qualityScore,
    'leafAreaIndex': leafAreaIndex,
    'plantHeight': plantHeight,
    'canopyCover': canopyCover,
    'chlorophyllContent': chlorophyllContent,
    'moistureContent': moistureContent,
    'dryMatterContent': dryMatterContent,
    'imageUrl': imageUrl,
    'location': location,
    'weatherConditions': weatherConditions,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  /// Creates a copy of this [BiomassModel] with updated fields.
  BiomassModel copyWith({
    String? id,
    String? cropId,
    String? userId,
    double? biomassValue,
    DateTime? measurementDate,
    String? growthStage,
    double? estimatedYield,
    double? qualityScore,
    double? leafAreaIndex,
    double? plantHeight,
    double? canopyCover,
    double? chlorophyllContent,
    double? moistureContent,
    double? dryMatterContent,
    String? imageUrl,
    String? location,
    String? weatherConditions,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BiomassModel(
      id: id ?? this.id,
      cropId: cropId ?? this.cropId,
      userId: userId ?? this.userId,
      biomassValue: biomassValue ?? this.biomassValue,
      measurementDate: measurementDate ?? this.measurementDate,
      growthStage: growthStage ?? this.growthStage,
      estimatedYield: estimatedYield ?? this.estimatedYield,
      qualityScore: qualityScore ?? this.qualityScore,
      leafAreaIndex: leafAreaIndex ?? this.leafAreaIndex,
      plantHeight: plantHeight ?? this.plantHeight,
      canopyCover: canopyCover ?? this.canopyCover,
      chlorophyllContent: chlorophyllContent ?? this.chlorophyllContent,
      moistureContent: moistureContent ?? this.moistureContent,
      dryMatterContent: dryMatterContent ?? this.dryMatterContent,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      weatherConditions: weatherConditions ?? this.weatherConditions,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Returns true if the biomass is considered healthy based on quality score and biomass value.
  bool get isHealthy => qualityScore >= 75 && biomassValue > 1000;

  /// Returns a color representing the growth stage.
  Color getGrowthStageColor() {
    switch (growthStage.toLowerCase()) {
      case 'seedling':
        return Colors.green.shade300;
      case 'vegetative':
        return Colors.green.shade600;
      case 'flowering':
        return Colors.orange.shade400;
      case 'fruiting':
        return Colors.red.shade400;
      case 'maturity':
        return Colors.brown.shade400;
      default:
        return Colors.grey;
    }
  }

  /// Returns a textual quality rating based on the quality score.
  String getQualityRating() {
    if (qualityScore >= 90) return 'Excellent';
    if (qualityScore >= 75) return 'Good';
    if (qualityScore >= 50) return 'Fair';
    return 'Poor';
  }

  /// Calculates biomass per plant given the number of plants per hectare.
  double calculateBiomassPerPlant(int plantsPerHectare) {
    if (plantsPerHectare <= 0) return 0;
    return biomassValue / plantsPerHectare;
  }

  /// Validates if the record has essential data.
  bool get isValid =>
      id.isNotEmpty &&
          cropId.isNotEmpty &&
          userId.isNotEmpty &&
          biomassValue > 0 &&
          measurementDate.isBefore(DateTime.now());

  /// Returns a short summary of the biomass record.
  String get summary =>
      'Stage: $growthStage | Biomass: ${biomassValue.toStringAsFixed(1)} kg/ha | Quality: ${getQualityRating()}';

  @override
  String toString() {
    return 'BiomassModel(id: $id, cropId: $cropId, userId: $userId, '
        'biomassValue: $biomassValue, growthStage: $growthStage, '
        'qualityScore: $qualityScore, estimatedYield: $estimatedYield)';
  }

  /// Growth stage constants for reference.
  static const List<String> growthStages = [
    'Seedling',
    'Vegetative',
    'Flowering',
    'Fruiting',
    'Maturity',
  ];

  /// Quality rating thresholds.
  static const Map<String, double> qualityThresholds = {
    'Excellent': 90,
    'Good': 75,
    'Fair': 50,
    'Poor': 0,
  };
}