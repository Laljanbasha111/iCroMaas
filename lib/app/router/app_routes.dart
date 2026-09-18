import 'package:flutter/material.dart';

/// Defines all route names and paths used in the Crop Analyzer app.
/// Centralized route management for consistency and maintainability.
class AppRoutes {
  // Authentication
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String otp = '/otp';
  static const String forgotPassword = '/forgot-password';
  static const String changePassword = '/change-password';

  // Home & Dashboard
  static const String home = '/home';
  static const String dashboard = '/dashboard';

  // Analysis
  static const String analysis = '/analysis';
  static const String analyticsDashboard = '/analysis/dashboard';
  static const String gallery = '/analysis/gallery';

  // Reports
  static const String reportGenerator = '/reports/generator';
  static const String reportHistory = '/reports/history';

  // Weather
  static const String weatherForecast = '/weather/forecast';
  static const String farmingAdvice = '/weather/advice';

  // Profile
  static const String editProfile = '/profile/edit';
  static const String account = '/profile/account';

  // Settings
  static const String settings = '/settings';

  // Help & Support
  static const String help = '/help';

  // Libraries
  static const String diseaseLibrary = '/library/disease';
  static const String fertilizer = '/library/fertilizer';
  static const String irrigation = '/library/irrigation';

  // Calendar & Notifications
  static const String calendar = '/calendar';
  static const String notifications = '/notifications';

  // Admin
  static const String admin = '/admin';

  /// Returns a map of all route names for debugging or analytics.
  static Map<String, String> get allRoutes => {
    'Splash': splash,
    'Onboarding': onboarding,
    'Login': login,
    'Signup': signup,
    'OTP': otp,
    'ForgotPassword': forgotPassword,
    'ChangePassword': changePassword,
    'Home': home,
    'Dashboard': dashboard,
    'Analysis': analysis,
    'AnalyticsDashboard': analyticsDashboard,
    'Gallery': gallery,
    'ReportGenerator': reportGenerator,
    'ReportHistory': reportHistory,
    'WeatherForecast': weatherForecast,
    'FarmingAdvice': farmingAdvice,
    'EditProfile': editProfile,
    'Account': account,
    'Settings': settings,
    'Help': help,
    'DiseaseLibrary': diseaseLibrary,
    'Fertilizer': fertilizer,
    'Irrigation': irrigation,
    'Calendar': calendar,
    'Notifications': notifications,
    'Admin': admin,
  };
}