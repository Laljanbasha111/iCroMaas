import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  bool _initialized = false;

  late FirebaseApp _firebaseApp;
  late FirebaseAuth _auth;
  late FirebaseFirestore _firestore;
  late FirebaseStorage _storage;

  // -------------------- Initialization --------------------
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      _firebaseApp = await Firebase.initializeApp();
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _storage = FirebaseStorage.instance;
      _firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      _initialized = true;
    } catch (e) {
      debugPrint('Firebase initialization error: $e');
      rethrow;
    }
  }

  bool isInitialized() => _initialized;

  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;
  FirebaseStorage get storage => _storage;

  // -------------------- Authentication --------------------
  User? getCurrentUser() => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  bool isUserLoggedIn() => _auth.currentUser != null;

  String? getUserId() => _auth.currentUser?.uid;

  String? getUserEmail() => _auth.currentUser?.email;

  Future<UserCredential?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(getAuthErrorMessage(e.code));
    } catch (e) {
      throw Exception('Sign-in failed: $e');
    }
  }

  Future<UserCredential?> signUp(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.sendEmailVerification();
      await _firestore.collection('users').doc(credential.user?.uid).set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(getAuthErrorMessage(e.code));
    } catch (e) {
      throw Exception('Sign-up failed: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign-out failed: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(getAuthErrorMessage(e.code));
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  Future<void> updateProfile(String displayName, String? photoUrl) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        if (photoUrl != null) {
          await user.updatePhotoURL(photoUrl);
        }
        await user.reload();
      }
    } catch (e) {
      throw Exception('Profile update failed: $e');
    }
  }

  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).delete();
        await user.delete();
      }
    } catch (e) {
      throw Exception('Account deletion failed: $e');
    }
  }

  // -------------------- Storage --------------------
  Future<String?> uploadImage(File file, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw Exception(getStorageErrorMessage(e.code));
    } catch (e) {
      throw Exception('Image upload failed: $e');
    }
  }

  Future<Uint8List?> downloadImage(String path) async {
    try {
      final ref = _storage.ref().child(path);
      return await ref.getData();
    } on FirebaseException catch (e) {
      throw Exception(getStorageErrorMessage(e.code));
    } catch (e) {
      throw Exception('Image download failed: $e');
    }
  }

  Future<void> deleteImage(String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.delete();
    } on FirebaseException catch (e) {
      throw Exception(getStorageErrorMessage(e.code));
    } catch (e) {
      throw Exception('Image deletion failed: $e');
    }
  }

  Future<String?> getDownloadUrl(String path) async {
    try {
      final ref = _storage.ref().child(path);
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw Exception(getStorageErrorMessage(e.code));
    } catch (e) {
      throw Exception('Failed to get download URL: $e');
    }
  }

  Future<String?> uploadCropImage(File file, String userId, String cropId) async {
    final path = generateStoragePath(userId, 'crops', cropId);
    return await uploadImage(file, path);
  }

  Future<String?> uploadDiseaseImage(File file, String userId, String diseaseId) async {
    final path = generateStoragePath(userId, 'diseases', diseaseId);
    return await uploadImage(file, path);
  }

  // -------------------- Firestore Integration --------------------
  Future<void> createUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  Future<DocumentSnapshot?> getUserProfile(String userId) async {
    try {
      return await _firestore.collection('users').doc(userId).get();
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  Future<void> deleteUserProfile(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user profile: $e');
    }
  }

  // -------------------- Helper Methods --------------------
  String getAuthErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return 'Authentication error occurred.';
    }
  }

  String getStorageErrorMessage(String code) {
    switch (code) {
      case 'object-not-found':
        return 'File not found.';
      case 'unauthorized':
        return 'You do not have permission to access this file.';
      case 'cancelled':
        return 'Upload cancelled.';
      case 'unknown':
        return 'Unknown storage error occurred.';
      default:
        return 'Storage error occurred.';
    }
  }

  bool isEmailValid(String email) {
    final regex = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  bool isPasswordStrong(String password) {
    final regex = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d).{8,}$');
    return regex.hasMatch(password);
  }

  String generateStoragePath(String userId, String type, String id) {
    return 'users/$userId/$type/$id/${DateTime.now().millisecondsSinceEpoch}.jpg';
  }
}