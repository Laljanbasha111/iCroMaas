import 'package:flutter/material.dart';

/// Represents a pesticide record in the Crop Analyzer app.
/// Includes detailed chemical, biological, and safety information.
class PesticideModel {
  /// Unique identifier for the pesticide record.
  final String id;

  /// Pesticide name (e.g., Chlorpyrifos, Imidacloprid).
  final String name;

  /// Pesticide type (Insecticide/Herbicide/Fungicide/Rodenticide/Nematicide).
  final String type;

  /// Active ingredient name.
  final String activeIngredient;

  /// Concentration (e.g., "25% EC", "50% WP").
  final String concentration;

  /// Formulation type (EC/WP/SC/SL/GR).
  final String? formulationType;

  /// List of target pests.
  final List<String> targetPests;

  /// Target diseases (for fungicides).
  final List<String>? targetDiseases;

  /// Application rate (e.g., "2 ml/liter", "500 g/ha").
  final String applicationRate;

  /// Application method (Spray/Dust/Granular/Seed treatment).
  final String applicationMethod;

  /// When to apply (Pre-emergence/Post-emergence/Flowering).
  final String? applicationTiming;

  /// Pre-harvest interval in days.
  final int safetyPeriod;

  /// List of suitable crops.
  final List<String> suitableCrops;

  /// Safety precautions.
  final List<String> precautions;

  /// Symptoms of pest/disease it treats.
  final List<String>? symptoms;

  /// How it works (Contact/Systemic/Stomach poison).
  final String? modeOfAction;

  /// Manufacturer name.
  final String? manufacturer;

  /// Price per unit.
  final double? price;

  /// Packaging size (e.g., "1 liter bottle").
  final String? packagingSize;

  /// Storage instructions.
  final String? storageInstructions;

  /// Shelf life.
  final String? shelfLife;

  /// Toxicity level (Low/Medium/High/Very High).
  final String toxicityLevel;

  /// WHO toxicity class (Ia/Ib/II/III/U).
  final String? toxicityClass;

  /// Environmental impact.
  final String? environmentalImpact;

  /// Is water soluble.
  final bool waterSoluble;

  /// Rain fastness period (e.g., "2 hours").
  final String? rainFastness;

  /// Compatible with other pesticides.
  final List<String>? compatibleWith;

  /// Incompatible with other pesticides.
  final List<String>? incompatibleWith;

  /// Re-entry interval in hours.
  final int? reEntryInterval;

  /// Resistance management advice.
  final String? resistanceManagement;

  /// First aid measures.
  final List<String>? firstAidMeasures;

  /// Disposal instructions.
  final String? disposalInstructions;

  /// Product image URL.
  final String? imageUrl;

  /// Detailed description.
  final String? description;

  /// Dosage instructions.
  final String? dosageInstructions;

  /// Government registration number.
  final String? registrationNumber;

  /// Approved by (e.g., "CIB&RC India").
  final String? approvedBy;

  /// Record creation timestamp.
  final DateTime createdAt;

  /// Last update timestamp.
  final DateTime? updatedAt;

