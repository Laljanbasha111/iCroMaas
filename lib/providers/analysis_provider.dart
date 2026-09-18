import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

import '../core/database/analysis_database.dart';
import '../models/analysis_model.dart';

/// Manages crop analysis history, database persistence, dashboard
/// statistics, loading state, progress state, and sharing.
///
/// Automatic prediction has been removed from this provider.
///
/// This provider no longer uses:
/// - TFLite
/// - YOLO
/// - Flask/API analysis
/// - CropModelService
/// - PredictionResult
/// - Interpreter
class AnalysisProvider extends ChangeNotifier {
  // ===============================================================
  // SERVICES
  // ===============================================================

  final AnalysisDatabase _analysisDatabase =
      AnalysisDatabase.instance;

  // ===============================================================
  // GENERAL STATE
  // ===============================================================

  bool _isLoading = false;

  bool _isAnalyzing = false;

  String? _error;

  double _progress = 0.0;

  AnalysisModel? _currentResult;

  final List<AnalysisModel> _analysisHistory =
  <AnalysisModel>[];

  // ===============================================================
  // DASHBOARD STATISTICS
  // ===============================================================

  Map<String, int> _statistics = <String, int>{
    'total': 0,
    'healthy': 0,
    'issues': 0,
  };

  // ===============================================================
  // GENERAL GETTERS
  // ===============================================================

  bool get isLoading => _isLoading;

  bool get isAnalyzing => _isAnalyzing;

  String? get error => _error;

  double get progress => _progress;

  AnalysisModel? get currentResult => _currentResult;

  List<AnalysisModel> get analysisHistory =>
      List.unmodifiable(_analysisHistory);

  // ===============================================================
  // COMPATIBILITY GETTERS
  // ===============================================================

  /// Kept for compatibility with older screens.
  ///
  /// No prediction model is active, so this always returns null.
  dynamic get latestPrediction => null;

  /// Kept for compatibility with older screens.
  ///
  /// No YOLO/API result is available.
  Map<String, dynamic>? get yoloResults => null;

  /// Kept for compatibility with older screens.
  ///
  /// No YOLO/API service is initialized.
  bool get yoloInitialized => false;

  /// Kept for compatibility with older screens.
  String? get nitrogenStatus => null;

  /// Kept for compatibility with older screens.
  double? get nitrogenConfidence => null;

  /// Kept for compatibility with older screens.
  String? get cropType => null;

  /// Kept for compatibility with older screens.
  double? get cropTypeConfidence => null;

  /// Kept for compatibility with older screens.
  String? get biomassLevel => null;

  /// Kept for compatibility with older screens.
  double? get biomassConfidence => null;

  /// Kept for compatibility with older screens.
  ///
  /// There is no local model configured.
  bool get cropModelInitialized => false;

  /// Kept for compatibility with older screens.
  String get currentCrop => 'Unknown';

  /// Indicates that no automatic analysis engine is configured.
  String get currentModelType => 'None';

  /// There is no model file because model inference was removed.
  String get currentModelPath => '';

  // ===============================================================
  // DASHBOARD GETTERS
  // ===============================================================

  int get totalAnalyses =>
      _statistics['total'] ?? 0;

  int get healthyAnalyses =>
      _statistics['healthy'] ?? 0;

  int get issueAnalyses =>
      _statistics['issues'] ?? 0;

  Map<String, int> get statistics =>
      Map.unmodifiable(_statistics);

  // ===============================================================
  // CONSTRUCTOR
  // ===============================================================

  AnalysisProvider() {
    _loadDashboardStatistics();
  }

  // ===============================================================
  // LOAD DASHBOARD STATISTICS
  // ===============================================================

  Future<void> _loadDashboardStatistics() async {
    await _refreshStatisticsFromDatabase(
      notify: true,
    );
  }

  // ===============================================================
  // REFRESH DASHBOARD STATISTICS
  // ===============================================================

  Future<void> refreshStatistics() async {
    await _refreshStatisticsFromDatabase(
      notify: true,
    );
  }

  // ===============================================================
  // READ STATISTICS FROM DATABASE
  // ===============================================================

