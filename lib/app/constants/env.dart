import 'package:flutter_dotenv/flutter_dotenv.dart';  // ✅ FIXED: Added 'i' at the beginning

/// Environment configuration for Crop Analyzer app.
/// Supports multiple environments (dev, staging, prod).
class Env {
  static const String environment = String.fromEnvironment('ENV', defaultValue: 'dev');

  static bool get isDev => environment == 'dev';
  static bool get isStaging => environment == 'staging';
  static bool get isProd => environment == 'prod';

  static String get baseUrl {
    switch (environment) {
      case 'staging':
        return 'https://staging.api.cropanalyzer.com';
      case 'prod':
        return 'https://api.cropanalyzer.com';
      default:
        return 'https://dev.api.cropanalyzer.com';
    }
  }

  static String get firebaseProjectId {
    switch (environment) {
      case 'staging':
        return 'crop-analyzer-staging';
      case 'prod':
        return 'crop-analyzer-prod';
      default:
        return 'crop-analyzer-dev';
    }
  }

  // ============================================================================
  // API KEYS - Loaded from .env file
  // ============================================================================

  /// Google Gemini AI API Key
  static String get geminiApiKey =>
      dotenv.env['GEMINI_API_KEY'] ?? '';

  /// Google Maps API Key
  static String get googleMapsApiKey =>
      dotenv.env['GOOGLE_MAPS_API_KEY'] ?? 'YOUR_GOOGLE_MAPS_API_KEY';

  /// Weather API Key
  static String get weatherApiKey =>
      dotenv.env['WEATHER_API_KEY'] ?? 'YOUR_WEATHER_API_KEY';

  /// OpenAI API Key (optional, if you want to use ChatGPT instead)
  static String get openAiApiKey =>
      dotenv.env['OPENAI_API_KEY'] ?? '';

  // ============================================================================
  // VALIDATION HELPERS
  // ============================================================================

  /// Check if Gemini AI is properly configured
  static bool get isGeminiConfigured => geminiApiKey.isNotEmpty;

  /// Check if Google Maps is properly configured
  static bool get isGoogleMapsConfigured =>
      googleMapsApiKey.isNotEmpty && googleMapsApiKey != 'YOUR_GOOGLE_MAPS_API_KEY';

  /// Check if Weather API is properly configured
  static bool get isWeatherConfigured =>
      weatherApiKey.isNotEmpty && weatherApiKey != 'YOUR_WEATHER_API_KEY';

  // ============================================================================
  // DEBUG HELPERS
  // ============================================================================

  /// Print environment configuration (for debugging)
  static void printConfig() {
    print('🌍 Environment: $environment');
    print('🔗 Base URL: $baseUrl');
    print('🔥 Firebase Project: $firebaseProjectId');
    print('🤖 Gemini AI: ${isGeminiConfigured ? "✅ Configured" : "❌ Not configured"}');
    print('🗺️  Google Maps: ${isGoogleMapsConfigured ? "✅ Configured" : "❌ Not configured"}');
    print('🌤️  Weather API: ${isWeatherConfigured ? "✅ Configured" : "❌ Not configured"}');
  }
}