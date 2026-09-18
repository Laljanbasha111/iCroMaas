import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/database/test_results_database.dart';
import '../../../models/crop_data_model.dart';
import '../../../models/prediction_result_model.dart';
import '../../../models/test_result_model.dart';

/// Controller for crop test history and reference data.
///
/// Local TFLite model support has been removed.
///
/// Crop analysis should now be performed through the API/YOLO flow
/// used by AnalysisProvider and AnalysisLoadingScreen.
class CropTestController extends GetxController {
  // ===============================================================
  // SERVICES
  // ===============================================================

  final TestResultsDatabase _database =
      TestResultsDatabase.instance;

  // ===============================================================
  // OBSERVABLE STATE
  // ===============================================================

  final RxBool isLoading = false.obs;

  /// Always false because local TFLite models were removed.
  final RxBool isModelLoaded = false.obs;

  final Rx<CropData?> currentCropData =
  Rx<CropData?>(null);

  /// Kept for compatibility with existing UI code.
  ///
  /// This value is not populated by local inference because TFLite
  /// support has been removed.
  final Rx<PredictionResult?> currentPrediction =
  Rx<PredictionResult?>(null);

  final Rx<TestResult?> currentTestResult =
  Rx<TestResult?>(null);

  final Rx<CropDataList?> allCropData =
  Rx<CropDataList?>(null);

  final RxList<TestResult> testHistory =
      <TestResult>[].obs;

  final RxString errorMessage = ''.obs;

  // ===============================================================
  // STATISTICS
  // ===============================================================

  final RxInt totalTests = 0.obs;

  final RxDouble averageAccuracy = 0.0.obs;

  final RxInt goodPredictions = 0.obs;

  final RxInt excellentPredictions = 0.obs;

  // ===============================================================
  // LIFECYCLE
  // ===============================================================

  @override
  void onInit() {
    super.onInit();

    debugPrint(
      '🎮 CropTestController initialized',
    );

    _initialize();
  }

  // ===============================================================
  // INITIALIZE CONTROLLER
  // ===============================================================

  Future<void> _initialize() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Initialize database.
      await _database.init();

      debugPrint(
        '✅ Test results database initialized',
      );

      // Load crop reference data.
      await loadCropData();

      // Local TFLite model loading has intentionally been removed.
      isModelLoaded.value = false;

      // Load saved test history.
      await loadTestHistory();

      // Update statistics.
      updateStatistics();

      isLoading.value = false;

