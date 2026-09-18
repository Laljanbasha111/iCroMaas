import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// ✅ Comment out imports until services are created
// import '../models/user_model.dart';
// import '../database/cache_service.dart';
// import '../database/secure_storage_service.dart';
// import '../network/network_info.dart';

/// AppProvider manages global application state, initialization, user session,
/// connectivity, and lifecycle events for the Crop Analyzer app.
class AppProvider extends ChangeNotifier with WidgetsBindingObserver {
  // ✅ Comment out until services are created
  // final CacheService _cacheService = CacheService();
  // final SecureStorageService _secureStorage = SecureStorageService();
  // final NetworkInfo _networkInfo = NetworkInfo();

  bool _isInitialized = false;
  bool _isLoading = false;
  bool _isFirstLaunch = false;
  bool _isOnline = true;
  String? _error;
  String _appVersion = '';
  String _buildNumber = '';
  // UserModel? _currentUser;
  dynamic _currentUser; // ✅ Temporary until UserModel is created
  DateTime? _lastSyncTime;

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  bool get isFirstLaunch => _isFirstLaunch;
  bool get isOnline => _isOnline;
  String? get error => _error;
  String get appVersion => _appVersion;
  String get buildNumber => _buildNumber;
  dynamic get currentUser => _currentUser;
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Initialize the app on startup.
  Future<void> initialize() async {
    _setLoading(true);
    try {
      WidgetsBinding.instance.addObserver(this);
      await _loadPreferences();
      await checkFirstLaunch();
      await loadAppInfo();
      await checkConnectivity();
      await _loadUserSession();
      _setInitialized(true);
      _error = null;
    } catch (e) {
      _handleError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Check if this is the first time the app is launched.
  Future<void> checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    _isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    notifyListeners();
  }

  /// Mark onboarding as completed.
  Future<void> markFirstLaunchComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstLaunch', false);
    _isFirstLaunch = false;
    notifyListeners();
  }

  /// Load app version and build number.
  Future<void> loadAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    _appVersion = info.version;
    _buildNumber = info.buildNumber;
    notifyListeners();
  }

  /// Check internet connectivity.
  Future<void> checkConnectivity() async {
    // ✅ Fixed: Handle List<ConnectivityResult>
    final connectivityResult = await Connectivity().checkConnectivity();
    _isOnline = !connectivityResult.contains(ConnectivityResult.none);
    notifyListeners();
  }

  /// Sync local data with the server.
  Future<void> syncData() async {
    if (!_isOnline) return;
    _setLoading(true);
    try {
      // Placeholder for sync logic (upload local data, fetch updates, etc.)
      await Future.delayed(const Duration(seconds: 2));
      updateLastSync();
      _error = null;
    } catch (e) {
      _handleError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Clear app cache and temporary data.
  Future<void> clearCache() async {
    _setLoading(true);
    try {
      // ✅ Uncomment when CacheService is ready
      // await _cacheService.clear();
      // await _secureStorage.clear();
      _error = null;
    } catch (e) {
      _handleError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Reset app to default state.
  Future<void> resetApp() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await clearCache();
      _currentUser = null;
      _isFirstLaunch = true;
      _lastSyncTime = null;
      _error = null;
      notifyListeners();
    } catch (e) {
      _handleError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Update last sync timestamp.
  void updateLastSync() {
    _lastSyncTime = DateTime.now();
    notifyListeners();
  }

  /// Set current user session.
  Future<void> setUser(dynamic user) async {
    _currentUser = user;
    // ✅ Uncomment when SecureStorageService is ready
    // await _secureStorage.write('user_session', user.toJson());
    notifyListeners();
  }

  /// Clear current user session.
  Future<void> clearUser() async {
    _currentUser = null;
    // ✅ Uncomment when SecureStorageService is ready
    // await _secureStorage.delete('user_session');
    notifyListeners();
  }

  /// Display an error message.
  void showError(String message) {
    _error = message;
    notifyListeners();
  }

  /// Clear error state.
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Called when app starts.
  void onAppStart() {
    log('App started');
    checkConnectivity();
  }

  /// Called when app resumes.
  void onAppResume() {
    log('App resumed');
    checkConnectivity();
  }

  /// Called when app pauses.
  void onAppPause() {
    log('App paused');
  }

  /// Called when app is detached or closed.
  void onAppDetach() {
    log('App detached');
    WidgetsBinding.instance.removeObserver(this);
  }

  /// Lifecycle event handler.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        onAppResume();
        break;
      case AppLifecycleState.paused:
        onAppPause();
        break;
      case AppLifecycleState.detached:
        onAppDetach();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden: // ✅ Added missing case
        break;
    }
  }

  /// Helper: Set loading state.
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Helper: Set initialized state.
  void _setInitialized(bool value) {
    _isInitialized = value;
    notifyListeners();
  }

  /// Helper: Handle errors.
  void _handleError(dynamic error) {
    _error = error.toString();
    log('AppProvider Error: $_error');
    _isLoading = false;
    notifyListeners();
  }

  /// Helper: Load preferences.
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
  }

  /// Helper: Save preferences (currently unused).
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstLaunch', _isFirstLaunch);
  }

  /// Helper: Load user session from secure storage.
  Future<void> _loadUserSession() async {
    // ✅ Uncomment when SecureStorageService is ready
    // final json = await _secureStorage.read('user_session');
    // if (json != null) {
    //   _currentUser = UserModel.fromJson(json);
    // }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}