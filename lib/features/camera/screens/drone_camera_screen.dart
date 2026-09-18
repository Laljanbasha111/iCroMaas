import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import '../../../app/theme/app_colors.dart';

/// Drone Camera Screen for Crop Analyzer app.
/// Provides live camera preview, flash control, camera switch, and image capture.
/// Captured image is saved temporarily and passed to /image-preview route.
///
/// Note: Ensure camera permissions are declared in AndroidManifest.xml and Info.plist.
class DroneCameraScreen extends StatefulWidget {
  const DroneCameraScreen({super.key});

  @override
  State<DroneCameraScreen> createState() => _DroneCameraScreenState();
}

class _DroneCameraScreenState extends State<DroneCameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isRearCamera = true;
  FlashMode _flashMode = FlashMode.auto;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  /// Initializes available cameras and sets up the controller.
  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        throw Exception('No cameras found on this device.');
      }

      final selectedCamera = _isRearCamera
          ? _cameras!.firstWhere(
            (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      )
          : _cameras!.firstWhere(
            (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      _controller = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      await _controller!.setFlashMode(_flashMode);

      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera initialization failed: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  /// Toggles between front and rear cameras.
  Future<void> _switchCamera() async {
    setState(() {
      _isRearCamera = !_isRearCamera;
      _isInitialized = false;
    });
    await _controller?.dispose();
    await _initializeCamera();
  }

  /// Cycles through flash modes: auto → on → off → auto.
  Future<void> _toggleFlash() async {
    if (_controller == null) return;
    FlashMode newMode;
    switch (_flashMode) {
      case FlashMode.auto:
        newMode = FlashMode.always;
        break;
      case FlashMode.always:
        newMode = FlashMode.off;
        break;
      default:
        newMode = FlashMode.auto;
    }
    try {
      await _controller!.setFlashMode(newMode);
      setState(() => _flashMode = newMode);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to change flash mode: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  /// Captures an image and navigates to image preview screen.
  Future<void> _captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_isCapturing) return;

    setState(() => _isCapturing = true);

    try {
      final XFile file = await _controller!.takePicture();
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath =
          '${tempDir.path}/captured_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await file.saveTo(filePath);

      if (mounted) {
        context.go('/image-preview', extra: {'imagePath': filePath});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to capture image: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// Builds flash icon based on current flash mode.
  IconData _getFlashIcon() {
    switch (_flashMode) {
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.off:
        return Icons.flash_off;
      default:
        return Icons.flash_auto;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Drone Camera'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library, color: Colors.white),
            tooltip: 'Gallery',
            onPressed: () => context.go('/upload'),
          ),
        ],
      ),
      body: _isInitialized
          ? Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: CameraPreview(_controller!),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Flash toggle
                IconButton(
                  icon: Icon(_getFlashIcon(),
                      color: Colors.white, size: 28),
                  onPressed: _toggleFlash,
                ),

                // Capture button
                GestureDetector(
                  onTap: _captureImage,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary,
                        width: 4,
                      ),
                      color: _isCapturing
                          ? AppColors.primary.withOpacity(0.5)
                          : AppColors.primary,
                    ),
                    child: const Icon(Icons.camera_alt,
                        color: Colors.white, size: 32),
                  ),
                ),

                // Switch camera
                IconButton(
                  icon: const Icon(Icons.cameraswitch,
                      color: Colors.white, size: 28),
                  onPressed: _switchCamera,
                ),
              ],
            ),
          ),
        ],
      )
          : const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 3,
        ),
      ),
    );
  }
}