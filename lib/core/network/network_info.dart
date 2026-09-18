import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:http/http.dart' as http;

enum ConnectionType {
  wifi,
  mobile,
  ethernet,
  bluetooth,
  vpn,
  none,
}

enum ConnectionQuality {
  excellent,
  good,
  fair,
  poor,
  noConnection,
}

class NetworkInfo {
  static final NetworkInfo _instance = NetworkInfo._internal();
  factory NetworkInfo() => _instance;
  NetworkInfo._internal();

  final Connectivity _connectivity = Connectivity();
  final InternetConnection _internetChecker = InternetConnection();
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();
  final StreamController<ConnectionType> _connectionTypeController = StreamController<ConnectionType>.broadcast();

  bool _initialized = false;
  bool _isOfflineMode = false;
  bool _isConnected = false;
  ConnectionType _connectionType = ConnectionType.none;
  ConnectionQuality _connectionQuality = ConnectionQuality.noConnection;
  double _networkSpeedMbps = 0.0;
  double _signalStrength = 0.0;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  StreamSubscription<InternetStatus>? _internetSubscription;

  // -------------------- Initialization --------------------
  Future<void> initialize() async {
    if (_initialized) return;

    final connectivityResult = await _connectivity.checkConnectivity();
    _connectionType = _mapConnectivityResult(connectivityResult);
    _isConnected = await _internetChecker.hasInternetAccess;
    _connectionQuality = await getConnectionQuality();
    _networkSpeedMbps = await getNetworkSpeed();
    _listenToConnectivityChanges();
    _initialized = true;
  }

  // -------------------- Connectivity Check --------------------
  Future<bool> isConnected() async {
    if (_isOfflineMode) return false;
    _isConnected = await _internetChecker.hasInternetAccess;
    return _isConnected;
  }

  Future<bool> hasInternetAccess() async {
    if (_isOfflineMode) return false;
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // -------------------- Connection Type --------------------
  Future<ConnectionType> getConnectionType() async {
    final result = await _connectivity.checkConnectivity();
    _connectionType = _mapConnectivityResult(result);
    return _connectionType;
  }

  ConnectionType _mapConnectivityResult(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return ConnectionType.none;
    }

    // Priority order: wifi > ethernet > mobile > vpn > bluetooth
    if (results.contains(ConnectivityResult.wifi)) {
      return ConnectionType.wifi;
    } else if (results.contains(ConnectivityResult.ethernet)) {
      return ConnectionType.ethernet;
    } else if (results.contains(ConnectivityResult.mobile)) {
      return ConnectionType.mobile;
    } else if (results.contains(ConnectivityResult.vpn)) {
      return ConnectionType.vpn;
    } else if (results.contains(ConnectivityResult.bluetooth)) {
      return ConnectionType.bluetooth;
    }

    return ConnectionType.none;
  }

  // -------------------- Connection Quality --------------------
  Future<ConnectionQuality> getConnectionQuality() async {
    if (!await isConnected()) return ConnectionQuality.noConnection;
    final speed = await getNetworkSpeed();
    if (speed > 10) return ConnectionQuality.excellent;
    if (speed > 5) return ConnectionQuality.good;
    if (speed > 1) return ConnectionQuality.fair;
    if (speed > 0.1) return ConnectionQuality.poor;
    return ConnectionQuality.noConnection;
  }

  // -------------------- Network Speed Test --------------------
  Future<double> getNetworkSpeed() async {
    if (_isOfflineMode) return 0.0;
    try {
      final stopwatch = Stopwatch()..start();
      final response = await http.get(
        Uri.parse('https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png'),
      ).timeout(const Duration(seconds: 10));
      stopwatch.stop();

      if (response.statusCode == 200) {
        final bytes = response.contentLength ?? response.bodyBytes.length;
        final seconds = stopwatch.elapsedMilliseconds / 1000;
        final speedMbps = (bytes * 8) / (seconds * 1024 * 1024);
        _networkSpeedMbps = double.parse(speedMbps.toStringAsFixed(2));
        return _networkSpeedMbps;
      }
    } catch (e) {
      debugPrint('Network speed test error: $e');
    }
    return 0.0;
  }

  // -------------------- Connectivity Stream --------------------
  /// Stream that emits connection status changes (true = connected, false = disconnected)
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  /// Stream that emits connection type changes
  Stream<ConnectionType> get connectionTypeStream => _connectionTypeController.stream;

