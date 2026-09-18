import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_auth/local_auth.dart';

class UserProfile {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final bool emailVerified;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  UserProfile({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
    this.emailVerified = false,
    this.createdAt,
    this.lastLoginAt,
  });

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'phoneNumber': phoneNumber,
    'emailVerified': emailVerified,
    'createdAt': createdAt?.toIso8601String(),
    'lastLoginAt': lastLoginAt?.toIso8601String(),
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    uid: json['uid'],
    email: json['email'],
    displayName: json['displayName'],
    photoUrl: json['photoUrl'],
    phoneNumber: json['phoneNumber'],
    emailVerified: json['emailVerified'] ?? false,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : null,
    lastLoginAt: json['lastLoginAt'] != null
        ? DateTime.parse(json['lastLoginAt'])
        : null,
  );
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // FIX 1: Properly initialize GoogleSignIn with scopes
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  final LocalAuthentication _localAuth = LocalAuthentication();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> initialize() async {
    await _auth.setPersistence(Persistence.LOCAL);
  }

  // -------------------- Email/Password Authentication --------------------
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      await _updateUserProfileInFirestore(credential.user);
      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(getAuthErrorMessage(e.code));
    }
  }

  Future<UserCredential?> signUpWithEmail(
      String email, String password, String name) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await credential.user?.updateDisplayName(name);
      await credential.user?.sendEmailVerification();
      await _createUserProfileInFirestore(credential.user, name);
      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(getAuthErrorMessage(e.code));
    }
  }

  // -------------------- Google Sign-In --------------------
  // FIX 2: Correct method name from 'signin' to 'signIn'
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      await _updateUserProfileInFirestore(userCredential.user);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(getAuthErrorMessage(e.code));
    }
  }

  // -------------------- Phone Authentication --------------------
  Future<void> signInWithPhone(String phoneNumber,
      {required Function(String verificationId) codeSent,
        required Function(PhoneAuthCredential credential) verificationCompleted,
        required Function(String error) verificationFailed}) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: formatPhoneNumber(phoneNumber),
        verificationCompleted: verificationCompleted,
        verificationFailed: (e) => verificationFailed(e.message ?? 'Error'),
        codeSent: (verificationId, _) => codeSent(verificationId),
        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (e) {
      throw Exception('Phone authentication failed: $e');
    }
  }

  Future<UserCredential?> verifyOTP(
      String verificationId, String smsCode) async {
    try {
      final credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: smsCode);
      final userCredential = await _auth.signInWithCredential(credential);
      await _updateUserProfileInFirestore(userCredential.user);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(getAuthErrorMessage(e.code));
    }
  }

  // -------------------- Anonymous Authentication --------------------
  Future<UserCredential?> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();
      await _updateUserProfileInFirestore(credential.user);
      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(getAuthErrorMessage(e.code));
    }
  }

  // -------------------- Biometric Authentication --------------------
  // FIX 3 & 4: Correct AuthenticationOptions usage
  Future<bool> authenticateWithBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) return false;
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access Crop Analyzer',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      debugPrint('Biometric auth error: $e');
      return false;
    }
  }

  // -------------------- User Management --------------------
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(getAuthErrorMessage(e.code));
    }
  }

  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw Exception(getAuthErrorMessage(e.code));
    }
  }

  Future<void> updateProfile(String name, String? photoUrl) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(name);
        if (photoUrl != null) await user.updatePhotoURL(photoUrl);
        await _updateUserProfileInFirestore(user);
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

  Future<void> reauthenticate(String password) async {
    try {
      final user = _auth.currentUser;
      if (user != null && user.email != null) {
        final credential = EmailAuthProvider.credential(
            email: user.email!, password: password);
        await user.reauthenticateWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(getAuthErrorMessage(e.code));
    }
  }

  // -------------------- User Session --------------------
  User? getCurrentUser() => _auth.currentUser;
  bool isUserLoggedIn() => _auth.currentUser != null;
  String? getUserId() => _auth.currentUser?.uid;
  String? getUserEmail() => _auth.currentUser?.email;
  bool isEmailVerified() => _auth.currentUser?.emailVerified ?? false;

  Future<String?> getIdToken() async {
    return await _auth.currentUser?.getIdToken();
  }

  Stream<User?> get userChanges => _auth.userChanges();

  // -------------------- Firestore User Profile --------------------
  Future<void> _createUserProfileInFirestore(User? user, String name) async {
    if (user == null) return;
    final userProfile = UserProfile(
      uid: user.uid,
      email: user.email,
      displayName: name,
      photoUrl: user.photoURL,
      phoneNumber: user.phoneNumber,
      emailVerified: user.emailVerified,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
    await _firestore.collection('users').doc(user.uid).set(userProfile.toJson());
  }

  Future<void> _updateUserProfileInFirestore(User? user) async {
    if (user == null) return;
    final data = {
      'displayName': user.displayName,
      'photoUrl': user.photoURL,
      'emailVerified': user.emailVerified,
      'lastLoginAt': DateTime.now().toIso8601String(),
    };
    await _firestore.collection('users').doc(user.uid).set(data, SetOptions(merge: true));
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserProfile.fromJson(doc.data()!);
    }
    return null;
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
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return 'Authentication error occurred.';
    }
  }

  bool isEmailValid(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  bool isPasswordStrong(String password) {
    final regex = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d).{8,}$');
    return regex.hasMatch(password);
  }

  bool isPhoneNumberValid(String phone) {
    final regex = RegExp(r'^\+?[0-9]{10,15}$');
    return regex.hasMatch(phone);
  }

  String formatPhoneNumber(String phone) {
    if (!phone.startsWith('+')) {
      return '+$phone';
    }
    return phone;
  }
}