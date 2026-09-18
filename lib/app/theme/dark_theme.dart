import 'package:flutter/material.dart';

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  fontFamily: 'Roboto',
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF4CAF50),
    onPrimary: Colors.white,
    secondary: Color(0xFF8BC34A),
    onSecondary: Colors.black,
    surface: Color(0xFF1E1E1E),
    onSurface: Colors.white,
    error: Color(0xFFCF6679),
    onError: Colors.black,
  ),

  // -------------------- Scaffold & Background --------------------
  scaffoldBackgroundColor: const Color(0xFF121212),
  canvasColor: const Color(0xFF121212),

  // -------------------- AppBar Theme --------------------
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1E1E1E),
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
    backgroundColor: Color(0xFF1E1E1E),
    selectedItemColor: Color(0xFF4CAF50),
    unselectedItemColor: Colors.grey,
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
  ),

  // -------------------- Navigation Bar Theme --------------------
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: const Color(0xFF1E1E1E),
    indicatorColor: const Color(0x334CAF50),
    labelTextStyle: WidgetStateProperty.all(
      const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
    ),
    iconTheme: WidgetStateProperty.all(
      const IconThemeData(color: Colors.white),
    ),
  ),

  // -------------------- Card Theme --------------------
  cardTheme: const CardThemeData(  // ✅ FIXED: CardTheme → CardThemeData
    color: Color(0xFF1E1E1E),
    elevation: 2,
    margin: EdgeInsets.all(8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    shadowColor: Colors.black,
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
      foregroundColor: const Color(0xFF8BC34A),
      side: const BorderSide(color: Color(0xFF8BC34A)),
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
      foregroundColor: const Color(0xFF8BC34A),
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
    fillColor: const Color(0xFF1E1E1E),
    hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),  // ✅ Using const color
    labelStyle: const TextStyle(color: Colors.white),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF4CAF50)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF616161)),  // ✅ Using const color
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFCF6679)),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFCF6679), width: 2),
    ),
  ),

  // -------------------- Icon Theme --------------------
  iconTheme: const IconThemeData(
    color: Colors.white,
    size: 24,
  ),

  // -------------------- Dialog Theme --------------------
  dialogTheme: const DialogThemeData(  // ✅ FIXED: DialogTheme → DialogThemeData
    backgroundColor: Color(0xFF1E1E1E),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    contentTextStyle: TextStyle(
      color: Color(0xFFBDBDBD),  // ✅ Using const color instead of Colors.grey.shade300
      fontSize: 16,
    ),
  ),

  // -------------------- SnackBar Theme --------------------
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Color(0xFF2C2C2C),
    contentTextStyle: TextStyle(color: Colors.white),
    behavior: SnackBarBehavior.floating,
    elevation: 4,
  ),

  // -------------------- Chip Theme --------------------
  chipTheme: const ChipThemeData(
    backgroundColor: Color(0xFF2C2C2C),
    selectedColor: Color(0xFF4CAF50),
    disabledColor: Color(0xFF424242),  // ✅ Using const color
    labelStyle: TextStyle(color: Colors.white),
    secondaryLabelStyle: TextStyle(color: Colors.white),
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
  ),

  // -------------------- Tab Bar Theme --------------------
  tabBarTheme: const TabBarThemeData(  // ✅ FIXED: TabBarTheme → TabBarThemeData
    labelColor: Color(0xFF4CAF50),
    unselectedLabelColor: Colors.grey,
    indicatorColor: Color(0xFF4CAF50),
    labelStyle: TextStyle(fontWeight: FontWeight.w600),
    unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400),
  ),

  // -------------------- Typography --------------------
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.bold, color: Colors.white),
    displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.bold, color: Colors.white),
    displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: Colors.white),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.white),
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: Colors.white),
    titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
    titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.white),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.white),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.white70),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
    labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: Colors.white70),
  ),

  // -------------------- Divider Theme --------------------
  dividerTheme: const DividerThemeData(
    color: Color(0xFF424242),  // ✅ Using const color
    thickness: 1,
    space: 1,
  ),

  // -------------------- Tooltip Theme --------------------
  tooltipTheme: const TooltipThemeData(
    decoration: BoxDecoration(
      color: Color(0xFF2C2C2C),
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    textStyle: TextStyle(color: Colors.white),
  ),

  // -------------------- Popup Menu Theme --------------------
  popupMenuTheme: const PopupMenuThemeData(
    color: Color(0xFF1E1E1E),
    textStyle: TextStyle(color: Colors.white),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
  ),

  // -------------------- Progress Indicator Theme --------------------
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: Color(0xFF4CAF50),
    linearTrackColor: Color(0xFF2C2C2C),
    circularTrackColor: Color(0xFF2C2C2C),
  ),

  // -------------------- Checkbox, Radio, Switch --------------------
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.all(const Color(0xFF4CAF50)),
    checkColor: WidgetStateProperty.all(Colors.white),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  ),
  radioTheme: RadioThemeData(
    fillColor: WidgetStateProperty.all(const Color(0xFF4CAF50)),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.all(const Color(0xFF4CAF50)),
    trackColor: WidgetStateProperty.all(const Color(0x334CAF50)),
  ),
);