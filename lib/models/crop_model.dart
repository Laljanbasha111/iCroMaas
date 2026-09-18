import 'package:flutter/material.dart';

/// Represents a crop record in the Crop Analyzer app.
/// Includes agronomic, environmental, and financial details.
class CropModel {
  /// Unique identifier for the crop record.
  final String id;

  /// Crop name (e.g., Wheat, Rice, Corn).
  final String name;

  /// Scientific name of the crop (optional).
  final String? scientificName;

  /// Crop category (Cereal, Vegetable, Fruit, Legume, Cash Crop).
  final String category;

  /// Crop variety (optional).
  final String? variety;

  /// Date when the crop was planted.
  final DateTime plantingDate;

  /// Expected harvest date.
  final DateTime expectedHarvestDate;

  /// Actual harvest date (optional).
  final DateTime? actualHarvestDate;

  /// Current growth stage (Seedling, Vegetative, Flowering, Fruiting, Maturity, Harvested).
  final String currentStage;

  /// Field area in hectares.
  final double fieldArea;

  /// Field location or name.
  final String location;

  /// GPS latitude (optional).
  final double? latitude;

  /// GPS longitude (optional).
  final double? longitude;

  /// Crop image URL (optional).
  final String? imageUrl;

  /// Health status (Healthy, Moderate, Poor, Critical).
  final String healthStatus;

  /// Owner user ID.
  final String userId;

  /// Soil type (optional).
  final String? soilType;

  /// Irrigation method (optional).
  final String? irrigationType;

  /// Seed source (optional).
  final String? seedSource;

  /// Planting density (plants per hectare, optional).
  final double? plantingDensity;

  /// Expected yield in kg/hectare (optional).
  final double? expectedYield;

  /// Actual yield in kg/hectare (optional).
  final double? actualYield;

  /// Total investment in currency (optional).
  final double? totalInvestment;

  /// Additional notes (optional).
  final String? notes;

  /// Whether the crop is currently active.
  final bool isActive;

  /// Record creation timestamp.
  final DateTime createdAt;

  /// Last update timestamp (optional).
  final DateTime? updatedAt;

