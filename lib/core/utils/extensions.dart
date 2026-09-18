import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// ----------------------
/// STRING EXTENSIONS
/// ----------------------
extension StringExtensions on String {
  /// Capitalize first letter
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// Capitalize each word
  String capitalizeWords() {
    if (isEmpty) return this;
    return split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  /// Validate email format
  bool isValidEmail() {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(this);
  }

  /// Validate phone number
  bool isValidPhone() {
    final regex = RegExp(r'^\+?[\d\s]{7,15}$');
    return regex.hasMatch(this);
  }

  /// Convert to title case
  String toTitleCase() {
    if (isEmpty) return this;
    return toLowerCase()
        .split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Truncate with ellipsis
  String truncate(int length) {
    if (isEmpty || length <= 0) return '';
    return this.length > length ? '${substring(0, length)}...' : this;
  }

  /// Remove all whitespace
  String removeWhitespace() {
    return replaceAll(RegExp(r'\s+'), '');
  }

  /// Check if string is numeric
  bool isNumeric() {
    return double.tryParse(this) != null;
  }

  /// Convert to int safely
  int toInt({int defaultValue = 0}) {
    return int.tryParse(this) ?? defaultValue;
  }

  /// Convert to double safely
  double toDouble({double defaultValue = 0.0}) {
    return double.tryParse(this) ?? defaultValue;
  }
}

/// ----------------------
/// DATETIME EXTENSIONS
/// ----------------------
extension DateTimeExtensions on DateTime {
  /// Check if today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  /// Check if tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }

  /// Get relative time string
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min${diff.inMinutes == 1 ? '' : 's'} ago';
    if (diff.inHours < 24) return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} week${diff.inDays ~/ 7 == 1 ? '' : 's'} ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} month${diff.inDays ~/ 30 == 1 ? '' : 's'} ago';
    return '${(diff.inDays / 365).floor()} year${diff.inDays ~/ 365 == 1 ? '' : 's'} ago';
  }

  /// Format as short date
  String get formatShort => DateFormat('dd MMM yyyy').format(this);

  /// Format as long date
  String get formatLong => DateFormat('EEEE, MMMM dd, yyyy').format(this);
}

/// ----------------------
/// LIST EXTENSIONS
/// ----------------------
extension ListExtensions<T> on List<T>? {
  /// Check if null or empty
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Get first element or null
  T? get firstOrNull => (this == null || this!.isEmpty) ? null : this!.first;

  /// Get last element or null
  T? get lastOrNull => (this == null || this!.isEmpty) ? null : this!.last;
}

/// ----------------------
/// BUILD CONTEXT EXTENSIONS
/// ----------------------
extension BuildContextExtensions on BuildContext {
  /// Show snackbar
  void showSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show error snackbar
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show success snackbar
  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Get text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Get color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Navigate to page
  Future<T?> push<T>(Widget page) {
    return Navigator.push(
      this,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  /// Go back
  void pop<T extends Object?>([T? result]) {
    Navigator.pop(this, result);
  }
}

/// ----------------------
/// COLOR EXTENSIONS
/// ----------------------
extension ColorExtensions on Color {
  /// Convert to hex string
  String toHex({bool leadingHashSign = true}) {
    final hex = value.toRadixString(16).padLeft(8, '0').toUpperCase();
    return leadingHashSign ? '#$hex' : hex;
  }

  /// Lighten color
  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  /// Darken color
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}

/// ----------------------
/// NUMBER EXTENSIONS
/// ----------------------
extension NumberExtensions on num {
  /// Format as currency
  String toCurrency({String symbol = '₹', int decimalDigits = 2}) {
    final format = NumberFormat.currency(symbol: symbol, decimalDigits: decimalDigits);
    return format.format(this);
  }

  /// Format as percentage
  String toPercentage({int decimalDigits = 1}) {
    return '${toStringAsFixed(decimalDigits)}%';
  }

  /// Check if positive
  bool get isPositive => this > 0;

  /// Check if negative
  bool get isNegative => this < 0;
}