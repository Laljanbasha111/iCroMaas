import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

part 'test_result_model.g.dart';

/// Model for storing test results with accuracy metrics
@HiveType(typeId: 1)
class TestResult extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String cropName;

  @HiveField(2)
  final double referenceBiomass;

  @HiveField(3)
  final double referenceNitrogen;

  @HiveField(4)
  final double predictedBiomass;

  @HiveField(5)
  final double predictedNitrogen;

  @HiveField(6)
  final DateTime timestamp;

  @HiveField(7)
  final String imagePath;

  TestResult({
    required this.id,
    required this.cropName,
    required this.referenceBiomass,
    required this.referenceNitrogen,
    required this.predictedBiomass,
    required this.predictedNitrogen,
    required this.timestamp,
    required this.imagePath,
  });

  /// Calculate biomass accuracy (0-100%)
  double get biomassAccuracy {
    if (referenceBiomass == 0) return 0.0;
    final error = (predictedBiomass - referenceBiomass).abs();
    final accuracy = (1 - (error / referenceBiomass)) * 100;
    return accuracy.clamp(0.0, 100.0);
  }

  /// Calculate nitrogen accuracy (0-100%)
  double get nitrogenAccuracy {
    if (referenceNitrogen == 0) return 0.0;
    final error = (predictedNitrogen - referenceNitrogen).abs();
    final accuracy = (1 - (error / referenceNitrogen)) * 100;
    return accuracy.clamp(0.0, 100.0);
  }

  /// Calculate overall accuracy (average of biomass and nitrogen)
  double get overallAccuracy {
    return (biomassAccuracy + nitrogenAccuracy) / 2;
  }

  /// Biomass error (predicted - reference)
  double get biomassError => predictedBiomass - referenceBiomass;

  /// Nitrogen error (predicted - reference)
  double get nitrogenError => predictedNitrogen - referenceNitrogen;

  /// Check if prediction is good (>= 80% accuracy)
  bool get isGoodPrediction => overallAccuracy >= 80.0;

  /// Check if prediction is excellent (>= 90% accuracy)
  bool get isExcellentPrediction => overallAccuracy >= 90.0;

  /// Get accuracy category
  String get accuracyCategory {
    if (overallAccuracy >= 90) return 'Excellent';
    if (overallAccuracy >= 80) return 'Good';
    if (overallAccuracy >= 70) return 'Fair';
    return 'Poor';
  }

  /// Formatted timestamp
  String get formattedTimestamp {
    return DateFormat('MMM dd, yyyy HH:mm').format(timestamp);
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'crop_name': cropName,
      'reference_biomass': referenceBiomass,
      'reference_nitrogen': referenceNitrogen,
      'predicted_biomass': predictedBiomass,
      'predicted_nitrogen': predictedNitrogen,
      'timestamp': timestamp.toIso8601String(),
      'image_path': imagePath,
      'biomass_accuracy': biomassAccuracy,
      'nitrogen_accuracy': nitrogenAccuracy,
      'overall_accuracy': overallAccuracy,
    };
  }

  /// Create from JSON
  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      id: json['id'] as String,
      cropName: json['crop_name'] as String,
      referenceBiomass: (json['reference_biomass'] as num).toDouble(),
      referenceNitrogen: (json['reference_nitrogen'] as num).toDouble(),
      predictedBiomass: (json['predicted_biomass'] as num).toDouble(),
      predictedNitrogen: (json['predicted_nitrogen'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      imagePath: json['image_path'] as String,
    );
  }

  @override
  String toString() {
    return 'TestResult(crop: $cropName, accuracy: ${overallAccuracy.toStringAsFixed(2)}%)';
  }
}