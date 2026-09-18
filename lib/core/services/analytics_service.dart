import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Singleton service for Firebase Analytics and custom event tracking
class AnalyticsService {
  AnalyticsService._();
  static final instance = AnalyticsService._();

  late final FirebaseAnalytics _analytics;
  late final FirebaseFirestore _firestore;

  bool _initialized = false;
  DateTime? _sessionStartTime;
  String? _userId;

  // ==================== Initialization ====================

  Future<void> initialize() async {
    if (_initialized) {
      debugPrint('⚠️ AnalyticsService already initialized');
      return;
    }

    try {
      _analytics = FirebaseAnalytics.instance;
      _firestore = FirebaseFirestore.instance;
      _sessionStartTime = DateTime.now();

      await _logAppLaunch();
      _initialized = true;
      debugPrint('✅ AnalyticsService initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize AnalyticsService: $e');
      _initialized = false;
    }
  }

  // ==================== Core Analytics ====================

  Future<void> logEvent(String name, [Map<String, dynamic>? parameters]) async {
    if (!_initialized) {
      debugPrint('⚠️ AnalyticsService not initialized. Call initialize() first.');
      return;
    }

    try {
      Map<String, Object>? firebaseParams;

      if (parameters != null) {
        firebaseParams = {};

        parameters.forEach((key, value) {
          if (value != null) {
            // Convert to Firebase-compatible types
            if (value is String || value is num || value is bool) {
              firebaseParams![key] = value as Object;
            } else {
              firebaseParams![key] = value.toString();
            }
          }
        });
      }

      await _analytics.logEvent(
        name: name,
        parameters: firebaseParams,
      );
      await _saveEventToFirestore(name, parameters);
      debugPrint('📊 Event logged: $name');
    } catch (e) {
      debugPrint('❌ Error logging event "$name": $e');
    }
  }

  Future<void> logScreenView(String screenName) async {
    if (!_initialized) return;

    try {
      await _analytics.logScreenView(screenName: screenName);
      await _saveEventToFirestore('screen_view', {'screen_name': screenName});
      debugPrint('📱 Screen view logged: $screenName');
    } catch (e) {
      debugPrint('❌ Error logging screen view: $e');
    }
  }

  Future<void> setUserId(String userId) async {
    if (!_initialized) return;

    try {
      _userId = userId;
      await _analytics.setUserId(id: userId);
      debugPrint('👤 User ID set: $userId');
    } catch (e) {
      debugPrint('❌ Error setting user ID: $e');
    }
  }

  Future<void> setUserProperty(String name, String value) async {
    if (!_initialized) return;

    try {
      await _analytics.setUserProperty(name: name, value: value);
      debugPrint('🏷️ User property set: $name = $value');
    } catch (e) {
      debugPrint('❌ Error setting user property: $e');
    }
  }

  Future<void> resetAnalyticsData() async {
    if (!_initialized) return;

    try {
      await _analytics.resetAnalyticsData();
      _userId = null;
      _sessionStartTime = null;
      debugPrint('🔄 Analytics data reset');
    } catch (e) {
      debugPrint('❌ Error resetting analytics data: $e');
    }
  }

  // ==================== User Events ====================

  Future<void> logLogin(String method) =>
      logEvent('login', {'method': method});

  Future<void> logSignUp(String method) =>
      logEvent('sign_up', {'method': method});

  Future<void> logLogout() => logEvent('logout');

  // ==================== Crop Analytics ====================

  Future<void> logCropAdded(String cropType) =>
      logEvent('crop_added', {'crop_type': cropType});

  Future<void> logCropUpdated(String cropType) =>
      logEvent('crop_updated', {'crop_type': cropType});

  Future<void> logCropDeleted(String cropType) =>
      logEvent('crop_deleted', {'crop_type': cropType});

  Future<void> logCropViewed(String cropType) =>
      logEvent('crop_viewed', {'crop_type': cropType});

  Future<void> logHarvestData(String cropType, double yieldAmount) =>
      logEvent('harvest_recorded', {
        'crop_type': cropType,
        'yield_amount': yieldAmount,
      });

  // ==================== Disease Analytics ====================

