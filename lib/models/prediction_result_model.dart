/// Represents the result of a crop analysis.
///
/// This class is retained for compatibility with existing screens
/// and stored analysis data.
///
/// It is a plain data model only. It does not:
/// - Load an analysis engine
/// - Run image analysis
/// - Load local model files
/// - Make network requests
class PredictionResult {
  final double predictedBiomass;
  final double predictedNitrogen;
  final double confidence;
  final DateTime timestamp;
  final String? cropName;
  final String? imagePath;

  const PredictionResult({
    required this.predictedBiomass,
    required this.predictedNitrogen,
    required this.confidence,
    required this.timestamp,
    this.cropName,
    this.imagePath,
  });

  // ============================================================
  // FORMATTED GETTERS
  // ============================================================

  /// Biomass formatted for display.
  String get formattedBiomass {
    return '${predictedBiomass.toStringAsFixed(2)} g/m²';
  }

  /// Nitrogen formatted for display.
  String get formattedNitrogen {
    return '${predictedNitrogen.toStringAsFixed(2)} %';
  }

  /// Confidence formatted as a percentage.
  ///
  /// Example:
  ///
  /// ```text
  /// confidence = 0.95
  /// result     = 95.0%
  /// ```
  String get formattedConfidence {
    return '${confidencePercentage.toStringAsFixed(1)}%';
  }

  /// Confidence represented as a percentage number.
  ///
  /// Example:
  ///
  /// ```text
  /// confidence = 0.95
  /// result     = 95.0
  /// ```
  double get confidencePercentage {
    return _normalizeConfidence(confidence) * 100.0;
  }

  /// Timestamp formatted as:
  ///
  /// ```text
  /// dd/MM/yyyy  HH:mm
  /// ```
  String get formattedTimestamp {
    final String day =
    timestamp.day.toString().padLeft(2, '0');

    final String month =
    timestamp.month.toString().padLeft(2, '0');

    final String year =
    timestamp.year.toString();

    final String hour =
    timestamp.hour.toString().padLeft(2, '0');

    final String minute =
    timestamp.minute.toString().padLeft(2, '0');

    return '$day/$month/$year  $hour:$minute';
  }

  // ============================================================
  // ACCURACY METHODS
  // ============================================================

  /// Calculates biomass accuracy against an actual value.
  ///
  /// Returns a value between 0.0 and 100.0.
  double calculateBiomassAccuracy(
      double actualBiomass,
      ) {
    return _calculateAccuracy(
      predictedValue: predictedBiomass,
      actualValue: actualBiomass,
    );
  }

  /// Calculates nitrogen accuracy against an actual value.
  ///
  /// Returns a value between 0.0 and 100.0.
  double calculateNitrogenAccuracy(
      double actualNitrogen,
      ) {
    return _calculateAccuracy(
      predictedValue: predictedNitrogen,
      actualValue: actualNitrogen,
    );
  }

  /// Calculates the average biomass and nitrogen accuracy.
  double calculateOverallAccuracy(
      double actualBiomass,
      double actualNitrogen,
      ) {
    final double biomassAccuracy =
    calculateBiomassAccuracy(actualBiomass);

    final double nitrogenAccuracy =
    calculateNitrogenAccuracy(actualNitrogen);

    return (
        biomassAccuracy +
            nitrogenAccuracy
    ) /
        2.0;
  }

  /// Returns the biomass error percentage.
  double getBiomassError(
      double actualBiomass,
      ) {
    return _calculateErrorPercentage(
      predictedValue: predictedBiomass,
      actualValue: actualBiomass,
    );
  }

  /// Returns the nitrogen error percentage.
  double getNitrogenError(
      double actualNitrogen,
      ) {
    return _calculateErrorPercentage(
      predictedValue: predictedNitrogen,
      actualValue: actualNitrogen,
    );
  }

  /// Returns true when the average accuracy is at least 80%.
  bool isGoodPrediction(
      double actualBiomass,
      double actualNitrogen,
      ) {
    return calculateOverallAccuracy(
      actualBiomass,
      actualNitrogen,
    ) >=
        80.0;
  }

  // ============================================================
  // PREDICTION HELPERS
  // ============================================================

