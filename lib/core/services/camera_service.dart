import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;

class CameraService {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  CameraController? _cameraController;
  List<CameraDescription> _availableCameras = [];
  CameraDescription? _currentCamera;
  bool _isInitialized = false;
  bool _isRecording = false;
  FlashMode _currentFlashMode = FlashMode.off;
  double _currentZoomLevel = 1.0;
  double _minZoomLevel = 1.0;
  double _maxZoomLevel = 1.0;
  final ImagePicker _imagePicker = ImagePicker();

  // -------------------- Initialization --------------------
  Future<void> initialize() async {
    try {
      await _checkPermissions();
      _availableCameras = await availableCameras();
      if (_availableCameras.isEmpty) {
        throw Exception('No cameras available on this device.');
      }
      _currentCamera = _availableCameras.first;
      await initializeCamera(_currentCamera!);
      _isInitialized = true;
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      rethrow;
    }
  }

  Future<void> initializeCamera(CameraDescription camera) async {
    try {
      _cameraController?.dispose();
      _cameraController = CameraController(
        camera,
        ResolutionPreset.max,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await _cameraController!.initialize();
      _minZoomLevel = await _cameraController!.getMinZoomLevel();
      _maxZoomLevel = await _cameraController!.getMaxZoomLevel();
      _currentZoomLevel = 1.0;
      _currentFlashMode = FlashMode.off;
      _currentCamera = camera;
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      rethrow;
    }
  }

  Future<void> _checkPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final storageStatus = await Permission.storage.request();
    final micStatus = await Permission.microphone.request();
    if (cameraStatus.isDenied || storageStatus.isDenied || micStatus.isDenied) {
      throw Exception('Camera, storage, or microphone permission denied.');
    }
  }

  // -------------------- Camera Operations --------------------
  Future<XFile?> takePicture() async {
    try {
      if (_cameraController == null || !_cameraController!.value.isInitialized) {
        throw Exception('Camera not initialized.');
      }
      final file = await _cameraController!.takePicture();
      return await savePicture(file);
    } catch (e) {
      debugPrint('Error taking picture: $e');
      return null;
    }
  }

  Future<void> startVideoRecording() async {
    try {
      if (_cameraController == null || !_cameraController!.value.isInitialized) {
        throw Exception('Camera not initialized.');
      }
      if (_isRecording) return;
      await _cameraController!.startVideoRecording();
      _isRecording = true;
    } catch (e) {
      debugPrint('Error starting video recording: $e');
      rethrow;
    }
  }

  Future<XFile?> stopVideoRecording() async {
    try {
      if (!_isRecording) return null;
      final file = await _cameraController!.stopVideoRecording();
      _isRecording = false;
      return await saveVideo(file);
    } catch (e) {
      debugPrint('Error stopping video recording: $e');
      return null;
    }
  }

  Future<void> switchCamera() async {
    try {
      if (_availableCameras.length < 2) return;
      final newCamera = _currentCamera == _availableCameras.first
          ? _availableCameras.last
          : _availableCameras.first;
      await initializeCamera(newCamera);
    } catch (e) {
      debugPrint('Error switching camera: $e');
    }
  }

  Future<void> setFlashMode(FlashMode mode) async {
    try {
      if (_cameraController == null) return;
      await _cameraController!.setFlashMode(mode);
      _currentFlashMode = mode;
    } catch (e) {
      debugPrint('Error setting flash mode: $e');
    }
  }

  Future<void> setZoomLevel(double zoom) async {
    try {
      if (_cameraController == null) return;
      zoom = zoom.clamp(_minZoomLevel, _maxZoomLevel);
      await _cameraController!.setZoomLevel(zoom);
      _currentZoomLevel = zoom;
    } catch (e) {
      debugPrint('Error setting zoom level: $e');
    }
  }

  Future<void> setFocusPoint(Offset point) async {
    try {
      if (_cameraController == null) return;
      await _cameraController!.setFocusPoint(point);
    } catch (e) {
      debugPrint('Error setting focus point: $e');
    }
  }

  // -------------------- Gallery Integration --------------------
  Future<XFile?> pickImageFromGallery() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      return pickedFile;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  Future<XFile?> pickVideoFromGallery() async {
    try {
      final pickedFile = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
      );
      return pickedFile;
    } catch (e) {
      debugPrint('Error picking video from gallery: $e');
      return null;
    }
  }

  // -------------------- Helper Methods --------------------
  Future<List<CameraDescription>> getAvailableCameras() async {
    try {
      return await availableCameras();
    } catch (e) {
      debugPrint('Error getting available cameras: $e');
      return [];
    }
  }

  CameraController? getCameraController() => _cameraController;
  bool isCameraInitialized() => _cameraController?.value.isInitialized ?? false;
  bool isRecording() => _isRecording;
  FlashMode getCurrentFlashMode() => _currentFlashMode;
  double getCurrentZoomLevel() => _currentZoomLevel;
  double getMaxZoomLevel() => _maxZoomLevel;
  double getMinZoomLevel() => _minZoomLevel;

  Future<XFile> savePicture(XFile file) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = path.join(directory.path, 'photo_$timestamp.jpg');
      final savedFile = await File(file.path).copy(filePath);
      return XFile(savedFile.path);
    } catch (e) {
      debugPrint('Error saving picture: $e');
      rethrow;
    }
  }

  Future<XFile> saveVideo(XFile file) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = path.join(directory.path, 'video_$timestamp.mp4');
      final savedFile = await File(file.path).copy(filePath);
      return XFile(savedFile.path);
    } catch (e) {
      debugPrint('Error saving video: $e');
      rethrow;
    }
  }

  // -------------------- Camera Preview --------------------
  Widget buildCameraPreview() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return CameraPreview(_cameraController!);
  }

  // -------------------- Disposal --------------------
  void dispose() {
    _cameraController?.dispose();
    _isInitialized = false;
    _isRecording = false;
  }
}