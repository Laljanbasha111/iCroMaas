import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../router/app_routes.dart';

/// RouteGuards handle authentication and permission-based navigation.
class RouteGuards {
  /// Ensures user is authenticated before accessing protected routes.
  static String? authGuard(BuildContext context, GoRouterState state) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return AppRoutes.login;
    }
    return null;
  }

  /// Restricts access to admin-only routes.
  static String? adminGuard(BuildContext context, GoRouterState state) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return AppRoutes.home;
    }
    // Note: Firebase Auth doesn't have built-in roles
    // You'll need to implement custom claims or Firestore-based roles
    return null;
  }

  /// Example of a permission-based guard (e.g., camera or location).
  static String? permissionGuard(
      BuildContext context,
      GoRouterState state,
      bool hasPermission,
      ) {
    if (!hasPermission) {
      // Note: Don't use context in redirect functions
      // Show snackbar after navigation instead
      return AppRoutes.settings;
    }
    return null;
  }
}