  void _listenToConnectivityChanges() {
    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) async {
      final newType = _mapConnectivityResult(results);

      if (newType != _connectionType) {
        _connectionType = newType;
        _connectionTypeController.add(_connectionType);
        _onConnectionTypeChangedCallback?.call(_connectionType);
      }
    });

    // Listen to internet status changes
    _internetSubscription = _internetChecker.onStatusChange.listen((InternetStatus status) {
      final connected = status == InternetStatus.connected;

      if (connected != _isConnected) {
        _isConnected = connected;
        _connectionStatusController.add(_isConnected);

        if (_isConnected) {
          _onConnectedCallback?.call();
        } else {
          _onDisconnectedCallback?.call();
        }
      }
    });
  }

  // -------------------- Offline Mode --------------------
  void enableOfflineMode() {
    _isOfflineMode = true;
    _connectionStatusController.add(false);
  }

  void disableOfflineMode() {
    _isOfflineMode = false;
    _connectionStatusController.add(true);
  }

  bool isOfflineMode() => _isOfflineMode;

  // -------------------- Helper Methods --------------------
  Future<bool> isWiFi() async => (await getConnectionType()) == ConnectionType.wifi;
  Future<bool> isMobile() async => (await getConnectionType()) == ConnectionType.mobile;
  Future<bool> isEthernet() async => (await getConnectionType()) == ConnectionType.ethernet;

  Future<double> getSignalStrength() async {
    switch (_connectionType) {
      case ConnectionType.wifi:
        _signalStrength = Random().nextDouble() * 100;
        break;
      case ConnectionType.mobile:
        _signalStrength = Random().nextDouble() * 80;
        break;
      case ConnectionType.ethernet:
        _signalStrength = 100.0;
        break;
      default:
        _signalStrength = 0.0;
    }
    return double.parse(_signalStrength.toStringAsFixed(2));
  }

  Future<double> estimateBandwidth() async {
    final speed = await getNetworkSpeed();
    return double.parse(speed.toStringAsFixed(2));
  }

  Future<int> pingServer(String url) async {
    try {
      final stopwatch = Stopwatch()..start();
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      stopwatch.stop();

      if (response.statusCode == 200) {
        return stopwatch.elapsedMilliseconds;
      }
    } catch (e) {
      debugPrint('Ping error: $e');
    }
    return -1;
  }

  // -------------------- Network Events (Callbacks) --------------------
  VoidCallback? _onConnectedCallback;
  VoidCallback? _onDisconnectedCallback;
  Function(ConnectionType)? _onConnectionTypeChangedCallback;

  /// Set callback for when network connects
  void setOnConnectedCallback(VoidCallback callback) => _onConnectedCallback = callback;

  /// Set callback for when network disconnects
  void setOnDisconnectedCallback(VoidCallback callback) => _onDisconnectedCallback = callback;

  /// Set callback for when connection type changes
  void setOnConnectionTypeChangedCallback(Function(ConnectionType) callback) =>
      _onConnectionTypeChangedCallback = callback;

  // -------------------- Network Statistics --------------------
  Map<String, dynamic> getNetworkStats() {
    return {
      'connected': _isConnected,
      'type': _connectionType.toString(),
      'quality': _connectionQuality.toString(),
      'speed_mbps': _networkSpeedMbps,
      'signal_strength': _signalStrength,
      'offline_mode': _isOfflineMode,
    };
  }

  // -------------------- Debug Utilities --------------------
  Future<void> printNetworkSummary() async {
    final connected = await isConnected();
    final type = await getConnectionType();
    final quality = await getConnectionQuality();
    final speed = await getNetworkSpeed();
    final signal = await getSignalStrength();

    debugPrint('═══════════════════════════════════════');
    debugPrint('🌐 Network Summary');
    debugPrint('═══════════════════════════════════════');
    debugPrint('Connected: $connected');
    debugPrint('Type: $type');
    debugPrint('Quality: $quality');
    debugPrint('Speed: ${speed.toStringAsFixed(2)} Mbps');
    debugPrint('Signal Strength: ${signal.toStringAsFixed(2)}%');
    debugPrint('Offline Mode: $_isOfflineMode');
    debugPrint('═══════════════════════════════════════');
  }

  // -------------------- Dispose --------------------
  void dispose() {
    _connectivitySubscription?.cancel();
    _internetSubscription?.cancel();
    _connectionStatusController.close();
    _connectionTypeController.close();
  }
}