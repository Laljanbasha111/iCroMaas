import 'package:flutter/foundation.dart';

class DroneService extends ChangeNotifier {
  bool _isConnected = false;
  bool _isFlying = false;
  bool _isCameraActive = false;
  double _altitude = 0.0;
  double _battery = 100.0;
  String _gpsStatus = 'No Signal';
  int _capturedImages = 0;

  // Getters
  bool get isConnected => _isConnected;
  bool get isFlying => _isFlying;
  bool get isCameraActive => _isCameraActive;
  double get altitude => _altitude;
  double get battery => _battery;
  String get gpsStatus => _gpsStatus;
  int get capturedImages => _capturedImages;

  // Connect to drone
  Future<void> connect() async {
    // Simulate connection delay
    await Future.delayed(const Duration(seconds: 2));

    _isConnected = true;
    _gpsStatus = 'GPS Ready';
    _battery = 95.0;
    notifyListeners();
  }

  // Disconnect from drone
  Future<void> disconnect() async {
    _isConnected = false;
    _isFlying = false;
    _isCameraActive = false;
    _altitude = 0.0;
    _gpsStatus = 'No Signal';
    notifyListeners();
  }

  // Takeoff
  Future<void> takeoff() async {
    if (!_isConnected) {
      throw Exception('Drone not connected');
    }

    _isFlying = true;
    notifyListeners();

    // Simulate takeoff
    for (int i = 0; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      _altitude = i.toDouble();
      _battery -= 0.1;
      notifyListeners();
    }

    _isCameraActive = true;
    notifyListeners();
  }

  // Land
  Future<void> land() async {
    _isFlying = false;

    // Simulate landing
    for (int i = _altitude.toInt(); i >= 0; i--) {
      await Future.delayed(const Duration(milliseconds: 200));
      _altitude = i.toDouble();
      notifyListeners();
    }

    _isCameraActive = false;
    notifyListeners();
  }

  // Capture image
  Future<String> captureImage() async {
    if (!_isCameraActive) {
      throw Exception('Camera not active');
    }

    _capturedImages++;
    _battery -= 0.5;
    notifyListeners();

    // Simulate image capture
    await Future.delayed(const Duration(seconds: 1));

    return '/simulated/drone/image_$_capturedImages.jpg';
  }

  // Change altitude
  void changeAltitude(double delta) {
    _altitude = (_altitude + delta).clamp(0, 50);
    _battery -= 0.2;
    notifyListeners();
  }
}