  Future<void> _refreshStatisticsFromDatabase({
    bool notify = true,
  }) async {
    try {
      final List<Map<String, dynamic>> rows =
      await _analysisDatabase.getAllAnalyses();

      final int total = rows.length;

      int healthy = 0;
      int issues = 0;

      for (final Map<String, dynamic> row in rows) {
        if (_readDatabaseHealth(row)) {
          healthy++;
        } else {
          issues++;
        }
      }

      if (healthy + issues != total) {
        issues = total - healthy;

        if (issues < 0) {
          issues = 0;
        }
      }

      _statistics = <String, int>{
        'total': total,
        'healthy': healthy,
        'issues': issues,
      };

      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📊 DASHBOARD STATISTICS');
      debugPrint('🗄️ Database records: $total');
      debugPrint('✅ Healthy: $healthy');
      debugPrint('⚠️ Issues: $issues');
      debugPrint('📊 Statistics: $_statistics');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (notify) {
        notifyListeners();
      }
    } catch (error, stackTrace) {
      debugPrint(
        '❌ Failed to calculate dashboard statistics: $error',
      );

      if (kDebugMode) {
        debugPrint(
          'Stack trace:\n$stackTrace',
        );
      }

      _statistics = <String, int>{
        'total': 0,
        'healthy': 0,
        'issues': 0,
      };

      if (notify) {
        notifyListeners();
      }
    }
  }

  // ===============================================================
  // READ HEALTH FROM DATABASE
  // ===============================================================

  bool _readDatabaseHealth(
      Map<String, dynamic> row,
      ) {
    final dynamic value =
        row['is_healthy'] ?? row['isHealthy'];

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
          normalized == 'healthy' ||
          normalized == '1') {
        return true;
      }

