/// Firebase configuration and constants for the Crop Analyzer app.
/// Contains all Firebase-related configuration values, collection names,
/// field keys, storage paths, function names, and other reusable constants.
class FirebaseConstants {
  // ============================================================
  // =============== FIREBASE CONFIGURATION =====================
  // ============================================================

  static const String projectId = 'crop-analyzer-app';
  static const String androidAppId =
      '1:1234567890:android:abcdef1234567890abcdef';
  static const String iosAppId =
      '1:1234567890:ios:abcdef1234567890abcdef';
  static const String apiKey = 'AIzaSyA-EXAMPLE-KEY-1234567890abcdef';
  static const String storageBucket = 'crop-analyzer-app.appspot.com';
  static const String messagingSenderId = '1234567890';
  static const String databaseUrl =
      'https://crop-analyzer-app-default-rtdb.firebaseio.com';

  // ============================================================
  // =============== AUTHENTICATION =============================
  // ============================================================

  static const List<String> authProviders = [
    'password',
    'google.com',
    'facebook.com',
    'apple.com',
  ];

  static const List<String> signInMethods = [
    'emailLink',
    'emailPassword',
    'googleSignIn',
    'facebookSignIn',
    'appleSignIn',
  ];

  static const List<String> oauthScopes = [
    'email',
    'profile',
    'openid',
  ];

  // ============================================================
  // =============== FIRESTORE COLLECTIONS ======================
  // ============================================================

  static const String usersCollection = 'users';
  static const String cropsCollection = 'crops';
  static const String fieldsCollection = 'fields';
  static const String analysisCollection = 'analysis';
  static const String reportsCollection = 'reports';
  static const String notificationsCollection = 'notifications';
  static const String weatherCollection = 'weather';
  static const String recommendationsCollection = 'recommendations';
  static const String settingsCollection = 'settings';
  static const String logsCollection = 'logs';

  // ============================================================
  // =============== FIRESTORE DOCUMENT FIELDS ==================
  // ============================================================

  // Common fields
  static const String fieldId = 'id';
  static const String fieldCreatedAt = 'createdAt';
  static const String fieldUpdatedAt = 'updatedAt';
  static const String fieldDeletedAt = 'deletedAt';
  static const String fieldOwnerId = 'ownerId';
  static const String fieldStatus = 'status';
  static const String fieldIsActive = 'isActive';

  // User fields
  static const String userName = 'name';
  static const String userEmail = 'email';
  static const String userPhone = 'phone';
  static const String userAvatarUrl = 'avatarUrl';
  static const String userRole = 'role';
  static const String userLocation = 'location';
  static const String userPreferences = 'preferences';
  static const String userLastLogin = 'lastLogin';

  // Crop fields
  static const String cropName = 'name';
  static const String cropType = 'type';
  static const String cropVariety = 'variety';
  static const String cropHealthStatus = 'healthStatus';
  static const String cropFieldId = 'fieldId';
  static const String cropImageUrl = 'imageUrl';
  static const String cropPlantedDate = 'plantedDate';
  static const String cropHarvestDate = 'harvestDate';
  static const String cropYield = 'yield';
  static const String cropNotes = 'notes';

  // Analysis fields
  static const String analysisCropId = 'cropId';
  static const String analysisImageUrl = 'imageUrl';
  static const String analysisResult = 'result';
  static const String analysisConfidence = 'confidence';
  static const String analysisDiseaseDetected = 'diseaseDetected';
  static const String analysisHealthScore = 'healthScore';
  static const String analysisPerformedAt = 'performedAt';
  static const String analysisModelVersion = 'modelVersion';

  // Report fields
  static const String reportTitle = 'title';
  static const String reportDescription = 'description';
  static const String reportFileUrl = 'fileUrl';
  static const String reportGeneratedAt = 'generatedAt';
  static const String reportCropId = 'cropId';
  static const String reportType = 'type';

  // Notification fields
  static const String notificationTitle = 'title';
  static const String notificationBody = 'body';
  static const String notificationType = 'type';
  static const String notificationRead = 'read';
  static const String notificationTimestamp = 'timestamp';

  // Weather fields
  static const String weatherTemperature = 'temperature';
  static const String weatherHumidity = 'humidity';
  static const String weatherRainfall = 'rainfall';
  static const String weatherWindSpeed = 'windSpeed';
  static const String weatherCondition = 'condition';
  static const String weatherTimestamp = 'timestamp';

  // Recommendation fields
  static const String recommendationType = 'type';
  static const String recommendationMessage = 'message';
  static const String recommendationPriority = 'priority';
  static const String recommendationCreatedAt = 'createdAt';

  // ============================================================
  // =============== STORAGE PATHS ==============================
  // ============================================================

  static const String storageUserAvatars = 'users/avatars/';
  static const String storageCropImages = 'crops/images/';
  static const String storageAnalysisImages = 'analysis/images/';
  static const String storageReportFiles = 'reports/files/';
  static const String storageTempFiles = 'temp/';

  // ============================================================
  // =============== CLOUD FUNCTIONS ============================
  // ============================================================

  static const String functionAnalyzeImage = 'analyzeImage';
  static const String functionGenerateReport = 'generateReport';
  static const String functionSendNotification = 'sendNotification';
  static const String functionSyncWeatherData = 'syncWeatherData';
  static const String functionUpdateCropHealth = 'updateCropHealth';

