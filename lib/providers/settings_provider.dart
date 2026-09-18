import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// SettingsProvider manages app preferences, theme, notifications,
/// language, privacy, and data usage for the Crop Analyzer app.
class SettingsProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  // Theme
  bool _isDarkMode = false;
  ThemeMode _themeMode = ThemeMode.light;
  Color _primaryColor = Colors.green;

  // Notifications
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 8, minute: 0);

  // Language
  String _language = 'en';

  // Data & Storage
  bool _autoSyncEnabled = true;
  String _dataUsageMode = 'wifi_only';
  int _imageQuality = 80;
  double _cacheSize = 0.0;

  // Privacy
  bool _analyticsEnabled = true;
  bool _crashReportsEnabled = true;
  bool _locationTrackingEnabled = true;

  // App Info
  String _appVersion = '';
  String _buildNumber = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  TimeOfDay get notificationTime => _notificationTime;
  String get language => _language;
  bool get autoSyncEnabled => _autoSyncEnabled;
  String get dataUsageMode => _dataUsageMode;
  double get cacheSize => _cacheSize;
  int get imageQuality => _imageQuality;
  bool get analyticsEnabled => _analyticsEnabled;
  bool get crashReportsEnabled => _crashReportsEnabled;
  bool get locationTrackingEnabled => _locationTrackingEnabled;
  String get appVersion => _appVersion;
  String get buildNumber => _buildNumber;

  /// Initialize settings on app start.
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await loadSettings();
      await loadAppInfo();
      await getCacheSize();
      _error = null;
    } catch (e) {
      _handleError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Load settings from SharedPreferences.
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = _getBool(prefs, 'isDarkMode', false);
    _notificationsEnabled = _getBool(prefs, 'notificationsEnabled', true);
    _soundEnabled = _getBool(prefs, 'soundEnabled', true);
    _vibrationEnabled = _getBool(prefs, 'vibrationEnabled', true);
    _language = _getString(prefs, 'language', 'en');
    _autoSyncEnabled = _getBool(prefs, 'autoSyncEnabled', true);
    _dataUsageMode = _getString(prefs, 'dataUsageMode', 'wifi_only');
    _analyticsEnabled = _getBool(prefs, 'analyticsEnabled', true);
    _crashReportsEnabled = _getBool(prefs, 'crashReportsEnabled', true);
    _locationTrackingEnabled = _getBool(prefs, 'locationTrackingEnabled', true);
    _imageQuality = _getInt(prefs, 'imageQuality', 80);
    _themeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  /// Save settings to SharedPreferences.
  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await _saveBool(prefs, 'isDarkMode', _isDarkMode);
    await _saveBool(prefs, 'notificationsEnabled', _notificationsEnabled);
    await _saveBool(prefs, 'soundEnabled', _soundEnabled);
    await _saveBool(prefs, 'vibrationEnabled', _vibrationEnabled);
    await _saveString(prefs, 'language', _language);
    await _saveBool(prefs, 'autoSyncEnabled', _autoSyncEnabled);
    await _saveString(prefs, 'dataUsageMode', _dataUsageMode);
    await _saveBool(prefs, 'analyticsEnabled', _analyticsEnabled);
    await _saveBool(prefs, 'crashReportsEnabled', _crashReportsEnabled);
    await _saveBool(prefs, 'locationTrackingEnabled', _locationTrackingEnabled);
    await _saveInt(prefs, 'imageQuality', _imageQuality);
  }

  /// Reset all settings to defaults.
  Future<void> resetSettings() async {
    _isDarkMode = false;
    _themeMode = ThemeMode.light;
    _notificationsEnabled = true;
    _soundEnabled = true;
    _vibrationEnabled = true;
    _language = 'en';
    _autoSyncEnabled = true;
    _dataUsageMode = 'wifi_only';
    _analyticsEnabled = true;
    _crashReportsEnabled = true;
    _locationTrackingEnabled = true;
    _imageQuality = 80;
    await saveSettings();
    notifyListeners();
  }

  /// Export settings as JSON.
  Future<String> exportSettings() async {
    final data = {
      'isDarkMode': _isDarkMode,
      'notificationsEnabled': _notificationsEnabled,
      'soundEnabled': _soundEnabled,
      'vibrationEnabled': _vibrationEnabled,
      'language': _language,
      'autoSyncEnabled': _autoSyncEnabled,
      'dataUsageMode': _dataUsageMode,
      'analyticsEnabled': _analyticsEnabled,
      'crashReportsEnabled': _crashReportsEnabled,
      'locationTrackingEnabled': _locationTrackingEnabled,
      'imageQuality': _imageQuality,
    };
    return jsonEncode(data);
  }

  /// Import settings from JSON.
  Future<void> importSettings(String json) async {
    try {
      final data = jsonDecode(json);
      _isDarkMode = data['isDarkMode'] ?? false;
      _notificationsEnabled = data['notificationsEnabled'] ?? true;
      _soundEnabled = data['soundEnabled'] ?? true;
      _vibrationEnabled = data['vibrationEnabled'] ?? true;
      _language = data['language'] ?? 'en';
      _autoSyncEnabled = data['autoSyncEnabled'] ?? true;
      _dataUsageMode = data['dataUsageMode'] ?? 'wifi_only';
      _analyticsEnabled = data['analyticsEnabled'] ?? true;
      _crashReportsEnabled = data['crashReportsEnabled'] ?? true;
      _locationTrackingEnabled = data['locationTrackingEnabled'] ?? true;
      _imageQuality = data['imageQuality'] ?? 80;
      await saveSettings();
      notifyListeners();
    } catch (e) {
      _handleError(e);
    }
  }

  // ---------------- THEME SETTINGS ----------------

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    _themeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
    saveSettings();
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _isDarkMode = mode == ThemeMode.dark;
    saveSettings();
    notifyListeners();
  }

  void setPrimaryColor(Color color) {
    _primaryColor = color;
    notifyListeners();
  }

  void resetTheme() {
    _isDarkMode = false;
    _themeMode = ThemeMode.light;
    _primaryColor = Colors.green;
    saveSettings();
    notifyListeners();
  }

  // ---------------- NOTIFICATION SETTINGS ----------------

  void toggleNotifications() {
    _notificationsEnabled = !_notificationsEnabled;
    saveSettings();
    notifyListeners();
  }

  void toggleSound() {
    _soundEnabled = !_soundEnabled;
    saveSettings();
    notifyListeners();
  }

  void toggleVibration() {
    _vibrationEnabled = !_vibrationEnabled;
    saveSettings();
    notifyListeners();
  }

  void setNotificationTime(TimeOfDay time) {
    _notificationTime = time;
    notifyListeners();
  }

  // ---------------- LANGUAGE SETTINGS ----------------

  void setLanguage(String languageCode) {
    _language = languageCode;
    saveSettings();
    notifyListeners();
  }

  List<Map<String, String>> getSupportedLanguages() {
    return [
      {'code': 'en', 'name': 'English'},
      {'code': 'hi', 'name': 'Hindi'},
      {'code': 'es', 'name': 'Spanish'},
      {'code': 'fr', 'name': 'French'},
      {'code': 'de', 'name': 'German'},
    ];
  }

  // ---------------- DATA & STORAGE ----------------

  void toggleAutoSync() {
    _autoSyncEnabled = !_autoSyncEnabled;
    saveSettings();
    notifyListeners();
  }

  void setDataUsageMode(String mode) {
    _dataUsageMode = mode;
    saveSettings();
    notifyListeners();
  }

  Future<void> clearCache() async {
    try {
      final tempDir = Directory.systemTemp;
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
      _cacheSize = 0.0;
      notifyListeners();
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> getCacheSize() async {
    try {
      final tempDir = Directory.systemTemp;
      double size = 0;
      if (tempDir.existsSync()) {
        size = await _calculateDirectorySize(tempDir);
      }
      _cacheSize = size / (1024 * 1024);
      notifyListeners();
    } catch (e) {
      _handleError(e);
    }
  }

  Future<double> _calculateDirectorySize(Directory dir) async {
    double total = 0;
    try {
      if (dir.existsSync()) {
        final files = dir.listSync(recursive: true, followLinks: false);
        for (var file in files) {
          if (file is File) {
            total += await file.length();
          }
        }
      }
    } catch (e) {
      log('Error calculating cache size: $e');
    }
    return total;
  }

  void setImageQuality(int quality) {
    _imageQuality = quality.clamp(10, 100);
    saveSettings();
    notifyListeners();
  }

  // ---------------- PRIVACY SETTINGS ----------------

  void toggleAnalytics() {
    _analyticsEnabled = !_analyticsEnabled;
    saveSettings();
    notifyListeners();
  }

  void toggleCrashReports() {
    _crashReportsEnabled = !_crashReportsEnabled;
    saveSettings();
    notifyListeners();
  }

  void toggleLocationTracking() {
    _locationTrackingEnabled = !_locationTrackingEnabled;
    saveSettings();
    notifyListeners();
  }

  // ---------------- APP INFO ----------------

  Future<void> loadAppInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      _appVersion = info.version;
      _buildNumber = info.buildNumber;
      notifyListeners();
    } catch (e) {
      _handleError(e);
    }
  }

  Future<bool> checkForUpdates() async {
    // Placeholder for update check logic
    await Future.delayed(const Duration(seconds: 1));
    return false;
  }

  // ---------------- HELPERS ----------------

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _handleError(dynamic error) {
    _error = error.toString();
    log('SettingsProvider Error: $_error');
    _isLoading = false;
    notifyListeners();
  }

  bool _getBool(SharedPreferences prefs, String key, bool defaultValue) {
    return prefs.getBool(key) ?? defaultValue;
  }

  String _getString(SharedPreferences prefs, String key, String defaultValue) {
    return prefs.getString(key) ?? defaultValue;
  }

  int _getInt(SharedPreferences prefs, String key, int defaultValue) {
    return prefs.getInt(key) ?? defaultValue;
  }

  Future<void> _saveBool(SharedPreferences prefs, String key, bool value) async {
    await prefs.setBool(key, value);
  }

  Future<void> _saveString(SharedPreferences prefs, String key, String value) async {
    await prefs.setString(key, value);
  }

  Future<void> _saveInt(SharedPreferences prefs, String key, int value) async {
    await prefs.setInt(key, value);
  }
}