      if (normalized == 'false' ||
          normalized == 'no' ||
          normalized == 'unhealthy' ||
          normalized == '0') {
        return false;
      }
    }

    final dynamic disease =
        row['disease_name'] ?? row['diseaseName'];

    final String diseaseName =
        disease?.toString().trim().toLowerCase() ?? '';

    if (diseaseName.isNotEmpty &&
        diseaseName != 'none' &&
        diseaseName != 'unknown' &&
        diseaseName != 'null') {
      return false;
    }

    final double healthScore = _toDouble(
      row['health_score'] ?? row['healthScore'],
    );

    if (healthScore > 0.0) {
      return healthScore >= 70.0;
    }

    return true;
  }

  // ===============================================================
  // AUTOMATIC ANALYSIS
  // ===============================================================

  /// Automatic analysis is disabled because the API, YOLO, and
  /// TFLite implementations were removed.
  ///
  /// This method validates the image path and then reports a clear
  /// error instead of creating fake prediction results.
  Future<void> analyzeImage(
      File imageFile, {
        String? cropName,
        String modelType = 'none',
      }) async {
    _setAnalyzing(true);
    _updateProgress(0.05);
    _error = null;

    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔍 AUTOMATIC ANALYSIS REQUEST');

      if (!await imageFile.exists()) {
        throw Exception(
          'Image file does not exist:\n${imageFile.path}',
        );
      }

      final int fileSize =
      await imageFile.length();

      if (fileSize <= 0) {
        throw Exception(
          'Image file is empty.',
        );
      }

      _updateProgress(0.25);

      throw StateError(
        'Automatic crop analysis is disabled. '
            'The API, YOLO, and TFLite analysis engines '
            'have been removed from the app.',
      );
    } catch (error, stackTrace) {
      _handleError(error);

      debugPrint(
        '❌ Automatic analysis error: $error',
      );

      if (kDebugMode) {
        debugPrint(
          'Stack trace:\n$stackTrace',
        );
      }
    } finally {
      _setAnalyzing(false);
      _updateProgress(0.0);
    }
  }

  // ===============================================================
  // OLD YOLO METHOD COMPATIBILITY
  // ===============================================================

  /// Compatibility method for older screens.
  ///
  /// It no longer calls a YOLO or API service. It delegates to
  /// [analyzeImage], which reports that automatic analysis is
  /// disabled.
  @Deprecated(
    'YOLO/API analysis was removed. Use analyzeImage instead.',
  )
  Future<void> analyzeImageWithYolo(
      File imageFile,
      ) async {
    await analyzeImage(imageFile);
  }

  /// Compatibility method for older screens.
  ///
  /// No external service is initialized.
  @Deprecated(
    'YOLO/API initialization was removed.',
  )
  Future<void> initializeYoloModels() async {
    _error =
    'No automatic analysis engine is configured. '
        'API, YOLO, and TFLite have been removed.';

    notifyListeners();
  }

  // ===============================================================
  // CLEAR OLD MODEL RESULTS
  // ===============================================================

  /// Compatibility method for older screens.
  ///
  /// There are no model results to clear.
  void clearYoloResults() {
    notifyListeners();
  }

  // ===============================================================
  // SAVE ANALYSIS
  // ===============================================================

  Future<void> saveAnalysis(
      AnalysisModel analysis,
      ) async {
    _setLoading(true);

    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('💾 SAVING ANALYSIS');
      debugPrint('🌱 Crop: ${analysis.cropType}');
      debugPrint('❤️ Health: ${analysis.healthScore}');
      debugPrint('🌾 Biomass: ${analysis.biomass}');
      debugPrint('🧪 Nitrogen: ${analysis.nitrogenLevel}');
      debugPrint('🎯 Confidence: ${analysis.confidence}');

      final bool isHealthy =
      _isAnalysisHealthy(analysis);

      final Map<String, dynamic> databaseRecord =
      _analysisModelToDatabaseMap(
        analysis,
        isHealthy,
      );

      debugPrint(
        '🗄️ Database record: $databaseRecord',
      );

      final String databaseId =
      await _analysisDatabase.insertAnalysis(
        databaseRecord,
      );

      debugPrint(
        '✅ Database ID: $databaseId',
      );

      final int existingIndex =
      _analysisHistory.indexWhere(
            (AnalysisModel item) =>
        item.id == analysis.id,
      );

      if (existingIndex >= 0) {
        _analysisHistory[existingIndex] = analysis;
      } else {
        _analysisHistory.insert(0, analysis);
      }

      _currentResult = analysis;

      await _refreshStatisticsFromDatabase(
        notify: false,
      );

      _error = null;

      notifyListeners();

      debugPrint('📊 COUNTS AFTER SAVE:');
      debugPrint('Analyses = $totalAnalyses');
      debugPrint('Healthy = $healthyAnalyses');
      debugPrint('Issues = $issueAnalyses');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    } catch (error, stackTrace) {
      _handleError(error);

      debugPrint(
        '❌ Failed to save analysis: $error',
      );

      if (kDebugMode) {
        debugPrint(
          'Stack trace:\n$stackTrace',
        );
      }

      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ===============================================================
  // ANALYSIS MODEL TO DATABASE MAP
  // ===============================================================

  Map<String, dynamic> _analysisModelToDatabaseMap(
      AnalysisModel analysis,
      bool isHealthy,
      ) {
    String diseaseName = 'None';

    if (analysis.hasDisease) {
      diseaseName =
          analysis.diseaseType ??
              'Disease detected';
    }

    if (analysis.hasPest) {
      if (diseaseName == 'None') {
        diseaseName =
            analysis.pestType ??
                'Pest detected';
      } else {
        diseaseName =
        '$diseaseName / '
            '${analysis.pestType ?? 'Pest detected'}';
      }
    }

    return <String, dynamic>{
      'crop_name': analysis.cropType,
      'disease_name': diseaseName,
      'is_healthy': isHealthy ? 1 : 0,
      'confidence': _normalizeConfidence(
        analysis.confidence,
      ),
      'nitrogen': _toDouble(
        analysis.nitrogenLevel,
      ),
      'biomass': _toDouble(
        analysis.biomass,
      ),
      'health_score': _toDouble(
        analysis.healthScore,
      ),
      'severity': _getSeverityFromHealthScore(
        analysis.healthScore,
        isHealthy,
      ),
      'image_path': analysis.imageUrl,
      'timestamp': analysis.date.toIso8601String(),
    };
  }

  // ===============================================================
  // HEALTH CHECK
  // ===============================================================

  bool _isAnalysisHealthy(
      AnalysisModel analysis,
      ) {
    if (analysis.hasDisease ||
        analysis.hasPest) {
      return false;
    }

    return _toDouble(
      analysis.healthScore,
    ) >=
        70.0;
  }

  // ===============================================================
  // SEVERITY
  // ===============================================================

  String _getSeverityFromHealthScore(
      double healthScore,
      bool isHealthy,
      ) {
    final double score =
    _toDouble(healthScore);

    if (isHealthy) {
      return 'Healthy';
    }

    if (score >= 50.0) {
      return 'Moderate';
    }

    if (score >= 25.0) {
      return 'Severe';
    }

    return 'Critical';
  }

  // ===============================================================
  // FETCH HISTORY
  // ===============================================================

  Future<void> fetchAnalysisHistory(
      String userId,
      ) async {
    _setLoading(true);

    try {
      _error = null;

      final List<Map<String, dynamic>> rows =
      await _analysisDatabase.getAllAnalyses();

      _analysisHistory.clear();

      for (final Map<String, dynamic> row
      in rows) {
        final AnalysisModel? model =
        _databaseRowToAnalysisModel(row);

        if (model != null) {
          _analysisHistory.add(model);
        }
      }

      await _refreshStatisticsFromDatabase(
        notify: false,
      );

      notifyListeners();

      debugPrint(
        '📚 Loaded '
            '${_analysisHistory.length} analyses.',
      );

      debugPrint(
        '📊 Dashboard: $_statistics',
      );
    } catch (error, stackTrace) {
      _handleError(error);

      if (kDebugMode) {
        debugPrint(
          'Fetch history error:\n$stackTrace',
        );
      }
    } finally {
      _setLoading(false);
    }
  }

  // ===============================================================
  // DATABASE ROW TO ANALYSIS MODEL
  // ===============================================================

  AnalysisModel? _databaseRowToAnalysisModel(
      Map<String, dynamic> row,
      ) {
    try {
      final DateTime date =
          DateTime.tryParse(
            row['timestamp']?.toString() ?? '',
          ) ??
              DateTime.now();

      final double healthScore =
      _toDouble(
        row['health_score'] ??
            row['healthScore'],
      );

      final double biomass =
      _toDouble(row['biomass']);

      final double nitrogen =
      _toDouble(row['nitrogen']);

      final double confidence =
      _normalizeConfidence(
        row['confidence'],
      );

      final bool isHealthy =
      _readDatabaseHealth(row);

      final String diseaseName =
          row['disease_name']
              ?.toString()
              .trim() ??
              'None';

      final String normalizedDisease =
      diseaseName.toLowerCase();

      final bool hasDisease =
          !isHealthy &&
              normalizedDisease != 'none' &&
              normalizedDisease != 'unknown' &&
              normalizedDisease != 'null' &&
              normalizedDisease.isNotEmpty;

      final String databaseId =
          row['id']?.toString() ??
              row['documentId']?.toString() ??
              date.microsecondsSinceEpoch
                  .toString();

      return AnalysisModel(
        id: 'db_$databaseId',
        userId: 'local_user',
        cropType:
        row['crop_name']?.toString() ??
            row['cropName']?.toString() ??
            'Unknown',
        healthScore: healthScore,
        biomass: biomass,
        nitrogenLevel: nitrogen,
        confidence: confidence,
        diseaseProbability: 0.0,
        pestProbability: 0.0,
        hasDisease: hasDisease,
        hasPest: false,
        diseaseType:
        hasDisease ? diseaseName : null,
        pestType: null,
        notes: 'Loaded from local database',
        location: null,
        imageUrl:
        row['image_path']?.toString() ??
            row['imageUrl']?.toString(),
        date: date,
        recommendations: const <String>[],
        createdAt: date,
        updatedAt: date,
      );
    } catch (error) {
      debugPrint(
        '⚠️ Could not convert database row: '
            '$error',
      );

      return null;
    }
  }

  // ===============================================================
  // DELETE ANALYSIS
  // ===============================================================

  Future<void> deleteAnalysis(
      String analysisId,
      ) async {
    _setLoading(true);

    try {
      String? databaseId;

      if (analysisId.startsWith('db_')) {
        databaseId =
            analysisId.substring(3);
      }

      if (databaseId == null ||
          databaseId.trim().isEmpty) {
        final AnalysisModel? target =
        getAnalysisById(analysisId);

        if (target != null) {
          final List<Map<String, dynamic>>
          rows =
          await _analysisDatabase
              .getAllAnalyses();

          for (final Map<String, dynamic> row
          in rows) {
            final String timestamp =
                row['timestamp']?.toString() ??
                    '';

            if (timestamp ==
                target.date.toIso8601String()) {
              final dynamic rawId =
                  row['id'] ??
                      row['documentId'];

              if (rawId != null) {
                databaseId =
                    rawId.toString();
              }

              break;
            }
          }
        }
      }

      if (databaseId != null &&
          databaseId.trim().isNotEmpty) {
        final bool deleted =
        await _analysisDatabase
            .deleteAnalysis(databaseId);

        debugPrint(
          deleted
              ? '✅ Database analysis deleted: '
              '$databaseId'
              : '⚠️ Database analysis was not '
              'deleted: $databaseId',
        );
      } else {
        debugPrint(
          '⚠️ Could not determine database ID '
              'for: $analysisId',
        );
      }

      _analysisHistory.removeWhere(
            (AnalysisModel analysis) =>
        analysis.id == analysisId,
      );

      if (_currentResult?.id == analysisId) {
        _currentResult = null;
      }

      await _refreshStatisticsFromDatabase(
        notify: false,
      );

      notifyListeners();

      debugPrint('🗑️ Analysis deleted.');
      debugPrint(
        '📊 Counts after delete: $_statistics',
      );
    } catch (error, stackTrace) {
      _handleError(error);

      debugPrint(
        '❌ Delete analysis error: $error',
      );

      if (kDebugMode) {
        debugPrint(
          'Stack trace:\n$stackTrace',
        );
      }
    } finally {
      _setLoading(false);
    }
  }

  // ===============================================================
  // CLEAR HISTORY
  // ===============================================================

  Future<void> clearHistory() async {
    _setLoading(true);

    try {
      final bool cleared =
      await _analysisDatabase.clearHistory();

      debugPrint(
        '🗑️ Database clear result: $cleared',
      );

      _analysisHistory.clear();

      _currentResult = null;

      _statistics = <String, int>{
        'total': 0,
        'healthy': 0,
        'issues': 0,
      };

      await _refreshStatisticsFromDatabase(
        notify: false,
      );

      notifyListeners();

      debugPrint(
        '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
      );
      debugPrint(
        '🗑️ ALL ANALYSIS HISTORY CLEARED',
      );
      debugPrint(
        '📊 Analyses: $totalAnalyses',
      );
      debugPrint(
        '✅ Healthy: $healthyAnalyses',
      );
      debugPrint(
        '⚠️ Issues: $issueAnalyses',
      );
      debugPrint(
        '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
      );
    } catch (error, stackTrace) {
      _handleError(error);

      debugPrint(
        '❌ Clear history error: $error',
      );

      if (kDebugMode) {
        debugPrint(
          'Stack trace:\n$stackTrace',
        );
      }
    } finally {
      _setLoading(false);
    }
  }

  // ===============================================================
  // CLEAR PREDICTION
  // ===============================================================

  void clearPrediction() {
    _currentResult = null;
    notifyListeners();
  }

  // ===============================================================
  // CLEAR ERROR
  // ===============================================================

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ===============================================================
  // RETRY ANALYSIS
  // ===============================================================

  Future<void> retryAnalysis(
      File imageFile, {
        String? cropName,
        String modelType = 'none',
      }) async {
    await analyzeImage(
      imageFile,
      cropName: cropName,
      modelType: modelType,
    );
  }

  // ===============================================================
  // FIND ANALYSIS
  // ===============================================================

  AnalysisModel? getAnalysisById(
      String id,
      ) {
    for (final AnalysisModel analysis
    in _analysisHistory) {
      if (analysis.id == id) {
        return analysis;
      }
    }

    return null;
  }

  // ===============================================================
  // SEARCH HISTORY
  // ===============================================================

  Future<List<AnalysisModel>> searchHistory(
      String query,
      ) async {
    try {
      final List<Map<String, dynamic>> rows =
      await _analysisDatabase.searchAnalyses(
        query,
      );

      return rows
          .map(_databaseRowToAnalysisModel)
          .whereType<AnalysisModel>()
          .toList();
    } catch (error) {
      debugPrint(
        '❌ Search failed: $error',
      );

      return <AnalysisModel>[];
    }
  }

  // ===============================================================
  // EXPORT ANALYSIS
  // ===============================================================

  Future<File?> exportAnalysis(
      String analysisId,
      ) async {
    try {
      final AnalysisModel? analysis =
      getAnalysisById(analysisId);

      if (analysis == null) {
        throw Exception(
          'Analysis not found.',
        );
      }

      debugPrint(
        '📄 Exporting analysis: $analysisId',
      );

      // Add PDF/export implementation here
      // when required.
      return null;
    } catch (error) {
      _handleError(error);
      return null;
    }
  }

  // ===============================================================
  // SHARE ANALYSIS
  // ===============================================================

  Future<void> shareAnalysis(
      String analysisId,
      ) async {
    try {
      final AnalysisModel? analysis =
      getAnalysisById(analysisId);

      if (analysis == null) {
        throw Exception(
          'Analysis not found.',
        );
      }

      final File? file =
      await exportAnalysis(analysisId);

      if (file != null) {
        await Share.shareXFiles(
          <XFile>[
            XFile(file.path),
          ],
          text: 'Crop Analysis Report',
        );

        return;
      }

      await Share.share(
        _buildShareText(analysis),
      );
    } catch (error) {
      _handleError(error);
    }
  }

  // ===============================================================
  // BUILD SHARE TEXT
  // ===============================================================

  String _buildShareText(
      AnalysisModel analysis,
      ) {
    final List<String> recommendationList =
        analysis.recommendations ??
            const <String>[];

    final String recommendations =
    recommendationList.isEmpty
        ? 'No recommendations available.'
        : recommendationList.join('\n');

    return '''
🌱 CROP ANALYSIS REPORT

Crop: ${analysis.cropType}

Health Score:
${_toDouble(analysis.healthScore).toStringAsFixed(1)}%

Biomass:
${_toDouble(analysis.biomass).toStringAsFixed(2)}

Nitrogen:
${_toDouble(analysis.nitrogenLevel).toStringAsFixed(2)}

Confidence:
${(_normalizeConfidence(analysis.confidence) * 100).toStringAsFixed(1)}%

Disease Probability:
${_toDouble(analysis.diseaseProbability).toStringAsFixed(1)}%

Pest Probability:
${_toDouble(analysis.pestProbability).toStringAsFixed(1)}%

Recommendations:
$recommendations

Analysis Date:
${analysis.date.toLocal()}
''';
  }

  // ===============================================================
  // LOADING STATE
  // ===============================================================

  void _setLoading(
      bool value,
      ) {
    if (_isLoading == value) {
      return;
    }

    _isLoading = value;
    notifyListeners();
  }

  // ===============================================================
  // ANALYZING STATE
  // ===============================================================

  void _setAnalyzing(
      bool value,
      ) {
    if (_isAnalyzing == value) {
      return;
    }

    _isAnalyzing = value;
    notifyListeners();
  }

  // ===============================================================
  // PROGRESS STATE
  // ===============================================================

  void _updateProgress(
      double value,
      ) {
    final double safeValue =
    value.clamp(0.0, 1.0).toDouble();

    if ((_progress - safeValue).abs() <
        0.001) {
      return;
    }

    _progress = safeValue;
    notifyListeners();
  }

  // ===============================================================
  // ERROR STATE
  // ===============================================================

  void _handleError(
      dynamic error,
      ) {
    _error = error.toString();

    _isAnalyzing = false;
    _isLoading = false;

    notifyListeners();
  }

  // ===============================================================
  // CONVERT VALUE TO DOUBLE
  // ===============================================================

  double _toDouble(
      dynamic value,
      ) {
    if (value == null) {
      return 0.0;
    }

    if (value is double) {
      if (value.isNaN ||
          value.isInfinite) {
        return 0.0;
      }

      return value;
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

      return parsed ?? 0.0;
    }

    return 0.0;
  }

  // ===============================================================
  // NORMALIZE CONFIDENCE
  // ===============================================================

  double _normalizeConfidence(
      dynamic value,
      ) {
    final double confidence =
    _toDouble(value);

    if (confidence.isNaN ||
        confidence.isInfinite) {
      return 0.0;
    }

    if (confidence >= 0.0 &&
        confidence <= 1.0) {
      return confidence;
    }

    if (confidence > 1.0 &&
        confidence <= 100.0) {
      return confidence / 100.0;
    }

    if (confidence < 0.0) {
      return 0.0;
    }

    return 1.0;
  }

  // ===============================================================
  // DISPOSE
  // ===============================================================

  @override
  void dispose() {
    _analysisHistory.clear();

    _currentResult = null;

    super.dispose();
  }
}