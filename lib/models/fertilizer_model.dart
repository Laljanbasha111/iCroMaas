import 'package:flutter/material.dart';

/// Represents a fertilizer record in the Crop Analyzer app.
/// Includes detailed nutrient composition, application methods, and usage guidelines.
class FertilizerModel {
  /// Unique identifier for the fertilizer record.
  final String id;

  /// Fertilizer name (e.g., Urea, DAP, NPK 10-26-26).
  final String name;

  /// Fertilizer type (Organic/Inorganic/Bio-fertilizer/Liquid/Granular).
  final String type;

  /// NPK ratio (e.g., "10-20-10").
  final String npkRatio;

  /// Nitrogen percentage.
  final double nitrogen;

  /// Phosphorus percentage.
  final double phosphorus;

  /// Potassium percentage.
  final double potassium;

  /// Secondary nutrients (Ca, Mg, S).
  final Map<String, double>? secondaryNutrients;

  /// Micronutrients (Fe, Zn, Mn, Cu, B, Mo).
  final Map<String, double>? microNutrients;

  /// Application rate in kg/hectare.
  final double applicationRate;

  /// Application method (Broadcasting/Drilling/Foliar/Fertigation).
  final String applicationMethod;

  /// When to apply (Pre-planting/Basal/Top-dressing).
  final String? applicationTiming;

  /// List of suitable crops.
  final List<String> suitableCrops;

  /// List of benefits.
  final List<String> benefits;

  /// Safety precautions.
  final List<String> precautions;

  /// Manufacturer name.
  final String? manufacturer;

  /// Price per kg/liter.
  final double? price;

  /// Packaging size (e.g., "50 kg bag").
  final String? packagingSize;

  /// Storage instructions.
  final String? storageInstructions;

  /// Shelf life.
  final String? shelfLife;

  /// Whether the fertilizer is organic certified.
  final bool organicCertified;

  /// Whether the fertilizer is water soluble.
  final bool waterSoluble;

  /// Suitable soil types.
  final List<String>? soilType;

  /// Suitable pH range.
  final String? phRange;

  /// Product image URL.
  final String? imageUrl;

  /// Detailed description.
  final String? description;

  /// Dosage instructions.
  final String? dosageInstructions;

  /// Compatible with other fertilizers.
  final List<String>? compatibleWith;

  /// Incompatible with other fertilizers.
  final List<String>? incompatibleWith;

  /// Environmental impact.
  final String? environmentalImpact;

  /// Record creation timestamp.
  final DateTime createdAt;

  /// Last update timestamp.
  final DateTime? updatedAt;

