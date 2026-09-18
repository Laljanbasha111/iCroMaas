import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// ===============================================================
/// AnalysisDatabase
///
/// Firebase Firestore database for crop analysis history.
///
/// Firestore structure:
///
/// users
///   └── {userId}
///       └── analyses
///           └── {analysisId}
///
/// Each analysis document stores:
/// - Crop name
/// - Disease name
/// - Healthy / Issue status
/// - Confidence
/// - Nitrogen
/// - Biomass
/// - Health score
/// - Severity
/// - Image path
/// - Timestamp
///
/// Also provides REAL-TIME statistics:
///
///     total
///     healthy
///     issues
///
/// These statistics are listened to by HomeScreen.
/// ===============================================================
class AnalysisDatabase {
  // ===============================================================
  // SINGLETON
  // ===============================================================

  static final AnalysisDatabase instance =
  AnalysisDatabase._init();

  AnalysisDatabase._init();

  factory AnalysisDatabase() => instance;

  // ===============================================================
  // FIREBASE
  // ===============================================================

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // ===============================================================
  // STREAM
  // ===============================================================

  final StreamController<Map<String, int>>
  _statisticsController =
  StreamController<Map<String, int>>.broadcast();

  Map<String, int>? _lastStatistics;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _statisticsSubscription;

  bool _statisticsListenerStarted = false;

  // ===============================================================
  // COLLECTION
  // ===============================================================

