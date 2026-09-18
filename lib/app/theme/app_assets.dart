import 'package:flutter/material.dart';

/// Centralized asset management for the Crop Analyzer app.
/// Contains all image, icon, animation, and font asset paths.
/// Organized by category for easy access and maintenance.
class AppAssets {
  // ===========================
  // IMAGES
  // ===========================
  static const String _imagePath = 'assets/images';

  // Logos
  static const String logoPrimary = '$_imagePath/logo_primary.png';
  static const String logoSecondary = '$_imagePath/logo_secondary.png';
  static const String logoWhite = '$_imagePath/logo_white.png';
  static const String logoDark = '$_imagePath/logo_dark.png';

  // Splash & Backgrounds
  static const String splashBackground = '$_imagePath/splash_background.png';
  static const String onboardingBackground = '$_imagePath/onboarding_background.png';
  static const String dashboardBackground = '$_imagePath/dashboard_background.png';
  static const String loginBackground = '$_imagePath/login_background.png';
  static const String analysisBackground = '$_imagePath/analysis_background.png';

  // Onboarding Illustrations
  static const String onboarding1 = '$_imagePath/onboarding_1.png';
  static const String onboarding2 = '$_imagePath/onboarding_2.png';
  static const String onboarding3 = '$_imagePath/onboarding_3.png';

  // Profile & Placeholders
  static const String profilePlaceholder = '$_imagePath/profile_placeholder.png';
  static const String userAvatar = '$_imagePath/user_avatar.png';
  static const String emptyState = '$_imagePath/empty_state.png';
  static const String noData = '$_imagePath/no_data.png';

  // Crop & Drone Images
  static const String cropHealthy = '$_imagePath/crop_healthy.png';
  static const String cropDiseased = '$_imagePath/crop_diseased.png';
  static const String cropNitrogenDeficient = '$_imagePath/crop_nitrogen_deficient.png';
  static const String droneTopView = '$_imagePath/drone_top_view.png';
  static const String droneField = '$_imagePath/drone_field.png';
  static const String droneCamera = '$_imagePath/drone_camera.png';

  // Weather & Environment
  static const String sunny = '$_imagePath/sunny.png';
  static const String cloudy = '$_imagePath/cloudy.png';
  static const String rainy = '$_imagePath/rainy.png';
  static const String storm = '$_imagePath/storm.png';
  static const String wind = '$_imagePath/wind.png';

  // ===========================
  // ICONS
  // ===========================
  static const String _iconPath = 'assets/icons';

  // Navigation Icons
  static const String iconHome = '$_iconPath/home.png';
  static const String iconCamera = '$_iconPath/camera.png';
  static const String iconUpload = '$_iconPath/upload.png';
  static const String iconAnalysis = '$_iconPath/analysis.png';
  static const String iconReport = '$_iconPath/report.png';
  static const String iconHistory = '$_iconPath/history.png';
  static const String iconProfile = '$_iconPath/profile.png';
  static const String iconWeather = '$_iconPath/weather.png';
  static const String iconChatbot = '$_iconPath/chatbot.png';
  static const String iconSettings = '$_iconPath/settings.png';
  static const String iconNotification = '$_iconPath/notification.png';

  // Functional Icons
  static const String iconEdit = '$_iconPath/edit.png';
  static const String iconDelete = '$_iconPath/delete.png';
  static const String iconSave = '$_iconPath/save.png';
  static const String iconShare = '$_iconPath/share.png';
  static const String iconDownload = '$_iconPath/download.png';
  static const String iconFilter = '$_iconPath/filter.png';
  static const String iconSearch = '$_iconPath/search.png';
  static const String iconInfo = '$_iconPath/info.png';
  static const String iconHelp = '$_iconPath/help.png';
  static const String iconLogout = '$_iconPath/logout.png';

  // Category Icons
  static const String iconCropHealth = '$_iconPath/crop_health.png';
  static const String iconNitrogen = '$_iconPath/nitrogen.png';
  static const String iconBiomass = '$_iconPath/biomass.png';
  static const String iconDisease = '$_iconPath/disease.png';
  static const String iconPesticide = '$_iconPath/pesticide.png';
  static const String iconFertilizer = '$_iconPath/fertilizer.png';
  static const String iconSoil = '$_iconPath/soil.png';
  static const String iconDrone = '$_iconPath/drone.png';
  static const String iconAI = '$_iconPath/ai.png';
  static const String iconReportPDF = '$_iconPath/report_pdf.png';

  // Status Icons
  static const String iconSuccess = '$_iconPath/success.png';
  static const String iconError = '$_iconPath/error.png';
  static const String iconWarning = '$_iconPath/warning.png';
  static const String iconInfoCircle = '$_iconPath/info_circle.png';
  static const String iconLoading = '$_iconPath/loading.png';

  // ===========================
  // ANIMATIONS (Lottie)
  // ===========================
  static const String _animationPath = 'assets/animations';

  // Splash & Loading
  static const String splashAnimation = '$_animationPath/splash_animation.json';
  static const String loadingAnimation = '$_animationPath/loading_animation.json';
  static const String scanningAnimation = '$_animationPath/scanning_animation.json';
  static const String droneAnimation = '$_animationPath/drone_animation.json';

  // Success & Error
  static const String successAnimation = '$_animationPath/success_animation.json';
  static const String errorAnimation = '$_animationPath/error_animation.json';
  static const String warningAnimation = '$_animationPath/warning_animation.json';

  // Empty & No Data
  static const String emptyStateAnimation = '$_animationPath/empty_state_animation.json';
  static const String noDataAnimation = '$_animationPath/no_data_animation.json';

  // Analysis & AI
  static const String aiProcessingAnimation = '$_animationPath/ai_processing.json';
  static const String cropGrowthAnimation = '$_animationPath/crop_growth.json';
  static const String weatherAnimation = '$_animationPath/weather_animation.json';
  static const String chatbotAnimation = '$_animationPath/chatbot_animation.json';

  // ===========================
  // FONTS
  // ===========================
  static const String _fontPath = 'assets/fonts';

  static const String fontRobotoRegular = '$_fontPath/Roboto-Regular.ttf';
  static const String fontRobotoBold = '$_fontPath/Roboto-Bold.ttf';
  static const String fontRobotoItalic = '$_fontPath/Roboto-Italic.ttf';

  // ===========================
  // UTILITY METHODS
  // ===========================

  /// Returns the correct logo based on theme brightness.
  static String getLogo(Brightness brightness) {
    return brightness == Brightness.dark ? logoWhite : logoPrimary;
  }

  /// Returns the correct background image for splash or onboarding.
  static String getBackground(String screen) {
    switch (screen) {
      case 'splash':
        return splashBackground;
      case 'onboarding':
        return onboardingBackground;
      case 'dashboard':
        return dashboardBackground;
      case 'login':
        return loginBackground;
      case 'analysis':
        return analysisBackground;
      default:
        return splashBackground;
    }
  }

  /// Returns the correct animation for a given state.
  static String getAnimation(String state) {
    switch (state) {
      case 'loading':
        return loadingAnimation;
      case 'success':
        return successAnimation;
      case 'error':
        return errorAnimation;
      case 'empty':
        return emptyStateAnimation;
      case 'scanning':
        return scanningAnimation;
      case 'drone':
        return droneAnimation;
      default:
        return loadingAnimation;
    }
  }
}