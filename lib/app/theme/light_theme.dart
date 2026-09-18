import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  fontFamily: 'Roboto',

  // -------------------- Color Scheme --------------------
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF4CAF50),
    onPrimary: Colors.white,
    secondary: Color(0xFF8BC34A),
    onSecondary: Colors.black,
    surface: Color(0xFFF5F5F5),  // ✅ Replaces 'background'
    onSurface: Colors.black,     // ✅ Replaces 'onBackground'
    error: Color(0xFFB00020),
    onError: Colors.white,
  ),

  // -------------------- Scaffold & Background --------------------
  scaffoldBackgroundColor: const Color(0xFFFFFFFF),
  canvasColor: const Color(0xFFF5F5F5),

  // -------------------- AppBar Theme --------------------
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF4CAF50),
    foregroundColor: Colors.white,
    elevation: 2,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: IconThemeData(color: Colors.white),
  ),

  // -------------------- Bottom Navigation Bar --------------------
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: Color(0xFF4CAF50),
    unselectedItemColor: Colors.grey,
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
  ),

  // -------------------- Navigation Bar Theme --------------------
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: Colors.white,
    indicatorColor: const Color(0x334CAF50),
    labelTextStyle: WidgetStateProperty.all(  // ✅ Changed from MaterialStateProperty
      const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
    ),
    iconTheme: WidgetStateProperty.all(  // ✅ Changed from MaterialStateProperty
      const IconThemeData(color: Colors.black),
    ),
  ),

  // -------------------- Card Theme --------------------
  cardTheme: const CardThemeData(  // ✅ Changed from CardTheme to CardThemeData
    color: Colors.white,
    elevation: 2,
    margin: EdgeInsets.all(8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    shadowColor: Color(0x4D9E9E9E),  // ✅ Changed from Colors.grey.withOpacity(0.3)
  ),

  // -------------------- Elevated Button Theme --------------------
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF4CAF50),
      foregroundColor: Colors.white,
      elevation: 2,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
  ),

  // -------------------- Outlined Button Theme --------------------
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF4CAF50),
      side: const BorderSide(color: Color(0xFF4CAF50)),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      textStyle: const TextStyle(fontWeight: FontWeight.w500),
    ),
  ),

  // -------------------- Text Button Theme --------------------
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFF4CAF50),
      textStyle: const TextStyle(fontWeight: FontWeight.w500),
    ),
  ),

  // -------------------- Floating Action Button Theme --------------------
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF4CAF50),
    foregroundColor: Colors.white,
    elevation: 4,
    shape: CircleBorder(),
  ),

  // -------------------- Input Decoration Theme --------------------
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF5F5F5),
    hintStyle: const TextStyle(color: Color(0xFF757575)),  // ✅ Using const color
    labelStyle: const TextStyle(color: Colors.black),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF4CAF50)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFBDBDBD)),  // ✅ Using const color
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFB00020)),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFB00020), width: 2),
    ),
  ),

  // -------------------- Icon Theme --------------------
  iconTheme: const IconThemeData(
    color: Colors.black,
    size: 24,
  ),

  // -------------------- Dialog Theme --------------------
  dialogTheme: const DialogThemeData(  // ✅ Changed from DialogTheme to DialogThemeData
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    contentTextStyle: TextStyle(
      color: Color(0xFF424242),  // ✅ Using const color instead of Colors.grey.shade800
      fontSize: 16,
    ),
  ),

  // -------------------- SnackBar Theme --------------------
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Color(0xFF4CAF50),
    contentTextStyle: TextStyle(color: Colors.white),
    behavior: SnackBarBehavior.floating,
    elevation: 4,
  ),

  // -------------------- Chip Theme --------------------
  chipTheme: const ChipThemeData(
    backgroundColor: Color(0xFFF5F5F5),
    selectedColor: Color(0xFF4CAF50),
    disabledColor: Color(0xFFE0E0E0),  // ✅ Using const color
    labelStyle: TextStyle(color: Colors.black),
    secondaryLabelStyle: TextStyle(color: Colors.white),
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
  ),

  // -------------------- Tab Bar Theme --------------------
  tabBarTheme: const TabBarThemeData(  // ✅ Changed from TabBarTheme to TabBarThemeData
    labelColor: Color(0xFF4CAF50),
    unselectedLabelColor: Colors.grey,
    indicatorColor: Color(0xFF4CAF50),
    labelStyle: TextStyle(fontWeight: FontWeight.w600),
    unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400),
  ),

  // -------------------- Typography --------------------
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.bold, color: Colors.black),
    displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.bold, color: Colors.black),
    displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black),
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: Colors.black),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.black),
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: Colors.black),
    titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),
    titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.black87),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black),
    labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: Colors.black54),
  ),

  // -------------------- Divider Theme --------------------
  dividerTheme: const DividerThemeData(
    color: Color(0xFFE0E0E0),  // ✅ Using const color
    thickness: 1,
    space: 1,
  ),

  // -------------------- Tooltip Theme --------------------
  tooltipTheme: const TooltipThemeData(
    decoration: BoxDecoration(
      color: Color(0xFF424242),  // ✅ Using const color
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    textStyle: TextStyle(color: Colors.white),
  ),

  // -------------------- Popup Menu Theme --------------------
  popupMenuTheme: const PopupMenuThemeData(
    color: Colors.white,
    textStyle: TextStyle(color: Colors.black),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
  ),

  // -------------------- Progress Indicator Theme --------------------
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: Color(0xFF4CAF50),
    linearTrackColor: Color(0xFFE0E0E0),
    circularTrackColor: Color(0xFFE0E0E0),
  ),

  // -------------------- Checkbox, Radio, Switch --------------------
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.all(const Color(0xFF4CAF50)),  // ✅ Changed from MaterialStateProperty
    checkColor: WidgetStateProperty.all(Colors.white),  // ✅ Changed from MaterialStateProperty
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  ),
  radioTheme: RadioThemeData(
    fillColor: WidgetStateProperty.all(const Color(0xFF4CAF50)),  // ✅ Changed from MaterialStateProperty
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.all(const Color(0xFF4CAF50)),  // ✅ Changed from MaterialStateProperty
    trackColor: WidgetStateProperty.all(const Color(0x334CAF50)),  // ✅ Changed from MaterialStateProperty
  ),
);