  FertilizerModel({
    required this.id,
    required this.name,
    required this.type,
    required this.npkRatio,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    this.secondaryNutrients,
    this.microNutrients,
    required this.applicationRate,
    required this.applicationMethod,
    this.applicationTiming,
    required this.suitableCrops,
    required this.benefits,
    required this.precautions,
    this.manufacturer,
    this.price,
    this.packagingSize,
    this.storageInstructions,
    this.shelfLife,
    required this.organicCertified,
    required this.waterSoluble,
    this.soilType,
    this.phRange,
    this.imageUrl,
    this.description,
    this.dosageInstructions,
    this.compatibleWith,
    this.incompatibleWith,
    this.environmentalImpact,
    required this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor for creating a [FertilizerModel] from JSON data.
  factory FertilizerModel.fromJson(Map<String, dynamic> json) {
    return FertilizerModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'Inorganic',
      npkRatio: json['npkRatio'] ?? '0-0-0',
      nitrogen: (json['nitrogen'] ?? 0).toDouble(),
      phosphorus: (json['phosphorus'] ?? 0).toDouble(),
      potassium: (json['potassium'] ?? 0).toDouble(),
      secondaryNutrients: json['secondaryNutrients'] != null
          ? Map<String, double>.from(json['secondaryNutrients'])
          : null,
      microNutrients: json['microNutrients'] != null
          ? Map<String, double>.from(json['microNutrients'])
          : null,
      applicationRate: (json['applicationRate'] ?? 0).toDouble(),
      applicationMethod: json['applicationMethod'] ?? 'Broadcasting',
      applicationTiming: json['applicationTiming'],
      suitableCrops: List<String>.from(json['suitableCrops'] ?? []),
      benefits: List<String>.from(json['benefits'] ?? []),
      precautions: List<String>.from(json['precautions'] ?? []),
      manufacturer: json['manufacturer'],
      price: (json['price'] != null) ? (json['price'] as num).toDouble() : null,
      packagingSize: json['packagingSize'],
      storageInstructions: json['storageInstructions'],
      shelfLife: json['shelfLife'],
      organicCertified: json['organicCertified'] ?? false,
      waterSoluble: json['waterSoluble'] ?? false,
      soilType: json['soilType'] != null
          ? List<String>.from(json['soilType'])
          : null,
      phRange: json['phRange'],
      imageUrl: json['imageUrl'],
      description: json['description'],
      dosageInstructions: json['dosageInstructions'],
      compatibleWith: json['compatibleWith'] != null
          ? List<String>.from(json['compatibleWith'])
          : null,
      incompatibleWith: json['incompatibleWith'] != null
          ? List<String>.from(json['incompatibleWith'])
          : null,
      environmentalImpact: json['environmentalImpact'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
      json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  /// Converts the [FertilizerModel] instance to a JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'npkRatio': npkRatio,
    'nitrogen': nitrogen,
    'phosphorus': phosphorus,
    'potassium': potassium,
    'secondaryNutrients': secondaryNutrients,
    'microNutrients': microNutrients,
    'applicationRate': applicationRate,
    'applicationMethod': applicationMethod,
    'applicationTiming': applicationTiming,
    'suitableCrops': suitableCrops,
    'benefits': benefits,
    'precautions': precautions,
    'manufacturer': manufacturer,
    'price': price,
    'packagingSize': packagingSize,
    'storageInstructions': storageInstructions,
    'shelfLife': shelfLife,
    'organicCertified': organicCertified,
    'waterSoluble': waterSoluble,
    'soilType': soilType,
    'phRange': phRange,
    'imageUrl': imageUrl,
    'description': description,
    'dosageInstructions': dosageInstructions,
    'compatibleWith': compatibleWith,
    'incompatibleWith': incompatibleWith,
    'environmentalImpact': environmentalImpact,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  /// Creates a copy of this [FertilizerModel] with updated fields.
  FertilizerModel copyWith({
    String? id,
    String? name,
    String? type,
    String? npkRatio,
    double? nitrogen,
    double? phosphorus,
    double? potassium,
    Map<String, double>? secondaryNutrients,
    Map<String, double>? microNutrients,
    double? applicationRate,
    String? applicationMethod,
    String? applicationTiming,
    List<String>? suitableCrops,
    List<String>? benefits,
    List<String>? precautions,
    String? manufacturer,
    double? price,
    String? packagingSize,
    String? storageInstructions,
    String? shelfLife,
    bool? organicCertified,
    bool? waterSoluble,
    List<String>? soilType,
    String? phRange,
    String? imageUrl,
    String? description,
    String? dosageInstructions,
    List<String>? compatibleWith,
    List<String>? incompatibleWith,
    String? environmentalImpact,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FertilizerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      npkRatio: npkRatio ?? this.npkRatio,
      nitrogen: nitrogen ?? this.nitrogen,
      phosphorus: phosphorus ?? this.phosphorus,
      potassium: potassium ?? this.potassium,
      secondaryNutrients: secondaryNutrients ?? this.secondaryNutrients,
      microNutrients: microNutrients ?? this.microNutrients,
      applicationRate: applicationRate ?? this.applicationRate,
      applicationMethod: applicationMethod ?? this.applicationMethod,
      applicationTiming: applicationTiming ?? this.applicationTiming,
      suitableCrops: suitableCrops ?? this.suitableCrops,
      benefits: benefits ?? this.benefits,
      precautions: precautions ?? this.precautions,
      manufacturer: manufacturer ?? this.manufacturer,
      price: price ?? this.price,
      packagingSize: packagingSize ?? this.packagingSize,
      storageInstructions: storageInstructions ?? this.storageInstructions,
      shelfLife: shelfLife ?? this.shelfLife,
      organicCertified: organicCertified ?? this.organicCertified,
      waterSoluble: waterSoluble ?? this.waterSoluble,
      soilType: soilType ?? this.soilType,
      phRange: phRange ?? this.phRange,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      dosageInstructions: dosageInstructions ?? this.dosageInstructions,
      compatibleWith: compatibleWith ?? this.compatibleWith,
      incompatibleWith: incompatibleWith ?? this.incompatibleWith,
      environmentalImpact: environmentalImpact ?? this.environmentalImpact,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Returns a color representing the fertilizer type.
  Color getTypeColor() {
    switch (type.toLowerCase()) {
      case 'organic':
        return Colors.green;
      case 'inorganic':
        return Colors.blue;
      case 'bio-fertilizer':
        return Colors.orange;
      case 'liquid':
        return Colors.teal;
      case 'granular':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  /// Returns an icon representing the fertilizer type.
  IconData getTypeIcon() {
    switch (type.toLowerCase()) {
      case 'organic':
        return Icons.eco;
      case 'inorganic':
        return Icons.science;
      case 'bio-fertilizer':
        return Icons.biotech;
      case 'liquid':
        return Icons.water_drop;
      case 'granular':
        return Icons.grain;
      default:
        return Icons.agriculture;
    }
  }

  /// Returns an icon representing the application method.
  IconData getApplicationMethodIcon() {
    switch (applicationMethod.toLowerCase()) {
      case 'broadcasting':
        return Icons.spa;
      case 'drilling':
        return Icons.construction;
      case 'foliar':
        return Icons.local_florist;
      case 'fertigation':
        return Icons.water;
      default:
        return Icons.agriculture;
    }
  }

  /// Checks if the fertilizer is organic.
  bool isOrganic() => type.toLowerCase() == 'organic' || organicCertified;

  /// Checks if the fertilizer is suitable for a specific crop.
  bool isSuitableForCrop(String cropName) {
    return suitableCrops.any(
          (crop) => crop.toLowerCase() == cropName.toLowerCase(),
    );
  }

  /// Calculates the cost per hectare based on price and application rate.
  double? calculateCostPerHectare() {
    if (price == null) return null;
    return price! * applicationRate;
  }

  /// Returns a summary of the nutrient composition.
  String getNutrientSummary() {
    return 'N: ${nitrogen.toStringAsFixed(1)}%, '
        'P: ${phosphorus.toStringAsFixed(1)}%, '
        'K: ${potassium.toStringAsFixed(1)}%';
  }

  /// Returns the total NPK percentage.
  double getTotalNutrients() => nitrogen + phosphorus + potassium;

  /// Checks if the fertilizer has a balanced NPK ratio.
  bool isBalanced() {
    final avg = (nitrogen + phosphorus + potassium) / 3;
    return (nitrogen - avg).abs() < 5 &&
        (phosphorus - avg).abs() < 5 &&
        (potassium - avg).abs() < 5;
  }

  /// Returns a short summary of the fertilizer.
  String get summary =>
      '$name (${npkRatio}) - ${type.toUpperCase()} | Rate: ${applicationRate.toStringAsFixed(1)} kg/ha';

  @override
  String toString() =>
      'FertilizerModel(id: $id, name: $name, type: $type, npk: $npkRatio, rate: $applicationRate kg/ha)';

  // -----------------------------
  // Constants
  // -----------------------------

  static const List<String> fertilizerTypes = [
    'Organic',
    'Inorganic',
    'Bio-fertilizer',
    'Liquid',
    'Granular',
  ];

  static const List<String> applicationMethods = [
    'Broadcasting',
    'Drilling',
    'Foliar',
    'Fertigation',
  ];

  static const List<String> soilTypes = [
    'Loamy',
    'Sandy',
    'Clay',
    'Silty',
    'Peaty',
    'Chalky',
  ];

  /// Filters fertilizers by type.
  static List<FertilizerModel> filterByType(
      List<FertilizerModel> fertilizers, String type) {
    return fertilizers
        .where((f) => f.type.toLowerCase() == type.toLowerCase())
        .toList();
  }

  /// Filters fertilizers suitable for a specific crop.
  static List<FertilizerModel> filterByCrop(
      List<FertilizerModel> fertilizers, String cropName) {
    return fertilizers
        .where((f) => f.isSuitableForCrop(cropName))
        .toList();
  }

  /// Searches fertilizers by name or nutrient keyword.
  static List<FertilizerModel> searchFertilizers(
      List<FertilizerModel> fertilizers, String query) {
    final lowerQuery = query.toLowerCase();
    return fertilizers.where((f) {
      return f.name.toLowerCase().contains(lowerQuery) ||
          f.npkRatio.toLowerCase().contains(lowerQuery) ||
          f.description?.toLowerCase().contains(lowerQuery) == true;
    }).toList();
  }
}