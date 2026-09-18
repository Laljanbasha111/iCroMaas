/// Represents the complete result of a crop analysis.
///
/// This model is shared between:
/// - AnalysisProvider
/// - AnalysisScreen
/// - AnalysisResultScreen
/// - Local TFLite inference
/// - YOLO/API inference
/// - Analysis history
/// - SQLite database storage
class AnalysisModel {
  // ============================================================
  // BASIC INFORMATION
  // ============================================================

  final String id;

  final String userId;

  final String cropType;

  // ============================================================
  // ANALYSIS METRICS
  // ============================================================

  /// Overall crop health score from 0 to 100.
  final double healthScore;

  /// Biomass value.
  final double biomass;

  /// Nitrogen level/value.
  final double nitrogenLevel;

  /// Model confidence.
  ///
  /// Usually represented as 0.0 - 1.0.
  /// The model also accepts 0 - 100 values and normalizes them
  /// when reading from maps.
  final double confidence;

  /// Probability of disease, normally represented as 0-1.
  final double diseaseProbability;

  /// Probability of pest, normally represented as 0-1.
  final double pestProbability;

  // ============================================================
  // HEALTH FLAGS
  // ============================================================

  final bool hasDisease;

  final bool hasPest;

  // ============================================================
  // DISEASE / PEST INFORMATION
  // ============================================================

  final String? diseaseType;

  final String? pestType;

  // ============================================================
  // ADDITIONAL INFORMATION
  // ============================================================

  final String notes;

  final String? location;

  /// Local image path or remote image URL.
  final String? imageUrl;

  /// Date on which analysis was performed.
  final DateTime date;

  /// AI-generated recommendations.
  final List<String>? recommendations;

  // ============================================================
  // DATABASE TIMESTAMPS
  // ============================================================

  final DateTime createdAt;

  final DateTime updatedAt;

  // ============================================================
  // CONSTRUCTOR
  // ============================================================

