import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ✅ REMOVED: part 'hive_service.g.dart';
// This will be generated after running build_runner

// -------------------- Type Adapters --------------------
@HiveType(typeId: 1)
class UserModel extends HiveObject {
  @HiveField(0)
  String uid;
  @HiveField(1)
  String name;
  @HiveField(2)
  String email;
  @HiveField(3)
  String? photoUrl;
  @HiveField(4)
  DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.createdAt,
  });
}

@HiveType(typeId: 2)
class CropModel extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String type;
  @HiveField(3)
  DateTime plantedDate;
  @HiveField(4)
  double area;

  CropModel({
    required this.id,
    required this.name,
    required this.type,
    required this.plantedDate,
    required this.area,
  });
}

@HiveType(typeId: 3)
class DiseaseModel extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String cropType;
  @HiveField(3)
  String severity;
  @HiveField(4)
  DateTime detectedAt;

  DiseaseModel({
    required this.id,
    required this.name,
    required this.cropType,
    required this.severity,
    required this.detectedAt,
  });
}

@HiveType(typeId: 4)
class FieldModel extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  double latitude;
  @HiveField(3)
  double longitude;
  @HiveField(4)
  double area;

  FieldModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.area,
  });
}

@HiveType(typeId: 5)
class AnalysisModel extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String cropId;
  @HiveField(2)
  String result;
  @HiveField(3)
  double confidence;
  @HiveField(4)
  DateTime analyzedAt;

  AnalysisModel({
    required this.id,
    required this.cropId,
    required this.result,
    required this.confidence,
    required this.analyzedAt,
  });
}

// -------------------- Hive Service --------------------
class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Map<String, Box> _openBoxes = {};
  bool _initialized = false;
  final int _dbVersion = 1;  // ✅ Changed from int to final int

  // -------------------- Initialization --------------------
  Future<void> initialize() async {
    if (_initialized) return;
    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();

    // ✅ Register adapters (these will be generated)
    // Temporarily comment these out until you generate the adapters
    // Hive.registerAdapter(UserModelAdapter());
    // Hive.registerAdapter(CropModelAdapter());
    // Hive.registerAdapter(DiseaseModelAdapter());
    // Hive.registerAdapter(FieldModelAdapter());
    // Hive.registerAdapter(AnalysisModelAdapter());

    await _migrateDatabase();
    _initialized = true;
  }

  // -------------------- Encryption --------------------
  Future<List<int>> _getEncryptionKey() async {
    const keyName = 'hive_encryption_key';
    String? encodedKey = await _secureStorage.read(key: keyName);
    if (encodedKey == null) {
      final key = Hive.generateSecureKey();
      encodedKey = base64UrlEncode(key);
      await _secureStorage.write(key: keyName, value: encodedKey);
    }
    return base64Url.decode(encodedKey);
  }

  // -------------------- Box Management --------------------
  Future<Box> openBox(String boxName, {bool encrypted = false}) async {
    if (_openBoxes.containsKey(boxName)) return _openBoxes[boxName]!;
    Box box;
    if (encrypted) {
      final key = await _getEncryptionKey();
      box = await Hive.openBox(boxName,
          encryptionCipher: HiveAesCipher(key));
    } else {
      box = await Hive.openBox(boxName);
    }
    _openBoxes[boxName] = box;
    return box;
  }

  Future<void> closeBox(String boxName) async {
    if (_openBoxes.containsKey(boxName)) {
      await _openBoxes[boxName]!.close();
      _openBoxes.remove(boxName);
    }
  }

  Future<void> deleteBox(String boxName) async {
    await closeBox(boxName);
    await Hive.deleteBoxFromDisk(boxName);
  }

  bool boxExists(String boxName) => Hive.isBoxOpen(boxName);

  int getBoxLength(String boxName) {
    final box = _openBoxes[boxName];
    return box?.length ?? 0;
  }

  List<dynamic> getBoxKeys(String boxName) {
    final box = _openBoxes[boxName];
    return box?.keys.toList() ?? [];
  }

  // -------------------- CRUD Operations --------------------
  Future<int> addItem(String boxName, dynamic item) async {
    final box = await openBox(boxName);
    return await box.add(item);
  }

  dynamic getItem(String boxName, dynamic key) {
    final box = _openBoxes[boxName];
    return box?.get(key);
  }

  Future<void> updateItem(String boxName, dynamic key, dynamic item) async {
    final box = _openBoxes[boxName];
    if (box != null && box.containsKey(key)) {
      await box.put(key, item);
    }
  }

  Future<void> deleteItem(String boxName, dynamic key) async {
    final box = _openBoxes[boxName];
    if (box != null && box.containsKey(key)) {
      await box.delete(key);
    }
  }

  List<dynamic> getAllItems(String boxName) {
    final box = _openBoxes[boxName];
    return box?.values.toList() ?? [];
  }

  Future<void> clearBox(String boxName) async {
    final box = _openBoxes[boxName];
    await box?.clear();
  }

  // -------------------- Migration --------------------
  Future<void> _migrateDatabase() async {
    final prefsFile = File('${(await getApplicationDocumentsDirectory()).path}/hive_version.txt');
    int currentVersion = 0;
    if (await prefsFile.exists()) {
      final content = await prefsFile.readAsString();
      currentVersion = int.tryParse(content) ?? 0;
    }

    if (currentVersion < _dbVersion) {
      await _performMigration(currentVersion, _dbVersion);
      await prefsFile.writeAsString('$_dbVersion');
    }
  }

  Future<void> _performMigration(int oldVersion, int newVersion) async {
    debugPrint('Migrating Hive database from v$oldVersion to v$newVersion...');
    if (oldVersion < 1) {
      await Hive.openBox('users_box');
      await Hive.openBox('crops_box');
      await Hive.openBox('diseases_box');
      await Hive.openBox('fields_box');
      await Hive.openBox('analyses_box');
      await Hive.openBox('settings_box');
      await Hive.openBox('cache_box');
    }
  }

  // -------------------- Backup & Restore --------------------
  Future<String> backupDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${dir.path}/hive_backup');
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    for (final boxName in _openBoxes.keys) {
      final box = _openBoxes[boxName];
      if (box != null) {
        final file = File('${backupDir.path}/$boxName.json');
        final data = box.toMap();
        await file.writeAsString(jsonEncode(data));
      }
    }

    return backupDir.path;
  }

  Future<void> restoreDatabase(String backupPath) async {
    final backupDir = Directory(backupPath);
    if (!await backupDir.exists()) {
      throw Exception('Backup directory not found');
    }

    final files = backupDir.listSync();
    for (final file in files) {
      if (file is File && file.path.endsWith('.json')) {
        final boxName = file.uri.pathSegments.last.replaceAll('.json', '');
        final content = await file.readAsString();
        final data = jsonDecode(content);
        final box = await openBox(boxName);
        await box.clear();
        await box.putAll(Map<String, dynamic>.from(data));
      }
    }
  }

  // -------------------- Utility --------------------
  Future<void> printBoxSummary(String boxName) async {
    final box = _openBoxes[boxName];
    if (box == null) {
      debugPrint('Box "$boxName" is not open.');
      return;
    }
    debugPrint('Box "$boxName" Summary:');
    debugPrint('Total Items: ${box.length}');
    debugPrint('Keys: ${box.keys.toList()}');
  }

  Future<void> closeAllBoxes() async {
    for (final box in _openBoxes.values) {
      await box.close();
    }
    _openBoxes.clear();
  }

  Future<void> dispose() async {
    await closeAllBoxes();
  }
}