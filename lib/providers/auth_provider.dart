import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Handles authentication for the Crop Analyzer application.
///
/// Supports:
/// - Email/password sign in
/// - Email/password account creation
/// - Firebase authentication state
/// - Sign out
///
/// Google Sign-In is intentionally not initialized in this provider.
/// This avoids relying on a version-specific GoogleSignIn constructor.
/// If Google login is implemented elsewhere, that code can manage its
/// GoogleSignIn instance independently.
class AppAuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;

  bool get isLoading => _isLoading;

  String? get error => _error;

  bool get isAuthenticated => _user != null;

  AppAuthProvider() {
    _listenToAuthState();
  }

  /// Listen for Firebase authentication state changes.
  void _listenToAuthState() {
    _auth.authStateChanges().listen(
          (User? user) {
        _user = user;
        notifyListeners();
      },
      onError: (Object error) {
        log(
          '❌ Authentication state error: $error',
          name: 'AppAuthProvider',
        );
      },
    );
  }

  /// Sign in using email and password.
  Future<void> signInWithEmail(
      String email,
      String password,
      ) async {
    _setLoading(true);
    _clearError();

    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      _error = null;

      log(
        '✅ Email sign-in successful',
        name: 'AppAuthProvider',
      );
    } on FirebaseAuthException catch (e) {
      _error = _firebaseAuthErrorMessage(e);

      log(
        '❌ Sign-in error: ${e.code} - ${e.message}',
        name: 'AppAuthProvider',
      );
    } catch (e, stackTrace) {
      _error = 'Unable to sign in. Please try again.';

      log(
        '❌ Unexpected sign-in error: $e',
        name: 'AppAuthProvider',
        stackTrace: stackTrace,
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Create a new Firebase account using email and password.
  Future<void> signUpWithEmail(
      String email,
      String password,
      ) async {
    _setLoading(true);
    _clearError();

    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      _error = null;

      log(
        '✅ Account creation successful',
        name: 'AppAuthProvider',
      );
    } on FirebaseAuthException catch (e) {
      _error = _firebaseAuthErrorMessage(e);

      log(
        '❌ Sign-up error: ${e.code} - ${e.message}',
        name: 'AppAuthProvider',
      );
    } catch (e, stackTrace) {
      _error = 'Unable to create your account. Please try again.';

      log(
        '❌ Unexpected sign-up error: $e',
        name: 'AppAuthProvider',
        stackTrace: stackTrace,
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Sign out the current Firebase user.
  Future<void> signOut() async {
    _setLoading(true);
    _clearError();

    try {
      await _auth.signOut();

      _user = null;
      _error = null;

      log(
        '✅ Sign-out successful',
        name: 'AppAuthProvider',
      );
    } on FirebaseAuthException catch (e) {
      _error = _firebaseAuthErrorMessage(e);

      log(
        '❌ Sign-out error: ${e.code} - ${e.message}',
        name: 'AppAuthProvider',
      );
    } catch (e, stackTrace) {
      _error = 'Unable to sign out. Please try again.';

      log(
        '❌ Unexpected sign-out error: $e',
        name: 'AppAuthProvider',
        stackTrace: stackTrace,
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Update loading state.
  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }

    _isLoading = value;
    notifyListeners();
  }

  /// Clear the current authentication error.
  void _clearError() {
    if (_error == null) {
      return;
    }

    _error = null;
    notifyListeners();
  }

  /// Convert Firebase authentication error codes into
  /// user-friendly messages.
  String _firebaseAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';

      case 'user-disabled':
        return 'This account has been disabled.';

      case 'user-not-found':
        return 'No account was found with this email.';

      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';

      case 'email-already-in-use':
        return 'An account already exists with this email.';

      case 'weak-password':
        return 'The password is too weak. Please use a stronger password.';

      case 'operation-not-allowed':
        return 'Email/password authentication is not enabled.';

      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      case 'requires-recent-login':
        return 'Please sign in again before performing this action.';

      default:
        return e.message?.isNotEmpty == true
            ? e.message!
            : 'Authentication failed. Please try again.';
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}