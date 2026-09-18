import 'env.dart';

/// Global application configuration for Crop Analyzer app.
/// Provides environment-aware constants and settings.
class AppConfig {
  static const String appName = 'Crop Analyzer';
  static const String version = '1.0.0';
  static const String buildNumber = '1';

  // ✅ Changed from const to static - allows runtime values
  static String get apiBaseUrl => Env.baseUrl;
  static String get firebaseProjectId => Env.firebaseProjectId;

  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  static const String supportEmail = 'support@cropanalyzer.com';
  static const String privacyPolicyUrl = 'https://cropanalyzer.com/privacy';
  static const String termsUrl = 'https://cropanalyzer.com/terms';

  static const bool enableCrashlytics = true;
  static const bool enableAnalytics = true;

  static const String defaultLanguage = 'en';
  static const List<String> supportedLanguages = ['en', 'te', 'hi'];

  static const String defaultCurrency = 'INR';
  static const String defaultCountry = 'India';

  // ✅ Changed from const to static - allows runtime values
  static bool get enableDebugLogs => Env.isDev;

  // ✅ Changed from const to static - allows runtime values
  static Map<String, dynamic> get info => {
    'App Name': appName,
    'Version': version,
    'Environment': Env.environment,
    'Base URL': apiBaseUrl,
    'Firebase Project': firebaseProjectId,
  };
}