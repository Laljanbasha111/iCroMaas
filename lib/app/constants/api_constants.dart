/// API Constants for the Crop Analyzer app.
/// Contains all base URLs, endpoints, headers, configuration values,
/// and reusable constants for API communication.
class ApiConstants {
  // ============================================================
  // =============== API CONFIGURATION ==========================
  // ============================================================

  /// Base URLs for different environments
  static const String baseUrlDev = 'https://api-dev.cropanalyzer.com';
  static const String baseUrlStaging = 'https://api-staging.cropanalyzer.com';
  static const String baseUrlProd = 'https://api.cropanalyzer.com';

  /// API version
  static const String apiVersion = '/v1';

  /// Timeout durations (in milliseconds)
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 20000;
  static const int sendTimeout = 20000;

  /// Retry configuration
  static const int maxRetries = 3;
  static const int retryDelayMs = 2000;

  // ============================================================
  // =============== AUTHENTICATION ENDPOINTS ===================
  // ============================================================

  static const String login = '/authentication/login';
  static const String register = '/authentication/register';
  static const String logout = '/authentication/logout';
  static const String refreshToken = '/authentication/refresh-token';
  static const String forgotPassword = '/authentication/forgot-password';
  static const String resetPassword = '/authentication/reset-password';
  static const String verifyEmail = '/authentication/verify-email';
  static const String changePassword = '/authentication/change-password';

  // ============================================================
  // =============== USER ENDPOINTS =============================
  // ============================================================

  static const String getProfile = '/user/profile';
  static const String updateProfile = '/user/update';
  static const String uploadAvatar = '/user/avatar';
  static const String deleteAccount = '/user/delete';
  static const String getUserStats = '/user/stats';

  // ============================================================
  // =============== CROP ENDPOINTS =============================
  // ============================================================

  static const String getAllCrops = '/crops';
  static const String getCropById = '/crops/{id}';
  static const String createCrop = '/crops/create';
  static const String updateCrop = '/crops/update/{id}';
  static const String deleteCrop = '/crops/delete/{id}';
  static const String getCropHistory = '/crops/{id}/history';
  static const String getCropAnalytics = '/crops/{id}/analytics';

  // ============================================================
  // =============== ANALYSIS ENDPOINTS =========================
  // ============================================================

  static const String analyzeImage = '/analysis/analyze';
  static const String getAnalysisById = '/analysis/{id}';
  static const String getAnalysisHistory = '/analysis/history';
  static const String deleteAnalysis = '/analysis/delete/{id}';
  static const String exportAnalysis = '/analysis/export/{id}';
  static const String getDiseaseDetection = '/analysis/{id}/disease';
  static const String getHealthAssessment = '/analysis/{id}/health';

  // ============================================================
  // =============== FIELD ENDPOINTS ============================
  // ============================================================

  static const String getAllFields = '/fields';
  static const String getFieldById = '/fields/{id}';
  static const String createField = '/fields/create';
  static const String updateField = '/fields/update/{id}';
  static const String deleteField = '/fields/delete/{id}';
  static const String getFieldCrops = '/fields/{id}/crops';

  // ============================================================
  // =============== WEATHER ENDPOINTS ==========================
  // ============================================================

  static const String getCurrentWeather = '/weather/current';
  static const String getWeatherForecast = '/weather/forecast';
  static const String getWeatherHistory = '/weather/history';
  static const String getWeatherAlerts = '/weather/alerts';

  // ============================================================
  // =============== RECOMMENDATION ENDPOINTS ===================
  // ============================================================

  static const String getRecommendations = '/recommendations';
  static const String getFertilizerRecommendations =
      '/recommendations/fertilizer';
  static const String getPesticideRecommendations =
      '/recommendations/pesticide';
  static const String getIrrigationRecommendations =
      '/recommendations/irrigation';

  // ============================================================
  // =============== REPORT ENDPOINTS ===========================
  // ============================================================

  static const String generateReport = '/reports/generate';
  static const String getReportById = '/reports/{id}';
  static const String getAllReports = '/reports';
  static const String downloadReport = '/reports/{id}/download';
  static const String shareReport = '/reports/{id}/share';