  const AnalysisModel({
    required this.id,
    required this.userId,
    required this.cropType,
    required this.healthScore,
    this.biomass = 0.0,
    this.confidence = 0.0,
    this.hasDisease = false,
    this.hasPest = false,
    this.notes = '',
    this.location,
    this.imageUrl,
    required this.date,
    this.diseaseType,
    this.pestType,
    this.recommendations,
    this.nitrogenLevel = 0.0,
    this.diseaseProbability = 0.0,
    this.pestProbability = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  // ============================================================
  // FROM MAP
  // ============================================================

  factory AnalysisModel.fromMap(
      Map<String, dynamic> map,
      ) {
    final DateTime now = DateTime.now();

    return AnalysisModel(
      id: _readString(
        map['id'],
        fallback: '',
      ),

      userId: _readString(
        map['userId'] ?? map['user_id'],
        fallback: '',
      ),

      cropType: _readString(
        map['cropType'] ??
            map['cropName'] ??
            map['crop_name'],
        fallback: 'Unknown',
      ),

      healthScore: _readDouble(
        map['healthScore'] ??
            map['health_score'],
        fallback: 0.0,
      ),

      biomass: _readDouble(
        map['biomass'] ??
            map['predictedBiomass'],
        fallback: 0.0,
      ),

      confidence: _normalizeConfidence(
        _readDouble(
          map['confidence'],
          fallback: 0.0,
        ),
      ),

      hasDisease: _readBool(
        map['hasDisease'] ??
            map['has_disease'] ??
            (map['isHealthy'] == false),
        fallback: false,
      ),

      hasPest: _readBool(
        map['hasPest'] ??
            map['has_pest'],
        fallback: false,
      ),

      notes: _readString(
        map['notes'],
        fallback: '',
      ),

      location: _readNullableString(
        map['location'],
      ),

      imageUrl: _readNullableString(
        map['imageUrl'] ??
            map['imagePath'] ??
            map['image_path'],
      ),

      date: _readDateTime(
        map['date'] ??
            map['timestamp'],
        fallback: now,
      ),

      diseaseType: _readNullableString(
        map['diseaseType'] ??
            map['disease_name'],
      ),

      pestType: _readNullableString(
        map['pestType'] ??
            map['pest_type'],
      ),

      recommendations: _readStringList(
        map['recommendations'],
      ),

      nitrogenLevel: _readDouble(
        map['nitrogenLevel'] ??
            map['nitrogen'] ??
            map['predictedNitrogen'],
        fallback: 0.0,
      ),

      diseaseProbability: _readDouble(
        map['diseaseProbability'] ??
            map['disease_probability'],
        fallback: 0.0,
      ),

      pestProbability: _readDouble(
        map['pestProbability'] ??
            map['pest_probability'],
        fallback: 0.0,
      ),

      createdAt: _readDateTime(
        map['createdAt'] ??
            map['created_at'],
        fallback: now,
      ),

      updatedAt: _readDateTime(
        map['updatedAt'] ??
            map['updated_at'],
        fallback: now,
      ),
    );
  }

  // ============================================================
  // FROM DATABASE MAP
  // ============================================================

  /// Creates an AnalysisModel from the SQLite database format
  /// used by AnalysisDatabase.
  factory AnalysisModel.fromDatabaseMap(
      Map<String, dynamic> map,
      ) {
    final DateTime now = DateTime.now();

    final String diseaseName = _readString(
      map['disease_name'],
      fallback: 'Unknown',
    );

    final bool healthy = _readBool(
      map['is_healthy'],
      fallback: false,
    );

    return AnalysisModel(
      // SQLite uses INTEGER id.
      id: _readString(
        map['id'],
        fallback: '',
      ),

      userId: _readString(
        map['user_id'],
        fallback: '',
      ),

      cropType: _readString(
        map['crop_name'],
        fallback: 'Unknown',
      ),

      healthScore: _readDouble(
        map['health_score'],
        fallback: 0.0,
      ),

      biomass: _readDouble(
        map['biomass'],
        fallback: 0.0,
      ),

      confidence: _normalizeConfidence(
        _readDouble(
          map['confidence'],
          fallback: 0.0,
        ),
      ),

      hasDisease: !healthy &&
          diseaseName.toLowerCase() != 'unknown' &&
          diseaseName.trim().isNotEmpty,

      hasPest: false,

      notes: _readString(
        map['notes'],
        fallback: '',
      ),

      imageUrl: _readNullableString(
        map['image_path'],
      ),

      date: _readDateTime(
        map['timestamp'],
        fallback: now,
      ),

      diseaseType: diseaseName.toLowerCase() == 'unknown'
          ? null
          : diseaseName,

      pestType: null,

      recommendations: null,

      nitrogenLevel: _readDouble(
        map['nitrogen'],
        fallback: 0.0,
      ),

      diseaseProbability: 0.0,

      pestProbability: 0.0,

      createdAt: _readDateTime(
        map['timestamp'],
        fallback: now,
      ),

      updatedAt: _readDateTime(
        map['timestamp'],
        fallback: now,
      ),
    );
  }

  // ============================================================
  // TO MAP
  // ============================================================

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'cropType': cropType,
      'healthScore': healthScore,
      'biomass': biomass,
      'confidence': confidence,
      'hasDisease': hasDisease,
      'hasPest': hasPest,
      'notes': notes,
      'location': location,
      'imageUrl': imageUrl,

      // Compatibility with AnalysisResultScreen.
      'imagePath': imageUrl,

      'date': date.toIso8601String(),

      'diseaseType': diseaseType,
      'pestType': pestType,

      'recommendations':
      recommendations ?? <String>[],

      'nitrogenLevel': nitrogenLevel,
      'diseaseProbability': diseaseProbability,
      'pestProbability': pestProbability,

      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // ============================================================
  // TO DATABASE MAP
  // ============================================================

  /// Converts this AnalysisModel into the exact format expected
  /// by AnalysisDatabase.insertAnalysis().
  ///
  /// This is the important bridge between:
  ///
  /// AnalysisProvider
  ///        ↓
  /// AnalysisModel
  ///        ↓
  /// AnalysisDatabase
  ///        ↓
  /// SQLite
  Map<String, dynamic> toDatabaseMap() {
    return <String, dynamic>{
      'crop_name': cropType.trim().isEmpty
          ? 'Unknown'
          : cropType.trim(),

      'disease_name':
      diseaseType?.trim().isNotEmpty == true
          ? diseaseType!.trim()
          : hasDisease
          ? 'Disease detected'
          : 'Unknown',

      'is_healthy':
      isHealthyForDashboard ? 1 : 0,

      'confidence':
      _normalizeConfidence(confidence),

      'nitrogen':
      _safeDouble(nitrogenLevel),

      'biomass':
      _safeDouble(biomass),

      'health_score':
      _safeDouble(
        healthScore.clamp(0.0, 100.0),
      ),

      'severity':
      severity,

      'image_path':
      imageUrl,

      'timestamp':
      date.toIso8601String(),
    };
  }

  // ============================================================
  // DASHBOARD HEALTH STATUS
  // ============================================================

  /// Determines whether this analysis should be counted under
  /// "Healthy" on the HomeScreen.
  ///
  /// Healthy means:
  ///
  /// - Health score >= 80
  /// - No disease
  /// - No pest
  ///
  /// Everything else is counted as an issue.
  bool get isHealthyForDashboard {
    return healthScore >= 80.0 &&
        !hasDisease &&
        !hasPest;
  }

  /// Returns the status used by the dashboard/database.
  String get dashboardStatus {
    if (isHealthyForDashboard) {
      return 'Healthy';
    }

    return 'Issue';
  }

  // ============================================================
  // SEVERITY
  // ============================================================

  String get severity {
    if (isHealthyForDashboard) {
      return 'None';
    }

    if (hasDisease || hasPest) {
      if (healthScore < 40) {
        return 'Severe';
      }

      if (healthScore < 60) {
        return 'High';
      }

      return 'Moderate';
    }

    if (healthScore < 40) {
      return 'Severe';
    }

    if (healthScore < 60) {
      return 'High';
    }

    if (healthScore < 80) {
      return 'Moderate';
    }

    return 'Low';
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  AnalysisModel copyWith({
    String? id,
    String? userId,
    String? cropType,
    double? healthScore,
    double? biomass,
    double? confidence,
    bool? hasDisease,
    bool? hasPest,
    String? notes,
    String? location,
    String? imageUrl,
    DateTime? date,
    String? diseaseType,
    String? pestType,
    List<String>? recommendations,
    double? nitrogenLevel,
    double? diseaseProbability,
    double? pestProbability,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AnalysisModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      cropType: cropType ?? this.cropType,
      healthScore:
      healthScore ?? this.healthScore,
      biomass:
      biomass ?? this.biomass,
      confidence:
      confidence ?? this.confidence,
      hasDisease:
      hasDisease ?? this.hasDisease,
      hasPest:
      hasPest ?? this.hasPest,
      notes:
      notes ?? this.notes,
      location:
      location ?? this.location,
      imageUrl:
      imageUrl ?? this.imageUrl,
      date:
      date ?? this.date,
      diseaseType:
      diseaseType ?? this.diseaseType,
      pestType:
      pestType ?? this.pestType,
      recommendations:
      recommendations ?? this.recommendations,
      nitrogenLevel:
      nitrogenLevel ?? this.nitrogenLevel,
      diseaseProbability:
      diseaseProbability ?? this.diseaseProbability,
      pestProbability:
      pestProbability ?? this.pestProbability,
      createdAt:
      createdAt ?? this.createdAt,
      updatedAt:
      updatedAt ?? this.updatedAt,
    );
  }

  // ============================================================
  // HELPER: STRING
  // ============================================================

  static String _readString(
      dynamic value, {
        String fallback = '',
      }) {
    if (value == null) {
      return fallback;
    }

    final String result =
    value.toString().trim();

    if (result.isEmpty) {
      return fallback;
    }

    return result;
  }

  // ============================================================
  // HELPER: NULLABLE STRING
  // ============================================================

  static String? _readNullableString(
      dynamic value,
      ) {
    if (value == null) {
      return null;
    }

    final String result =
    value.toString().trim();

    if (result.isEmpty) {
      return null;
    }

    return result;
  }

  // ============================================================
  // HELPER: DOUBLE
  // ============================================================

  static double _readDouble(
      dynamic value, {
        double fallback = 0.0,
      }) {
    if (value == null) {
      return fallback;
    }

    if (value is num) {
      final double result =
      value.toDouble();

      if (result.isNaN ||
          result.isInfinite) {
        return fallback;
      }

      return result;
    }

    if (value is String) {
      final double? parsed =
      double.tryParse(
        value.trim(),
      );

      if (parsed == null ||
          parsed.isNaN ||
          parsed.isInfinite) {
        return fallback;
      }

      return parsed;
    }

    try {
      final double parsed =
      double.parse(
        value.toString(),
      );

      if (parsed.isNaN ||
          parsed.isInfinite) {
        return fallback;
      }

      return parsed;
    } catch (_) {
      return fallback;
    }
  }

  // ============================================================
  // HELPER: SAFE DOUBLE
  // ============================================================

  static double _safeDouble(
      double value,
      ) {
    if (value.isNaN ||
        value.isInfinite) {
      return 0.0;
    }

    return value;
  }

  // ============================================================
  // HELPER: CONFIDENCE NORMALIZATION
  // ============================================================

  static double _normalizeConfidence(
      double value,
      ) {
    if (value.isNaN ||
        value.isInfinite) {
      return 0.0;
    }

    // Already 0.0 - 1.0.
    if (value >= 0.0 &&
        value <= 1.0) {
      return value;
    }

    // Convert 0 - 100 to 0.0 - 1.0.
    if (value > 1.0 &&
        value <= 100.0) {
      return value / 100.0;
    }

    if (value < 0.0) {
      return 0.0;
    }

    return 1.0;
  }

  // ============================================================
  // HELPER: BOOLEAN
  // ============================================================

  static bool _readBool(
      dynamic value, {
        bool fallback = false,
      }) {
    if (value == null) {
      return fallback;
    }

    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    if (value is String) {
      final String normalized =
      value.trim().toLowerCase();

      if (normalized == 'true' ||
          normalized == 'yes' ||
          normalized == '1' ||
          normalized == 'healthy') {
        return true;
      }

      if (normalized == 'false' ||
          normalized == 'no' ||
          normalized == '0' ||
          normalized == 'issue' ||
          normalized == 'unhealthy') {
        return false;
      }
    }

    return fallback;
  }

  // ============================================================
  // HELPER: STRING LIST
  // ============================================================

  static List<String>? _readStringList(
      dynamic value,
      ) {
    if (value == null) {
      return null;
    }

    if (value is List) {
      final List<String> result =
      value
          .map(
            (dynamic item) =>
            item.toString(),
      )
          .where(
            (String item) =>
        item.trim().isNotEmpty,
      )
          .toList();

      return result;
    }

    if (value is String) {
      final String normalized =
      value.trim();

      if (normalized.isEmpty) {
        return null;
      }

      return <String>[normalized];
    }

    return null;
  }

  // ============================================================
  // HELPER: DATETIME
  // ============================================================

  static DateTime _readDateTime(
      dynamic value, {
        required DateTime fallback,
      }) {
    if (value == null) {
      return fallback;
    }

    // Normal DateTime.
    if (value is DateTime) {
      return value;
    }

    // ISO String.
    if (value is String) {
      final DateTime? parsed =
      DateTime.tryParse(
        value.trim(),
      );

      return parsed ?? fallback;
    }

    // Firestore Timestamp compatibility.
    try {
      final dynamic timestamp =
          value;

      final dynamic dateTime =
      timestamp.toDate();

      if (dateTime is DateTime) {
        return dateTime;
      }
    } catch (_) {
      // Ignore and use fallback.
    }

    // Milliseconds since epoch.
    if (value is int) {
      try {
        return DateTime
            .fromMillisecondsSinceEpoch(
          value,
        );
      } catch (_) {
        return fallback;
      }
    }

    if (value is num) {
      try {
        return DateTime
            .fromMillisecondsSinceEpoch(
          value.toInt(),
        );
      } catch (_) {
        return fallback;
      }
    }

    return fallback;
  }

  // ============================================================
  // DISPLAY HELPERS
  // ============================================================

  String get formattedCropType {
    if (cropType.trim().isEmpty) {
      return 'Unknown';
    }

    return cropType
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .trim();
  }

  String get formattedHealthScore {
    return '${healthScore.toStringAsFixed(0)}%';
  }

  String get formattedBiomass {
    return '${biomass.toStringAsFixed(1)} g/m²';
  }

  String get formattedNitrogen {
    return nitrogenLevel.toStringAsFixed(2);
  }

  String get formattedConfidence {
    return '${(confidence * 100).toStringAsFixed(1)}%';
  }

  // ============================================================
  // HEALTH STATUS
  // ============================================================

  String get healthStatus {
    if (isHealthyForDashboard) {
      return 'Healthy';
    }

    if (healthScore >= 60) {
      return 'Moderate';
    }

    return 'Needs Attention';
  }

  // ============================================================
  // JSON-LIKE DEBUG REPRESENTATION
  // ============================================================

  @override
  String toString() {
    return 'AnalysisModel('
        'id: $id, '
        'cropType: $cropType, '
        'healthScore: $healthScore, '
        'biomass: $biomass, '
        'nitrogenLevel: $nitrogenLevel, '
        'confidence: $confidence, '
        'hasDisease: $hasDisease, '
        'hasPest: $hasPest, '
        'isHealthy: $isHealthyForDashboard'
        ')';
  }
}