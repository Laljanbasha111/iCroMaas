import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';  // ✅ Changed import
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  late SharedPreferences _prefs;
  Box? _cacheBox;
  bool _initialized = false;
  final Map<String, dynamic> _memoryCache = {};
  final Map<String, DateTime> _expirationMap = {};
  final int _maxCacheEntries = 500;
  final int _maxCacheSizeMB = 50;

  // -------------------- Initialization --------------------
  Future<void> initialize() async {
    if (_initialized) return;
    WidgetsFlutterBinding.ensureInitialized();
    _prefs = await SharedPreferences.getInstance();

    // ✅ Initialize Hive with Flutter support
    await Hive.initFlutter();
    _cacheBox = await Hive.openBox('app_cache');

    await _cleanupExpiredData();
    _initialized = true;
  }

  // -------------------- Basic Key-Value Storage --------------------
  Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
    _memoryCache[key] = value;
  }

  String? getString(String key) {
    if (_memoryCache.containsKey(key)) return _memoryCache[key];
    return _prefs.getString(key);
  }

  Future<void> saveInt(String key, int value) async {
    await _prefs.setInt(key, value);
    _memoryCache[key] = value;
  }

  int? getInt(String key) {
    if (_memoryCache.containsKey(key)) return _memoryCache[key];
    return _prefs.getInt(key);
  }

  Future<void> saveBool(String key, bool value) async {
    await _prefs.setBool(key, value);
    _memoryCache[key] = value;
  }

  bool? getBool(String key) {
    if (_memoryCache.containsKey(key)) return _memoryCache[key];
    return _prefs.getBool(key);
  }

  Future<void> saveDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
    _memoryCache[key] = value;
  }

  double? getDouble(String key) {
    if (_memoryCache.containsKey(key)) return _memoryCache[key];
    return _prefs.getDouble(key);
  }

  // -------------------- Object and List Storage --------------------
  Future<void> saveObject(String key, Map<String, dynamic> object) async {
    final jsonString = jsonEncode(object);
    await _cacheBox?.put(key, jsonString);
    _memoryCache[key] = object;
  }

  Map<String, dynamic>? getObject(String key) {
    if (_memoryCache.containsKey(key)) return _memoryCache[key];
    final jsonString = _cacheBox?.get(key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  Future<void> saveList(String key, List<dynamic> list) async {
    final jsonString = jsonEncode(list);
    await _cacheBox?.put(key, jsonString);
    _memoryCache[key] = list;
  }

  List<dynamic>? getList(String key) {
    if (_memoryCache.containsKey(key)) return _memoryCache[key];
    final jsonString = _cacheBox?.get(key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString) as List<dynamic>;
  }

  // -------------------- Image Caching --------------------
  Future<void> saveImage(String key, File imageFile) async {
    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/$key.png';
    await imageFile.copy(filePath);
    await _cacheBox?.put('image_$key', filePath);
  }

  Future<File?> getImage(String key) async {
    final filePath = _cacheBox?.get('image_$key');
    if (filePath == null) return null;
    final file = File(filePath);
    if (await file.exists()) return file;
    return null;
  }

  // -------------------- Cache Management --------------------
  Future<void> remove(String key) async {
    await _prefs.remove(key);
    await _cacheBox?.delete(key);
    _memoryCache.remove(key);
    _expirationMap.remove(key);
  }

  Future<void> clear() async {
    await _prefs.clear();
    await _cacheBox?.clear();
    _memoryCache.clear();
    _expirationMap.clear();
  }

  bool containsKey(String key) {
    return _prefs.containsKey(key) ||
        _cacheBox?.containsKey(key) == true ||
        _memoryCache.containsKey(key);
  }

  List<String> getAllKeys() {
    final keys = <String>{};
    keys.addAll(_prefs.getKeys());
    keys.addAll(_cacheBox?.keys.cast<String>() ?? []);
    keys.addAll(_memoryCache.keys);
    return keys.toList();
  }

  Future<double> getCacheSize() async {
    final dir = await getApplicationDocumentsDirectory();
    int totalBytes = 0;
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        totalBytes += await entity.length();
      }
    }
    return totalBytes / (1024 * 1024);
  }

  // -------------------- Expiration Management --------------------
  Future<void> setExpiration(String key, Duration duration) async {
    final expirationTime = DateTime.now().add(duration);
    _expirationMap[key] = expirationTime;
    await _cacheBox?.put('exp_$key', expirationTime.toIso8601String());
  }

  DateTime? getExpiration(String key) {
    if (_expirationMap.containsKey(key)) return _expirationMap[key];
    final expString = _cacheBox?.get('exp_$key');
    if (expString == null) return null;
    return DateTime.tryParse(expString);
  }

  bool isExpired(String key) {
    final expiration = getExpiration(key);
    if (expiration == null) return false;
    return DateTime.now().isAfter(expiration);
  }

  Future<void> refreshCache(String key) async {
    if (containsKey(key)) {
      final value = _cacheBox?.get(key);
      if (value != null) {
        _memoryCache[key] = value;
      }
    }
  }

  Future<void> _cleanupExpiredData() async {
    final keys = getAllKeys();
    for (final key in keys) {
      if (isExpired(key)) {
        await remove(key);
      }
    }
  }

  // -------------------- Memory Management --------------------
  Future<void> enforceCacheLimits() async {
    final cacheSize = await getCacheSize();
    if (cacheSize > _maxCacheSizeMB) {
      await _evictLeastRecentlyUsed();
    }
    if (_memoryCache.length > _maxCacheEntries) {
      await _evictLeastRecentlyUsed();
    }
  }

  Future<void> _evictLeastRecentlyUsed() async {
    if (_memoryCache.isEmpty) return;
    final oldestKey = _expirationMap.entries
        .where((e) => e.value.isBefore(DateTime.now()))
        .map((e) => e.key)
        .firstOrNull;
    if (oldestKey != null) {
      await remove(oldestKey);
    } else {
      final firstKey = _memoryCache.keys.first;
      await remove(firstKey);
    }
  }

  // -------------------- Cache Categories --------------------
  Future<void> cacheUserPreferences(Map<String, dynamic> prefs) async {
    await saveObject('user_preferences', prefs);
    await setExpiration('user_preferences', const Duration(days: 30));
  }

  Future<void> cacheApiResponse(String endpoint, Map<String, dynamic> data) async {
    await saveObject('api_$endpoint', data);
    await setExpiration('api_$endpoint', const Duration(hours: 6));
  }

  Future<void> cacheWeatherData(Map<String, dynamic> data) async {
    await saveObject('weather_data', data);
    await setExpiration('weather_data', const Duration(hours: 3));
  }

  Future<void> cacheCropData(Map<String, dynamic> data) async {
    await saveObject('crop_data', data);
    await setExpiration('crop_data', const Duration(days: 7));
  }

  Future<void> cacheDiseaseData(Map<String, dynamic> data) async {
    await saveObject('disease_data', data);
    await setExpiration('disease_data', const Duration(days: 7));
  }

  Future<void> cacheAnalysisResults(Map<String, dynamic> data) async {
    await saveObject('analysis_results', data);
    await setExpiration('analysis_results', const Duration(days: 3));
  }

  Future<void> cacheSessionData(Map<String, dynamic> data) async {
    await saveObject('session_data', data);
    await setExpiration('session_data', const Duration(hours: 12));
  }

  // -------------------- Utility --------------------
  Future<void> printCacheSummary() async {
    final size = await getCacheSize();
    debugPrint('Cache Summary:');
    debugPrint('Total Keys: ${getAllKeys().length}');
    debugPrint('Cache Size: ${size.toStringAsFixed(2)} MB');
  }

  // -------------------- Cleanup --------------------
  Future<void> dispose() async {
    await _cacheBox?.close();
  }
}

extension _IterableFirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}