  CollectionReference<Map<String, dynamic>>
  get _analysesCollection {
    final User? user = _auth.currentUser;

    if (user == null) {
      throw StateError(
        'No authenticated Firebase user found.',
      );
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('analyses');
  }

  // ===============================================================
  // USER CHECK
  // ===============================================================

  User? get currentUser => _auth.currentUser;

  bool get isUserLoggedIn =>
      _auth.currentUser != null;

  // ===============================================================
  // REAL-TIME STATISTICS STREAM
  // ===============================================================

  /// Watches dashboard statistics in REAL TIME.
  ///
  /// Whenever an analysis is:
  ///
  /// - added
  /// - updated
  /// - deleted
  ///
  /// the Home Screen receives new statistics automatically.
  ///
  /// Returned map:
  ///
  /// {
  ///   'total': 10,
  ///   'healthy': 7,
  ///   'issues': 3,
  /// }
  Stream<Map<String, int>> watchStatistics() {
    final User? user = _auth.currentUser;

    if (user == null) {
      return Stream.value(
        <String, int>{
          'total': 0,
          'healthy': 0,
          'issues': 0,
        },
      );
    }

    if (!_statisticsListenerStarted) {
      _startStatisticsListener();
    }

    return _statisticsController.stream;
  }

  // ===============================================================
  // START FIRESTORE LISTENER
  // ===============================================================

  void _startStatisticsListener() {
    if (_statisticsListenerStarted) {
      return;
    }

    final User? user = _auth.currentUser;

    if (user == null) {
      return;
    }

    _statisticsListenerStarted = true;

    final Query<Map<String, dynamic>> query =
    _firestore
        .collection('users')
        .doc(user.uid)
        .collection('analyses')
        .orderBy(
      'timestamp',
      descending: true,
    );

    _statisticsSubscription =
        query.snapshots().listen(
              (QuerySnapshot<Map<String, dynamic>> snapshot) {
            int total = snapshot.docs.length;
            int healthy = 0;
            int issues = 0;

            for (final QueryDocumentSnapshot<
                Map<String, dynamic>> document
            in snapshot.docs) {
              final Map<String, dynamic> data =
              document.data();

              final bool isHealthy =
              _isHealthyValue(
                data['is_healthy'],
              );

              if (isHealthy) {
                healthy++;
              } else {
                issues++;
              }
            }

            final Map<String, int> statistics =
            <String, int>{
              'total': total,
              'healthy': healthy,
              'issues': issues,
            };

            if (_lastStatistics == null ||
                !_mapsAreEqual(
                  _lastStatistics!,
                  statistics,
                )) {
              _lastStatistics = statistics;

              if (!_statisticsController.isClosed) {
                _statisticsController.add(
                  statistics,
                );
              }
            }
          },
          onError: (Object error) {
            // Keep the application running even if
            // the Firestore listener encounters an error.
            //
            // The Home Screen can still use getStatistics()
            // through the Refresh button.
          },
        );
  }

  // ===============================================================
  // STOP STATISTICS LISTENER
  // ===============================================================

  Future<void> _stopStatisticsListener() async {
    await _statisticsSubscription?.cancel();

    _statisticsSubscription = null;
    _statisticsListenerStarted = false;
  }

  // ===============================================================
  // REFRESH STATISTICS
  // ===============================================================

  Future<void> refreshStatistics() async {
    try {
      final Map<String, int> statistics =
      await getStatistics();

      _lastStatistics = statistics;

      if (!_statisticsController.isClosed) {
        _statisticsController.add(
          statistics,
        );
      }
    } catch (_) {
      // Do not crash the application.
    }
  }

  // ===============================================================
  // GET STATISTICS
  // ===============================================================

  Future<Map<String, int>> getStatistics() async {
    final User? user = _auth.currentUser;

    if (user == null) {
      return <String, int>{
        'total': 0,
        'healthy': 0,
        'issues': 0,
      };
    }

    try {
      final QuerySnapshot<Map<String, dynamic>>
      snapshot =
      await _analysesCollection.get();

      int total = snapshot.docs.length;
      int healthy = 0;
      int issues = 0;

      for (final QueryDocumentSnapshot<
          Map<String, dynamic>> document
      in snapshot.docs) {
        final Map<String, dynamic> data =
        document.data();

        if (_isHealthyValue(
          data['is_healthy'],
        )) {
          healthy++;
        } else {
          issues++;
        }
      }

      return <String, int>{
        'total': total,
        'healthy': healthy,
        'issues': issues,
      };
    } catch (e) {
      rethrow;
    }
  }

  // ===============================================================
  // COMPARE STATISTICS
  // ===============================================================

  bool _mapsAreEqual(
      Map<String, int> first,
      Map<String, int> second,
      ) {
    return first['total'] == second['total'] &&
        first['healthy'] == second['healthy'] &&
        first['issues'] == second['issues'];
  }

  // ===============================================================
  // INSERT ANALYSIS
  // ===============================================================

  Future<String> insertAnalysis(
      Map<String, dynamic> analysis,
      ) async {
    final User? user = _auth.currentUser;

    if (user == null) {
      throw StateError(
        'Cannot save analysis. User is not logged in.',
      );
    }

    final Map<String, dynamic> data =
    _sanitizeAnalysisData(
      analysis,
    );

    final DocumentReference<
        Map<String, dynamic>> document =
    await _analysesCollection.add(
      data,
    );

    // The Firestore snapshot listener will automatically
    // update the Home Screen statistics.
    return document.id;
  }

  // ===============================================================
  // INSERT MULTIPLE ANALYSES
  // ===============================================================

  Future<void> insertMultipleAnalyses(
      List<Map<String, dynamic>> analyses,
      ) async {
    if (analyses.isEmpty) {
      return;
    }

    final WriteBatch batch =
    _firestore.batch();

    for (final Map<String, dynamic> analysis
    in analyses) {
      final DocumentReference<
          Map<String, dynamic>> document =
      _analysesCollection.doc();

      batch.set(
        document,
        _sanitizeAnalysisData(
          analysis,
        ),
      );
    }

    await batch.commit();

    // Firestore listener updates automatically.
  }

  // ===============================================================
  // UPDATE ANALYSIS
  // ===============================================================

  Future<bool> updateAnalysis(
      String id,
      Map<String, dynamic> analysis,
      ) async {
    try {
      await _analysesCollection
          .doc(id)
          .update(
        _sanitizeAnalysisData(
          analysis,
        ),
      );

      return true;
    } catch (_) {
      return false;
    }
  }

  // ===============================================================
  // GET ALL ANALYSES
  // ===============================================================

  Future<List<Map<String, dynamic>>>
  getAllAnalyses() async {
    final QuerySnapshot<Map<String, dynamic>>
    snapshot =
    await _analysesCollection
        .orderBy(
      'timestamp',
      descending: true,
    )
        .get();

    return snapshot.docs.map(
          (
          QueryDocumentSnapshot<
              Map<String, dynamic>> document,
          ) {
        final Map<String, dynamic> data =
        Map<String, dynamic>.from(
          document.data(),
        );

        data['id'] = document.id;

        return data;
      },
    ).toList();
  }

  // ===============================================================
  // GET ANALYSIS BY ID
  // ===============================================================

  Future<Map<String, dynamic>?>
  getAnalysisById(
      String id,
      ) async {
    try {
      final DocumentSnapshot<
          Map<String, dynamic>> document =
      await _analysesCollection
          .doc(id)
          .get();

      if (!document.exists) {
        return null;
      }

      final Map<String, dynamic> data =
      Map<String, dynamic>.from(
        document.data()!,
      );

      data['id'] = document.id;

      return data;
    } catch (_) {
      return null;
    }
  }

  // ===============================================================
  // GET RECENT ANALYSES
  // ===============================================================

  Future<List<Map<String, dynamic>>>
  getRecentAnalyses({
    int limit = 10,
  }) async {
    final int safeLimit =
    limit < 1 ? 1 : limit;

    final QuerySnapshot<Map<String, dynamic>>
    snapshot =
    await _analysesCollection
        .orderBy(
      'timestamp',
      descending: true,
    )
        .limit(safeLimit)
        .get();

    return snapshot.docs.map(
          (
          QueryDocumentSnapshot<
              Map<String, dynamic>> document,
          ) {
        final Map<String, dynamic> data =
        Map<String, dynamic>.from(
          document.data(),
        );

        data['id'] = document.id;

        return data;
      },
    ).toList();
  }

  // ===============================================================
  // GET ANALYSES BY CROP
  // ===============================================================

  Future<List<Map<String, dynamic>>>
  getAnalysesByCrop(
      String cropName,
      ) async {
    final QuerySnapshot<Map<String, dynamic>>
    snapshot =
    await _analysesCollection
        .where(
      'crop_name',
      isEqualTo: cropName,
    )
        .orderBy(
      'timestamp',
      descending: true,
    )
        .get();

    return snapshot.docs.map(
          (
          QueryDocumentSnapshot<
              Map<String, dynamic>> document,
          ) {
        final Map<String, dynamic> data =
        Map<String, dynamic>.from(
          document.data(),
        );

        data['id'] = document.id;

        return data;
      },
    ).toList();
  }

  // ===============================================================
  // TOTAL COUNT
  // ===============================================================

  Future<int> getTotalAnalysesCount() async {
    final Map<String, int> statistics =
    await getStatistics();

    return statistics['total'] ?? 0;
  }

  // ===============================================================
  // HEALTHY COUNT
  // ===============================================================

  Future<int> getHealthyCount() async {
    final Map<String, int> statistics =
    await getStatistics();

    return statistics['healthy'] ?? 0;
  }

  // ===============================================================
  // ISSUES COUNT
  // ===============================================================

  Future<int> getIssuesCount() async {
    final Map<String, int> statistics =
    await getStatistics();

    return statistics['issues'] ?? 0;
  }

  // ===============================================================
  // DELETE SINGLE ANALYSIS
  // ===============================================================

  Future<bool> deleteAnalysis(
      String id,
      ) async {
    try {
      await _analysesCollection
          .doc(id)
          .delete();

      // Firestore listener automatically updates
      // the dashboard count.

      return true;
    } catch (_) {
      return false;
    }
  }

  // ===============================================================
  // DELETE ALL ANALYSES
  // ===============================================================

  Future<bool> clearHistory() async {
    try {
      final QuerySnapshot<Map<String, dynamic>>
      snapshot =
      await _analysesCollection.get();

      if (snapshot.docs.isEmpty) {
        return true;
      }

      final WriteBatch batch =
      _firestore.batch();

      for (final QueryDocumentSnapshot<
          Map<String, dynamic>> document
      in snapshot.docs) {
        batch.delete(
          document.reference,
        );
      }

      await batch.commit();

      return true;
    } catch (_) {
      return false;
    }
  }

  // ===============================================================
  // CHECK HISTORY
  // ===============================================================

  Future<bool> hasHistory() async {
    final int count =
    await getTotalAnalysesCount();

    return count > 0;
  }

  // ===============================================================
  // GET LATEST ANALYSIS
  // ===============================================================

  Future<Map<String, dynamic>?>
  getLatestAnalysis() async {
    try {
      final QuerySnapshot<Map<String, dynamic>>
      snapshot =
      await _analysesCollection
          .orderBy(
        'timestamp',
        descending: true,
      )
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      final QueryDocumentSnapshot<
          Map<String, dynamic>> document =
          snapshot.docs.first;

      final Map<String, dynamic> data =
      Map<String, dynamic>.from(
        document.data(),
      );

      data['id'] = document.id;

      return data;
    } catch (_) {
      return null;
    }
  }

  // ===============================================================
  // SEARCH ANALYSES
  // ===============================================================

  Future<List<Map<String, dynamic>>>
  searchAnalyses(
      String query,
      ) async {
    final String search =
    query.trim().toLowerCase();

    if (search.isEmpty) {
      return getAllAnalyses();
    }

    final List<Map<String, dynamic>>
    allAnalyses =
    await getAllAnalyses();

    return allAnalyses.where(
          (
          Map<String, dynamic> analysis,
          ) {
        final String cropName =
        _safeString(
          analysis['crop_name'],
          '',
        ).toLowerCase();

        final String diseaseName =
        _safeString(
          analysis['disease_name'],
          '',
        ).toLowerCase();

        final String severity =
        _safeString(
          analysis['severity'],
          '',
        ).toLowerCase();

        return cropName.contains(search) ||
            diseaseName.contains(search) ||
            severity.contains(search);
      },
    ).toList();
  }

  // ===============================================================
  // SANITIZE ANALYSIS DATA
  // ===============================================================

  Map<String, dynamic>
  _sanitizeAnalysisData(
      Map<String, dynamic> analysis,
      ) {
    final String cropName =
    _safeString(
      analysis['crop_name'] ??
          analysis['cropName'],
      'Unknown',
    );

    final String diseaseName =
    _safeString(
      analysis['disease_name'] ??
          analysis['diseaseName'],
      'Unknown',
    );

    final double confidence =
    _toDouble(
      analysis['confidence'],
    );

    final double nitrogen =
    _toDouble(
      analysis['nitrogen'],
    );

    final double biomass =
    _toDouble(
      analysis['biomass'],
    );

    final double healthScore =
    _toDouble(
      analysis['health_score'] ??
          analysis['healthScore'],
    );

    final String severity =
    _safeString(
      analysis['severity'],
      'Unknown',
    );

    final String? imagePath =
    analysis['image_path'] ??
        analysis['imagePath']
            != null
        ? (
        analysis['image_path'] ??
            analysis['imagePath']
    ).toString()
        : null;

    final int isHealthy =
    analysis.containsKey(
      'is_healthy',
    )
        ? _toSQLiteBoolean(
      analysis['is_healthy'],
    )
        : analysis.containsKey(
      'isHealthy',
    )
        ? _toSQLiteBoolean(
      analysis['isHealthy'],
    )
        : _calculateHealthStatus(
      healthScore: healthScore,
      diseaseName: diseaseName,
      severity: severity,
      analysis: analysis,
    );

    final Timestamp timestamp =
    _convertToTimestamp(
      analysis['timestamp'],
    );

    return <String, dynamic>{
      'crop_name': cropName,
      'disease_name': diseaseName,
      'is_healthy': isHealthy == 1,
      'confidence': confidence,
      'nitrogen': nitrogen,
      'biomass': biomass,
      'health_score': healthScore,
      'severity': severity,
      'image_path': imagePath,
      'timestamp': timestamp,
      'user_id': _auth.currentUser?.uid,
    };
  }

  // ===============================================================
  // CALCULATE HEALTH STATUS
  // ===============================================================

  int _calculateHealthStatus({
    required double healthScore,
    required String diseaseName,
    required String severity,
    required Map<String, dynamic> analysis,
  }) {
    final String disease =
    diseaseName
        .toLowerCase()
        .trim();

    final String severityValue =
    severity
        .toLowerCase()
        .trim();

    final bool diseaseDetected =
        disease.isNotEmpty &&
            disease != 'unknown' &&
            disease != 'none' &&
            disease != 'healthy' &&
            disease != 'no disease';

    final bool seriousSeverity =
        severityValue == 'high' ||
            severityValue == 'severe' ||
            severityValue == 'critical';

    if (diseaseDetected ||
        seriousSeverity) {
      return 0;
    }

    if (healthScore > 0) {
      return healthScore >= 70.0
          ? 1
          : 0;
    }

    final bool hasDisease =
        _toSQLiteBoolean(
          analysis['has_disease'],
        ) ==
            1;

    final bool hasPest =
        _toSQLiteBoolean(
          analysis['has_pest'],
        ) ==
            1;

    if (hasDisease || hasPest) {
      return 0;
    }

    return 1;
  }

  // ===============================================================
  // HEALTH VALUE CONVERSION
  // ===============================================================

  bool _isHealthyValue(
      dynamic value,
      ) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    if (value is String) {
      final String normalized =
      value
          .toLowerCase()
          .trim();

      return normalized == 'true' ||
          normalized == '1' ||
          normalized == 'yes' ||
          normalized == 'healthy';
    }

    return false;
  }