  Future<void> logDiseaseDetected(String diseaseName, double confidence) =>
      logEvent('disease_detected', {
        'disease_name': diseaseName,
        'confidence': confidence,
      });

  Future<void> logDiseaseTreated(String diseaseName) =>
      logEvent('disease_treated', {'disease_name': diseaseName});

  Future<void> logDiseaseSeverity(String diseaseName, String severityLevel) =>
      logEvent('disease_severity', {
        'disease_name': diseaseName,
        'severity': severityLevel,
      });

  // ==================== Analysis Analytics ====================

  /// ✅ Log when crop analysis is performed
  Future<void> logAnalysisPerformed(String analysisType, {
    String? cropType,
    double? nitrogen,
    double? biomass,
    double? confidence,
  }) => logEvent('analysis_performed', {
    'analysis_type': analysisType,
    'crop_type': cropType,
    'nitrogen': nitrogen,
    'biomass': biomass,
    'confidence': confidence,
  });

  Future<void> logAnalysisShared(String analysisType) =>
      logEvent('analysis_shared', {'analysis_type': analysisType});

  /// ✅ Log analysis success/failure
  Future<void> logAnalysisResult(bool success, {String? errorMessage}) =>
      logEvent('analysis_result', {
        'success': success,
        'error_message': errorMessage,
      });

  // ==================== Camera Analytics ====================

  Future<void> logImageCaptured(String source) =>
      logEvent('image_captured', {'source': source});

  Future<void> logImageProcessed(String processType, int durationMs) =>
      logEvent('image_processed', {
        'process_type': processType,
        'duration_ms': durationMs,
      });

  // ==================== Search Analytics ====================

  Future<void> logSearchQuery(String query) =>
      logEvent('search_query', {'query': query});

  Future<void> logFilterApplied(String filterType) =>
      logEvent('filter_applied', {'filter_type': filterType});

  // ==================== Share & Conversion ====================

  Future<void> logShare(String contentType, String itemId) =>
      logEvent('share', {
        'content_type': contentType,
        'item_id': itemId,
      });

  Future<void> logPurchase(double value, String currency) =>
      logEvent('purchase', {
        'value': value,
        'currency': currency,
      });

  Future<void> logFeatureAdoption(String featureName) =>
      logEvent('feature_adopted', {'feature_name': featureName});

  Future<void> logReferral(String referralCode) =>
      logEvent('referral_used', {'referral_code': referralCode});

  // ==================== User Behavior ====================

  Future<void> logButtonClick(String buttonName) =>
      logEvent('button_click', {'button_name': buttonName});

  Future<void> logFeatureUsage(String featureName) =>
      logEvent('feature_usage', {'feature_name': featureName});

  Future<void> logTimeSpent(String screenName, int durationSeconds) =>
      logEvent('time_spent', {
        'screen_name': screenName,
        'duration_seconds': durationSeconds,
      });

  // ==================== Performance Metrics ====================

  Future<void> _logAppLaunch() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      await logEvent('app_launch', {
        'app_version': packageInfo.version,
        'build_number': packageInfo.buildNumber,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('❌ Error logging app launch: $e');
    }
  }

  Future<void> logScreenLoadTime(String screenName, int durationMs) =>
      logEvent('screen_load_time', {
        'screen_name': screenName,
        'duration_ms': durationMs,
      });

  Future<void> logAPICall(String endpoint, int statusCode, int durationMs) =>
      logEvent('api_call', {
        'endpoint': endpoint,
        'status_code': statusCode,
        'duration_ms': durationMs,
      });

  /// ✅ Log backend API analysis performance
  Future<void> logBackendAnalysis({
    required String cropType,
    required int durationMs,
    required bool success,
    String? errorMessage,
  }) => logEvent('backend_analysis', {
    'crop_type': cropType,
    'duration_ms': durationMs,
    'success': success,
    'error_message': errorMessage,
  });

  Future<void> logMLInference(String modelName, int durationMs) =>
      logEvent('ml_inference', {
        'model_name': modelName,
        'duration_ms': durationMs,
      });

  // ==================== Error Tracking ====================

