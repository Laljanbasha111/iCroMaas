import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import '../../core/services/storage_service.dart';

class AnalyticsStats {
  final int totalAnalyses;
  final int healthyPercentage;
  final int diseasesDetected;
  final int averageHealthScore;
  final String? mostAnalyzedCrop;
  final String? recentActivity;

  AnalyticsStats({
    this.totalAnalyses = 0,
    this.healthyPercentage = 0,
    this.diseasesDetected = 0,
    this.averageHealthScore = 0,
    this.mostAnalyzedCrop,
    this.recentActivity,
  });
}

class AnalyticsProvider with ChangeNotifier {
  final StorageService _storageService = StorageService.instance;

  AnalyticsStats _stats = AnalyticsStats();
  List<FlSpot> _healthScoreTrend = [];
  Map<String, double> _cropDistribution = {};
  Map<String, double> _diseaseFrequency = {};
  Map<String, double> _monthlyAnalysisCount = {};
  Map<String, double> _healthScoreDistribution = {};
  String? _trendSummary;

  // Getters
  AnalyticsStats get stats => _stats;
  List<FlSpot> get healthScoreTrend => _healthScoreTrend;
  Map<String, double> get cropDistribution => _cropDistribution;
  Map<String, double> get diseaseFrequency => _diseaseFrequency;
  Map<String, double> get monthlyAnalysisCount => _monthlyAnalysisCount;
  Map<String, double> get healthScoreDistribution => _healthScoreDistribution;
  String? get trendSummary => _trendSummary;

  /// Fetch analytics data
  Future<void> fetchAnalyticsData({String? period, DateTimeRange? range}) async {
    try {
      // Load analysis history
      final historyData = await _storageService.getJson('analysis_history_index');

      if (historyData == null || historyData['items'] is! List) {
        _setDefaultData();
        notifyListeners();
        return;
      }

      final List<Map<String, dynamic>> analyses = List<Map<String, dynamic>>.from(historyData['items']);

      // Calculate statistics
      _calculateStats(analyses);
      _calculateHealthScoreTrend(analyses);
      _calculateCropDistribution(analyses);
      _calculateDiseaseFrequency(analyses);
      _calculateMonthlyCount(analyses);
      _calculateHealthScoreDistribution(analyses);
      _generateTrendSummary(analyses);

      notifyListeners();
    } catch (e) {
      debugPrint('Failed to fetch analytics: $e');
      _setDefaultData();
      notifyListeners();
    }
  }

  /// Calculate statistics
  void _calculateStats(List<Map<String, dynamic>> analyses) {
    if (analyses.isEmpty) {
      _stats = AnalyticsStats();
      return;
    }

    int totalHealthScore = 0;
    int diseasesCount = 0;
    int healthyCount = 0;
    Map<String, int> cropCounts = {};

    for (var analysis in analyses) {
      final data = analysis['data'] as Map<String, dynamic>?;
      if (data == null) continue;

      final healthScore = (data['healthScore'] ?? 0) as num;
      totalHealthScore += healthScore.toInt();

      if (healthScore >= 80) {
        healthyCount++;
      }

      final diseases = data['diseases'] as List?;
      if (diseases != null) {
        diseasesCount += diseases.length;
      }

      final cropType = data['cropType'] as String?;
      if (cropType != null) {
        cropCounts[cropType] = (cropCounts[cropType] ?? 0) + 1;
      }
    }

    final mostAnalyzed = cropCounts.entries.isEmpty
        ? null
        : cropCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    _stats = AnalyticsStats(
      totalAnalyses: analyses.length,
      healthyPercentage: analyses.isEmpty ? 0 : ((healthyCount / analyses.length) * 100).toInt(),
      diseasesDetected: diseasesCount,
      averageHealthScore: analyses.isEmpty ? 0 : (totalHealthScore / analyses.length).toInt(),
      mostAnalyzedCrop: mostAnalyzed,
      recentActivity: analyses.isEmpty ? 'No activity' : '${analyses.length} analyses',
    );
  }

  /// Calculate health score trend
  void _calculateHealthScoreTrend(List<Map<String, dynamic>> analyses) {
    _healthScoreTrend = [];
    for (int i = 0; i < analyses.length && i < 10; i++) {
      final data = analyses[i]['data'] as Map<String, dynamic>?;
      final healthScore = (data?['healthScore'] ?? 0) as num;
      _healthScoreTrend.add(FlSpot(i.toDouble(), healthScore.toDouble()));
    }
  }

  /// Calculate crop distribution
  void _calculateCropDistribution(List<Map<String, dynamic>> analyses) {
    Map<String, int> counts = {};
    for (var analysis in analyses) {
      final data = analysis['data'] as Map<String, dynamic>?;
      final cropType = data?['cropType'] as String? ?? 'Unknown';
      counts[cropType] = (counts[cropType] ?? 0) + 1;
    }

    final total = analyses.length;
    if (total > 0) {
      _cropDistribution = counts.map((key, value) => MapEntry(key, (value / total) * 100));
    }
  }

