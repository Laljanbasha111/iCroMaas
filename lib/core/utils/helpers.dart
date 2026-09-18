import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:share_plus/share_plus.dart';

class Helpers {
  // -----------------------------
  // UI HELPERS
  // -----------------------------

  static void showLoadingDialog(BuildContext context, {String message = 'Loading...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              const CircularProgressIndicator(color: Colors.green),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  static Future<bool> showConfirmDialog(
      BuildContext context,
      String title,
      String message, {
        String confirmText = 'Yes',
        String cancelText = 'No',
      }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static Future<void> showAlertDialog(
      BuildContext context,
      String title,
      String message, {
        String buttonText = 'OK',
      }) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  static Future<void> showBottomSheet(BuildContext context, Widget child) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  // -----------------------------
  // VALIDATION HELPERS
  // -----------------------------

  static bool isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    final regex = RegExp(r'^\+?[\d\s]{7,15}$');
    return regex.hasMatch(phone);
  }

  static bool isValidPassword(String password) {
    return password.length >= 8;
  }

  static bool isValidUrl(String url) {
    final regex = RegExp(r'^(https?:\/\/)?([\w\-]+\.)+[a-zA-Z]{2,}(\/\S*)?$');
    return regex.hasMatch(url);
  }

  // -----------------------------
  // FILE HELPERS
  // -----------------------------

  static String getFileSize(File file) {
    final bytes = file.lengthSync();
    return formatFileSize(bytes);
  }

  static String getFileExtension(String path) {
    return path.split('.').last.toLowerCase();
  }

  static bool isImageFile(String path) {
    final ext = getFileExtension(path);
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext);
  }

  static bool isVideoFile(String path) {
    final ext = getFileExtension(path);
    return ['mp4', 'mov', 'avi', 'mkv', 'flv', 'wmv'].contains(ext);
  }

  // -----------------------------
  // STRING HELPERS
  // -----------------------------

  static String generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (log(bytes) / log(1024)).floor();
    final size = (bytes / pow(1024, i)).toStringAsFixed(2);
    return '$size ${suffixes[i]}';
  }

  static String getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    final domain = parts[1];
    final masked = name.length > 1 ? '${name[0]}***' : '***';
    return '$masked@$domain';
  }

  static String maskPhone(String phone) {
    if (phone.length <= 4) return phone;
    return '******${phone.substring(phone.length - 4)}';
  }

  // -----------------------------
  // NETWORK HELPERS
  // -----------------------------

  static Future<bool> hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  static bool isNetworkError(dynamic error) {
    return error is SocketException || error.toString().contains('Network');
  }

  // -----------------------------
  // DEVICE HELPERS
  // -----------------------------

  static String getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.shortestSide;
    return width < 600 ? 'Mobile' : 'Tablet';
  }

  static bool isAndroid() => Platform.isAndroid;

  static bool isIOS() => Platform.isIOS;

  // -----------------------------
  // DATA HELPERS
  // -----------------------------

  static String encodeJson(Map<String, dynamic> data) {
    return jsonEncode(data);
  }

  static Map<String, dynamic>? decodeJson(String jsonString) {
    try {
      return jsonDecode(jsonString);
    } catch (_) {
      return null;
    }
  }

  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  static Future<void> shareText(String text) async {
    await Share.share(text);
  }

  // -----------------------------
  // MATH HELPERS
  // -----------------------------

  static double calculatePercentage(double value, double total) {
    if (total == 0) return 0;
    return (value / total) * 100;
  }

  static double roundToDecimal(double value, int places) {
    final mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }

  static num clamp(num value, num min, num max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }
}