  CropModel({
    required this.id,
    required this.name,
    this.scientificName,
    required this.category,
    this.variety,
    required this.plantingDate,
    required this.expectedHarvestDate,
    this.actualHarvestDate,
    required this.currentStage,
    required this.fieldArea,
    required this.location,
    this.latitude,
    this.longitude,
    this.imageUrl,
    required this.healthStatus,
    required this.userId,
    this.soilType,
    this.irrigationType,
    this.seedSource,
    this.plantingDensity,
    this.expectedYield,
    this.actualYield,
    this.totalInvestment,
    this.notes,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor for creating a [CropModel] from JSON data.
  factory CropModel.fromJson(Map<String, dynamic> json) {
    return CropModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      scientificName: json['scientificName'],
      category: json['category'] ?? 'Unknown',
      variety: json['variety'],
      plantingDate: DateTime.parse(json['plantingDate']),
      expectedHarvestDate: DateTime.parse(json['expectedHarvestDate']),
      actualHarvestDate: json['actualHarvestDate'] != null
          ? DateTime.parse(json['actualHarvestDate'])
          : null,
      currentStage: json['currentStage'] ?? 'Seedling',
      fieldArea: (json['fieldArea'] ?? 0).toDouble(),
      location: json['location'] ?? '',
      latitude: (json['latitude'] != null)
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: (json['longitude'] != null)
          ? (json['longitude'] as num).toDouble()
          : null,
      imageUrl: json['imageUrl'],
      healthStatus: json['healthStatus'] ?? 'Healthy',
      userId: json['userId'] ?? '',
      soilType: json['soilType'],
      irrigationType: json['irrigationType'],
      seedSource: json['seedSource'],
      plantingDensity: (json['plantingDensity'] != null)
          ? (json['plantingDensity'] as num).toDouble()
          : null,
      expectedYield: (json['expectedYield'] != null)
          ? (json['expectedYield'] as num).toDouble()
          : null,
      actualYield: (json['actualYield'] != null)
          ? (json['actualYield'] as num).toDouble()
          : null,
      totalInvestment: (json['totalInvestment'] != null)
          ? (json['totalInvestment'] as num).toDouble()
          : null,
      notes: json['notes'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
      json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  /// Converts the [CropModel] instance to a JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'scientificName': scientificName,
    'category': category,
    'variety': variety,
    'plantingDate': plantingDate.toIso8601String(),
    'expectedHarvestDate': expectedHarvestDate.toIso8601String(),
    'actualHarvestDate': actualHarvestDate?.toIso8601String(),
    'currentStage': currentStage,
    'fieldArea': fieldArea,
    'location': location,
    'latitude': latitude,
    'longitude': longitude,
    'imageUrl': imageUrl,
    'healthStatus': healthStatus,
    'userId': userId,
    'soilType': soilType,
    'irrigationType': irrigationType,
    'seedSource': seedSource,
    'plantingDensity': plantingDensity,
    'expectedYield': expectedYield,
    'actualYield': actualYield,
    'totalInvestment': totalInvestment,
    'notes': notes,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  /// Creates a copy of this [CropModel] with updated fields.
  CropModel copyWith({
    String? id,
    String? name,
    String? scientificName,
    String? category,
    String? variety,
    DateTime? plantingDate,
    DateTime? expectedHarvestDate,
    DateTime? actualHarvestDate,
    String? currentStage,
    double? fieldArea,
    String? location,
    double? latitude,
    double? longitude,
    String? imageUrl,
    String? healthStatus,
    String? userId,
    String? soilType,
    String? irrigationType,
    String? seedSource,
    double? plantingDensity,
    double? expectedYield,
    double? actualYield,
    double? totalInvestment,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CropModel(
      id: id ?? this.id,
      name: name ?? this.name,
      scientificName: scientificName ?? this.scientificName,
      category: category ?? this.category,
      variety: variety ?? this.variety,
      plantingDate: plantingDate ?? this.plantingDate,
      expectedHarvestDate: expectedHarvestDate ?? this.expectedHarvestDate,
      actualHarvestDate: actualHarvestDate ?? this.actualHarvestDate,
      currentStage: currentStage ?? this.currentStage,
      fieldArea: fieldArea ?? this.fieldArea,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      healthStatus: healthStatus ?? this.healthStatus,
      userId: userId ?? this.userId,
      soilType: soilType ?? this.soilType,
      irrigationType: irrigationType ?? this.irrigationType,
      seedSource: seedSource ?? this.seedSource,
      plantingDensity: plantingDensity ?? this.plantingDensity,
      expectedYield: expectedYield ?? this.expectedYield,
      actualYield: actualYield ?? this.actualYield,
      totalInvestment: totalInvestment ?? this.totalInvestment,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Calculates the number of days until expected harvest.
  int getDaysUntilHarvest() {
    final now = DateTime.now();
    return expectedHarvestDate.difference(now).inDays;
  }

  /// Calculates the number of days since planting.
  int getDaysSincePlanting() {
    final now = DateTime.now();
    return now.difference(plantingDate).inDays;
  }

  /// Returns the growth progress percentage (0–100).
  double getGrowthProgress() {
    final totalDays =
    expectedHarvestDate.difference(plantingDate).inDays.toDouble();
    final elapsedDays = DateTime.now().difference(plantingDate).inDays.toDouble();
    if (totalDays <= 0) return 0;
    final progress = (elapsedDays / totalDays) * 100;
    return progress.clamp(0, 100);
  }

  /// Returns true if the crop is overdue for harvest.
  bool isOverdue() {
    if (actualHarvestDate != null) return false;
    return DateTime.now().isAfter(expectedHarvestDate);
  }

  /// Returns a color representing the health status.
  Color getHealthStatusColor() {
    switch (healthStatus.toLowerCase()) {
      case 'healthy':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'poor':
        return Colors.redAccent;
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Returns an icon representing the crop category.
  IconData getCategoryIcon() {
    switch (category.toLowerCase()) {
      case 'cereal':
        return Icons.grain;
      case 'vegetable':
        return Icons.eco;
      case 'fruit':
        return Icons.apple;
      case 'legume':
        return Icons.spa;
      case 'cash crop':
        return Icons.attach_money;
      default:
        return Icons.agriculture;
    }
  }

  /// Returns the stage progress (0–1) based on growth stage.
  double getStageProgress() {
    final index = growthStages.indexOf(currentStage);
    if (index == -1) return 0;
    return (index + 1) / growthStages.length;
  }

  /// Calculates the return on investment (ROI) percentage.
  double? calculateROI() {
    if (actualYield == null ||
        expectedYield == null ||
        totalInvestment == null ||
        totalInvestment == 0) return null;
    final revenue = actualYield! * 1; // Assuming 1 currency unit per kg
    final roi = ((revenue - totalInvestment!) / totalInvestment!) * 100;
    return roi;
  }

  /// Returns a short summary of the crop.
  String get summary =>
      '$name (${category.toUpperCase()}) - ${currentStage.toUpperCase()} | Health: $healthStatus';

  @override
  String toString() {
    return 'CropModel(id: $id, name: $name, category: $category, '
        'stage: $currentStage, health: $healthStatus, fieldArea: $fieldArea ha)';
  }

  // -----------------------------
  // Constants
  // -----------------------------

  static const List<String> cropCategories = [
    'Cereal',
    'Vegetable',
    'Fruit',
    'Legume',
    'Cash Crop',
  ];

  static const List<String> growthStages = [
    'Seedling',
    'Vegetative',
    'Flowering',
    'Fruiting',
    'Maturity',
    'Harvested',
  ];

  static const List<String> healthStatuses = [
    'Healthy',
    'Moderate',
    'Poor',
    'Critical',
  ];

  static const List<String> irrigationTypes = [
    'Drip',
    'Sprinkler',
    'Flood',
    'Manual',
    'Rain-fed',
  ];

  static const List<String> soilTypes = [
    'Loamy',
    'Sandy',
    'Clay',
    'Silty',
    'Peaty',
    'Chalky',
  ];
}