  Future<void> logError(
      String errorType,
      String message, {
        String? screen,
        String? stackTrace,
      }) => logEvent('error', {
    'error_type': errorType,
    'message': message,
    'screen': screen,
    'stack_trace': stackTrace,
  });

  Future<void> logCrash(String message, String stackTrace) =>
      logEvent('crash', {
        'message': message,
        'stack_trace': stackTrace,
      });

  // ==================== Session Tracking ====================

  Future<void> logSessionStart() async {
    _sessionStartTime = DateTime.now();
    await logEvent('session_start', {
      'timestamp': _sessionStartTime!.toIso8601String(),
    });
  }

  Future<void> logSessionEnd() async {
    if (_sessionStartTime == null) return;

    final duration = DateTime.now().difference(_sessionStartTime!).inSeconds;
    await logEvent('session_end', {'duration_seconds': duration});
    _sessionStartTime = null;
  }

  Future<void> logActiveUser() =>
      logEvent('active_user', {
        'timestamp': DateTime.now().toIso8601String(),
      });

  // ==================== Custom Events ====================

  Future<void> logWeatherEvent(String condition, double temperature) =>
      logEvent('weather_event', {
        'condition': condition,
        'temperature': temperature,
      });

  Future<void> logNotificationReceived(String title) =>
      logEvent('notification_received', {'title': title});

  Future<void> logSettingsChange(String settingName, String newValue) =>
      logEvent('settings_change', {
        'setting_name': settingName,
        'new_value': newValue,
      });

  // ==================== User Properties ====================

  Future<void> setUserType(String type) =>
      setUserProperty('user_type', type);

  Future<void> setUserLocation(String location) =>
      setUserProperty('location', location);

  Future<void> setLanguagePreference(String language) =>
      setUserProperty('language', language);

  Future<void> setAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      await setUserProperty('app_version', packageInfo.version);
    } catch (e) {
      debugPrint('❌ Error setting app version: $e');
    }
  }

  Future<void> setDeviceType() async {
    final deviceInfo = DeviceInfoPlugin();
    String deviceType = 'unknown';

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceType = '${androidInfo.manufacturer} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceType = '${iosInfo.name} ${iosInfo.model}';
      }
    } catch (e) {
      debugPrint('❌ Error getting device type: $e');
    }

    await setUserProperty('device_type', deviceType);
  }

  Future<void> setSubscriptionStatus(String status) =>
      setUserProperty('subscription_status', status);

  // ==================== Analytics Summary ====================

  Future<Map<String, dynamic>> getAnalyticsSummary() async {
    if (!_initialized) {
      return {'error': 'Analytics not initialized'};
    }

    try {
      final snapshot = await _firestore
          .collection('analytics')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      return {
        'total_events': snapshot.docs.length,
        'recent_events': snapshot.docs.map((doc) => doc.data()).toList(),
        'session_start': _sessionStartTime?.toIso8601String(),
        'user_id': _userId,
      };
    } catch (e) {
      debugPrint('❌ Error getting analytics summary: $e');
      return {'error': e.toString()};
    }
  }

  Future<void> exportAnalyticsData() async {
    if (!_initialized) return;

    try {
      final snapshot = await _firestore.collection('analytics').get();
      final data = snapshot.docs.map((doc) => doc.data()).toList();
      debugPrint('📊 Exported Analytics Data: ${data.length} records');
      // TODO: Implement actual export (CSV, JSON file, etc.)
    } catch (e) {
      debugPrint('❌ Error exporting analytics data: $e');
    }
  }

  // ==================== Helper Methods ====================

  Future<void> _saveEventToFirestore(
      String eventName,
      Map<String, dynamic>? parameters,
      ) async {
    try {
      await _firestore.collection('analytics').add({
        'event_name': eventName,
        'parameters': parameters ?? {},
        'user_id': _userId,
        'timestamp': FieldValue.serverTimestamp(),
        'platform': Platform.operatingSystem,
      });
    } catch (e) {
      debugPrint('❌ Error saving analytics event to Firestore: $e');
    }
  }

  // ==================== Getters ====================

  bool get isInitialized => _initialized;
  String? get userId => _userId;
  DateTime? get sessionStartTime => _sessionStartTime;
}