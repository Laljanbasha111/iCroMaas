import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../core/services/firestore_service.dart';
import '../models/user_model.dart';

/// ProfileProvider manages user profile data, updates, image uploads,
/// validation, and profile completion tracking.
class ProfileProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  bool _isUpdating = false;
  String? _error;
  UserModel? _currentUser;
  String? _profileImageUrl;
  double _completionPercentage = 0.0;

  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String? get error => _error;
  UserModel? get currentUser => _currentUser;
  String? get profileImageUrl => _profileImageUrl;
  bool get isProfileComplete => _completionPercentage >= 100;
  double get completionPercentage => _completionPercentage;

  /// Load user profile from Firestore.
  Future<void> loadProfile(String userId) async {
    _setLoading(true);
    try {
      final doc = await _firestoreService.getDocument('users', userId);

      if (doc != null && doc.exists) {
        final userData = Map<String, dynamic>.from(
          doc.data() as Map<String, dynamic>,
        );

        userData['id'] = userId;

        _currentUser = UserModel.fromMap(userData);
        _profileImageUrl = _currentUser!.profileImageUrl;

        _calculateProfileCompletion();
      }
      _error = null;
    } catch (e) {
      _handleError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Update complete profile.
  Future<void> updateProfile(UserModel user) async {
    _setUpdating(true);
    try {
      await _firestoreService.updateDocument('users', user.id, user.toMap());
      _currentUser = user;
      _calculateProfileCompletion();
      _error = null;
    } catch (e) {
      _handleError(e);
    } finally {
      _setUpdating(false);
    }
  }

  /// Update name only.
  Future<void> updateName(String name) async {
    if (name.trim().isEmpty) {
      _error = 'Name cannot be empty';
      notifyListeners();
      return;
    }
    await _updateField('name', name);
  }

  /// Update email (Note: Firebase Auth email update requires re-authentication).
  Future<void> updateEmail(String email) async {
    if (!_validateEmail(email)) {
      _error = 'Invalid email address';
      notifyListeners();
      return;
    }
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.verifyBeforeUpdateEmail(email);
        await _updateField('email', email);
      }
    } catch (e) {
      _handleError(e);
    }
  }
  Future<void> verifyEmail() async {
    await FirebaseAuth.instance.currentUser?.sendEmailVerification();
  }

  /// Update phone number.
  Future<void> updatePhone(String phone) async {
    if (!_validatePhone(phone)) {
      _error = 'Invalid phone number';
      notifyListeners();
      return;
    }
    await _updateField('phone', phone);
  }

  /// Update location.
  Future<void> updateLocation(String location) async {
    await _updateField('location', location);
  }

  /// Update farm size.
  Future<void> updateFarmSize(double size) async {
    await _updateField('farmSize', size);
  }

  /// Update crops list.
  Future<void> updateCrops(List<String> crops) async {
    await _updateField('crops', crops);
  }

  /// Update preferred language.
  Future<void> updateLanguage(String language) async {
    await _updateField('language', language);
  }

  /// Upload profile image from file.
  Future<void> uploadProfileImage(File imageFile) async {
    _setUpdating(true);
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');
      final compressed = await _compressImage(imageFile);
      final imageUrl = await _uploadImageToStorage(compressed, userId);
      await _updateField('profileImageUrl', imageUrl);
      _profileImageUrl = imageUrl;
      _error = null;
    } catch (e) {
      _handleError(e);
    } finally {
      _setUpdating(false);
    }
  }

  /// Pick image from gallery and upload.
  Future<void> pickAndUploadImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      await uploadProfileImage(File(picked.path));
    }
  }

  /// Capture image from camera and upload.
  Future<void> captureAndUploadImage() async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      await uploadProfileImage(File(picked.path));
    }
  }

  /// Delete profile image.
  Future<void> deleteProfileImage() async {
    _setUpdating(true);
    try {
      if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
        await _deleteImageFromStorage(_profileImageUrl!);
        await _updateField('profileImageUrl', '');
        _profileImageUrl = '';
      }
      _error = null;
    } catch (e) {
      _handleError(e);
    } finally {
      _setUpdating(false);
    }
  }

  /// Validate profile completeness.
  bool validateProfile() {
    if (_currentUser == null) return false;
    final user = _currentUser!;
    if (user.name.isEmpty ||
        user.email.isEmpty ||
        user.phone.isEmpty ||
        user.location.isEmpty ||
        user.farmSize <= 0 ||
        user.crops.isEmpty) {
      return false;
    }
    return true;
  }

  /// Calculate profile completion percentage.
  void _calculateProfileCompletion() {
    if (_currentUser == null) {
      _completionPercentage = 0;
      return;
    }
    final user = _currentUser!;
    int completed = 0;
    const int total = 7;

    if (user.name.isNotEmpty) completed++;
    if (user.email.isNotEmpty) completed++;
    if (user.phone.isNotEmpty) completed++;
    if (user.location.isNotEmpty) completed++;
    if (user.farmSize > 0) completed++;
    if (user.crops.isNotEmpty) completed++;
    if (user.profileImageUrl.isNotEmpty) completed++;

    _completionPercentage = (completed / total) * 100;
    notifyListeners();
  }

  /// Refresh profile data.
  Future<void> refreshProfile() async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await loadProfile(userId);
    }
  }

  /// Reset profile to default.
  Future<void> resetProfile() async {
    _currentUser = null;
    _profileImageUrl = null;
    _completionPercentage = 0.0;
    _error = null;
    notifyListeners();
  }

  /// Helper: Update a single field in Firestore and local model.
  Future<void> _updateField(String field, dynamic value) async {
    _setUpdating(true);
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');
      await _firestoreService.updateDocument('users', userId, {
        field: value,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      final updatedMap = _currentUser?.toMap() ?? <String, dynamic>{'id': userId};
      updatedMap[field] = value;
      updatedMap['updatedAt'] = DateTime.now().toIso8601String();
      _currentUser = UserModel.fromMap(updatedMap);
      _calculateProfileCompletion();
      _error = null;
    } catch (e) {
      _handleError(e);
    } finally {
      _setUpdating(false);
    }
  }

  /// Helper: Upload image to Firebase Storage.
  Future<String> _uploadImageToStorage(File image, String userId) async {
    final fileName =
        'profile_${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
    final ref = _storage.ref().child('profile_images/$userId/$fileName');
    final uploadTask = await ref.putFile(image);
    return await uploadTask.ref.getDownloadURL();
  }

  /// Helper: Delete image from Firebase Storage.
  Future<void> _deleteImageFromStorage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      log('Failed to delete image: $e');
    }
  }

  /// Helper: Compress image before upload.
  Future<File> _compressImage(File image) async {
    final targetPath = path.join(
      path.dirname(image.path),
      'compressed_${path.basename(image.path)}',
    );
    final result = await FlutterImageCompress.compressAndGetFile(
      image.absolute.path,
      targetPath,
      quality: 75,
    );
    return result != null ? File(result.path) : image;
  }

  /// Helper: Validate email format.
  bool _validateEmail(String email) {
    final regex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  /// Helper: Validate phone number format.
  bool _validatePhone(String phone) {
    final regex = RegExp(r'^\+?[0-9]{7,15}$');
    return regex.hasMatch(phone);
  }

  /// Helper: Set loading state.
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Helper: Set updating state.
  void _setUpdating(bool value) {
    _isUpdating = value;
    notifyListeners();
  }

  /// Helper: Handle errors.
  void _handleError(dynamic error) {
    _error = error.toString();
    log('ProfileProvider Error: $_error');
    _isLoading = false;
    _isUpdating = false;
    notifyListeners();
  }
}