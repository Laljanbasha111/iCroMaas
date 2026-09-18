import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Enum representing the type of network connection.
enum ConnectionType { wifi, mobile, ethernet, none }

/// ConnectivityProvider manages real-time network connectivity and internet access status.
class ConnectivityProvider extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  final InternetConnection _internetChecker = InternetConnection();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  StreamSubscription<InternetStatus>? _internetSubscription;

  bool _isConnected = false;
  bool _hasInternetAccess = false;
  ConnectionType _connectionType = ConnectionType.none;
  String _connectionStatus = 'Offline';
  DateTime? _lastCheckedTime;
  final List<String> _connectionHistory = [];

  bool get isConnected => _isConnected;
  bool get isOnline => _isConnected && _hasInternetAccess;
  bool get hasInternetAccess => _hasInternetAccess;
  ConnectionType get connectionType => _connectionType;
  String get connectionStatus => _connectionStatus;
  DateTime? get lastCheckedTime => _lastCheckedTime;
  List<String> get connectionHistory => List.unmodifiable(_connectionHistory);

  /// Initialize connectivity monitoring.
  Future<void> initialize() async {
    await checkConnectivity();
    await checkInternetAccess();
    startMonitoring();
  }

  /// Check current connectivity status.
  Future<void> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      await _handleConnectionChange(result);
    } catch (e) {
      log('Connectivity check failed: $e');
    }
  }

  /// Verify actual internet access.
  Future<void> checkInternetAccess() async {
    try {
      final hasAccess = await _internetChecker.hasInternetAccess;
      _hasInternetAccess = hasAccess;
      _lastCheckedTime = DateTime.now();
      _notifyConnectionStatus();
    } catch (e) {
      log('Internet access check failed: $e');
    }
  }

  /// Start listening to connectivity changes.
  void startMonitoring() {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_handleConnectionChange);
    _internetSubscription =
        _internetChecker.onStatusChange.listen((status) {
          final hasAccess = status == InternetStatus.connected;
          if (_hasInternetAccess != hasAccess) {
            _hasInternetAccess = hasAccess;
            _lastCheckedTime = DateTime.now();
            _notifyConnectionStatus();
          }
        });
  }

  /// Stop listening to connectivity changes.
  void stopMonitoring() {
    _connectivitySubscription?.cancel();
    _internetSubscription?.cancel();
  }

  /// Retry connection check manually.
  Future<void> retryConnection() async {
    await checkConnectivity();
    await checkInternetAccess();
  }

  /// Show offline dialog when no connection.
  Future<void> showNoConnectionDialog(BuildContext context) async {
    if (!isOnline) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No Internet Connection'),
          content: const Text(
            'Please check your network settings and try again.',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await retryConnection();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
  }

  /// Show snackbar when connection is restored.
  void showConnectionRestoredSnackbar(BuildContext context) {
    if (isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connection restored'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Handle connectivity result changes.
  Future<void> _handleConnectionChange(List<ConnectivityResult> results) async {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      _setConnectionType(ConnectionType.none);
      _setConnected(false);
    } else {
      // Priority: WiFi > Ethernet > Mobile
      if (results.contains(ConnectivityResult.wifi)) {
        _setConnectionType(ConnectionType.wifi);
        _setConnected(true);
      } else if (results.contains(ConnectivityResult.ethernet)) {
        _setConnectionType(ConnectionType.ethernet);
        _setConnected(true);
      } else if (results.contains(ConnectivityResult.mobile)) {
        _setConnectionType(ConnectionType.mobile);
        _setConnected(true);
      } else {
        _setConnectionType(ConnectionType.none);
        _setConnected(false);
      }
    }
    await checkInternetAccess();
    _logConnectionChange();
  }

  /// Helper: Set connection state.
  void _setConnected(bool value) {
    if (_isConnected != value) {
      _isConnected = value;
      _lastCheckedTime = DateTime.now();
      _notifyConnectionStatus();
    }
  }

  /// Helper: Set connection type.
  void _setConnectionType(ConnectionType type) {
    if (_connectionType != type) {
      _connectionType = type;
      _lastCheckedTime = DateTime.now();
      _notifyConnectionStatus();
    }
  }

  /// Helper: Notify listeners and update connection status string.
  void _notifyConnectionStatus() {
    if (!_isConnected) {
      _connectionStatus = 'Offline';
    } else if (_isConnected && !_hasInternetAccess) {
      _connectionStatus = 'Connected (No Internet)';
    } else {
      switch (_connectionType) {
        case ConnectionType.wifi:
          _connectionStatus = 'Connected via WiFi';
          break;
        case ConnectionType.mobile:
          _connectionStatus = 'Connected via Mobile Data';
          break;
        case ConnectionType.ethernet:
          _connectionStatus = 'Connected via Ethernet';
          break;
        case ConnectionType.none:
          _connectionStatus = 'Offline';
          break;
      }
    }
    _connectionHistory.add(
      '${DateTime.now().toIso8601String()} - $_connectionStatus',
    );
    notifyListeners();
  }

  /// Helper: Log connection changes.
  void _logConnectionChange() {
    log('Connection changed: $_connectionStatus');
  }

  @override
  void dispose() {
    stopMonitoring();
    super.dispose();
  }
}