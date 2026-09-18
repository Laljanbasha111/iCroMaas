import 'package:flutter/material.dart';

/// App-wide constants for the Crop Analyzer app.
/// Contains configuration values, theme colors, typography, assets,
/// feature flags, and other reusable constants.
class AppConstants {
  // ============================================================
  // =============== APP INFORMATION ============================
  // ============================================================

  static const String appName = 'Crop Analyzer';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Crop Analyzer helps farmers and agronomists analyze crop health, detect diseases, and optimize yield using AI-powered image analysis.';
  static const String packageName = 'com.cropanalyzer.app';
  static const String developerName = 'AgriTech Solutions';
  static const String developerWebsite = 'https://www.cropanalyzer.com';
  static const String supportEmail = 'support@cropanalyzer.com';
  static const String contactNumber = '+1 (800) 555-0199';
  static const String websiteUrl = 'https://www.cropanalyzer.com';

  // ============================================================
  // =============== THEME CONFIGURATION ========================
  // ============================================================

  // Primary Colors
  static const Color primaryColor = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF60AD5E);
  static const Color primaryDark = Color(0xFF005005);

  // Secondary Colors
  static const Color secondaryColor = Color(0xFF81C784);
  static const Color secondaryLight = Color(0xFFB2FAB4);
  static const Color secondaryDark = Color(0xFF519657);

  // Accent Colors
  static const Color accentColor = Color(0xFF43A047);
  static const Color accentLight = Color(0xFF76D275);
  static const Color accentDark = Color(0xFF00701A);

  // Background Colors
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Colors.white;
  static const Color scaffoldBackground = Color(0xFFF9FAFB);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Colors.white;

  // Status Colors
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF388E3C);
  static const Color warningColor = Color(0xFFFBC02D);
  static const Color infoColor = Color(0xFF1976D2);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF81C784), Color(0xFF388E3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================================
  // =============== TYPOGRAPHY ================================
  // ============================================================

  static const String fontFamilyPrimary = 'Poppins';
  static const String fontFamilySecondary = 'Roboto';

  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 20.0;
  static const double fontSizeExtraLarge = 28.0;

  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightBold = FontWeight.w700;

  static const double lineHeightTight = 1.1;
  static const double lineHeightNormal = 1.4;
  static const double lineHeightRelaxed = 1.6;

  // ============================================================
  // =============== SPACING & SIZING ===========================
  // ============================================================

  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  static const double marginSmall = 8.0;
  static const double marginMedium = 16.0;
  static const double marginLarge = 24.0;

  static const double borderRadiusSmall = 6.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 20.0;

  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 28.0;
  static const double iconSizeLarge = 36.0;

  static const double buttonHeightSmall = 40.0;
  static const double buttonHeightMedium = 48.0;
  static const double buttonHeightLarge = 56.0;

  static const double cardElevation = 4.0;
  static const double cardCornerRadius = 12.0;

  // ============================================================
  // =============== ANIMATION DURATIONS ========================
  // ============================================================

  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 600);

  static const Duration transitionShort = Duration(milliseconds: 250);
  static const Duration transitionMedium = Duration(milliseconds: 400);
  static const Duration transitionLong = Duration(milliseconds: 700);

  // ============================================================
  // =============== IMAGE ASSETS PATHS =========================
  // ============================================================

  static const String logoPrimary = 'assets/images/logo_primary.png';
  static const String logoSecondary = 'assets/images/logo_secondary.png';
  static const String appIcon = 'assets/icons/app_icon.png';

  static const String placeholderImage = 'assets/images/placeholder.png';
  static const String backgroundImage = 'assets/images/background.jpg';
  static const String onboardingImage1 = 'assets/images/onboarding1.png';
  static const String onboardingImage2 = 'assets/images/onboarding2.png';
  static const String onboardingImage3 = 'assets/images/onboarding3.png';

  // ============================================================
  // =============== STORAGE KEYS ===============================
  // ============================================================

  // SharedPreferences Keys
  static const String keyUserToken = 'user_token';
  static const String keyUserProfile = 'user_profile';
  static const String keyAppTheme = 'app_theme';
  static const String keyLanguage = 'language';
  static const String keyOnboardingShown = 'onboarding_shown';

  // Secure Storage Keys
  static const String keySecureAuthToken = 'secure_auth_token';
  static const String keySecureRefreshToken = 'secure_refresh_token';

  // Cache Keys
  static const String cacheWeatherData = 'cache_weather_data';
  static const String cacheCropData = 'cache_crop_data';
  static const String cacheAnalysisResults = 'cache_analysis_results';

  // ============================================================
  // =============== APP SETTINGS ===============================
  // ============================================================

  static const String defaultLanguage = 'en';
  static const List<String> supportedLanguages = ['en', 'es', 'fr', 'hi'];
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String currencyFormat = 'USD';

  // ============================================================
  // =============== FEATURE FLAGS ==============================
  // ============================================================

  static const bool enableCropAnalysis = true;
  static const bool enableWeatherIntegration = true;
  static const bool enableOfflineMode = true;
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = true;
  static const bool debugMode = false;

  // ============================================================
  // =============== CROP TYPES ================================
  // ============================================================

  static const List<String> supportedCrops = [
    'Wheat',
    'Rice',
    'Corn',
    'Soybean',
    'Cotton',
    'Sugarcane',
    'Potato',
    'Tomato',
    'Barley',
    'Maize',
  ];

  static const Map<String, List<String>> cropCategories = {
    'Cereals': ['Wheat', 'Rice', 'Corn', 'Barley', 'Maize'],
    'Legumes': ['Soybean'],
    'Root Crops': ['Potato'],
    'Vegetables': ['Tomato'],
    'Industrial Crops': ['Cotton', 'Sugarcane'],
  };

  // ============================================================
  // =============== DISEASE TYPES ==============================
  // ============================================================

  static const List<String> commonDiseases = [
    'Leaf Blight',
    'Rust',
    'Powdery Mildew',
    'Bacterial Wilt',
    'Root Rot',
    'Downy Mildew',
    'Anthracnose',
  ];

  static const Map<String, String> diseaseSeverityLevels = {
    'Low': 'Minor infection, minimal yield impact.',
    'Moderate': 'Visible symptoms, moderate yield loss.',
    'High': 'Severe infection, significant yield loss.',
    'Critical': 'Widespread infection, crop failure risk.',
  };

  // ============================================================
  // =============== HEALTH STATUS ==============================
  // ============================================================

  static const List<String> healthStatuses = [
    'Healthy',
    'Moderate',
    'Poor',
    'Critical',
  ];

  static const Map<String, Color> healthStatusColors = {
    'Healthy': Colors.green,
    'Moderate': Colors.orange,
    'Poor': Colors.redAccent,
    'Critical': Colors.red,
  };

  // ============================================================
  // =============== ANALYSIS SETTINGS ==========================
  // ============================================================

  static const double confidenceThreshold = 0.75;
  static const int maxImageSizeMB = 10;
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png'];

  // ============================================================
  // =============== NOTIFICATION SETTINGS ======================
  // ============================================================

  static const List<String> notificationTypes = [
    'General',
    'Weather Alert',
    'Crop Health',
    'System Update',
  ];

  static const Map<String, bool> defaultNotificationSettings = {
    'General': true,
    'Weather Alert': true,
    'Crop Health': true,
    'System Update': false,
  };

  // ============================================================
  // =============== VALIDATION RULES ===========================
  // ============================================================

  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 20;

  static const String emailRegex =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String passwordRegex =
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';

  static const String passwordRequirement =
      'Password must contain at least 8 characters, including uppercase, lowercase, number, and special character.';

  // ============================================================
  // =============== URLS =======================================
  // ============================================================

  static const String termsOfServiceUrl =
      'https://www.cropanalyzer.com/terms';
  static const String privacyPolicyUrl =
      'https://www.cropanalyzer.com/privacy';
  static const String helpCenterUrl =
      'https://www.cropanalyzer.com/help';
  static const String faqUrl = 'https://www.cropanalyzer.com/faq';

  // ============================================================
  // =============== SOCIAL MEDIA LINKS =========================
  // ============================================================

  static const String facebookUrl = 'https://facebook.com/cropanalyzer';
  static const String twitterUrl = 'https://twitter.com/cropanalyzer';
  static const String instagramUrl = 'https://instagram.com/cropanalyzer';
  static const String linkedinUrl = 'https://linkedin.com/company/cropanalyzer';
  static const String youtubeUrl = 'https://youtube.com/@cropanalyzer';

  // ============================================================
  // =============== MAP CONFIGURATION ==========================
  // ============================================================

  static const double defaultLatitude = 28.6139;
  static const double defaultLongitude = 77.2090;
  static const double defaultZoomLevel = 10.0;
  static const double minZoomLevel = 5.0;
  static const double maxZoomLevel = 18.0;

  // ============================================================
  // =============== PAGINATION SETTINGS ========================
  // ============================================================

  static const int itemsPerPage = 20;
  static const int loadMoreThreshold = 5;
}