  /// Calculate disease frequency
  void _calculateDiseaseFrequency(List<Map<String, dynamic>> analyses) {
    Map<String, int> counts = {};
    for (var analysis in analyses) {
      final data = analysis['data'] as Map<String, dynamic>?;
      final diseases = data?['diseases'] as List?;
      if (diseases != null) {
        for (var disease in diseases) {
          final name = disease['name'] as String? ?? 'Unknown';
          counts[name] = (counts[name] ?? 0) + 1;
        }
      }
    }

    _diseaseFrequency = counts.map((key, value) => MapEntry(key, value.toDouble()));
  }

  /// Calculate monthly analysis count
  void _calculateMonthlyCount(List<Map<String, dynamic>> analyses) {
    Map<String, int> counts = {};
    for (var analysis in analyses) {
      final timestamp = analysis['timestamp'] as int?;
      if (timestamp != null) {
        final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final month = '${date.month}/${date.year}';
        counts[month] = (counts[month] ?? 0) + 1;
      }
    }

    _monthlyAnalysisCount = counts.map((key, value) => MapEntry(key, value.toDouble()));
  }

  /// Calculate health score distribution
  void _calculateHealthScoreDistribution(List<Map<String, dynamic>> analyses) {
    Map<String, int> distribution = {
      '0-20': 0,
      '21-40': 0,
      '41-60': 0,
      '61-80': 0,
      '81-100': 0,
    };

    for (var analysis in analyses) {
      final data = analysis['data'] as Map<String, dynamic>?;
      final healthScore = (data?['healthScore'] ?? 0) as num;

      if (healthScore <= 20) {
        distribution['0-20'] = distribution['0-20']! + 1;
      } else if (healthScore <= 40) {
        distribution['21-40'] = distribution['21-40']! + 1;
      } else if (healthScore <= 60) {
        distribution['41-60'] = distribution['41-60']! + 1;
      } else if (healthScore <= 80) {
        distribution['61-80'] = distribution['61-80']! + 1;
      } else {
        distribution['81-100'] = distribution['81-100']! + 1;
      }
    }

    _healthScoreDistribution = distribution.map((key, value) => MapEntry(key, value.toDouble()));
  }

  /// Generate trend summary
  void _generateTrendSummary(List<Map<String, dynamic>> analyses) {
    if (analyses.isEmpty) {
      _trendSummary = 'No data available for trend analysis.';
      return;
    }

    _trendSummary = '''
Total analyses performed: ${analyses.length}
Average health score: ${_stats.averageHealthScore}%
Most analyzed crop: ${_stats.mostAnalyzedCrop ?? 'N/A'}
Diseases detected: ${_stats.diseasesDetected}
Healthy crops: ${_stats.healthyPercentage}%
    ''';
  }

  /// Export analytics data
  Future<void> exportAnalyticsData() async {
    final data = {
      'stats': {
        'totalAnalyses': _stats.totalAnalyses,
        'healthyPercentage': _stats.healthyPercentage,
        'diseasesDetected': _stats.diseasesDetected,
        'averageHealthScore': _stats.averageHealthScore,
        'mostAnalyzedCrop': _stats.mostAnalyzedCrop,
      },
      'cropDistribution': _cropDistribution,
      'diseaseFrequency': _diseaseFrequency,
      'monthlyAnalysisCount': _monthlyAnalysisCount,
      'healthScoreDistribution': _healthScoreDistribution,
      'trendSummary': _trendSummary,
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(data);

    // ✅ Fixed: Correct Share.share() usage
    final result = await Share.share(jsonString, subject: 'Analytics Data Export');

    if (result.status == ShareResultStatus.success) {
      debugPrint('Analytics data shared successfully');
    }
  }

  /// Set default data
  void _setDefaultData() {
    _stats = AnalyticsStats();
    _healthScoreTrend = [
      const FlSpot(0, 75),
      const FlSpot(1, 80),
      const FlSpot(2, 78),
      const FlSpot(3, 85),
      const FlSpot(4, 82),
    ];
    _cropDistribution = {'Wheat': 30, 'Rice': 25, 'Corn': 20, 'Tomato': 15, 'Potato': 10};
    _diseaseFrequency = {'Leaf Blight': 5, 'Rust': 3, 'Mildew': 2};
    _monthlyAnalysisCount = {'Jan': 10, 'Feb': 15, 'Mar': 12, 'Apr': 18};
    _healthScoreDistribution = {'0-20': 2, '21-40': 5, '41-60': 10, '61-80': 15, '81-100': 20};
    _trendSummary = 'Sample trend data. Perform analyses to see real trends.';
  }
}