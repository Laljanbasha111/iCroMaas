import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import '../../models/prediction_result_model.dart';

/// Crop analysis service.
///
/// Local model inference has been removed from the application.
///
/// Crop analysis should now be performed through the API/YOLO flow,
/// normally through AnalysisProvider and YoloModelService.
///
/// This class is retained as a compatibility service so existing
/// code that references CropAnalyzerService can continue compiling.
class CropAnalyzerService {
  CropAnalyzerService._internal();

  static final CropAnalyzerService _instance =
  CropAnalyzerService._internal();

  factory CropAnalyzerService() {
    return _instance;
  }

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  // ============================================================
  // INITIALIZE
  // ============================================================

  /// Initializes the compatibility service.
  ///
  /// No local model is loaded here.
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint(
        '⚠️ CropAnalyzerService is already initialized.',
      );

      return;
    }

    try {
      debugPrint(
        '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
      );
      debugPrint(
        '🚀 INITIALIZING CROP ANALYZER SERVICE',
      );
      debugPrint(
        '📡 Local model inference is disabled.',
      );
      debugPrint(
        '🌐 Use the API/YOLO analysis service instead.',
      );
      debugPrint(
        '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
      );

      _isInitialized = true;

      debugPrint(
        '✅ CropAnalyzerService initialized.',
      );
    } catch (error, stackTrace) {
      _isInitialized = false;

      debugPrint(
        '❌ Failed to initialize CropAnalyzerService: $error',
      );

      debugPrint(
        '📌 Stack trace: $stackTrace',
      );

      rethrow;
    }
  }

  // ============================================================
  // ANALYZE CROP FILE
  // ============================================================

  /// Validates an image file.
  ///
  /// Local inference is no longer performed by this method.
  /// Use AnalysisProvider.analyzeImageWithYolo() for real analysis.
  Future<AnalysisResult> analyzeCrop(
      File imageFile,
      ) async {
    if (!_isInitialized) {
      await initialize();
    }

    debugPrint(
      '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
    );
    debugPrint(
      '🌾 CROP FILE ANALYSIS REQUEST',
    );
    debugPrint(
      '📡 Local model inference is disabled.',
    );
    debugPrint(
      '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
    );

    try {
      if (!await imageFile.exists()) {
        throw Exception(
          'Image file not found:\n${imageFile.path}',
        );
      }

      final int fileSize = await imageFile.length();

      if (fileSize <= 0) {
        throw Exception(
          'Image file is empty.',
        );
      }

      final Uint8List imageBytes =
      await imageFile.readAsBytes();

      if (imageBytes.isEmpty) {
        throw Exception(
          'Unable to read image bytes.',
        );
      }

      final img.Image? decodedImage =
      img.decodeImage(imageBytes);

      if (decodedImage == null) {
        throw Exception(
          'Could not decode the selected image. '
              'Please select a valid JPG or PNG image.',
        );
      }

      debugPrint(
        '✅ Image validated successfully.',
      );

      debugPrint(
        '📐 Image dimensions: '
            '${decodedImage.width} x ${decodedImage.height}',
      );

      return const AnalysisResult(
        error:
        'Local image analysis is disabled. '
            'Use the API/YOLO analysis service instead.',
      );
    } catch (error, stackTrace) {
      debugPrint(
        '❌ Crop file validation failed: $error',
      );

      debugPrint(
        '📌 Stack trace: $stackTrace',
      );

      return AnalysisResult(
        error: 'Image analysis failed: $error',
      );
    }
  }

  // ============================================================
  // ANALYZE IMAGE DIRECTLY
  // ============================================================

  /// Validates an already decoded image.
  ///
  /// Local inference is no longer performed by this method.
  /// Use the API/YOLO analysis service for crop predictions.
  Future<AnalysisResult> analyzeImage(
      img.Image image,
      ) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      if (image.width <= 0 || image.height <= 0) {
        throw Exception(
          'Invalid image dimensions.',
        );
      }

      debugPrint(
        '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
      );
      debugPrint(
        '🖼️ DIRECT IMAGE ANALYSIS REQUEST',
      );
      debugPrint(
        '📐 ${image.width} x ${image.height}',
      );
      debugPrint(
        '📡 Local model inference is disabled.',
      );
      debugPrint(
        '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
      );

      return const AnalysisResult(
        error:
        'Local image analysis is disabled. '
            'Use the API/YOLO analysis service instead.',
      );
    } catch (error, stackTrace) {
      debugPrint(
        '❌ Direct image validation failed: $error',
      );

      debugPrint(
        '📌 Stack trace: $stackTrace',
      );

      return AnalysisResult(
        error: 'Image analysis failed: $error',
      );
    }
  }

  // ============================================================
  // SERVICE CHECK
  // ============================================================

  /// Checks whether this compatibility service is initialized.
  ///
  /// This does not check an ML model because local models have been
  /// removed. For API availability, use the API service health check.
  Future<bool> testConnection() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      debugPrint(
        'ℹ️ CropAnalyzerService is initialized.',
      );

      debugPrint(
        'ℹ️ No local prediction model is loaded.',
      );

      return _isInitialized;
    } catch (error, stackTrace) {
      debugPrint(
        '❌ CropAnalyzerService check failed: $error',
      );

      debugPrint(
        '📌 Stack trace: $stackTrace',
      );

      return false;
    }
  }

  // ============================================================
  // SERVICE INFORMATION
  // ============================================================

  /// Returns information about the current analysis mode.
  Map<String, dynamic> getModelInfo() {
    return <String, dynamic>{
      'initialized': _isInitialized,
      'mode': 'api',
      'local_inference': false,
      'model_loaded': false,
      'model_path': '',
      'message':
      'Local model inference has been removed. '
          'Use the API/YOLO analysis service.',
    };
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  void dispose() {
    debugPrint(
      '🧹 Disposing CropAnalyzerService...',
    );

    _isInitialized = false;

    debugPrint(
      '✅ CropAnalyzerService disposed.',
    );
  }
}

