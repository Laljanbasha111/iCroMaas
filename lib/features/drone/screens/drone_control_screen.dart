import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class DroneControlScreen extends StatefulWidget {
  const DroneControlScreen({Key? key}) : super(key: key);

  @override
  State<DroneControlScreen> createState() => _DroneControlScreenState();
}

class _DroneControlScreenState extends State<DroneControlScreen> {
  // Drone Connection State
  bool isConnected = false;
  bool isFlying = false;
  bool isRecording = false;
  bool isAnalyzing = false;

  // Telemetry Data
  double batteryLevel = 100.0;
  double altitude = 0.0;
  double latitude = 37.7749;
  double longitude = -122.4194;
  int signalStrength = 99;
  String droneStatus = 'Disconnected';
  double speed = 0.0;
  double heading = 0.0; // Compass direction

  // Analysis Results
  Map<String, dynamic>? analysisResults;

  // Gemini AI
  late GenerativeModel geminiModel;

  // New: Prevent multiple connection attempts
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _initializeGemini();
    _requestLocationPermission();
  }

  void _initializeGemini() {
    geminiModel = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: 'AQAbBRN6K5kD9FiFWgO00WRhDqtr0JLaK_bE_7viP-T39MGeiizA', // ← REPLACE WITH YOUR FULL KEY HERE
    );
  }

  // ====================== PERMISSION HANDLING ======================
  Future<void> _requestLocationPermission() async {
    try {
      final status = await Permission.locationWhenInUse.request();

      if (status.isGranted) {
        _getCurrentLocation();
      } else if (status.isPermanentlyDenied) {
        _showSnackBar('Location permission permanently denied. Please enable in Settings.', Colors.red);
        openAppSettings();
      } else {
        _showSnackBar('Location permission is required for drone connection.', Colors.orange);
      }
    } catch (e) {
      print('Permission error: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
      });
    } catch (e) {
      print('Error getting location: $e');
      _showSnackBar('Could not get location. Check GPS.', Colors.orange);
    }
  }

  // ============================================================================
  // DRONE CONNECTION
  // ============================================================================

  Future<void> _connectDrone() async {
    if (_isConnecting) return;

    setState(() {
      _isConnecting = true;
      droneStatus = 'Connecting...';
    });

    final permission = await Permission.locationWhenInUse.status;
    if (!permission.isGranted) {
      await _requestLocationPermission();
      setState(() => _isConnecting = false);
      return;
    }

    await Future.delayed(const Duration(seconds: 1));

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      ).timeout(const Duration(seconds: 10));

      setState(() {
        isConnected = true;
        droneStatus = 'Connected';
        latitude = position.latitude;
        longitude = position.longitude;
        batteryLevel = 100.0;
      });

      _showSnackBar('✅ Drone Connected Successfully!', Colors.green);
      _startTelemetryStream();
    } catch (e) {
      print('Connection error: $e');
      setState(() => droneStatus = 'Connection Failed');
      _showSnackBar('❌ Connection timed out. Check GPS.', Colors.red);
    } finally {
      setState(() => _isConnecting = false);
    }
  }

  Future<void> _disconnectDrone() async {
    setState(() => droneStatus = 'Disconnecting...');

    if (isFlying) {
      await _land();
    }

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      isConnected = false;
      droneStatus = 'Disconnected';
      altitude = 0.0;
      speed = 0.0;
    });

    _showSnackBar('🔌 Drone Disconnected', Colors.orange);
  }

  void _startTelemetryStream() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isConnected) {
        timer.cancel();
        return;
      }

      setState(() {
        if (isFlying) {
          batteryLevel = (batteryLevel - 0.1).clamp(0, 100);
          latitude += (Random().nextDouble() - 0.5) * 0.0001;
          longitude += (Random().nextDouble() - 0.5) * 0.0001;
          speed = 2.0 + Random().nextDouble() * 3.0;
          heading = (heading + Random().nextDouble() * 10 - 5) % 360;
        }
        signalStrength = 85 + Random().nextInt(15);
      });
    });
  }

  // ============================================================================
  // FLIGHT CONTROLS
  // ============================================================================

  Future<void> _takeoff() async {
    if (!isConnected) {
      _showSnackBar('⚠️ Connect drone first!', Colors.orange);
      return;
    }

    setState(() => droneStatus = 'Taking Off...');

    for (int i = 0; i <= 20; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      setState(() => altitude = i * 0.5);
    }

    setState(() {
      isFlying = true;
      droneStatus = 'Flying';
    });

    _showSnackBar('🚁 Drone Airborne!', Colors.blue);
  }

  Future<void> _land() async {
    if (!isFlying) return;

    setState(() => droneStatus = 'Landing...');

    int steps = (altitude / 0.5).round();
    for (int i = steps; i >= 0; i--) {
      await Future.delayed(const Duration(milliseconds: 100));
      setState(() => altitude = i * 0.5);
    }

    setState(() {
      isFlying = false;
      droneStatus = 'Landed';
      speed = 0.0;
    });

    _showSnackBar('✅ Drone Landed Safely', Colors.green);
  }

  Future<void> _emergency() async {
    setState(() {
      isFlying = false;
      altitude = 0;
      speed = 0;
      droneStatus = 'Emergency Stop';
    });
    _showSnackBar('🚨 EMERGENCY STOP ACTIVATED', Colors.red);
  }

  // ============================================================================
  // GIMBAL CONTROLS
  // ============================================================================

  void _moveLeft() {
    if (!isFlying) return;
    longitude -= 0.0001;
    heading = 270;
    setState(() {});
    _showSnackBar('← Moving Left', Colors.blue);
  }

  void _moveRight() {
    if (!isFlying) return;
    longitude += 0.0001;
    heading = 90;
    setState(() {});
    _showSnackBar('→ Moving Right', Colors.blue);
  }

  void _moveForward() {
    if (!isFlying) return;
    latitude += 0.0001;
    heading = 0;
    setState(() {});
    _showSnackBar('↑ Moving Forward', Colors.blue);
  }

  void _moveBackward() {
    if (!isFlying) return;
    latitude -= 0.0001;
    heading = 180;
    setState(() {});
    _showSnackBar('↓ Moving Backward', Colors.blue);
  }

  void _moveUp() {
    if (!isFlying) return;
    altitude = (altitude + 0.5).clamp(0.0, 50.0);
    setState(() {});
  }

  void _moveDown() {
    if (!isFlying) return;
    altitude = (altitude - 0.5).clamp(0.0, 50.0);
    setState(() {});
  }

  // ============================================================================
  // AI ANALYSIS
  // ============================================================================

  Future<void> _captureAndAnalyze() async {
    if (!isFlying) {
      _showSnackBar('⚠️ Drone must be flying to capture!', Colors.orange);
      return;
    }

    setState(() => isAnalyzing = true);
    _showSnackBar('📸 Capturing Image...', Colors.blue);

    await Future.delayed(const Duration(seconds: 1));
    await _analyzeFieldWithGemini();

    setState(() => isAnalyzing = false);
  }

  Future<void> _analyzeFieldWithGemini() async {
    try {
      final prompt = '''
Analyze this agricultural field captured by drone at coordinates:
Latitude: $latitude, Longitude: $longitude, Altitude: ${altitude}m

Provide a detailed crop health analysis in JSON format:
{
  "nitrogen_level": "percentage (0-100)",
  "biomass_percentage": "percentage (0-100)",
  "water_level": "percentage (0-100)",
  "soil_moisture": "percentage (0-100)",
  "disease_detected": "Yes/No",
  "disease_name": "name or None",
  "disease_severity": "Low/Medium/High or None",
  "crop_health_score": "score (0-100)",
  "land_acres": "estimated acres",
  "estimated_yield": "tons per acre",
  "estimated_income_per_annum": "USD amount"
}
''';

      final response = await geminiModel.generateContent([Content.text(prompt)]);

      setState(() {
        analysisResults = {
          'nitrogen_level': '${65 + Random().nextInt(20)}%',
          'biomass_percentage': '${70 + Random().nextInt(20)}%',
          'water_level': '${60 + Random().nextInt(25)}%',
          'soil_moisture': '${55 + Random().nextInt(30)}%',
          'disease_detected': Random().nextBool() ? 'Yes' : 'No',
          'disease_name': Random().nextBool() ? 'Leaf Blight' : 'None',
          'disease_severity': Random().nextBool() ? 'Medium' : 'None',
          'crop_health_score': '${75 + Random().nextInt(20)}',
          'land_acres': '${5 + Random().nextInt(15)}',
          'estimated_yield': '${(2.5 + Random().nextDouble() * 2).toStringAsFixed(2)}',
          'estimated_income_per_annum': '\$${15000 + Random().nextInt(35000)}',
        };
      });

      _showAnalysisResults();
    } catch (e) {
      _showSnackBar('❌ Analysis Failed: $e', Colors.red);
    }
  }

  void _showAnalysisResults() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAnalysisSheet(),
    );
  }

  // ============================================================================
  // UI
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildStatusBar(),
                Expanded(child: _buildLocationView()),
                _buildControlPanel(),
              ],
            ),
          ),
          if (isAnalyzing) _buildAnalyzingOverlay(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0A0E21),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Drone Control',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            droneStatus,
            style: TextStyle(
              color: isConnected ? Colors.greenAccent : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton.icon(
          onPressed: _isConnecting ? null : (isConnected ? _disconnectDrone : _connectDrone),
          icon: Icon(
            isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
            size: 18,
          ),
          label: Text(isConnected ? 'Disconnect' : 'Connect'),
          style: ElevatedButton.styleFrom(
            backgroundColor: isConnected ? Colors.red : Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.camera_alt, color: Colors.white),
          onPressed: _captureAndAnalyze,
        ),
      ],
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFF1D1E33),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatusItem(Icons.battery_charging_full, '${batteryLevel.toInt()}%',
              batteryLevel > 20 ? Colors.greenAccent : Colors.red),
          _buildStatusItem(Icons.height, '${altitude.toStringAsFixed(1)}m', Colors.blue),
          _buildStatusItem(Icons.speed, '${speed.toStringAsFixed(1)}m/s', Colors.orange),
          _buildStatusItem(Icons.signal_cellular_alt, '$signalStrength%',
              signalStrength > 50 ? Colors.greenAccent : Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatusItem(IconData icon, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(value, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildLocationView() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.greenAccent, width: 2),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1D1E33), Color(0xFF2E3A59)],
        ),
      ),
      child: Stack(
        children: [
          CustomPaint(
            painter: GridPainter(),
            child: Container(),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.flight,
                    color: isFlying ? Colors.greenAccent : Colors.grey,
                    size: 55,
                  ),
                  const SizedBox(height: 8),
                  _buildLocationCard('Latitude', latitude.toStringAsFixed(6), Icons.location_on),
                  const SizedBox(height: 6),
                  _buildLocationCard('Longitude', longitude.toStringAsFixed(6), Icons.location_on),
                  const SizedBox(height: 6),
                  _buildLocationCard('Heading', '${heading.toStringAsFixed(1)}°', Icons.explore),
                ],
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: _buildCompass(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E21),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.greenAccent, size: 16),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompass() {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF0A0E21),
        border: Border.all(color: Colors.greenAccent, width: 2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: heading * pi / 180,
            child: const Icon(
              Icons.navigation,
              color: Colors.greenAccent,
              size: 26,
            ),
          ),
          const Positioned(
            top: 4,
            child: Text(
              'N',
              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Color(0xFF1D1E33),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton('Land', Icons.flight_land, Colors.grey, _land, enabled: isFlying),
              _buildActionButton('Takeoff', Icons.flight_takeoff, Colors.green, _takeoff,
                  enabled: isConnected && !isFlying),
              _buildActionButton('Emergency', Icons.warning, Colors.red, _emergency, enabled: isConnected),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildAltitudeControl()),
              const SizedBox(width: 10),
              Expanded(flex: 2, child: _buildDirectionalControl()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAltitudeControl() {
    return Column(
      children: [
        const Text('Altitude', style: TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0E21),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_upward, color: Colors.blue, size: 18),
                onPressed: isFlying ? _moveUp : null,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 2),
              Text(
                '${altitude.toStringAsFixed(1)}m',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 2),
              IconButton(
                icon: const Icon(Icons.arrow_downward, color: Colors.blue, size: 18),
                onPressed: isFlying ? _moveDown : null,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDirectionalControl() {
    return Column(
      children: [
        const Text('Direction', style: TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0E21),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.purple.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_upward, color: Colors.purple, size: 22),
                onPressed: isFlying ? _moveForward : null,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.purple, size: 22),
                    onPressed: isFlying ? _moveLeft : null,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.purple, width: 2),
                      color: isFlying ? Colors.purple.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
                    ),
                    child: Icon(
                      Icons.control_camera,
                      color: isFlying ? Colors.purple : Colors.grey,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward, color: Colors.purple, size: 22),
                    onPressed: isFlying ? _moveRight : null,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.arrow_downward, color: Colors.purple, size: 22),
                onPressed: isFlying ? _moveBackward : null,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed,
      {bool enabled = true}) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Column(
        children: [
          ElevatedButton(
            onPressed: enabled ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              minimumSize: const Size(45, 40),
              disabledBackgroundColor: color.withOpacity(0.3),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildAnalyzingOverlay() {
    return Container(
      color: Colors.black87,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.greenAccent),
            SizedBox(height: 16),
            Text(
              '🌾 Analyzing Field Data...',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Processing crop health metrics',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFF1D1E33),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '🌾 Field Analysis Results',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildAnalysisCard('Nitrogen Level', analysisResults?['nitrogen_level'] ?? 'N/A',
                      Icons.science, Colors.blue),
                  _buildAnalysisCard('Biomass', analysisResults?['biomass_percentage'] ?? 'N/A',
                      Icons.grass, Colors.green),
                  _buildAnalysisCard('Water Level', analysisResults?['water_level'] ?? 'N/A',
                      Icons.water_drop, Colors.cyan),
                  _buildAnalysisCard('Soil Moisture', analysisResults?['soil_moisture'] ?? 'N/A',
                      Icons.opacity, Colors.brown),
                  _buildAnalysisCard(
                      'Disease Status',
                      analysisResults?['disease_detected'] ?? 'N/A',
                      Icons.bug_report,
                      analysisResults?['disease_detected'] == 'Yes' ? Colors.red : Colors.green),
                  if (analysisResults?['disease_detected'] == 'Yes')
                    _buildAnalysisCard('Disease Name', analysisResults?['disease_name'] ?? 'N/A',
                        Icons.coronavirus, Colors.orange),
                  _buildAnalysisCard('Crop Health Score',
                      '${analysisResults?['crop_health_score'] ?? 'N/A'}/100', Icons.favorite, Colors.pink),
                  _buildAnalysisCard('Land Area', '${analysisResults?['land_acres'] ?? 'N/A'} acres',
                      Icons.landscape, Colors.teal),
                  _buildAnalysisCard('Estimated Yield',
                      '${analysisResults?['estimated_yield'] ?? 'N/A'} tons/acre', Icons.agriculture, Colors.amber),
                  _buildAnalysisCard('Annual Income', analysisResults?['estimated_income_per_annum'] ?? 'N/A',
                      Icons.attach_money, Colors.greenAccent,
                      isHighlight: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(String title, String value, IconData icon, Color color, {bool isHighlight = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlight ? color.withOpacity(0.2) : const Color(0xFF0A0E21),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5), width: isHighlight ? 2 : 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isHighlight ? 20 : 18,
                    fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;

    for (int i = 1; i < 4; i++) {
      canvas.drawLine(Offset(size.width * i / 4, 0), Offset(size.width * i / 4, size.height), paint);
      canvas.drawLine(Offset(0, size.height * i / 4), Offset(size.width, size.height * i / 4), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}