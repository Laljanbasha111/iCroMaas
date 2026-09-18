import 'dart:io';

/// Retained temporarily so older screens do not fail to compile.
///
/// Automatic crop analysis has been disabled. This compatibility
/// service does not load files, run predictions, or generate results.
enum ModelType {
  nitrogen,
  croptype,
  biomass,
}

/// Temporary compatibility service.
///
/// This service is no longer an analysis engine. It only returns a
/// clear unavailable response to older code that may still call it.
///
/// Once all old references are removed, delete this file and update
/// any remaining imports.
@Deprecated(
  'Automatic analysis has been removed. '
      'Remove all usages of YoloModelService.',
)
class YoloModelService {
  static final YoloModelService _instance =
  YoloModelService._internal();

  factory YoloModelService() {
    return _instance;
  }

  YoloModelService._internal();

  bool _isInitialized = false;

  DateTime? _initializedAt;

  String get status => 'Automatic analysis disabled';

  bool get isInitialized => _isInitialized;

  DateTime? get initializedAt => _initializedAt;

  /// Compatibility initializer.
  ///
  /// No external service or local analysis engine is started.
  Future<void> initialize() async {
    _isInitialized = false;
    _initializedAt = null;
  }

  /// Compatibility method for older callers.
  ///
  /// Returns an unavailable response instead of generating fake data.
  Future<Map<String, dynamic>> runInference(
      String imagePath,
      ModelType modelType,
      ) async {
    final String safeImagePath =
    imagePath.trim();

    if (safeImagePath.isEmpty) {
      return _createUnavailableResult(
        analysisType: modelType.name,
        imagePath: safeImagePath,
        message: 'Image path is empty.',
      );
    }

    final File imageFile =
    File(safeImagePath);

    if (!await imageFile.exists()) {
      return _createUnavailableResult(
        analysisType: modelType.name,
        imagePath: safeImagePath,
        message: 'Image file does not exist.',
      );
    }

    return _createUnavailableResult(
      analysisType: modelType.name,
      imagePath: safeImagePath,
      message:
      'Automatic crop analysis is disabled.',
    );
  }

  /// Compatibility method for older callers.
  ///
  /// Returns an unavailable response instead of generating fake data.
  Future<Map<String, dynamic>> runAllModels(
      String imagePath,
      ) async {
    final String safeImagePath =
    imagePath.trim();

    if (safeImagePath.isEmpty) {
      return _createUnavailableResult(
        analysisType: 'all',
        imagePath: safeImagePath,
        message: 'Image path is empty.',
      );
    }

    final File imageFile =
    File(safeImagePath);

    if (!await imageFile.exists()) {
      return _createUnavailableResult(
        analysisType: 'all',
        imagePath: safeImagePath,
        message: 'Image file does not exist.',
      );
    }

    return _createUnavailableResult(
      analysisType: 'all',
      imagePath: safeImagePath,
      message:
      'Automatic crop analysis is disabled.',
    );
  }

  /// Converts a string into the old enum type for compatibility.
  ModelType modelTypeFromString(
      String? value,
      ) {
    final String normalized =
    (value ?? '').trim().toLowerCase();

    switch (normalized) {
      case 'nitrogen':
      case 'n':
        return ModelType.nitrogen;

      case 'biomass':
      case 'bio':
        return ModelType.biomass;

      case 'croptype':
      case 'crop_type':
      case 'crop':
      default:
        return ModelType.croptype;
    }
  }

  /// Resets the compatibility state.
  void reset() {
    _isInitialized = false;
    _initializedAt = null;
  }

  /// No resources need to be released.
  void dispose() {
    reset();
  }

  Map<String, dynamic> _createUnavailableResult({
    required String analysisType,
    required String imagePath,
    required String message,
  }) {
    return <String, dynamic>{
      'success': false,
      'available': false,
      'analysisType': analysisType,
      'modelType': analysisType,
      'predictions': <Map<String, dynamic>>[],
      'topPrediction': null,
      'inferenceTime': 0,
      'timestamp':
      DateTime.now().toIso8601String(),
      'imagePath': imagePath,
      'message': message,
    };
  }
}

/// Retained temporarily for source compatibility.
///
/// No automatic prediction data is produced.
@Deprecated(
  'Prediction data is no longer used.',
)
class PredictionData {
  final Map<String, dynamic> prediction;

  const PredictionData({
    required this.prediction,
  });
}