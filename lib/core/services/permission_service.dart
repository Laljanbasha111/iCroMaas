import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // -----------------------------
  // CAMERA PERMISSION
  // -----------------------------
  static Future<bool> requestCameraPermission(BuildContext context) async {
    final status = await Permission.camera.request();
    if (!context.mounted) return status.isGranted;
    return _handlePermissionStatus(context, Permission.camera, status);
  }

  static Future<bool> checkCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  // -----------------------------
  // STORAGE / PHOTOS PERMISSION
  // -----------------------------
  static Future<bool> requestStoragePermission(BuildContext context) async {
    Permission permission = Permission.storage;

    // For Android 13+ (API 33+), use photos/videos permissions
    // For older versions, use storage permission
    if (await Permission.photos.status != PermissionStatus.denied) {
      permission = Permission.photos;
    }

    final status = await permission.request();
    if (!context.mounted) return status.isGranted;
    return _handlePermissionStatus(context, permission, status);
  }

  static Future<bool> checkStoragePermission() async {
    Permission permission = Permission.storage;

    if (await Permission.photos.status != PermissionStatus.denied) {
      permission = Permission.photos;
    }

    final status = await permission.status;
    return status.isGranted;
  }

  // -----------------------------
  // LOCATION PERMISSION
  // -----------------------------
  static Future<bool> requestLocationPermission(BuildContext context) async {
    final status = await Permission.locationWhenInUse.request();
    if (!context.mounted) return status.isGranted;
    return _handlePermissionStatus(context, Permission.locationWhenInUse, status);
  }

  static Future<bool> checkLocationPermission() async {
    final status = await Permission.locationWhenInUse.status;
    return status.isGranted;
  }

  // -----------------------------
  // NOTIFICATION PERMISSION
  // -----------------------------
  static Future<bool> requestNotificationPermission(BuildContext context) async {
    final status = await Permission.notification.request();
    if (!context.mounted) return status.isGranted;
    return _handlePermissionStatus(context, Permission.notification, status);
  }

  static Future<bool> checkNotificationPermission() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  // -----------------------------
  // MICROPHONE PERMISSION
  // -----------------------------
  static Future<bool> requestMicrophonePermission(BuildContext context) async {
    final status = await Permission.microphone.request();
    if (!context.mounted) return status.isGranted;
    return _handlePermissionStatus(context, Permission.microphone, status);
  }

  static Future<bool> checkMicrophonePermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  // -----------------------------
  // CHECK ALL PERMISSIONS
  // -----------------------------
  static Future<Map<Permission, bool>> checkAllPermissions() async {
    Permission storagePermission = Permission.storage;
    if (await Permission.photos.status != PermissionStatus.denied) {
      storagePermission = Permission.photos;
    }

    final permissions = [
      Permission.camera,
      Permission.microphone,
      Permission.locationWhenInUse,
      Permission.notification,
      storagePermission,
    ];

    final Map<Permission, bool> results = {};
    for (final permission in permissions) {
      final status = await permission.status;
      results[permission] = status.isGranted;
    }
    return results;
  }

  // -----------------------------
  // REQUEST ALL PERMISSIONS
  // -----------------------------
  static Future<Map<Permission, PermissionStatus>> requestAllPermissions(
      BuildContext context) async {
    Permission storagePermission = Permission.storage;
    if (await Permission.photos.status != PermissionStatus.denied) {
      storagePermission = Permission.photos;
    }

    final permissions = [
      Permission.camera,
      Permission.microphone,
      Permission.locationWhenInUse,
      Permission.notification,
      storagePermission,
    ];

    final results = await permissions.request();

    if (!context.mounted) return results;

    for (final entry in results.entries) {
      final permission = entry.key;
      final status = entry.value;
      if (!status.isGranted) {
        await _handlePermissionStatus(context, permission, status);
      }
    }

    return results;
  }

  // -----------------------------
  // OPEN APP SETTINGS
  // -----------------------------
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }

  // -----------------------------
  // SHOW PERMISSION DIALOG
  // -----------------------------
  static Future<void> showPermissionDialog(
      BuildContext context, String permission, String reason) async {
    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('$permission Permission Required'),
        content: Text(reason),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  // -----------------------------
  // HANDLE PERMISSION DENIED
  // -----------------------------
  static Future<void> handlePermissionDenied(
      BuildContext context, String permission) async {
    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('$permission Permission Denied'),
        content: Text(
          'The $permission permission is required for this feature to work properly. '
              'Please grant permission to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // -----------------------------
  // HANDLE PERMANENTLY DENIED
  // -----------------------------
  static Future<void> handlePermissionPermanentlyDenied(
      BuildContext context, String permission) async {
    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('$permission Permission Permanently Denied'),
        content: Text(
          'The $permission permission has been permanently denied. '
              'Please open app settings to enable it manually.',
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

  // -----------------------------
  // HANDLE PERMISSION STATUS
  // -----------------------------
  static Future<bool> _handlePermissionStatus(
      BuildContext context, Permission permission, PermissionStatus status) async {
    if (!context.mounted) return status.isGranted;

    final name = getPermissionName(permission);
    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      await handlePermissionDenied(context, name);
      return false;
    } else if (status.isPermanentlyDenied) {
      await handlePermissionPermanentlyDenied(context, name);
      return false;
    } else if (status.isRestricted) {
      await showPermissionDialog(context, name,
          'The $name permission is restricted on this device.');
      return false;
    } else if (status.isLimited) {
      await showPermissionDialog(context, name,
          'The $name permission is limited. Some features may not work properly.');
      return true;
    }
    return false;
  }

  // -----------------------------
  // GET PERMISSION NAME
  // -----------------------------
  static String getPermissionName(Permission permission) {
    if (permission == Permission.camera) {
      return 'Camera';
    } else if (permission == Permission.microphone) {
      return 'Microphone';
    } else if (permission == Permission.locationWhenInUse ||
        permission == Permission.locationAlways) {
      return 'Location';
    } else if (permission == Permission.notification) {
      return 'Notifications';
    } else if (permission == Permission.photos ||
        permission == Permission.storage) {
      return 'Storage';
    } else {
      return 'Unknown';
    }
  }

  // -----------------------------
  // GET PERMISSION REASON
  // -----------------------------
  static String getPermissionReason(Permission permission) {
    if (permission == Permission.camera) {
      return 'Camera access is needed to capture crop images for analysis.';
    } else if (permission == Permission.microphone) {
      return 'Microphone access is needed for voice input and audio features.';
    } else if (permission == Permission.locationWhenInUse ||
        permission == Permission.locationAlways) {
      return 'Location access is needed to provide weather and field data for your crops.';
    } else if (permission == Permission.notification) {
      return 'Notification access is needed to alert you about crop updates and weather changes.';
    } else if (permission == Permission.photos ||
        permission == Permission.storage) {
      return 'Storage access is needed to save and upload crop images.';
    } else {
      return 'This permission is required for app functionality.';
    }
  }

  // -----------------------------
  // SHOULD SHOW RATIONALE
  // -----------------------------
  static Future<bool> shouldShowRationale(Permission permission) async {
    return await permission.shouldShowRequestRationale;
  }
}