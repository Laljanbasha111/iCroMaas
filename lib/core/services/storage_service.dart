import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// StorageService - Singleton class for managing local storage, file storage,
/// and image picking in the Crop Analyzer app.
class StorageService {
  //=============================
  // Singleton Setup
  //=============================
  StorageService._privateConstructor();
  static final StorageService _instance = StorageService._privateConstructor();
  static StorageService get instance => _instance;

  final ImagePicker _picker = ImagePicker();

  //=============================
  // Storage Keys
  //=============================
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';
  static const String userNameKey = 'user_name';
  static const String themeModeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String notificationsEnabledKey = 'notifications_enabled';
  static const String lastAnalysisKey = 'last_analysis';

  //=============================
  // SharedPreferences Methods
  //=============================

  Future<void> saveString(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (e) {
      throw Exception('Error saving string: $e');
    }
  }

  Future<String?> getString(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } catch (e) {
      throw Exception('Error getting string: $e');
    }
  }

  Future<void> saveBool(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
      throw Exception('Error saving bool: $e');
    }
  }

  Future<bool?> getBool(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(key);
    } catch (e) {
      throw Exception('Error getting bool: $e');
    }
  }

  Future<void> saveInt(String key, int value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(key, value);
    } catch (e) {
      throw Exception('Error saving int: $e');
    }
  }

  Future<int?> getInt(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(key);
    } catch (e) {
      throw Exception('Error getting int: $e');
    }
  }

  Future<void> saveDouble(String key, double value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(key, value);
    } catch (e) {
      throw Exception('Error saving double: $e');
    }
  }

  Future<double?> getDouble(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble(key);
    } catch (e) {
      throw Exception('Error getting double: $e');
    }
  }

  Future<void> saveJson(String key, Map<String, dynamic> json) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, jsonEncode(json));
    } catch (e) {
      throw Exception('Error saving JSON: $e');
    }
  }

  Future<Map<String, dynamic>?> getJson(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString);
    } catch (e) {
      throw Exception('Error getting JSON: $e');
    }
  }

  Future<void> remove(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } catch (e) {
      throw Exception('Error removing key: $e');
    }
  }

  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      throw Exception('Error clearing preferences: $e');
    }
  }

  Future<bool> containsKey(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(key);
    } catch (e) {
      throw Exception('Error checking key existence: $e');
    }
  }

  //=============================
  // File Storage Methods
  //=============================

  Future<String> getApplicationDocumentsDirectoryPath() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      return dir.path;
    } catch (e) {
      throw Exception('Error getting documents directory: $e');
    }
  }

  Future<String> getTemporaryDirectoryPath() async {
    try {
      final dir = await getTemporaryDirectory();
      return dir.path;
    } catch (e) {
      throw Exception('Error getting temporary directory: $e');
    }
  }

  Future<String> getLocalImagesDirectory() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${dir.path}/images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      return imagesDir.path;
    } catch (e) {
      throw Exception('Error getting images directory: $e');
    }
  }

  Future<File> saveImageToLocal(File image, String filename) async {
    try {
      final dirPath = await getLocalImagesDirectory();
      final newPath = '$dirPath/$filename';
      return await image.copy(newPath);
    } catch (e) {
      throw Exception('Error saving image locally: $e');
    }
  }

  Future<File?> getLocalImage(String filename) async {
    try {
      final dirPath = await getLocalImagesDirectory();
      final file = File('$dirPath/$filename');
      if (await file.exists()) return file;
      return null;
    } catch (e) {
      throw Exception('Error getting local image: $e');
    }
  }

  Future<void> deleteLocalImage(String filename) async {
    try {
      final dirPath = await getLocalImagesDirectory();
      final file = File('$dirPath/$filename');
      if (await file.exists()) await file.delete();
    } catch (e) {
      throw Exception('Error deleting local image: $e');
    }
  }

  Future<File> saveFileToLocal(File file, String filename) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final newPath = '${dir.path}/$filename';
      return await file.copy(newPath);
    } catch (e) {
      throw Exception('Error saving file locally: $e');
    }
  }

  Future<File?> getLocalFile(String filename) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$filename');
      if (await file.exists()) return file;
      return null;
    } catch (e) {
      throw Exception('Error getting local file: $e');
    }
  }

  Future<void> deleteLocalFile(String filename) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$filename');
      if (await file.exists()) await file.delete();
    } catch (e) {
      throw Exception('Error deleting local file: $e');
    }
  }

  Future<void> clearCache() async {
    try {
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    } catch (e) {
      throw Exception('Error clearing cache: $e');
    }
  }

  //=============================
  // Image Picker Methods
  //=============================

  Future<File?> pickImageFromGallery() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return null;
      return File(pickedFile.path);
    } catch (e) {
      throw Exception('Error picking image from gallery: $e');
    }
  }

  Future<File?> pickImageFromCamera() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile == null) return null;
      return File(pickedFile.path);
    } catch (e) {
      throw Exception('Error picking image from camera: $e');
    }
  }

  Future<List<File>> pickMultipleImages() async {
    try {
      final pickedFiles = await _picker.pickMultiImage();
      return pickedFiles.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      throw Exception('Error picking multiple images: $e');
    }
  }

  //=============================
  // Helper Methods
  //=============================

  Future<int> getFileSize(File file) async {
    try {
      return await file.length();
    } catch (e) {
      throw Exception('Error getting file size: $e');
    }
  }

  Future<String> getFileSizeString(File file) async {
    try {
      final bytes = await file.length();
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } catch (e) {
      throw Exception('Error formatting file size: $e');
    }
  }

  bool isImageFile(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.bmp') ||
        lower.endsWith('.webp');
  }

  Future<File?> compressImage(File image) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final result = await FlutterImageCompress.compressAndGetFile(
        image.absolute.path,
        targetPath,
        quality: 80,
      );

      // Convert XFile? to File?
      if (result == null) return null;
      return File(result.path);
    } catch (e) {
      throw Exception('Error compressing image: $e');
    }
  }
}