  static const List<String> callableFunctions = [
    functionAnalyzeImage,
    functionGenerateReport,
    functionSendNotification,
    functionSyncWeatherData,
    functionUpdateCropHealth,
  ];

  // ============================================================
  // =============== CLOUD MESSAGING ============================
  // ============================================================

  static const List<String> fcmTopics = [
    'all_users',
    'weather_alerts',
    'crop_health',
    'system_updates',
  ];

  static const String notificationChannelGeneral = 'general_notifications';
  static const String notificationChannelWeather = 'weather_alerts';
  static const String notificationChannelSystem = 'system_updates';

  static const List<String> messageTypes = [
    'alert',
    'reminder',
    'update',
    'promotion',
  ];

  // ============================================================
  // =============== REMOTE CONFIG ==============================
  // ============================================================

  static const Map<String, dynamic> remoteConfigDefaults = {
    'enable_crop_analysis': true,
    'enable_weather_sync': true,
    'max_analysis_per_day': 10,
    'min_confidence_threshold': 0.75,
    'show_ads': false,
    'maintenance_mode': false,
  };

  static const String configEnableCropAnalysis = 'enable_crop_analysis';
  static const String configEnableWeatherSync = 'enable_weather_sync';
  static const String configMaxAnalysisPerDay = 'max_analysis_per_day';
  static const String configMinConfidenceThreshold =
      'min_confidence_threshold';
  static const String configShowAds = 'show_ads';
  static const String configMaintenanceMode = 'maintenance_mode';

  // ============================================================
  // =============== ANALYTICS EVENTS ===========================
  // ============================================================

  static const String eventAppOpen = 'app_open';
  static const String eventLogin = 'login';
  static const String eventLogout = 'logout';
  static const String eventRegister = 'register';
  static const String eventCropAdded = 'crop_added';
  static const String eventCropAnalyzed = 'crop_analyzed';
  static const String eventReportGenerated = 'report_generated';
  static const String eventNotificationReceived = 'notification_received';
  static const String eventWeatherChecked = 'weather_checked';

  static const List<String> analyticsEvents = [
    eventAppOpen,
    eventLogin,
    eventLogout,
    eventRegister,
    eventCropAdded,
    eventCropAnalyzed,
    eventReportGenerated,
    eventNotificationReceived,
    eventWeatherChecked,
  ];

  static const List<String> analyticsParameters = [
    'user_id',
    'crop_id',
    'analysis_id',
    'report_id',
    'timestamp',
  ];

  // ============================================================
  // =============== DYNAMIC LINKS ==============================
  // ============================================================

  static const String dynamicLinkPrefix = 'https://cropanalyzer.page.link';
  static const String dynamicLinkDomain = 'cropanalyzer.page.link';
  static const String dynamicLinkAppPackage = 'com.cropanalyzer.app';

  static const String linkParamCropId = 'cropId';
  static const String linkParamReportId = 'reportId';
  static const String linkParamReferralCode = 'referralCode';

  // ============================================================
  // =============== CRASHLYTICS ================================
  // ============================================================

  static const List<String> crashlyticsCustomKeys = [
    'user_id',
    'screen_name',
    'last_action',
    'device_info',
  ];

  static const List<String> crashlyticsLogTags = [
    'AUTH',
    'CROP',
    'ANALYSIS',
    'REPORT',
    'NETWORK',
  ];

  // ============================================================
  // =============== SECURITY RULES =============================
  // ============================================================

  static const String ruleAllowRead = 'allow read: if request.authentication != null;';
  static const String ruleAllowWrite =
      'allow write: if request.authentication != null && request.authentication.uid == resource.data.ownerId;';
  static const String ruleAllowAdmin =
      'allow read, write: if request.authentication.token.admin == true;';

  // ============================================================
  // =============== QUERY LIMITS ===============================
  // ============================================================

  static const int maxQueryResults = 100;
  static const int batchWriteLimit = 500;
  static const int transactionRetryLimit = 5;

  // ============================================================
  // =============== ERROR CODES ================================
  // ============================================================

  static const Map<String, String> firebaseErrorMessages = {
    'invalid-email': 'The email address is invalid.',
    'user-disabled': 'This user account has been disabled.',
    'user-not-found': 'No user found with this email.',
    'wrong-password': 'Incorrect password. Please try again.',
    'email-already-in-use': 'This email is already registered.',
    'operation-not-allowed': 'This operation is not allowed.',
    'weak-password': 'The password is too weak.',
    'network-request-failed': 'Network error. Please check your connection.',
    'too-many-requests': 'Too many attempts. Please try again later.',
    'unknown': 'An unknown error occurred. Please try again.',
  };

  // ============================================================
  // =============== TIMEOUTS ==================================
  // ============================================================

  static const Duration authTimeout = Duration(seconds: 30);
  static const Duration firestoreTimeout = Duration(seconds: 20);
  static const Duration storageTimeout = Duration(seconds: 60);
  static const Duration functionTimeout = Duration(seconds: 45);

  // ============================================================
  // =============== CACHE SETTINGS =============================
  // ============================================================

  static const int firestoreCacheSizeBytes = 50 * 1024 * 1024; // 50 MB
  static const bool enablePersistence = true;
  static const Duration cacheExpiration = Duration(hours: 1);
}