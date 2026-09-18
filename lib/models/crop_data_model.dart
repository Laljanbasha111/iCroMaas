import 'dart:convert';
import 'package:flutter/services.dart';

/// Model for individual crop data
class CropData {
  final String id;
  final String name;
  final double biomass;
  final double nitrogen;
  final String imagePath;
  final String? description;

  CropData({
    required this.id,
    required this.name,
    required this.biomass,
    required this.nitrogen,
    required this.imagePath,
    this.description,
  });

  /// Formatted biomass with unit
  String get formattedBiomass => '${biomass.toStringAsFixed(1)} g/m²';

  /// Formatted nitrogen with unit
  String get formattedNitrogen => '${nitrogen.toStringAsFixed(1)}%';

  /// Create from JSON
  factory CropData.fromJson(Map<String, dynamic> json) {
    return CropData(
      id: json['id'] as String,
      name: json['name'] as String,
      biomass: (json['biomass'] as num).toDouble(),
      nitrogen: (json['nitrogen'] as num).toDouble(),
      imagePath: json['image_path'] as String,
      description: json['description'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'biomass': biomass,
      'nitrogen': nitrogen,
      'image_path': imagePath,
      'description': description,
    };
  }

  @override
  String toString() {
    return 'CropData(name: $name, biomass: $biomass, nitrogen: $nitrogen)';
  }
}

/// Model for list of crops
class CropDataList {
  final List<CropData> crops;

  CropDataList({required this.crops});

  /// Get number of crops
  int get length => crops.length;

  /// Check if list is empty
  bool get isEmpty => crops.isEmpty;

  /// Check if list is not empty
  bool get isNotEmpty => crops.isNotEmpty;

  /// Load from assets JSON file
  static Future<CropDataList> loadFromAssets() async {
    try {
      final jsonString = await rootBundle.loadString(
        'lib/assets/models/crops_reference_data.json',
      );
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      final cropsList = (jsonData['crops'] as List)
          .map((cropJson) => CropData.fromJson(cropJson as Map<String, dynamic>))
          .toList();

      return CropDataList(crops: cropsList);
    } catch (e) {
      print('❌ Error loading crop data from assets: $e');
      throw Exception('Failed to load crop data: $e');
    }
  }

  /// Search crops by name
  List<CropData> searchByName(String query) {
    if (query.isEmpty) return crops;

    final lowerQuery = query.toLowerCase();
    return crops.where((crop) {
      return crop.name.toLowerCase().contains(lowerQuery) ||
          (crop.description?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// Get crop by name
  CropData? getCropByName(String name) {
    try {
      return crops.firstWhere(
            (crop) => crop.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get crop by ID
  CropData? getCropById(String id) {
    try {
      return crops.firstWhere((crop) => crop.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Sort crops by name
  List<CropData> sortByName({bool ascending = true}) {
    final sorted = List<CropData>.from(crops);
    sorted.sort((a, b) => ascending
        ? a.name.compareTo(b.name)
        : b.name.compareTo(a.name));
    return sorted;
  }

  /// Sort crops by biomass
  List<CropData> sortByBiomass({bool ascending = true}) {
    final sorted = List<CropData>.from(crops);
    sorted.sort((a, b) => ascending
        ? a.biomass.compareTo(b.biomass)
        : b.biomass.compareTo(a.biomass));
    return sorted;
  }

  /// Sort crops by nitrogen
  List<CropData> sortByNitrogen({bool ascending = true}) {
    final sorted = List<CropData>.from(crops);
    sorted.sort((a, b) => ascending
        ? a.nitrogen.compareTo(b.nitrogen)
        : b.nitrogen.compareTo(a.nitrogen));
    return sorted;
  }

  /// Filter crops by biomass range
  List<CropData> filterByBiomassRange(double min, double max) {
    return crops.where((crop) =>
    crop.biomass >= min && crop.biomass <= max).toList();
  }

  /// Filter crops by nitrogen range
  List<CropData> filterByNitrogenRange(double min, double max) {
    return crops.where((crop) =>
    crop.nitrogen >= min && crop.nitrogen <= max).toList();
  }

  /// Get crop names list
  List<String> getCropNames() {
    return crops.map((crop) => crop.name).toList();
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'crops': crops.map((crop) => crop.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'CropDataList(count: ${crops.length})';
  }
}