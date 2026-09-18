import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ThemeProvider manages theme mode, colors, fonts, and persistence
/// for the Crop Analyzer app.
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  Color _primaryColor = Colors.green;
  Color _accentColor = Colors.greenAccent;

  double _fontSize = 16.0;
  String _fontFamily = 'Roboto';

  // ============================================================
  // GETTERS
  // ============================================================

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  bool get isLightMode => _themeMode == ThemeMode.light;

  bool get isSystemMode => _themeMode == ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  Color get primaryColor => _primaryColor;

  Color get accentColor => _accentColor;

  double get fontSize => _fontSize;

  String get fontFamily => _fontFamily;

  ThemeData get currentTheme {
    switch (_themeMode) {
      case ThemeMode.dark:
        return _buildDarkTheme(_primaryColor);

      case ThemeMode.light:
      case ThemeMode.system:
        return _buildLightTheme(_primaryColor);
    }
  }

  // ============================================================
  // INITIALIZE
  // ============================================================

  /// Initialize theme from saved preferences.
  Future<void> initialize() async {
    await loadTheme();
  }

  // ============================================================
  // THEME MODE
  // ============================================================

  /// Set theme mode.
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;

    await saveTheme();

    _notifyListeners();
  }

  /// Toggle between light and dark mode.
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      await setLightTheme();
    } else {
      await setDarkTheme();
    }
  }

  /// Set light theme.
  Future<void> setLightTheme() async {
    _themeMode = ThemeMode.light;

    await saveTheme();

    _notifyListeners();
  }

  /// Set dark theme.
  Future<void> setDarkTheme() async {
    _themeMode = ThemeMode.dark;

    await saveTheme();

    _notifyListeners();
  }

  /// Set system theme.
  Future<void> setSystemTheme() async {
    _themeMode = ThemeMode.system;

    await saveTheme();

    _notifyListeners();
  }

  // ============================================================
  // COLORS
  // ============================================================

  /// Set primary color.
  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;

    await saveTheme();

    _notifyListeners();
  }

  /// Set accent color.
  Future<void> setAccentColor(Color color) async {
    _accentColor = color;

    await saveTheme();

    _notifyListeners();
  }

  // ============================================================
  // FONT SETTINGS
  // ============================================================

  /// Set font size.
  Future<void> setFontSize(double size) async {
    _fontSize = size.clamp(12.0, 24.0).toDouble();

    await saveTheme();

    _notifyListeners();
  }

  /// Set font family.
  Future<void> setFontFamily(String family) async {
    if (family.trim().isEmpty) {
      return;
    }

    _fontFamily = family.trim();

    await saveTheme();

    _notifyListeners();
  }

  // ============================================================
  // PREDEFINED THEMES
  // ============================================================

  /// Apply predefined custom theme.
  Future<void> applyCustomTheme(String themeName) async {
    switch (themeName.toLowerCase().trim()) {
      case 'green':
        _primaryColor = Colors.green;
        _accentColor = Colors.greenAccent;
        break;

      case 'blue':
        _primaryColor = Colors.blue;
        _accentColor = Colors.lightBlueAccent;
        break;

      case 'orange':
        _primaryColor = Colors.orange;
        _accentColor = Colors.deepOrangeAccent;
        break;

      case 'purple':
        _primaryColor = Colors.purple;
        _accentColor = Colors.deepPurpleAccent;
        break;

      case 'red':
        _primaryColor = Colors.red;
        _accentColor = Colors.redAccent;
        break;

      default:
        _primaryColor = Colors.green;
        _accentColor = Colors.greenAccent;
    }

    await saveTheme();

    _notifyListeners();
  }

  // ============================================================
  // RESET
  // ============================================================

  /// Reset theme to default.
  Future<void> resetTheme() async {
    _themeMode = ThemeMode.system;

    _primaryColor = Colors.green;

    _accentColor = Colors.greenAccent;

    _fontSize = 16.0;

    _fontFamily = 'Roboto';

    await saveTheme();

    _notifyListeners();
  }

  // ============================================================
  // SAVE
  // ============================================================

  /// Save theme settings to SharedPreferences.
  Future<void> saveTheme() async {
    try {
      final SharedPreferences prefs =
      await SharedPreferences.getInstance();

      await prefs.setString(
        'themeMode',
        _themeMode.name,
      );

      await prefs.setString(
        'primaryColor',
        _getHexFromColor(_primaryColor),
      );

      await prefs.setString(
        'accentColor',
        _getHexFromColor(_accentColor),
      );

      await prefs.setDouble(
        'fontSize',
        _fontSize,
      );

      await prefs.setString(
        'fontFamily',
        _fontFamily,
      );
    } catch (e) {
      log('Error saving theme: $e');
    }
  }

  // ============================================================
  // LOAD
  // ============================================================

  /// Load theme settings from SharedPreferences.
  Future<void> loadTheme() async {
    try {
      final SharedPreferences prefs =
      await SharedPreferences.getInstance();

      // ----------------------------------------------------------
      // THEME MODE
      // ----------------------------------------------------------

      final String? modeString =
      prefs.getString('themeMode');

      if (modeString != null) {
        switch (modeString) {
          case 'dark':
          case 'ThemeMode.dark':
            _themeMode = ThemeMode.dark;
            break;

          case 'light':
          case 'ThemeMode.light':
            _themeMode = ThemeMode.light;
            break;

          case 'system':
          case 'ThemeMode.system':
          default:
            _themeMode = ThemeMode.system;
            break;
        }
      }

      // ----------------------------------------------------------
      // COLORS
      // ----------------------------------------------------------

      final String? primaryHex =
      prefs.getString('primaryColor');

      final String? accentHex =
      prefs.getString('accentColor');

      if (primaryHex != null &&
          primaryHex.trim().isNotEmpty) {
        try {
          _primaryColor =
              _getColorFromHex(primaryHex);
        } catch (e) {
          log(
            'Invalid saved primary color: $e',
          );
        }
      }

      if (accentHex != null &&
          accentHex.trim().isNotEmpty) {
        try {
          _accentColor =
              _getColorFromHex(accentHex);
        } catch (e) {
          log(
            'Invalid saved accent color: $e',
          );
        }
      }

      // ----------------------------------------------------------
      // FONT
      // ----------------------------------------------------------

      _fontSize =
          prefs.getDouble('fontSize') ?? 16.0;

      _fontSize =
          _fontSize.clamp(12.0, 24.0).toDouble();

      _fontFamily =
          prefs.getString('fontFamily') ?? 'Roboto';

      if (_fontFamily.trim().isEmpty) {
        _fontFamily = 'Roboto';
      }

      _notifyListeners();
    } catch (e) {
      log('Error loading theme: $e');
    }
  }

  // ============================================================
  // LIGHT THEME
  // ============================================================

  ThemeData _buildLightTheme(Color primary) {
    final ColorScheme colorScheme =
    ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    );

    return ThemeData(
      brightness: Brightness.light,

      useMaterial3: true,

      primaryColor: primary,

      colorScheme: colorScheme,

      scaffoldBackgroundColor: Colors.white,

      cardColor: Colors.white,

      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),

      bottomNavigationBarTheme:
      BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey,
      ),

      textTheme: TextTheme(
        bodyLarge: TextStyle(
          fontSize: _fontSize,
          fontFamily: _fontFamily,
          color: Colors.black,
        ),
        bodyMedium: TextStyle(
          fontSize: _fontSize - 2,
          fontFamily: _fontFamily,
          color: Colors.black87,
        ),
      ),

      iconTheme: IconThemeData(
        color: primary,
      ),

      elevatedButtonTheme:
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DARK THEME
  // ============================================================

  ThemeData _buildDarkTheme(Color primary) {
    final ColorScheme colorScheme =
    ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    );

    return ThemeData(
      brightness: Brightness.dark,

      useMaterial3: true,

      primaryColor: primary,

      colorScheme: colorScheme,

      scaffoldBackgroundColor: Colors.black,

      cardColor: Colors.grey.shade900,

      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),

      bottomNavigationBarTheme:
      BottomNavigationBarThemeData(
        backgroundColor: Colors.grey.shade900,
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey,
      ),

      textTheme: TextTheme(
        bodyLarge: TextStyle(
          fontSize: _fontSize,
          fontFamily: _fontFamily,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontSize: _fontSize - 2,
          fontFamily: _fontFamily,
          color: Colors.white70,
        ),
      ),

      iconTheme: IconThemeData(
        color: primary,
      ),

      elevatedButtonTheme:
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // COLOR CONVERSION
  // ============================================================

  /// Convert hex string to Color.
  Color _getColorFromHex(String hex) {
    String cleanHex =
    hex.trim().replaceFirst('#', '');

    if (cleanHex.length == 6) {
      cleanHex = 'FF$cleanHex';
    }

    if (cleanHex.length != 8) {
      throw FormatException(
        'Invalid color hex value: $hex',
      );
    }

    return Color(
      int.parse(
        cleanHex,
        radix: 16,
      ),
    );
  }

  /// Convert Color to hex string.
  String _getHexFromColor(Color color) {
    final int argb =
    color.toARGB32();

    final String hex =
    argb.toRadixString(16).padLeft(8, '0');

    return '#${hex.substring(2)}';
  }

  // ============================================================
  // NOTIFY
  // ============================================================

  void _notifyListeners() {
    if (!hasListeners) {
      return;
    }

    notifyListeners();
  }
}