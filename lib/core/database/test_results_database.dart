import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/test_result_model.dart';

/// Database service for managing test results using Hive
class TestResultsDatabase {
  static const String _boxName = 'test_results';
  static TestResultsDatabase? _instance;
  Box<TestResult>? _box;

  // Singleton pattern
  TestResultsDatabase._();

  static TestResultsDatabase get instance {
    _instance ??= TestResultsDatabase._();
    return _instance!;
  }

  /// Initialize the database
  Future<void> init() async {
    try {
      print('🗄️ Initializing Test Results Database...');

      // Initialize Hive (safe to call before opening boxes)
      await Hive.initFlutter();

      // Register adapter if not already registered
      // Make sure 1 matches the typeId used in TestResultAdapter
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(TestResultAdapter());
        print('✅ TestResult adapter registered');
      }

      // Open the box only if it's not already open
      if (Hive.isBoxOpen(_boxName)) {
        _box = Hive.box<TestResult>(_boxName);
        print('✅ Existing box loaded');
      } else {
        _box = await Hive.openBox<TestResult>(_boxName);
        print('✅ New box opened');
      }

      print('✅ Database initialized successfully');
      print('📊 Current records: ${_box!.length}');
    } catch (e) {
      print('❌ Error initializing database: $e');
      throw Exception('Failed to initialize database: $e');
    }
  }

  /// Check if database is initialized
  bool get isInitialized => _box != null && _box!.isOpen;

  /// Ensure database is initialized
  Future<void> _ensureInitialized() async {
    if (!isInitialized) {
      await init();
    }
  }

  /// Expose Hive listenable for real-time UI updates
  /// Use this with ValueListenableBuilder in the home screen
  ValueListenable<Box<TestResult>> listenable() {
    if (!isInitialized) {
      throw StateError('Database is not initialized. Call init() first.');
    }
    return _box!.listenable();
  }

  /// Normalize string values safely
  String _normalize(Object? value) {
    return value?.toString().trim().toLowerCase() ?? '';
  }

  /// Try to determine whether a result is healthy
  /// Adjust this logic if your model uses a different field name
  bool _isHealthyResult(TestResult result) {
    final json = result.toJson();

    final candidates = <String>[
      _normalize(json['status']),
      _normalize(json['prediction']),
      _normalize(json['label']),
      _normalize(json['result']),
      _normalize(json['health']),
      _normalize(json['outcome']),
    ].where((value) => value.isNotEmpty).toList();

    for (final value in candidates) {
      if (value.contains('healthy') ||
          value == 'good' ||
          value == 'normal' ||
          value == 'safe') {
        return true;
      }
    }

    // Fallback to your existing model property
    return result.isGoodPrediction;
  }

  /// Try to determine whether a result is an issue
  /// Adjust this logic if your model uses a different field name
  bool _isIssueResult(TestResult result) {
    final json = result.toJson();

    final candidates = <String>[
      _normalize(json['status']),
      _normalize(json['prediction']),
      _normalize(json['label']),
      _normalize(json['result']),
      _normalize(json['health']),
      _normalize(json['outcome']),
    ].where((value) => value.isNotEmpty).toList();

    for (final value in candidates) {
      if (value.contains('issue') ||
          value.contains('disease') ||
          value.contains('infect') ||
          value == 'bad' ||
          value == 'unhealthy') {
        return true;
      }
    }

    // Fallback: if it's not good, treat it as issue
    return !result.isGoodPrediction;
  }

  /// Add a new test result
  Future<void> addTestResult(TestResult result) async {
    await _ensureInitialized();

    try {
      print('💾 Saving test result: ${result.id}');
      await _box!.put(result.id, result);
      print('✅ Test result saved successfully');
    } catch (e) {
      print('❌ Error adding test result: $e');
      throw Exception('Failed to add test result: $e');
    }
  }

  /// Get a test result by ID
  TestResult? getTestResult(String id) {
    if (!isInitialized) return null;

    try {
      return _box!.get(id);
    } catch (e) {
      print('❌ Error getting test result: $e');
      return null;
    }
  }

  /// Get all test results
  List<TestResult> getAllTestResults() {
    if (!isInitialized) return [];

    try {
      return _box!.values.toList();
    } catch (e) {
      print('❌ Error getting all test results: $e');
      return [];
    }
  }

  /// Get test results by crop name
  List<TestResult> getTestResultsByCrop(String cropName) {
    if (!isInitialized) return [];

    try {
      return _box!.values
          .where((result) =>
      result.cropName.toLowerCase() == cropName.toLowerCase())
          .toList();
    } catch (e) {
      print('❌ Error getting test results by crop: $e');
      return [];
    }
  }

  /// Get recent test results (limit)
  List<TestResult> getRecentTestResults({int limit = 10}) {
    if (!isInitialized) return [];

    try {
      final results = _box!.values.toList();
      results.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return results.take(limit).toList();
    } catch (e) {
      print('❌ Error getting recent test results: $e');
      return [];
    }
  }

  /// Get test results within date range
  List<TestResult> getTestResultsByDateRange(DateTime start, DateTime end) {
    if (!isInitialized) return [];

    try {
      return _box!.values
          .where((result) =>
      result.timestamp.isAfter(start) && result.timestamp.isBefore(end))
          .toList();
    } catch (e) {
      print('❌ Error getting test results by date range: $e');
      return [];
    }
  }

  /// Get good predictions (accuracy >= 80%)
  List<TestResult> getGoodPredictions() {
    if (!isInitialized) return [];

    try {
      return _box!.values.where((result) => result.isGoodPrediction).toList();
    } catch (e) {
      print('❌ Error getting good predictions: $e');
      return [];
    }
  }

  /// Get excellent predictions (accuracy >= 90%)
  List<TestResult> getExcellentPredictions() {
    if (!isInitialized) return [];

    try {
      return _box!.values
          .where((result) => result.isExcellentPrediction)
          .toList();
    } catch (e) {
      print('❌ Error getting excellent predictions: $e');
      return [];
    }
  }

  /// Get healthy results count
  int getHealthyCount() {
    if (!isInitialized) return 0;

    try {
      return _box!.values.where((result) => _isHealthyResult(result)).length;
    } catch (e) {
      print('❌ Error getting healthy count: $e');
      return 0;
    }
  }

  /// Get issue results count
  int getIssueCount() {
    if (!isInitialized) return 0;

    try {
      return _box!.values.where((result) => _isIssueResult(result)).length;
    } catch (e) {
      print('❌ Error getting issue count: $e');
      return 0;
    }
  }

  /// Update a test result
  Future<void> updateTestResult(TestResult result) async {
    await _ensureInitialized();

    try {
      print('🔄 Updating test result: ${result.id}');
      await _box!.put(result.id, result);
      print('✅ Test result updated successfully');
    } catch (e) {
      print('❌ Error updating test result: $e');
      throw Exception('Failed to update test result: $e');
    }
  }

  /// Delete a test result by ID
  Future<void> deleteTestResult(String id) async {
    await _ensureInitialized();

    try {
      print('🗑️ Deleting test result: $id');
      await _box!.delete(id);
      print('✅ Test result deleted successfully');
    } catch (e) {
      print('❌ Error deleting test result: $e');
      throw Exception('Failed to delete test result: $e');
    }
  }

  /// Delete all test results
  Future<void> deleteAllTestResults() async {
    await _ensureInitialized();

    try {
      print('🗑️ Deleting all test results...');
      await _box!.clear();
      print('✅ All test results deleted successfully');
    } catch (e) {
      print('❌ Error deleting all test results: $e');
      throw Exception('Failed to delete all test results: $e');
    }
  }

  /// Delete test results by crop name
  Future<void> deleteTestResultsByCrop(String cropName) async {
    await _ensureInitialized();

    try {
      print('🗑️ Deleting test results for crop: $cropName');

      final keysToDelete = _box!.values
          .where((result) =>
      result.cropName.toLowerCase() == cropName.toLowerCase())
          .map((result) => result.id)
          .toList();

      await _box!.deleteAll(keysToDelete);
      print('✅ Deleted ${keysToDelete.length} test results for $cropName');
    } catch (e) {
      print('❌ Error deleting test results by crop: $e');
      throw Exception('Failed to delete test results by crop: $e');
    }
  }

  /// Get total count of test results
  int getTestResultsCount() {
    if (!isInitialized) return 0;
    return _box!.length;
  }

  /// Get count by crop name
  int getCountByCrop(String cropName) {
    if (!isInitialized) return 0;

    try {
      return _box!.values
          .where((result) =>
      result.cropName.toLowerCase() == cropName.toLowerCase())
          .length;
    } catch (e) {
      print('❌ Error getting count by crop: $e');
      return 0;
    }
  }

  /// Get average accuracy for all tests
  double getAverageAccuracy() {
    if (!isInitialized || _box!.isEmpty) return 0.0;

    try {
      final results = _box!.values.toList();
      final totalAccuracy = results.fold<double>(
        0.0,
            (sum, result) => sum + result.overallAccuracy,
      );
      return totalAccuracy / results.length;
    } catch (e) {
      print('❌ Error calculating average accuracy: $e');
      return 0.0;
    }
  }

  /// Get average accuracy by crop
  double getAverageAccuracyByCrop(String cropName) {
    if (!isInitialized) return 0.0;

    try {
      final results = getTestResultsByCrop(cropName);
      if (results.isEmpty) return 0.0;

      final totalAccuracy = results.fold<double>(
        0.0,
            (sum, result) => sum + result.overallAccuracy,
      );
      return totalAccuracy / results.length;
    } catch (e) {
      print('❌ Error calculating average accuracy by crop: $e');
      return 0.0;
    }
  }

  /// Get statistics
  Map<String, dynamic> getStatistics() {
    if (!isInitialized) {
      return {
        'total_tests': 0,
        'healthy_count': 0,
        'issue_count': 0,
        'average_accuracy': 0.0,
        'good_predictions': 0,
        'excellent_predictions': 0,
        'good_prediction_rate': 0.0,
        'excellent_prediction_rate': 0.0,
      };
    }

    try {
      final allResults = getAllTestResults();
      final healthyCount = getHealthyCount();
      final issueCount = getIssueCount();
      final goodPredictions = getGoodPredictions();
      final excellentPredictions = getExcellentPredictions();

      return {
        'total_tests': allResults.length,
        'healthy_count': healthyCount,
        'issue_count': issueCount,
        'average_accuracy': getAverageAccuracy(),
        'good_predictions': goodPredictions.length,
        'excellent_predictions': excellentPredictions.length,
        'good_prediction_rate': allResults.isEmpty
            ? 0.0
            : (goodPredictions.length / allResults.length) * 100,
        'excellent_prediction_rate': allResults.isEmpty
            ? 0.0
            : (excellentPredictions.length / allResults.length) * 100,
      };
    } catch (e) {
      print('❌ Error getting statistics: $e');
      return {
        'total_tests': 0,
        'healthy_count': 0,
        'issue_count': 0,
        'average_accuracy': 0.0,
        'good_predictions': 0,
        'excellent_predictions': 0,
        'good_prediction_rate': 0.0,
        'excellent_prediction_rate': 0.0,
      };
    }
  }

  /// Get statistics by crop
  Map<String, dynamic> getStatisticsByCrop(String cropName) {
    if (!isInitialized) {
      return {
        'crop_name': cropName,
        'total_tests': 0,
        'healthy_count': 0,
        'issue_count': 0,
        'average_accuracy': 0.0,
      };
    }

    try {
      final results = getTestResultsByCrop(cropName);
      final healthyCount =
          results.where((result) => _isHealthyResult(result)).length;
      final issueCount =
          results.where((result) => _isIssueResult(result)).length;
      final goodPredictions = results.where((r) => r.isGoodPrediction).length;
      final excellentPredictions =
          results.where((r) => r.isExcellentPrediction).length;

      return {
        'crop_name': cropName,
        'total_tests': results.length,
        'healthy_count': healthyCount,
        'issue_count': issueCount,
        'average_accuracy': getAverageAccuracyByCrop(cropName),
        'good_predictions': goodPredictions,
        'excellent_predictions': excellentPredictions,
        'good_prediction_rate': results.isEmpty
            ? 0.0
            : (goodPredictions / results.length) * 100,
        'excellent_prediction_rate': results.isEmpty
            ? 0.0
            : (excellentPredictions / results.length) * 100,
      };
    } catch (e) {
      print('❌ Error getting statistics by crop: $e');
      return {
        'crop_name': cropName,
        'total_tests': 0,
        'healthy_count': 0,
        'issue_count': 0,
        'average_accuracy': 0.0,
      };
    }
  }

  /// Print statistics
  void printStatistics() {
    final stats = getStatistics();
    print('📊 Database Statistics:');
    stats.forEach((key, value) {
      if (value is double) {
        print('   $key: ${value.toStringAsFixed(2)}');
      } else {
        print('   $key: $value');
      }
    });
  }

  /// Export all test results to JSON
  List<Map<String, dynamic>> exportToJson() {
    if (!isInitialized) return [];

    try {
      return _box!.values.map((result) => result.toJson()).toList();
    } catch (e) {
      print('❌ Error exporting to JSON: $e');
      return [];
    }
  }

  /// Import test results from JSON
  Future<void> importFromJson(List<Map<String, dynamic>> jsonList) async {
    await _ensureInitialized();

    try {
      print('📥 Importing ${jsonList.length} test results...');

      for (var json in jsonList) {
        final result = TestResult.fromJson(json);
        await addTestResult(result);
      }

      print('✅ Import completed successfully');
    } catch (e) {
      print('❌ Error importing from JSON: $e');
      throw Exception('Failed to import from JSON: $e');
    }
  }

  /// Close the database
  Future<void> close() async {
    if (_box != null && _box!.isOpen) {
      await _box!.close();
      print('🔒 Database closed');
    }
  }

  /// Dispose and reset
  static Future<void> dispose() async {
    if (_instance != null) {
      await _instance!.close();
      _instance = null;
      print('🗑️ Database disposed');
    }
  }
}