  // ===============================================================
  // SAFE STRING
  // ===============================================================

  String _safeString(
      dynamic value,
      String fallback,
      ) {
    if (value == null) {
      return fallback;
    }

    final String text =
    value.toString().trim();

    if (text.isEmpty) {
      return fallback;
    }

    return text;
  }

  // ===============================================================
  // DOUBLE CONVERSION
  // ===============================================================

  double _toDouble(
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
      final double result =
          double.tryParse(
            value.trim(),
          ) ??
              0.0;

      if (result.isNaN ||
          result.isInfinite) {
        return 0.0;
      }

      return result;
    }

    return 0.0;
  }

  // ===============================================================
  // BOOLEAN CONVERSION
  // ===============================================================

  int _toSQLiteBoolean(
      dynamic value,
      ) {
    if (value is bool) {
      return value ? 1 : 0;
    }

    if (value is num) {
      return value != 0 ? 1 : 0;
    }

    if (value is String) {
      final String normalized =
      value
          .toLowerCase()
          .trim();

      if (normalized == 'true' ||
          normalized == '1' ||
          normalized == 'yes' ||
          normalized == 'healthy') {
        return 1;
      }

      return 0;
    }

    return 0;
  }

  // ===============================================================
  // TIMESTAMP CONVERSION
  // ===============================================================

  Timestamp _convertToTimestamp(
      dynamic value,
      ) {
    if (value is Timestamp) {
      return value;
    }

    if (value is DateTime) {
      return Timestamp.fromDate(
        value,
      );
    }

    if (value is String) {
      final DateTime? date =
      DateTime.tryParse(
        value,
      );

      if (date != null) {
        return Timestamp.fromDate(
          date,
        );
      }
    }

    return Timestamp.now();
  }

  // ===============================================================
  // DATABASE SIZE
  // ===============================================================

  Future<int> getDatabaseSize() async {
    return getTotalAnalysesCount();
  }

  // ===============================================================
  // DISPOSE
  // ===============================================================

  Future<void> dispose() async {
    await _stopStatisticsListener();

    if (!_statisticsController
        .isClosed) {
      await _statisticsController.close();
    }
  }
}