  // ============================================================
  // =============== NOTIFICATION ENDPOINTS =====================
  // ============================================================

  static const String getNotifications = '/notifications';
  static const String markNotificationAsRead = '/notifications/{id}/read';
  static const String deleteNotification = '/notifications/{id}/delete';
  static const String getNotificationSettings = '/notifications/settings';
  static const String updateNotificationSettings =
      '/notifications/settings/update';

  // ============================================================
  // =============== STORAGE ENDPOINTS ==========================
  // ============================================================

  static const String uploadImage = '/storage/upload/image';
  static const String uploadFile = '/storage/upload/file';
  static const String deleteFile = '/storage/delete/{id}';
  static const String getFileUrl = '/storage/file/{id}/url';

  // ============================================================
  // =============== API HEADERS ================================
  // ============================================================

  static const String headerContentType = 'Content-Type';
  static const String headerAuthorization = 'Authorization';
  static const String headerAccept = 'Accept';
  static const String headerApiKey = 'x-api-key';

  static const String contentTypeJson = 'application/json';
  static const String contentTypeMultipart = 'multipart/form-data';
  static const String acceptJson = 'application/json';

  // ============================================================
  // =============== HTTP STATUS CODES ==========================
  // ============================================================

  static const int statusOk = 200;
  static const int statusCreated = 201;
  static const int statusNoContent = 204;
  static const int statusBadRequest = 400;
  static const int statusUnauthorized = 401;
  static const int statusForbidden = 403;
  static const int statusNotFound = 404;
  static const int statusConflict = 409;
  static const int statusInternalServerError = 500;
  static const int statusServiceUnavailable = 503;

  // ============================================================
  // =============== ERROR MESSAGES =============================
  // ============================================================

  static const String errorNetwork =
      'Network error. Please check your internet connection.';
  static const String errorTimeout =
      'Request timed out. Please try again later.';
  static const String errorUnauthorized =
      'Unauthorized access. Please log in again.';
  static const String errorForbidden =
      'Access denied. You do not have permission.';
  static const String errorNotFound = 'Requested resource not found.';
  static const String errorServer =
      'Server error. Please try again later.';
  static const String errorValidation =
      'Validation failed. Please check your input.';
  static const String errorUnknown =
      'An unknown error occurred. Please try again.';

  // ============================================================
  // =============== API KEYS AND SECRETS =======================
  // ============================================================

  static const String apiKey = 'YOUR_API_KEY_HERE';
  static const String secretKey = 'YOUR_SECRET_KEY_HERE';

  // ============================================================
  // =============== PAGINATION CONFIGURATION ===================
  // ============================================================

  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // ============================================================
  // =============== FILE UPLOAD CONFIGURATION ==================
  // ============================================================

  static const int maxFileSizeMB = 10;
  static const List<String> allowedFileTypes = [
    'jpg',
    'jpeg',
    'png',
    'pdf',
  ];
  static const int imageQuality = 85;

  // ============================================================
  // =============== CACHE CONFIGURATION ========================
  // ============================================================

  static const Duration cacheDuration = Duration(hours: 1);

  static const String cacheKeyUserProfile = 'cache_user_profile';
  static const String cacheKeyCrops = 'cache_crops';
  static const String cacheKeyWeather = 'cache_weather';
  static const String cacheKeyRecommendations = 'cache_recommendations';
  static const String cacheKeyReports = 'cache_reports';

  // ============================================================
  // =============== HELPER METHODS =============================
  // ============================================================

  /// Returns the full API URL for a given endpoint.
  static String buildUrl(String endpoint, {bool useProd = true}) {
    final base = useProd ? baseUrlProd : baseUrlDev;
    return '$base$apiVersion$endpoint';
  }

  /// Replaces path parameters in endpoints (e.g., {id}) with actual values.
  static String replacePathParams(String endpoint, Map<String, dynamic> params) {
    String result = endpoint;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value.toString());
    });
    return result;
  }
}