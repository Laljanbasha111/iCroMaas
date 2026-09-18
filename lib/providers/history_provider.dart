import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/firestore_service.dart';
import '../models/analysis_model.dart';

/// HistoryProvider manages crop analysis history, filtering, sorting, pagination,
/// caching, and statistics for the Crop Analyzer app.
class HistoryProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = false;
  String? _error;
  final List<AnalysisModel> _historyList = [];
  final List<AnalysisModel> _filteredHistory = [];

  // Pagination
  static const int _pageSize = 10;
  int _currentPage = 0;
  bool _hasMore = true;

  // Filters and sorting
  String? _currentFilter;
  String _currentSortOrder = 'date_desc';
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  double? _minHealthScore;
  double? _maxHealthScore;
  String? _filterCropType;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<AnalysisModel> get historyList => List.unmodifiable(_historyList);
  List<AnalysisModel> get filteredHistory => List.unmodifiable(_filteredHistory);
  int get totalCount => _historyList.length;
  bool get hasMore => _hasMore;
  String? get currentFilter => _currentFilter;
  String get currentSortOrder => _currentSortOrder;

  /// Fetch user's analysis history from Firestore.
  Future<void> fetchHistory(String userId) async {
    _setLoading(true);
    try {
      final allData = await _firestoreService.getAllDocuments('analysis');
      final userAnalyses = allData
          .map((doc) => AnalysisModel.fromMap(doc))
          .where((a) => a.userId == userId)
          .toList();

      _historyList
        ..clear()
        ..addAll(userAnalyses);
      _applyFilters();
      _applySorting();
      await _cacheHistory();
      _error = null;
      _hasMore = _historyList.length > _pageSize;
    } catch (e) {
      _handleError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Load next page of history (pagination).
  Future<void> fetchMoreHistory() async {
    if (!_hasMore || _isLoading) return;
    _setLoading(true);
    try {
      _currentPage++;
      final start = _currentPage * _pageSize;
      final end = start + _pageSize;
      if (start < _historyList.length) {
        final nextPage = _historyList.sublist(
          start,
          end > _historyList.length ? _historyList.length : end,
        );
        _filteredHistory.addAll(nextPage);
        _hasMore = end < _historyList.length;
      } else {
        _hasMore = false;
      }
      notifyListeners();
    } catch (e) {
      _handleError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh/reload history.
  Future<void> refreshHistory(String userId) async {
    _currentPage = 0;
    _hasMore = true;
    await fetchHistory(userId);
  }

  /// Add new analysis to history.
  Future<void> addToHistory(AnalysisModel analysis) async {
    _historyList.insert(0, analysis);
    _applyFilters();
    _applySorting();
    await _firestoreService.addDocument('analysis', analysis.toMap());
    await _cacheHistory();
    notifyListeners();
  }

  /// Delete specific analysis from history.
  Future<void> deleteFromHistory(String analysisId) async {
    _historyList.removeWhere((a) => a.id == analysisId);
    _filteredHistory.removeWhere((a) => a.id == analysisId);
    await _firestoreService.deleteDocument('analysis', analysisId);
    await _cacheHistory();
    notifyListeners();
  }

  /// Clear all history.
  Future<void> clearHistory() async {
    _historyList.clear();
    _filteredHistory.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_history');
    notifyListeners();
  }

  /// Search in history by crop type, notes, or location.
  void searchHistory(String query) {
    if (query.isEmpty) {
      _applyFilters();
      return;
    }
    final lowerQuery = query.toLowerCase();
    final results = _historyList.where((a) {
      return a.cropType.toLowerCase().contains(lowerQuery) ||
          a.notes.toLowerCase().contains(lowerQuery) ||
          (a.location?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
    _filteredHistory
      ..clear()
      ..addAll(results);
    notifyListeners();
  }

  /// Filter by crop type.
  void filterByType(String cropType) {
    _filterCropType = cropType;
    _applyFilters();
  }

  /// Filter by date range.
  void filterByDate(DateTime start, DateTime end) {
    _filterStartDate = start;
    _filterEndDate = end;
    _applyFilters();
  }

  /// Filter by health score range.
  void filterByHealthScore(double minScore, double maxScore) {
    _minHealthScore = minScore;
    _maxHealthScore = maxScore;
    _applyFilters();
  }

  /// Sort by date.
  void sortByDate({bool ascending = false}) {
    _currentSortOrder = ascending ? 'date_asc' : 'date_desc';
    _applySorting();
  }

  /// Sort by health score.
  void sortByHealthScore({bool ascending = false}) {
    _currentSortOrder = ascending ? 'health_asc' : 'health_desc';
    _applySorting();
  }

  /// Sort alphabetically by crop type.
  void sortByCropType() {
    _currentSortOrder = 'crop_asc';
    _applySorting();
  }

  /// Sort by biomass level.
  void sortByBiomass({bool ascending = false}) {
    _currentSortOrder = ascending ? 'biomass_asc' : 'biomass_desc';
    _applySorting();
  }

  /// Get specific analysis by ID.
  AnalysisModel? getHistoryById(String id) {
    try {
      return _historyList.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get recent N analyses.
  List<AnalysisModel> getRecentHistory(int count) {
    final sorted = List<AnalysisModel>.from(_historyList)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(count).toList();
  }

  /// Get statistics summary.
  Map<String, dynamic> getStatistics() {
    if (_historyList.isEmpty) {
      return {
        'total': 0,
        'averageHealth': 0.0,
        'diseasedCount': 0,
        'pestCount': 0,
      };
    }
    final total = _historyList.length;
    final avgHealth = _historyList.map((a) => a.healthScore).reduce((a, b) => a + b) / total;
    final diseased = _historyList.where((a) => a.hasDisease).length;
    final pest = _historyList.where((a) => a.hasPest).length;
    return {
      'total': total,
      'averageHealth': avgHealth,
      'diseasedCount': diseased,
      'pestCount': pest,
    };
  }

  /// Export history as JSON string.
  Future<String> exportHistory() async {
    final data = _historyList.map((a) => a.toMap()).toList();
    return jsonEncode(data);
  }

  /// Import history from JSON string.
  Future<void> importHistory(String data) async {
    try {
      final decoded = jsonDecode(data) as List<dynamic>;
      final imported = decoded.map((e) => AnalysisModel.fromMap(e)).toList();
      _historyList
        ..clear()
        ..addAll(imported);
      _applyFilters();
      _applySorting();
      await _cacheHistory();
      notifyListeners();
    } catch (e) {
      _handleError(e);
    }
  }

  /// Apply filters to history list.
  void _applyFilters() {
    List<AnalysisModel> filtered = List.from(_historyList);

    if (_filterCropType != null && _filterCropType!.isNotEmpty) {
      filtered = filtered
          .where((a) => a.cropType.toLowerCase() == _filterCropType!.toLowerCase())
          .toList();
    }

    if (_filterStartDate != null && _filterEndDate != null) {
      filtered = filtered
          .where((a) => a.date.isAfter(_filterStartDate!) && a.date.isBefore(_filterEndDate!))
          .toList();
    }

    if (_minHealthScore != null && _maxHealthScore != null) {
      filtered = filtered
          .where((a) =>
      a.healthScore >= _minHealthScore! && a.healthScore <= _maxHealthScore!)
          .toList();
    }

    _filteredHistory
      ..clear()
      ..addAll(filtered.take(_pageSize));
    _hasMore = filtered.length > _pageSize;
    notifyListeners();
  }

  /// Apply sorting to filtered history.
  void _applySorting() {
    switch (_currentSortOrder) {
      case 'date_asc':
        _filteredHistory.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'date_desc':
        _filteredHistory.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'health_asc':
        _filteredHistory.sort((a, b) => a.healthScore.compareTo(b.healthScore));
        break;
      case 'health_desc':
        _filteredHistory.sort((a, b) => b.healthScore.compareTo(a.healthScore));
        break;
      case 'crop_asc':
        _filteredHistory.sort((a, b) => a.cropType.compareTo(b.cropType));
        break;
      case 'biomass_asc':
        _filteredHistory.sort((a, b) => a.biomass.compareTo(b.biomass));
        break;
      case 'biomass_desc':
        _filteredHistory.sort((a, b) => b.biomass.compareTo(a.biomass));
        break;
      default:
        _filteredHistory.sort((a, b) => b.date.compareTo(a.date));
    }
    notifyListeners();
  }

  /// Cache history locally.
  Future<void> _cacheHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_historyList.map((a) => a.toMap()).toList());
    await prefs.setString('cached_history', jsonString);
  }

  /// Load cached history from local storage.
  Future<void> loadCachedHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('cached_history');
    if (jsonString != null) {
      final decoded = jsonDecode(jsonString) as List<dynamic>;
      final cached = decoded.map((e) => AnalysisModel.fromMap(e)).toList();
      _historyList
        ..clear()
        ..addAll(cached);
      _applyFilters();
      _applySorting();
      notifyListeners();
    }
  }

  /// Helper: Set loading state.
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Helper: Handle errors.
  void _handleError(dynamic error) {
    _error = error.toString();
    log('HistoryProvider Error: $_error');
    _isLoading = false;
    notifyListeners();
  }
}