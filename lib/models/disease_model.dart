import 'package:flutter/material.dart';

/// Represents a plant disease record in the Crop Analyzer app.
/// Includes detailed biological, environmental, and management information.
class DiseaseModel {
  /// Unique identifier for the disease record.
  final String id;

  /// Common name of the disease (e.g., Leaf Rust, Powdery Mildew).
  final String name;

  /// Scientific name of the disease (optional).
  final String? scientificName;

  /// Other common names (optional).
  final List<String>? commonNames;

  /// Detailed description of the disease.
  final String description;

  /// List of visible symptoms.
  final List<String> symptoms;

  /// Causes of the disease (fungal, bacterial, viral, etc.).
  final List<String> causes;

  /// General treatment methods.
  final List<String> treatment;

  /// Prevention measures.
  final List<String> prevention;

  /// Severity level (Low, Medium, High, Critical).
  final String severity;

  /// List of affected crops.
  final List<String> affectedCrops;

  /// Affected plant parts (Leaf, Stem, Root, Fruit, etc.).
  final List<String>? affectedParts;

  /// How the disease spreads (Airborne, Waterborne, Insect, Contact, etc.).
  final String? spreadMethod;

  /// Favorable conditions for disease development (temperature, humidity, etc.).
  final Map<String, dynamic>? favorableConditions;

  /// Image URL of the disease (optional).
  final String? imageUrl;

  /// Diagnosis method (optional).
  final String? diagnosisMethod;

  /// Organic treatment options (optional).
  final List<String>? organicTreatment;

  /// Chemical treatment options (optional).
  final List<String>? chemicalTreatment;

  /// Biological control methods (optional).
  final List<String>? biologicalControl;

  /// Expected recovery time (optional).
  final String? recoveryTime;

  /// Economic impact description (optional).
  final String? economicImpact;

  /// Reference links or sources (optional).
  final List<String>? references;

  /// Record creation timestamp.
  final DateTime createdAt;

  /// Last update timestamp (optional).
  final DateTime? updatedAt;

