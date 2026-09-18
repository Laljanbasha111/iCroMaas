import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// AppTheme defines the complete light and dark theme configurations
/// for the Crop Analyzer app, including typography, color schemes,
/// component themes, and helper methods.
class AppTheme {
  // ============================================================
  // =============== CUSTOM COLORS ==============================
  // ============================================================

  static const Color primaryColor = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF60AD5E);
  static const Color primaryDark = Color(0xFF005005);

  static const Color secondaryColor = Color(0xFF81C784);
  static const Color secondaryLight = Color(0xFFB2FAB4);
  static const Color secondaryDark = Color(0xFF519657);

  static const Color backgroundLight = Color(0xFFF9FAFB);
  static const Color backgroundDark = Color(0xFF121212);

  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E1E1E);

  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF388E3C);
  static const Color warningColor = Color(0xFFFBC02D);
  static const Color infoColor = Color(0xFF1976D2);

  static const Color healthyCropColor = Colors.green;
  static const Color moderateCropColor = Colors.orange;
  static const Color poorCropColor = Colors.redAccent;
  static const Color criticalCropColor = Colors.red;

  // ============================================================
  // =============== TYPOGRAPHY ================================
  // ============================================================

  static final TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.poppins(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
    ),
    displayMedium: GoogleFonts.poppins(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.25,
    ),
    displaySmall: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.w500,
    ),
    headlineMedium: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    headlineSmall: GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.w500,
    ),
    titleLarge: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: GoogleFonts.roboto(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    titleSmall: GoogleFonts.roboto(
      fontSize: 12,
      fontWeight: FontWeight.w400,
    ),
    bodyLarge: GoogleFonts.roboto(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
    ),
    bodyMedium: GoogleFonts.roboto(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
    bodySmall: GoogleFonts.roboto(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.3,
    ),
    labelLarge: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.25,
    ),
    labelMedium: GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.0,
    ),
    labelSmall: GoogleFonts.poppins(
      fontSize: 10,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
    ),
  );

  // ============================================================
  // =============== BORDER RADIUS & SPACING ====================
  // ============================================================

  static const double radiusSmall = 6.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 20.0;

  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  static const double marginSmall = 8.0;
  static const double marginMedium = 16.0;
  static const double marginLarge = 24.0;

  // ============================================================
  // =============== SHADOWS ===================================
  // ============================================================

  static const List<BoxShadow> cardShadows = [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 6,
      offset: Offset(0, 3),
    ),
  ];

  static const List<BoxShadow> buttonShadows = [
    BoxShadow(
      color: Colors.black26,
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  // ============================================================
  // =============== LIGHT THEME ================================
  // ============================================================

  static ThemeData getLightTheme() {
    final colorScheme = ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      background: backgroundLight,
      surface: surfaceLight,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onBackground: Colors.black,
      onSurface: Colors.black,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundLight,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceLight,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        shadowColor: Colors.black12,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          elevation: 2,
          shadowColor: Colors.black26,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: GoogleFonts.roboto(color: Colors.grey[700]),
        hintStyle: GoogleFonts.roboto(color: Colors.grey[500]),
      ),
      iconTheme: const IconThemeData(color: primaryColor, size: 24),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: secondaryLight,
        selectedColor: primaryColor,
        labelStyle: GoogleFonts.roboto(color: Colors.black),
        secondaryLabelStyle: GoogleFonts.roboto(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        contentTextStyle: GoogleFonts.roboto(
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLarge)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primaryColor,
        contentTextStyle: GoogleFonts.roboto(color: Colors.white),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade300,
        thickness: 1,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.all(primaryColor),
        trackColor: MaterialStateProperty.all(secondaryLight),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.all(primaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.all(primaryColor),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryColor,
        inactiveTrackColor: secondaryLight,
        thumbColor: primaryColor,
        overlayColor: primaryLight.withOpacity(0.2),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primaryColor,
        unselectedLabelColor: Colors.grey,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        textStyle: GoogleFonts.roboto(color: Colors.white),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: primaryColor,
        textColor: Colors.black,
        tileColor: surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),
    );
  }

  // ============================================================
  // =============== DARK THEME ================================
  // ============================================================

  static ThemeData getDarkTheme() {
    final colorScheme = ColorScheme.dark(
      primary: primaryLight,
      secondary: secondaryLight,
      background: backgroundDark,
      surface: surfaceDark,
      error: errorColor,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onBackground: Colors.white,
      onSurface: Colors.white,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundDark,
      textTheme: textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceDark,
        foregroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: primaryLight,
        unselectedItemColor: Colors.grey,
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        shadowColor: Colors.black54,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: Colors.black,
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          elevation: 2,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryLight,
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryLight,
          side: BorderSide(color: primaryLight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: primaryLight, width: 2),
        ),
        labelStyle: GoogleFonts.roboto(color: Colors.grey[300]),
        hintStyle: GoogleFonts.roboto(color: Colors.grey[400]),
      ),
      iconTheme: IconThemeData(color: primaryLight, size: 24),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryLight,
        foregroundColor: Colors.black,
        elevation: 4,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: secondaryDark,
        selectedColor: primaryLight,
        labelStyle: GoogleFonts.roboto(color: Colors.white),
        secondaryLabelStyle: GoogleFonts.roboto(color: Colors.black),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        contentTextStyle: GoogleFonts.roboto(
          fontSize: 14,
          color: Colors.white70,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLarge)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primaryLight,
        contentTextStyle: GoogleFonts.roboto(color: Colors.black),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade700,
        thickness: 1,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.all(primaryLight),
        trackColor: MaterialStateProperty.all(secondaryDark),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.all(primaryLight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.all(primaryLight),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryLight,
        inactiveTrackColor: secondaryDark,
        thumbColor: primaryLight,
        overlayColor: primaryLight.withOpacity(0.2),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primaryLight,
        unselectedLabelColor: Colors.grey,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: primaryLight, width: 2),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        textStyle: GoogleFonts.roboto(color: Colors.black),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: primaryLight,
        textColor: Colors.white,
        tileColor: surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),
    );
  }

  // ============================================================
  // =============== HELPER METHODS =============================
  // ============================================================

  static ThemeData getTheme(bool isDark) {
    return isDark ? getDarkTheme() : getLightTheme();
  }

  static Color getCustomColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'success':
        return successColor;
      case 'warning':
        return warningColor;
      case 'info':
        return infoColor;
      case 'healthy':
        return healthyCropColor;
      case 'moderate':
        return moderateCropColor;
      case 'poor':
        return poorCropColor;
      case 'critical':
        return criticalCropColor;
      default:
        return primaryColor;
    }
  }
}