  /// Returns true if biomass has a positive value.
  bool get hasBiomassPrediction {
    return _isValidPositiveNumber(
      predictedBiomass,
    );
  }

  /// Returns true if nitrogen has a positive value.
  bool get hasNitrogenPrediction {
    return _isValidPositiveNumber(
      predictedNitrogen,
    );
  }

  /// Returns true if a crop name is available.
  bool get hasCropName {
    return cropName != null &&
        cropName!.trim().isNotEmpty;
  }

  /// Returns true if an image path is available.
  bool get hasImage {
    return imagePath != null &&
        imagePath!.trim().isNotEmpty;
  }

  /// Returns true if at least one numeric result is available.
  bool get hasPrediction {
    return hasBiomassPrediction ||
        hasNitrogenPrediction;
  }

  // ============================================================
  // JSON SERIALIZATION
  // ============================================================

  /// Converts this result to a JSON-compatible map using
  /// snake_case keys.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'predicted_biomass': predictedBiomass,
      'predicted_nitrogen': predictedNitrogen,
      'confidence': _normalizeConfidence(
        confidence,
      ),
      'timestamp': timestamp.toIso8601String(),
      'crop_name': cropName,
      'image_path': imagePath,
    };
  }

  /// Converts this result to a map using camelCase keys.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'predictedBiomass': predictedBiomass,
      'predictedNitrogen': predictedNitrogen,
      'confidence': _normalizeConfidence(
        confidence,
      ),
      'timestamp': timestamp.toIso8601String(),
      'cropName': cropName,
      'imagePath': imagePath,
    };
  }

  /// Creates a result from JSON.
  ///
  /// Supports both snake_case and camelCase keys.
  factory PredictionResult.fromJson(
      Map<String, dynamic> json,
      ) {
    final dynamic biomassValue =
        json['predicted_biomass'] ??
            json['predictedBiomass'] ??
            json['biomass'];

    final dynamic nitrogenValue =
        json['predicted_nitrogen'] ??
            json['predictedNitrogen'] ??
            json['nitrogen'];

    final dynamic confidenceValue =
        json['confidence'] ??
            json['model_confidence'] ??
            json['confidencePercentage'] ??
            0.0;

    final dynamic timestampValue =
    json['timestamp'];

    final dynamic cropValue =
        json['crop_name'] ??
            json['cropName'] ??
            json['crop'];

    final dynamic imageValue =
        json['image_path'] ??
            json['imagePath'];

    return PredictionResult(
      predictedBiomass: _toDouble(
        biomassValue,
      ),
      predictedNitrogen: _toDouble(
        nitrogenValue,
      ),
      confidence: _normalizeConfidence(
        confidenceValue,
      ),
      timestamp: _parseDateTime(
        timestampValue,
      ),
      cropName: _toNullableString(
        cropValue,
      ),
      imagePath: _toNullableString(
        imageValue,
      ),
    );
  }

  /// Creates a result from a generic map.
  factory PredictionResult.fromMap(
      Map<String, dynamic> map,
      ) {
    return PredictionResult.fromJson(map);
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  /// Creates a copy with selected values replaced.
  ///
  /// A nullable field remains unchanged when its argument is null.
  PredictionResult copyWith({
    double? predictedBiomass,
    double? predictedNitrogen,
    double? confidence,
    DateTime? timestamp,
    String? cropName,
    String? imagePath,
  }) {
    return PredictionResult(
      predictedBiomass:
      predictedBiomass ??
          this.predictedBiomass,
      predictedNitrogen:
      predictedNitrogen ??
          this.predictedNitrogen,
      confidence:
      confidence ??
          this.confidence,
      timestamp:
      timestamp ??
          this.timestamp,
      cropName:
      cropName ??
          this.cropName,
      imagePath:
      imagePath ??
          this.imagePath,
    );
  }

  // ============================================================
  // INTERNAL ACCURACY HELPERS
  // ============================================================

  static double _calculateAccuracy({
    required double predictedValue,
    required double actualValue,
  }) {
    if (!_isValidPositiveNumber(actualValue)) {
      return 0.0;
    }

    final double difference =
    (predictedValue - actualValue).abs();

    final double accuracy =
        (1.0 - difference / actualValue) * 100.0;

    if (accuracy.isNaN ||
        accuracy.isInfinite) {
      return 0.0;
    }

    return accuracy
        .clamp(0.0, 100.0)
        .toDouble();
  }

  static double _calculateErrorPercentage({
    required double predictedValue,
    required double actualValue,
  }) {
    if (!_isValidPositiveNumber(actualValue)) {
      return 0.0;
    }

    final double error =
        ((predictedValue - actualValue).abs() /
            actualValue) *
            100.0;

    if (error.isNaN ||
        error.isInfinite) {
      return 0.0;
    }

    return error < 0.0 ? 0.0 : error;
  }

  // ============================================================
  // INTERNAL PARSING HELPERS
  // ============================================================

  /// Converts supported numeric values to double.
  ///
  /// Supports:
  /// - int
  /// - double
  /// - num
  /// - numeric strings
  /// - strings containing a percentage sign
  static double _toDouble(
      dynamic value,
      ) {
    if (value == null) {
      return 0.0;
    }

    if (value is num) {
      final double result =
      value.toDouble();

      if (result.isNaN ||
          result.isInfinite) {
        return 0.0;
      }

      return result;
    }

    if (value is String) {
      String cleaned =
      value.trim();

      if (cleaned.isEmpty) {
        return 0.0;
      }

      cleaned =
          cleaned.replaceAll('%', '');

      final double? parsed =
      double.tryParse(cleaned);

      if (parsed == null ||
          parsed.isNaN ||
          parsed.isInfinite) {
        return 0.0;
      }

      return parsed;
    }

    return 0.0;
  }

  /// Converts a value to a clean nullable string.
  static String? _toNullableString(
      dynamic value,
      ) {
    if (value == null) {
      return null;
    }

    final String result =
    value.toString().trim();

    if (result.isEmpty ||
        result.toLowerCase() == 'null') {
      return null;
    }

    return result;
  }

  /// Normalizes confidence into the range 0.0–1.0.
  ///
  /// Supported inputs:
  ///
  /// ```text
  /// 0.95   -> 0.95
  /// 95     -> 0.95
  /// "95%"  -> 0.95
  /// ```
  static double _normalizeConfidence(
      dynamic value,
      ) {
    final double parsed =
    _toDouble(value);

    if (parsed.isNaN ||
        parsed.isInfinite ||
        parsed <= 0.0) {
      return 0.0;
    }

    if (parsed > 1.0) {
      return (parsed / 100.0)
          .clamp(0.0, 1.0)
          .toDouble();
    }

    return parsed
        .clamp(0.0, 1.0)
        .toDouble();
  }

  /// Parses a date from a DateTime, string, or timestamp.
  static DateTime _parseDateTime(
      dynamic value,
      ) {
    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      final DateTime? parsed =
      DateTime.tryParse(value);

      if (parsed != null) {
        return parsed;
      }
    }

    if (value is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(
          value,
        );
      } catch (_) {
        return DateTime.now();
      }
    }

    if (value is double) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(
          value.toInt(),
        );
      } catch (_) {
        return DateTime.now();
      }
    }

    return DateTime.now();
  }

  static bool _isValidPositiveNumber(
      double value,
      ) {
    return value > 0.0 &&
        !value.isNaN &&
        !value.isInfinite;
  }

  // ============================================================
  // DEBUG / STRING
  // ============================================================

  @override
  String toString() {
    return 'PredictionResult('
        'crop: $cropName, '
        'biomass: $formattedBiomass, '
        'nitrogen: $formattedNitrogen, '
        'confidence: $formattedConfidence, '
        'timestamp: $formattedTimestamp'
        ')';
  }

  // ============================================================
  // EQUALITY
  // ============================================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is! PredictionResult) {
      return false;
    }

    return predictedBiomass ==
        other.predictedBiomass &&
        predictedNitrogen ==
            other.predictedNitrogen &&
        _normalizeConfidence(confidence) ==
            _normalizeConfidence(
              other.confidence,
            ) &&
        timestamp == other.timestamp &&
        cropName == other.cropName &&
        imagePath == other.imagePath;
  }

  @override
  int get hashCode {
    return Object.hash(
      predictedBiomass,
      predictedNitrogen,
      _normalizeConfidence(confidence),
      timestamp,
      cropName,
      imagePath,
    );
  }
}