// ================================================================
// ANALYSIS RESULT
// ================================================================

/// UI-friendly result returned by the crop analysis service.
class AnalysisResult {
  final String cropType;
  final String cropDisplayName;
  final double confidence;
  final double? nitrogenLevel;
  final double? biomass;
  final String? error;

  const AnalysisResult({
    this.cropType = 'unknown',
    this.cropDisplayName = 'Unknown',
    this.confidence = 0.0,
    this.nitrogenLevel,
    this.biomass,
    this.error,
  });

  // ============================================================
  // FROM PREDICTION RESULT
  // ============================================================

  factory AnalysisResult.fromPredictionResult(
      PredictionResult prediction,
      ) {
    final String crop =
    (prediction.cropName ?? '').trim();

    final String normalizedCrop =
    crop.isEmpty ? 'unknown' : crop.toLowerCase();

    final String displayCrop =
    crop.isEmpty ? 'Unknown' : crop;

    return AnalysisResult(
      cropType: normalizedCrop,
      cropDisplayName: displayCrop,
      confidence: _normalizeConfidence(
        prediction.confidence,
      ),
      nitrogenLevel: prediction.predictedNitrogen,
      biomass: prediction.predictedBiomass,
    );
  }

  // ============================================================
  // FROM JSON
  // ============================================================

  factory AnalysisResult.fromJson(
      Map<String, dynamic> json,
      ) {
    try {
      final dynamic confidenceValue =
          json['confidence'] ??
              json['confidence_score'] ??
              0.0;

      final dynamic nitrogenValue =
          json['nitrogen'] ??
              json['nitrogenLevel'] ??
              json['predictedNitrogen'];

      final dynamic biomassValue =
          json['biomass'] ??
              json['predictedBiomass'];

      final dynamic cropValue =
          json['crop_type'] ??
              json['cropType'] ??
              json['crop_name'] ??
              json['cropDisplayName'] ??
              'unknown';

      final String rawCrop =
          cropValue?.toString().trim() ?? '';

      final String crop =
      rawCrop.isEmpty ? 'unknown' : rawCrop;

      return AnalysisResult(
        cropType: crop.toLowerCase(),
        cropDisplayName:
        crop.toLowerCase() == 'unknown'
            ? 'Unknown'
            : crop,
        confidence: _normalizeConfidence(
          _toDouble(confidenceValue),
        ),
        nitrogenLevel: _toNullableDouble(
          nitrogenValue,
        ),
        biomass: _toNullableDouble(
          biomassValue,
        ),
        error: json['error']?.toString(),
      );
    } catch (error) {
      debugPrint(
        '❌ Error parsing AnalysisResult JSON: $error',
      );

      return AnalysisResult(
        error:
        'Failed to parse analysis result: $error',
      );
    }
  }

  // ============================================================
  // STATUS
  // ============================================================

  bool get hasError {
    return error != null &&
        error!.trim().isNotEmpty;
  }

  bool get isSuccessful {
    return !hasError &&
        cropType.toLowerCase() != 'unknown';
  }

  // ============================================================
  // NITROGEN STATUS
  // ============================================================

  String getNitrogenStatus() {
    final double? nitrogen = nitrogenLevel;

    if (nitrogen == null) {
      return 'Unknown';
    }

    if (nitrogen < 2.0) {
      return 'Low';
    }

    if (nitrogen < 3.5) {
      return 'Moderate';
    }

    return 'High';
  }

  // ============================================================
  // BIOMASS STATUS
  // ============================================================

  String getBiomassStatus() {
    final double? value = biomass;

    if (value == null) {
      return 'Unknown';
    }

    if (value < 50.0) {
      return 'Low';
    }

    if (value < 100.0) {
      return 'Moderate';
    }

    return 'High';
  }

  // ============================================================
  // TO JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'cropType': cropType,
      'cropDisplayName': cropDisplayName,
      'confidence': confidence,
      'nitrogenLevel': nitrogenLevel,
      'biomass': biomass,
      'error': error,
      'nitrogenStatus': getNitrogenStatus(),
      'biomassStatus': getBiomassStatus(),
    };
  }

  // ============================================================
  // VALUE HELPERS
  // ============================================================

  static double _normalizeConfidence(
      double value,
      ) {
    if (value.isNaN || value.isInfinite) {
      return 0.0;
    }

    double normalized = value;

    if (normalized > 1.0 &&
        normalized <= 100.0) {
      normalized = normalized / 100.0;
    }

    return normalized
        .clamp(0.0, 1.0)
        .toDouble();
  }

  static double _toDouble(
      dynamic value,
      ) {
    if (value == null) {
      return 0.0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString().trim(),
    ) ??
        0.0;
  }

  static double? _toNullableDouble(
      dynamic value,
      ) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString().trim(),
    );
  }

  // ============================================================
  // STRING REPRESENTATION
  // ============================================================

  @override
  String toString() {
    if (hasError) {
      return 'AnalysisResult(error: $error)';
    }

    return 'AnalysisResult('
        'crop: $cropDisplayName, '
        'confidence: '
        '${(confidence * 100).toStringAsFixed(1)}%, '
        'nitrogen: '
        '${nitrogenLevel?.toStringAsFixed(2) ?? 'N/A'}, '
        'biomass: '
        '${biomass?.toStringAsFixed(2) ?? 'N/A'}'
        ')';
  }
}