  DiseaseModel({
    required this.id,
    required this.name,
    this.scientificName,
    this.commonNames,
    required this.description,
    required this.symptoms,
    required this.causes,
    required this.treatment,
    required this.prevention,
    required this.severity,
    required this.affectedCrops,
    this.affectedParts,
    this.spreadMethod,
    this.favorableConditions,
    this.imageUrl,
    this.diagnosisMethod,
    this.organicTreatment,
    this.chemicalTreatment,
    this.biologicalControl,
    this.recoveryTime,
    this.economicImpact,
    this.references,
    required this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor for creating a [DiseaseModel] from JSON data.
  factory DiseaseModel.fromJson(Map<String, dynamic> json) {
    return DiseaseModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      scientificName: json['scientificName'],
      commonNames: json['commonNames'] != null
          ? List<String>.from(json['commonNames'])
          : null,
      description: json['description'] ?? '',
      symptoms: List<String>.from(json['symptoms'] ?? []),
      causes: List<String>.from(json['causes'] ?? []),
      treatment: List<String>.from(json['treatment'] ?? []),
      prevention: List<String>.from(json['prevention'] ?? []),
      severity: json['severity'] ?? 'Low',
      affectedCrops: List<String>.from(json['affectedCrops'] ?? []),
      affectedParts: json['affectedParts'] != null
          ? List<String>.from(json['affectedParts'])
          : null,
      spreadMethod: json['spreadMethod'],
      favorableConditions: json['favorableConditions'] != null
          ? Map<String, dynamic>.from(json['favorableConditions'])
          : null,
      imageUrl: json['imageUrl'],
      diagnosisMethod: json['diagnosisMethod'],
      organicTreatment: json['organicTreatment'] != null
          ? List<String>.from(json['organicTreatment'])
          : null,
      chemicalTreatment: json['chemicalTreatment'] != null
          ? List<String>.from(json['chemicalTreatment'])
          : null,
      biologicalControl: json['biologicalControl'] != null
          ? List<String>.from(json['biologicalControl'])
          : null,
      recoveryTime: json['recoveryTime'],
      economicImpact: json['economicImpact'],
      references: json['references'] != null
          ? List<String>.from(json['references'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
      json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  /// Converts the [DiseaseModel] instance to a JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'scientificName': scientificName,
    'commonNames': commonNames,
    'description': description,
    'symptoms': symptoms,
    'causes': causes,
    'treatment': treatment,
    'prevention': prevention,
    'severity': severity,
    'affectedCrops': affectedCrops,
    'affectedParts': affectedParts,
    'spreadMethod': spreadMethod,
    'favorableConditions': favorableConditions,
    'imageUrl': imageUrl,
    'diagnosisMethod': diagnosisMethod,
    'organicTreatment': organicTreatment,
    'chemicalTreatment': chemicalTreatment,
    'biologicalControl': biologicalControl,
    'recoveryTime': recoveryTime,
    'economicImpact': economicImpact,
    'references': references,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  /// Creates a copy of this [DiseaseModel] with updated fields.
  DiseaseModel copyWith({
    String? id,
    String? name,
    String? scientificName,
    List<String>? commonNames,
    String? description,
    List<String>? symptoms,
    List<String>? causes,
    List<String>? treatment,
    List<String>? prevention,
    String? severity,
    List<String>? affectedCrops,
    List<String>? affectedParts,
    String? spreadMethod,
    Map<String, dynamic>? favorableConditions,
    String? imageUrl,
    String? diagnosisMethod,
    List<String>? organicTreatment,
    List<String>? chemicalTreatment,
    List<String>? biologicalControl,
    String? recoveryTime,
    String? economicImpact,
    List<String>? references,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DiseaseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      scientificName: scientificName ?? this.scientificName,
      commonNames: commonNames ?? this.commonNames,
      description: description ?? this.description,
      symptoms: symptoms ?? this.symptoms,
      causes: causes ?? this.causes,
      treatment: treatment ?? this.treatment,
      prevention: prevention ?? this.prevention,
      severity: severity ?? this.severity,
      affectedCrops: affectedCrops ?? this.affectedCrops,
      affectedParts: affectedParts ?? this.affectedParts,
      spreadMethod: spreadMethod ?? this.spreadMethod,
      favorableConditions: favorableConditions ?? this.favorableConditions,
      imageUrl: imageUrl ?? this.imageUrl,
      diagnosisMethod: diagnosisMethod ?? this.diagnosisMethod,
      organicTreatment: organicTreatment ?? this.organicTreatment,
      chemicalTreatment: chemicalTreatment ?? this.chemicalTreatment,
      biologicalControl: biologicalControl ?? this.biologicalControl,
      recoveryTime: recoveryTime ?? this.recoveryTime,
      economicImpact: economicImpact ?? this.economicImpact,
      references: references ?? this.references,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Returns a color representing the severity level.
  Color getSeverityColor() {
    switch (severity.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.redAccent;
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Returns an icon representing the severity level.
  IconData getSeverityIcon() {
    switch (severity.toLowerCase()) {
      case 'low':
        return Icons.check_circle;
      case 'medium':
        return Icons.warning;
      case 'high':
        return Icons.error;
      case 'critical':
        return Icons.dangerous;
      default:
        return Icons.help_outline;
    }
  }

  /// Returns true if the disease is critical.
  bool isCritical() => severity.toLowerCase() == 'critical';

  /// Checks if the disease affects a specific crop.
  bool affectsCrop(String cropName) {
    return affectedCrops.any(
          (crop) => crop.toLowerCase() == cropName.toLowerCase(),
    );
  }

  /// Returns formatted treatment steps.
  String getTreatmentSteps() => treatment.isNotEmpty
      ? treatment.map((t) => '• $t').join('\n')
      : 'No treatment information available.';

  /// Returns formatted prevention steps.
  String getPreventionSteps() => prevention.isNotEmpty
      ? prevention.map((p) => '• $p').join('\n')
      : 'No prevention information available.';

  /// Returns a short summary of the disease.
  String getSummary() =>
      '$name (${severity.toUpperCase()}) - Affects ${affectedCrops.join(", ")}';

  /// Returns a formatted list of favorable conditions.
  String getFavorableConditionsSummary() {
    if (favorableConditions == null || favorableConditions!.isEmpty) {
      return 'No specific conditions recorded.';
    }
    return favorableConditions!.entries
        .map((e) => '${e.key}: ${e.value}')
        .join(', ');
  }

  /// Returns a combined list of all treatment options.
  List<String> getAllTreatmentOptions() {
    final all = <String>[];
    all.addAll(treatment);
    if (organicTreatment != null) all.addAll(organicTreatment!);
    if (chemicalTreatment != null) all.addAll(chemicalTreatment!);
    if (biologicalControl != null) all.addAll(biologicalControl!);
    return all;
  }

  /// Returns a list of all affected plant parts.
  List<String> getAffectedParts() =>
      affectedParts ?? ['Unknown parts affected'];

  /// Returns true if the disease spreads through insects.
  bool get isInsectBorne =>
      spreadMethod?.toLowerCase() == 'insect' ||
          spreadMethod?.toLowerCase() == 'vector';

  /// Returns true if the disease spreads through water.
  bool get isWaterBorne =>
      spreadMethod?.toLowerCase() == 'waterborne' ||
          spreadMethod?.toLowerCase() == 'water';

  /// Returns true if the disease spreads through air.
  bool get isAirBorne =>
      spreadMethod?.toLowerCase() == 'airborne' ||
          spreadMethod?.toLowerCase() == 'air';

  @override
  String toString() =>
      'DiseaseModel(id: $id, name: $name, severity: $severity, affectedCrops: ${affectedCrops.join(", ")})';

  // -----------------------------
  // Constants
  // -----------------------------

  static const List<String> severityLevels = [
    'Low',
    'Medium',
    'High',
    'Critical',
  ];

  static const List<String> spreadMethods = [
    'Airborne',
    'Waterborne',
    'Insect',
    'Contact',
    'Soilborne',
    'Seedborne',
  ];

  static const List<String> affectedPlantParts = [
    'Leaf',
    'Stem',
    'Root',
    'Fruit',
    'Flower',
    'Seed',
  ];

  static const List<String> diseaseTypes = [
    'Fungal',
    'Bacterial',
    'Viral',
    'Nematode',
    'Physiological',
  ];

  /// Filters a list of diseases by severity.
  static List<DiseaseModel> filterBySeverity(
      List<DiseaseModel> diseases, String level) {
    return diseases
        .where((d) => d.severity.toLowerCase() == level.toLowerCase())
        .toList();
  }

  /// Filters diseases that affect a specific crop.
  static List<DiseaseModel> filterByCrop(
      List<DiseaseModel> diseases, String cropName) {
    return diseases
        .where((d) => d.affectsCrop(cropName))
        .toList();
  }

  /// Searches diseases by name or symptom keyword.
  static List<DiseaseModel> searchDiseases(
      List<DiseaseModel> diseases, String query) {
    final lowerQuery = query.toLowerCase();
    return diseases.where((d) {
      return d.name.toLowerCase().contains(lowerQuery) ||
          d.symptoms.any((s) => s.toLowerCase().contains(lowerQuery)) ||
          (d.scientificName?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }
}