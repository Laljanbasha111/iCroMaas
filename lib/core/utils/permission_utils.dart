import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  // -----------------------------
  // CAMERA PERMISSION
  // -----------------------------

  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> checkCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  static Future<void> openCameraSettings() async {
    await openAppSettings();
  }

  // -----------------------------
  // STORAGE PERMISSION
  // -----------------------------

  static Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  static Future<bool> checkStoragePermission() async {
    final status = await Permission.storage.status;
    return status.isGranted;
  }

  static Future<void> openStorageSettings() async {
    await openAppSettings();
  }

  // -----------------------------
  // LOCATION PERMISSION
  // -----------------------------

  static Future<bool> requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  static Future<bool> checkLocationPermission() async {
    final status = await Permission.locationWhenInUse.status;
    return status.isGranted;
  }

  static Future<void> openLocationSettings() async {
    await openAppSettings();
  }

  // -----------------------------
  // NOTIFICATION PERMISSION
  // -----------------------------

  static Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  static Future<bool> checkNotificationPermission() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  // -----------------------------
  // MULTIPLE PERMISSIONS
  // -----------------------------

  static Future<Map<Permission, PermissionStatus>> requestMultiplePermissions(
      List<Permission> permissions) async {
    return await permissions.request();
  }

  static Future<Map<Permission, bool>> checkMultiplePermissions(
      List<Permission> permissions) async {
    final Map<Permission, bool> results = {};
    for (final permission in permissions) {
      final status = await permission.status;
      results[permission] = status.isGranted;
    }
    return results;
  }

  // -----------------------------
  // GENERAL HELPERS
  // -----------------------------

  static Future<void> showPermissionDeniedDialog(
      BuildContext context, String permission) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Permission Required'),
        content: Text(
          'The app needs $permission permission to function properly. '
              'Please enable it in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  static Future<void> handlePermissionStatus(
      PermissionStatus status,
      VoidCallback onGranted, {
        BuildContext? context,
        String permissionName = 'this',
      }) async {
    if (status.isGranted) {
      onGranted();
    } else if (status.isDenied) {
      if (context != null) {
        await showPermissionDeniedDialog(context, permissionName);
      }
    } else if (status.isPermanentlyDenied) {
      if (context != null) {
        await showPermissionDeniedDialog(context, permissionName);
      } else {
        await openAppSettings();
      }
    }
  }
}