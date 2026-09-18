import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:crypto/crypto.dart';

class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  late FlutterSecureStorage _secureStorage;
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _initialized = false;
  bool _biometricEnabled = false;

  // -------------------- Initialization --------------------
  Future<void> initialize() async {
    if (_initialized) return;

    // FIX 1: Remove deprecated encryptedSharedPreferences
    const androidOptions = AndroidOptions(
      resetOnError: true,
    );
    const iosOptions = IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    );
    _secureStorage = const FlutterSecureStorage(
      aOptions: androidOptions,
      iOptions: iosOptions,
    );

    // Check if biometric was previously enabled
    final biometricStatus = await read('biometric_enabled');
    _biometricEnabled = biometricStatus == 'true';

    _initialized = true;
  }

  // -------------------- Basic Operations --------------------
  Future<void> write(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _secureStorage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _secureStorage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await _secureStorage.deleteAll();
  }

  Future<bool> containsKey(String key) async {
    return await _secureStorage.containsKey(key: key);
  }

  Future<Map<String, String>> readAll() async {
    return await _secureStorage.readAll();
  }

  // -------------------- Token Management --------------------
  Future<void> saveToken(String token) async {
    final encryptedToken = _encryptData(token);
    await write('auth_token', encryptedToken);
  }

  Future<String?> getToken() async {
    final encryptedToken = await read('auth_token');
    if (encryptedToken == null) return null;
    return _decryptData(encryptedToken);
  }

  Future<void> deleteToken() async {
    await delete('auth_token');
  }

  Future<void> saveRefreshToken(String token) async {
    final encryptedToken = _encryptData(token);
    await write('refresh_token', encryptedToken);
  }

  Future<String?> getRefreshToken() async {
    final encryptedToken = await read('refresh_token');
    if (encryptedToken == null) return null;
    return _decryptData(encryptedToken);
  }

  Future<void> deleteRefreshToken() async {
    await delete('refresh_token');
  }

  // -------------------- Credential Management --------------------
  Future<void> saveCredentials(String username, String password) async {
    final credentials = jsonEncode({
      'username': username,
      'password': _encryptData(password),
    });
    await write('user_credentials', credentials);
  }

  Future<Map<String, String>?> getCredentials() async {
    final data = await read('user_credentials');
    if (data == null) return null;
    final decoded = jsonDecode(data);
    return {
      'username': decoded['username'],
      'password': _decryptData(decoded['password']),
    };
  }

  Future<void> deleteCredentials() async {
    await delete('user_credentials');
  }

  // -------------------- API Key Management --------------------
  Future<void> saveApiKey(String apiKey) async {
    final encryptedKey = _encryptData(apiKey);
    await write('api_key', encryptedKey);
  }

  Future<String?> getApiKey() async {
    final encryptedKey = await read('api_key');
    if (encryptedKey == null) return null;
    return _decryptData(encryptedKey);
  }

  Future<void> deleteApiKey() async {
    await delete('api_key');
  }

  // -------------------- Encryption Key Management --------------------
  Future<void> saveEncryptionKey(String key) async {
    final hash = sha256.convert(utf8.encode(key)).toString();
    await write('encryption_key', hash);
  }

  Future<String?> getEncryptionKey() async {
    return await read('encryption_key');
  }

  Future<void> deleteEncryptionKey() async {
    await delete('encryption_key');
  }

  // -------------------- Biometric Authentication --------------------
  Future<bool> isBiometricAvailable() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheckBiometrics && isDeviceSupported;
    } catch (e) {
      debugPrint('Error checking biometric availability: $e');
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Error getting available biometrics: $e');
      return [];
    }
  }

  // FIX 2: Update authenticate method signature
  Future<bool> enableBiometricProtection() async {
    try {
      final canCheck = await isBiometricAvailable();
      if (!canCheck) {
        debugPrint('Biometric authentication not available');
        return false;
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Enable biometric protection for secure storage',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        _biometricEnabled = true;
        await write('biometric_enabled', 'true');
      }
      return authenticated;
    } catch (e) {
      debugPrint('Error enabling biometric protection: $e');
      return false;
    }
  }

  // FIX 3: Update authenticate method signature
  Future<bool> authenticateWithBiometrics() async {
    if (!_biometricEnabled) {
      debugPrint('Biometric protection is not enabled');
      return false;
    }

    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access secure data',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      debugPrint('Biometric authentication error: $e');
      return false;
    }
  }

  Future<void> disableBiometricProtection() async {
    _biometricEnabled = false;
    await delete('biometric_enabled');
  }

  Future<bool> isBiometricEnabled() async {
    final value = await read('biometric_enabled');
    return value == 'true';
  }

  // -------------------- Session Management --------------------
  Future<void> saveSessionToken(String token) async {
    final encryptedToken = _encryptData(token);
    await write('session_token', encryptedToken);
  }

  Future<String?> getSessionToken() async {
    final encryptedToken = await read('session_token');
    if (encryptedToken == null) return null;
    return _decryptData(encryptedToken);
  }

  Future<void> deleteSessionToken() async {
    await delete('session_token');
  }

  // -------------------- Private Key Management --------------------
  Future<void> savePrivateKey(String privateKey) async {
    final encryptedKey = _encryptData(privateKey);
    await write('private_key', encryptedKey);
  }

  Future<String?> getPrivateKey() async {
    final encryptedKey = await read('private_key');
    if (encryptedKey == null) return null;
    return _decryptData(encryptedKey);
  }

  Future<void> deletePrivateKey() async {
    await delete('private_key');
  }

  // -------------------- Expiration Management --------------------
  Future<void> saveTokenWithExpiry(String token, Duration duration) async {
    final expiry = DateTime.now().add(duration).toIso8601String();
    await saveToken(token);
    await write('token_expiry', expiry);
  }

  Future<bool> isTokenExpired() async {
    final expiryString = await read('token_expiry');
    if (expiryString == null) return true;

    final expiry = DateTime.tryParse(expiryString);
    if (expiry == null) return true;

    return DateTime.now().isAfter(expiry);
  }

  Future<void> clearExpiredTokens() async {
    if (await isTokenExpired()) {
      await deleteToken();
      await delete('token_expiry');
    }
  }

  // -------------------- Helper Methods --------------------
  Future<bool> isSecureStorageAvailable() async {
    try {
      await write('test_key', 'test_value');
      final value = await read('test_key');
      await delete('test_key');
      return value == 'test_value';
    } catch (e) {
      debugPrint('Secure storage not available: $e');
      return false;
    }
  }

  Map<String, dynamic> getStorageOptions() {
    return {
      'platform': 'Flutter Secure Storage',
      'encryption': 'AES-256',
      'biometric': _biometricEnabled,
      'keychain': 'iOS Keychain / Android Keystore',
    };
  }

  // -------------------- Encryption Helpers --------------------
  String _encryptData(String data) {
    // Simple HMAC-based encryption for demonstration
    // In production, use proper AES encryption
    final key = utf8.encode('CropAnalyzerSecureKey2024!@#');
    final bytes = utf8.encode(data);
    final hmacSha256 = Hmac(sha256, key); // FIX 4: Correct capitalization
    final digest = hmacSha256.convert(bytes);

    // Combine original data with hash for verification
    final combined = '$data:${base64UrlEncode(digest.bytes)}';
    return base64UrlEncode(utf8.encode(combined));
  }

  String _decryptData(String encryptedData) {
    try {
      // Decode the base64 data
      final decoded = utf8.decode(base64Url.decode(encryptedData));

      // Split to get original data (before the hash)
      final parts = decoded.split(':');
      if (parts.isEmpty) return encryptedData;

      return parts[0];
    } catch (e) {
      debugPrint('Decryption error: $e');
      return encryptedData;
    }
  }

  // -------------------- Debug Utilities --------------------
  Future<void> printSecureStorageSummary() async {
    final allData = await readAll();
    debugPrint('═══════════════════════════════════════');
    debugPrint('Secure Storage Summary');
    debugPrint('═══════════════════════════════════════');
    debugPrint('Total Keys: ${allData.length}');
    debugPrint('Biometric Enabled: $_biometricEnabled');
    debugPrint('───────────────────────────────────────');
    for (final entry in allData.entries) {
      // Don't print sensitive values in production
      debugPrint('${entry.key}: [ENCRYPTED]');
    }
    debugPrint('═══════════════════════════════════════');
  }

  // -------------------- Cleanup --------------------
  Future<void> dispose() async {
    // Clean up resources if needed
    _initialized = false;
  }
}