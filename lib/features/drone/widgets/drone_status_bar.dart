import 'package:flutter/material.dart';

class DroneStatusBar extends StatelessWidget {
  final double battery;
  final String gpsStatus;
  final bool isConnected;

  const DroneStatusBar({
    super.key,
    required this.battery,
    required this.gpsStatus,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.grey[850],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatusItem(
            Icons.battery_full,
            '${battery.toInt()}%',
            battery > 20 ? Colors.green : Colors.red,
          ),
          _buildStatusItem(
            Icons.gps_fixed,
            gpsStatus,
            isConnected ? Colors.green : Colors.grey,
          ),
          _buildStatusItem(
            Icons.signal_cellular_alt,
            isConnected ? 'Connected' : 'Disconnected',
            isConnected ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}