      debugPrint(
        '✅ CropTestController initialization complete',
      );
    } catch (error, stackTrace) {
      isLoading.value = false;

      errorMessage.value =
      'Initialization failed: $error';

      debugPrint(
        '❌ CropTestController initialization error: $error',
      );

      debugPrint(
        'Stack trace: $stackTrace',
      );

      _showErrorSnackbar(
        title: 'Initialization Error',
        message: 'Failed to initialize: $error',
      );
    }
  }

  // ===============================================================
  // LOAD CROP REFERENCE DATA
  // ===============================================================

  Future<void> loadCropData() async {
    try {
      debugPrint(
        '📦 Loading crop reference data...',
      );

      final CropDataList cropDataList =
      await CropDataList.loadFromAssets();

      allCropData.value = cropDataList;

      debugPrint(
        '✅ Loaded ${cropDataList.crops.length} crops',
      );
    } catch (error, stackTrace) {
      debugPrint(
        '❌ Error loading crop data: $error',
      );

      debugPrint(
        'Stack trace: $stackTrace',
      );

      throw Exception(
        'Failed to load crop data: $error',
      );
    }
  }

  // ===============================================================
  // LEGACY MODEL METHOD
  // ===============================================================
  //
  // Kept so existing screens that call loadModel() continue to
  // compile. It does not load TFLite.

  Future<void> loadModel() async {
    isModelLoaded.value = false;

    debugPrint(
      'ℹ️ Local TFLite model loading was removed.',
    );

    _showInfoSnackbar(
      title: 'Local Models Removed',
      message:
      'Local TFLite models are no longer used. '
          'Use API analysis instead.',
    );
  }

  // ===============================================================
  // SELECT CROP
  // ===============================================================

  void selectCrop(
      CropData crop,
      ) {
    currentCropData.value = crop;

    currentPrediction.value = null;

    currentTestResult.value = null;

    errorMessage.value = '';

    debugPrint(
      '🌾 Selected crop: ${crop.name}',
    );
  }

  // ===============================================================
  // LEGACY REFERENCE PREDICTION
  // ===============================================================
  //
  // The previous implementation used CropModelService and TFLite.
  // It cannot run after removing those models.

  Future<void> runPredictionOnReferenceCrop() async {
    if (currentCropData.value == null) {
      _showErrorSnackbar(
        title: 'Crop Not Selected',
        message: 'Please select a crop first.',
      );

      return;
    }

    currentPrediction.value = null;

    currentTestResult.value = null;

    errorMessage.value =
    'Local TFLite prediction is no longer available.';

    debugPrint(
      'ℹ️ Reference-crop TFLite prediction skipped.',
    );

    _showInfoSnackbar(
      title: 'Local Prediction Removed',
      message:
      'Reference-crop testing used the removed TFLite model. '
          'Use the API crop analysis screen instead.',
    );
  }

  // ===============================================================
  // LEGACY CUSTOM IMAGE PREDICTION
  // ===============================================================
  //
  // The previous implementation used CropModelService and TFLite.
  // The image bytes are intentionally not processed locally.

  Future<void> runPredictionOnCustomImage(
      Uint8List imageBytes, {
        String? cropName,
        double? referenceBiomass,
        double? referenceNitrogen,
      }) async {
    if (imageBytes.isEmpty) {
      _showErrorSnackbar(
        title: 'Invalid Image',
        message: 'The selected image is empty.',
      );

      return;
    }

    currentPrediction.value = null;

    currentTestResult.value = null;

    errorMessage.value =
    'Local TFLite prediction is no longer available.';

    debugPrint(
      'ℹ️ Custom-image TFLite prediction skipped.',
    );

    _showInfoSnackbar(
      title: 'Local Prediction Removed',
      message:
      'Custom-image testing used the removed TFLite model. '
          'Use the API crop analysis screen instead.',
    );
  }

  // ===============================================================
  // LEGACY RESULT SNACKBAR
  // ===============================================================
  //
  // Kept for compatibility with any existing code that may call it.

  void showPredictionResult(
      TestResult result,
      ) {
    _showPredictionResult(result);
  }

  void _showPredictionResult(
      TestResult result,
      ) {
    final Color accuracyColor =
    result.isExcellentPrediction
        ? Colors.green
        : result.isGoodPrediction
        ? Colors.blue
        : Colors.orange;

    Get.snackbar(
      '${result.accuracyCategory} Prediction',
      'Overall Accuracy: '
          '${result.overallAccuracy.toStringAsFixed(2)}%\n'
          'Biomass: '
          '${result.predictedBiomass.toStringAsFixed(2)} g/m²\n'
          'Nitrogen: '
          '${result.predictedNitrogen.toStringAsFixed(2)}%',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: accuracyColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  // ===============================================================
  // LOAD TEST HISTORY
  // ===============================================================

  Future<void> loadTestHistory({
    int limit = 50,
  }) async {
    try {
      final List<TestResult> history =
      _database.getRecentTestResults(
        limit: limit,
      );

      testHistory.assignAll(history);

      debugPrint(
        '📜 Loaded ${history.length} test results',
      );
    } catch (error, stackTrace) {
      debugPrint(
        '❌ Error loading test history: $error',
      );

      debugPrint(
        'Stack trace: $stackTrace',
      );
    }
  }

  // ===============================================================
  // UPDATE STATISTICS
  // ===============================================================

  void updateStatistics() {
    try {
      final Map<String, dynamic> stats =
      _database.getStatistics();

      totalTests.value = _readInt(
        stats['total_tests'],
      );

      averageAccuracy.value = _readDouble(
        stats['average_accuracy'],
      );

      goodPredictions.value = _readInt(
        stats['good_predictions'],
      );

      excellentPredictions.value = _readInt(
        stats['excellent_predictions'],
      );

      debugPrint(
        '📊 Statistics updated:',
      );

      debugPrint(
        '   Total Tests: ${totalTests.value}',
      );

      debugPrint(
        '   Average Accuracy: '
            '${averageAccuracy.value.toStringAsFixed(2)}%',
      );

      debugPrint(
        '   Good Predictions: '
            '${goodPredictions.value}',
      );

      debugPrint(
        '   Excellent Predictions: '
            '${excellentPredictions.value}',
      );
    } catch (error, stackTrace) {
      debugPrint(
        '❌ Error updating statistics: $error',
      );

      debugPrint(
        'Stack trace: $stackTrace',
      );
    }
  }

  // ===============================================================
  // GET TEST RESULTS FOR A CROP
  // ===============================================================

  List<TestResult> getTestResultsForCrop(
      String cropName,
      ) {
    try {
      return _database.getTestResultsByCrop(
        cropName,
      );
    } catch (error, stackTrace) {
      debugPrint(
        '❌ Error loading crop test results: $error',
      );

      debugPrint(
        'Stack trace: $stackTrace',
      );

      return <TestResult>[];
    }
  }

  // ===============================================================
  // GET CROP STATISTICS
  // ===============================================================

  Map<String, dynamic> getStatisticsForCrop(
      String cropName,
      ) {
    try {
      return _database.getStatisticsByCrop(
        cropName,
      );
    } catch (error, stackTrace) {
      debugPrint(
        '❌ Error loading crop statistics: $error',
      );

      debugPrint(
        'Stack trace: $stackTrace',
      );

      return <String, dynamic>{};
    }
  }

  // ===============================================================
  // DELETE ONE TEST RESULT
  // ===============================================================

  Future<void> deleteTestResult(
      String id,
      ) async {
    try {
      await _database.deleteTestResult(id);

      await loadTestHistory();

      updateStatistics();

      _showSuccessSnackbar(
        title: 'Success',
        message: 'Test result deleted.',
      );
    } catch (error, stackTrace) {
      debugPrint(
        '❌ Error deleting test result: $error',
      );

      debugPrint(
        'Stack trace: $stackTrace',
      );

      _showErrorSnackbar(
        title: 'Error',
        message: 'Failed to delete test result.',
      );
    }
  }

  // ===============================================================
  // DELETE ALL TEST RESULTS
  // ===============================================================

  Future<void> clearAllTestResults() async {
    try {
      await _database.deleteAllTestResults();

      testHistory.clear();

      currentTestResult.value = null;

      currentPrediction.value = null;

      updateStatistics();

      _showSuccessSnackbar(
        title: 'Success',
        message: 'All test results cleared.',
      );
    } catch (error, stackTrace) {
      debugPrint(
        '❌ Error clearing test results: $error',
      );

      debugPrint(
        'Stack trace: $stackTrace',
      );

      _showErrorSnackbar(
        title: 'Error',
        message: 'Failed to clear test results.',
      );
    }
  }

  // ===============================================================
  // EXPORT TEST RESULTS
  // ===============================================================

  List<Map<String, dynamic>> exportTestResults() {
    try {
      return _database.exportToJson();
    } catch (error, stackTrace) {
      debugPrint(
        '❌ Error exporting test results: $error',
      );

      debugPrint(
        'Stack trace: $stackTrace',
      );

      return <Map<String, dynamic>>[];
    }
  }

  // ===============================================================
  // IMPORT TEST RESULTS
  // ===============================================================

  Future<void> importTestResults(
      List<Map<String, dynamic>> jsonList,
      ) async {
    try {
      await _database.importFromJson(jsonList);

      await loadTestHistory();

      updateStatistics();

      _showSuccessSnackbar(
        title: 'Success',
        message: 'Test results imported successfully.',
      );
    } catch (error, stackTrace) {
      debugPrint(
        '❌ Error importing test results: $error',
      );

      debugPrint(
        'Stack trace: $stackTrace',
      );

      _showErrorSnackbar(
        title: 'Error',
        message: 'Failed to import test results.',
      );
    }
  }

  // ===============================================================
  // MODEL INFORMATION COMPATIBILITY METHODS
  // ===============================================================
  //
  // These methods remain so old UI code can compile.
  // They report that no local model is loaded.

  Map<String, dynamic> getModelInfo() {
    return <String, dynamic>{
      'loaded': false,
      'mode': 'api',
      'local_tflite_removed': true,
      'model_type': 'API',
      'model_path': '',
      'message':
      'Local TFLite models have been removed. '
          'Use API/YOLO analysis.',
    };
  }

  bool get modelLoaded => false;

  // ===============================================================
  // DATABASE INFORMATION
  // ===============================================================

  Map<String, dynamic> getDatabaseStatistics() {
    try {
      return _database.getStatistics();
    } catch (error, stackTrace) {
      debugPrint(
        '❌ Error loading database statistics: $error',
      );

      debugPrint(
        'Stack trace: $stackTrace',
      );

      return <String, dynamic>{};
    }
  }

  void printDatabaseStatistics() {
    try {
      _database.printStatistics();
    } catch (error, stackTrace) {
      debugPrint(
        '❌ Error printing database statistics: $error',
      );

      debugPrint(
        'Stack trace: $stackTrace',
      );
    }
  }

  // ===============================================================
  // RESET CURRENT TEST
  // ===============================================================

  void resetCurrentTest() {
    currentPrediction.value = null;

    currentTestResult.value = null;

    currentCropData.value = null;

    errorMessage.value = '';

    debugPrint(
      '🔄 Current test reset',
    );
  }

  // ===============================================================
  // RELOAD DATA
  // ===============================================================

  Future<void> reloadAllData() async {
    try {
      isLoading.value = true;

      errorMessage.value = '';

      await loadCropData();

      await loadTestHistory();

      updateStatistics();

      isLoading.value = false;

      _showSuccessSnackbar(
        title: 'Success',
        message: 'Data reloaded successfully.',
      );
    } catch (error, stackTrace) {
      isLoading.value = false;

      errorMessage.value =
      'Failed to reload data: $error';

      debugPrint(
        '❌ Error reloading data: $error',
      );

      debugPrint(
        'Stack trace: $stackTrace',
      );

      _showErrorSnackbar(
        title: 'Error',
        message: 'Failed to reload data.',
      );
    }
  }

  // ===============================================================
  // VALUE CONVERSION HELPERS
  // ===============================================================

  int _readInt(
      dynamic value,
      ) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value.trim()) ?? 0;
    }

    return 0;
  }

  double _readDouble(
      dynamic value,
      ) {
    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value.trim()) ?? 0.0;
    }

    return 0.0;
  }

  // ===============================================================
  // SNACKBAR HELPERS
  // ===============================================================

  void _showSuccessSnackbar({
    required String title,
    required String message,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _showErrorSnackbar({
    required String title,
    required String message,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void _showInfoSnackbar({
    required String title,
    required String message,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  // ===============================================================
  // CLOSE
  // ===============================================================

  @override
  void onClose() {
    debugPrint(
      '🔒 CropTestController closed',
    );

    super.onClose();
  }
}