  PesticideModel({
    required this.id,
    required this.name,
    required this.type,
    required this.activeIngredient,
    required this.concentration,
    this.formulationType,
    required this.targetPests,
    this.targetDiseases,
    required this.applicationRate,
    required this.applicationMethod,
    this.applicationTiming,
    required this.safetyPeriod,
    required this.suitableCrops,
    required this.precautions,
    this.symptoms,
    this.modeOfAction,
    this.manufacturer,
    this.price,
    this.packagingSize,
    this.storageInstructions,
    this.shelfLife,
    required this.toxicityLevel,
    this.toxicityClass,
    this.environmentalImpact,
    required this.waterSoluble,
    this.rainFastness,
    this.compatibleWith,
    this.incompatibleWith,
    this.reEntryInterval,
    this.resistanceManagement,
    this.firstAidMeasures,
    this.disposalInstructions,
    this.imageUrl,
    this.description,
    this.dosageInstructions,
    this.registrationNumber,
    this.approvedBy,
    required this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor for creating a [PesticideModel] from JSON data.
  factory PesticideModel.fromJson(Map<String, dynamic> json) {
    return PesticideModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'Unknown',
      activeIngredient: json['activeIngredient'] ?? '',
      concentration: json['concentration'] ?? '',
      formulationType: json['formulationType'],
      targetPests: List<String>.from(json['targetPests'] ?? []),
      targetDiseases: json['targetDiseases'] != null
          ? List<String>.from(json['targetDiseases'])
          : null,
      applicationRate: json['applicationRate'] ?? '',
      applicationMethod: json['applicationMethod'] ?? '',
      applicationTiming: json['applicationTiming'],
      safetyPeriod: json['safetyPeriod'] ?? 0,
      suitableCrops: List<String>.from(json['suitableCrops'] ?? []),
      precautions: List<String>.from(json['precautions'] ?? []),
      symptoms: json['symptoms'] != null
          ? List<String>.from(json['symptoms'])
          : null,
      modeOfAction: json['modeOfAction'],
      manufacturer: json['manufacturer'],
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      packagingSize: json['packagingSize'],
      storageInstructions: json['storageInstructions'],
      shelfLife: json['shelfLife'],
      toxicityLevel: json['toxicityLevel'] ?? 'Medium',
      toxicityClass: json['toxicityClass'],
      environmentalImpact: json['environmentalImpact'],
      waterSoluble: json['waterSoluble'] ?? false,
      rainFastness: json['rainFastness'],
      compatibleWith: json['compatibleWith'] != null
          ? List<String>.from(json['compatibleWith'])
          : null,
      incompatibleWith: json['incompatibleWith'] != null
          ? List<String>.from(json['incompatibleWith'])
          : null,
      reEntryInterval: json['reEntryInterval'],
      resistanceManagement: json['resistanceManagement'],
      firstAidMeasures: json['firstAidMeasures'] != null
          ? List<String>.from(json['firstAidMeasures'])
          : null,
      disposalInstructions: json['disposalInstructions'],
      imageUrl: json['imageUrl'],
      description: json['description'],
      dosageInstructions: json['dosageInstructions'],
      registrationNumber: json['registrationNumber'],
      approvedBy: json['approvedBy'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
      json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  /// Converts the [PesticideModel] instance to a JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'activeIngredient': activeIngredient,
    'concentration': concentration,
    'formulationType': formulationType,
    'targetPests': targetPests,
    'targetDiseases': targetDiseases,
    'applicationRate': applicationRate,
    'applicationMethod': applicationMethod,
    'applicationTiming': applicationTiming,
    'safetyPeriod': safetyPeriod,
    'suitableCrops': suitableCrops,
    'precautions': precautions,
    'symptoms': symptoms,
    'modeOfAction': modeOfAction,
    'manufacturer': manufacturer,
    'price': price,
    'packagingSize': packagingSize,
    'storageInstructions': storageInstructions,
    'shelfLife': shelfLife,
    'toxicityLevel': toxicityLevel,
    'toxicityClass': toxicityClass,
    'environmentalImpact': environmentalImpact,
    'waterSoluble': waterSoluble,
    'rainFastness': rainFastness,
    'compatibleWith': compatibleWith,
    'incompatibleWith': incompatibleWith,
    'reEntryInterval': reEntryInterval,
    'resistanceManagement': resistanceManagement,
    'firstAidMeasures': firstAidMeasures,
    'disposalInstructions': disposalInstructions,
    'imageUrl': imageUrl,
    'description': description,
    'dosageInstructions': dosageInstructions,
    'registrationNumber': registrationNumber,
    'approvedBy': approvedBy,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  /// Creates a copy of this [PesticideModel] with updated fields.
  PesticideModel copyWith({
    String? id,
    String? name,
    String? type,
    String? activeIngredient,
    String? concentration,
    String? formulationType,
    List<String>? targetPests,
    List<String>? targetDiseases,
    String? applicationRate,
    String? applicationMethod,
    String? applicationTiming,
    int? safetyPeriod,
    List<String>? suitableCrops,
    List<String>? precautions,
    List<String>? symptoms,
    String? modeOfAction,
    String? manufacturer,
    double? price,
    String? packagingSize,
    String? storageInstructions,
    String? shelfLife,
    String? toxicityLevel,
    String? toxicityClass,
    String? environmentalImpact,
    bool? waterSoluble,
    String? rainFastness,
    List<String>? compatibleWith,
    List<String>? incompatibleWith,
    int? reEntryInterval,
    String? resistanceManagement,
    List<String>? firstAidMeasures,
    String? disposalInstructions,
    String? imageUrl,
    String? description,
    String? dosageInstructions,
    String? registrationNumber,
    String? approvedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PesticideModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      activeIngredient: activeIngredient ?? this.activeIngredient,
      concentration: concentration ?? this.concentration,
      formulationType: formulationType ?? this.formulationType,
      targetPests: targetPests ?? this.targetPests,
      targetDiseases: targetDiseases ?? this.targetDiseases,
      applicationRate: applicationRate ?? this.applicationRate,
      applicationMethod: applicationMethod ?? this.applicationMethod,
      applicationTiming: applicationTiming ?? this.applicationTiming,
      safetyPeriod: safetyPeriod ?? this.safetyPeriod,
      suitableCrops: suitableCrops ?? this.suitableCrops,
      precautions: precautions ?? this.precautions,
      symptoms: symptoms ?? this.symptoms,
      modeOfAction: modeOfAction ?? this.modeOfAction,
      manufacturer: manufacturer ?? this.manufacturer,
      price: price ?? this.price,
      packagingSize: packagingSize ?? this.packagingSize,
      storageInstructions: storageInstructions ?? this.storageInstructions,
      shelfLife: shelfLife ?? this.shelfLife,
      toxicityLevel: toxicityLevel ?? this.toxicityLevel,
      toxicityClass: toxicityClass ?? this.toxicityClass,
      environmentalImpact: environmentalImpact ?? this.environmentalImpact,
      waterSoluble: waterSoluble ?? this.waterSoluble,
      rainFastness: rainFastness ?? this.rainFastness,
      compatibleWith: compatibleWith ?? this.compatibleWith,
      incompatibleWith: incompatibleWith ?? this.incompatibleWith,
      reEntryInterval: reEntryInterval ?? this.reEntryInterval,
      resistanceManagement: resistanceManagement ?? this.resistanceManagement,
      firstAidMeasures: firstAidMeasures ?? this.firstAidMeasures,
      disposalInstructions: disposalInstructions ?? this.disposalInstructions,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      dosageInstructions: dosageInstructions ?? this.dosageInstructions,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      approvedBy: approvedBy ?? this.approvedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Returns a color representing the pesticide type.
  Color getTypeColor() {
    switch (type.toLowerCase()) {
      case 'insecticide':
        return Colors.orange;
      case 'herbicide':
        return Colors.green;
      case 'fungicide':
        return Colors.blue;
      case 'rodenticide':
        return Colors.brown;
      case 'nematicide':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  /// Returns an icon representing the pesticide type.
  IconData getTypeIcon() {
    switch (type.toLowerCase()) {
      case 'insecticide':
        return Icons.bug_report;
      case 'herbicide':
        return Icons.grass;
      case 'fungicide':
        return Icons.spa;
      case 'rodenticide':
        return Icons.pest_control_rodent;
      case 'nematicide':
        return Icons.eco;
      default:
        return Icons.science;
    }
  }

  /// Returns a color representing the toxicity level.
  Color getToxicityColor() {
    switch (toxicityLevel.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.redAccent;
      case 'very high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Returns an icon representing the toxicity level.
  IconData getToxicityIcon() {
    switch (toxicityLevel.toLowerCase()) {
      case 'low':
        return Icons.check_circle;
      case 'medium':
        return Icons.warning;
      case 'high':
        return Icons.error;
      case 'very high':
        return Icons.dangerous;
      default:
        return Icons.help_outline;
    }
  }

  /// Returns true if the pesticide is highly toxic.
  bool isHighlyToxic() =>
      toxicityLevel.toLowerCase() == 'high' ||
          toxicityLevel.toLowerCase() == 'very high';

  /// Checks if the pesticide is suitable for a specific crop.
  bool isSuitableForCrop(String cropName) {
    return suitableCrops.any(
          (crop) => crop.toLowerCase() == cropName.toLowerCase(),
    );
  }

  /// Checks if the pesticide targets a specific pest.
  bool targetsPest(String pestName) {
    return targetPests.any(
          (pest) => pest.toLowerCase() == pestName.toLowerCase(),
    );
  }

  /// Calculates cost per hectare if price is available.
  double? calculateCostPerHectare(double quantityPerHectare) {
    if (price == null) return null;
    return price! * quantityPerHectare;
  }

  /// Checks if it is safe for harvest based on safety period.
  bool isReadyForHarvest(DateTime applicationDate) {
    final harvestDate = applicationDate.add(Duration(days: safetyPeriod));
    return DateTime.now().isAfter(harvestDate);
  }

  /// Returns days until safe harvest.
  int getDaysUntilHarvest(DateTime applicationDate) {
    final harvestDate = applicationDate.add(Duration(days: safetyPeriod));
    return harvestDate.difference(DateTime.now()).inDays;
  }

  /// Returns a short summary of the pesticide.
  String getSummary() =>
      '$name (${type.toUpperCase()}) - ${activeIngredient} | Toxicity: $toxicityLevel';

  @override
  String toString() =>
      'PesticideModel(id: $id, name: $name, type: $type, toxicity: $toxicityLevel)';

  // -----------------------------
  // Constants
  // -----------------------------

  static const List<String> pesticideTypes = [
    'Insecticide',
    'Herbicide',
    'Fungicide',
    'Rodenticide',
    'Nematicide',
  ];

  static const List<String> toxicityLevels = [
    'Low',
    'Medium',
    'High',
    'Very High',
  ];

  static const List<String> formulationTypes = [
    'EC',
    'WP',
    'SC',
    'SL',
    'GR',
  ];

  static const List<String> applicationMethods = [
    'Spray',
    'Dust',
    'Granular',
    'Seed treatment',
  ];

  static const List<String> modesOfAction = [
    'Contact',
    'Systemic',
    'Stomach poison',
  ];
}