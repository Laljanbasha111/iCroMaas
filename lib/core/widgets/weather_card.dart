import 'package:flutter/material.dart';
import 'dart:math' as math;

class WeatherCard extends StatelessWidget {
  final double temperature;
  final String location;
  final String condition;
  final int? humidity;
  final double? windSpeed;
  final int? pressure;
  final double? feelsLike;
  final int? uvIndex;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool showDetails;
  final Gradient? gradient;

  const WeatherCard({
    Key? key,
    required this.temperature,
    required this.location,
    required this.condition,
    this.humidity,
    this.windSpeed,
    this.pressure,
    this.feelsLike,
    this.uvIndex,
    this.icon,
    this.onTap,
    this.showDetails = true,
    this.gradient,
  }) : super(key: key);

  IconData _getWeatherIcon(String condition) {
    final lower = condition.toLowerCase();
    if (lower.contains('sun') || lower.contains('clear')) {
      return Icons.wb_sunny_rounded;
    } else if (lower.contains('cloud')) {
      return Icons.cloud_rounded;
    } else if (lower.contains('rain')) {
      return Icons.grain_rounded;
    } else if (lower.contains('storm') || lower.contains('thunder')) {
      return Icons.flash_on_rounded;
    } else if (lower.contains('snow')) {
      return Icons.ac_unit_rounded;
    } else if (lower.contains('fog') || lower.contains('mist')) {
      return Icons.blur_on_rounded;
    } else {
      return Icons.wb_cloudy_rounded;
    }
  }

  Gradient _getWeatherGradient(String condition) {
    final lower = condition.toLowerCase();
    if (lower.contains('sun') || lower.contains('clear')) {
      return const LinearGradient(
        colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (lower.contains('cloud')) {
      return const LinearGradient(
        colors: [Color(0xFFB0BEC5), Color(0xFF90A4AE)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (lower.contains('rain')) {
      return const LinearGradient(
        colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (lower.contains('storm') || lower.contains('thunder')) {
      return const LinearGradient(
        colors: [Color(0xFF283593), Color(0xFF1A237E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (lower.contains('snow')) {
      return const LinearGradient(
        colors: [Color(0xFFE3F2FD), Color(0xFF90CAF9)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (lower.contains('fog') || lower.contains('mist')) {
      return const LinearGradient(
        colors: [Color(0xFFCFD8DC), Color(0xFFB0BEC5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      return const LinearGradient(
        colors: [Color(0xFF81D4FA), Color(0xFF0288D1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }

  Widget _buildTemperature() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          temperature.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            '°C',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white70,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.location_on, color: Colors.white70, size: 18),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            location,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCondition() {
    return Text(
      condition,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildWeatherDetails() {
    final details = <Widget>[];
    if (humidity != null) {
      details.add(_buildDetailItem(Icons.water_drop, 'Humidity', '$humidity%'));
    }
    if (windSpeed != null) {
      details.add(_buildDetailItem(Icons.air, 'Wind', '${windSpeed!.toStringAsFixed(1)} km/h'));
    }
    if (pressure != null) {
      details.add(_buildDetailItem(Icons.speed, 'Pressure', '$pressure hPa'));
    }
    if (feelsLike != null) {
      details.add(_buildDetailItem(Icons.thermostat, 'Feels Like', '${feelsLike!.toStringAsFixed(1)}°C'));
    }
    if (uvIndex != null) {
      details.add(_buildDetailItem(Icons.wb_sunny, 'UV Index', '$uvIndex'));
    }

    if (details.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 8,
        children: details,
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedIcon(IconData iconData) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 2 * math.pi),
      duration: const Duration(seconds: 10),
      builder: (context, angle, child) {
        return Transform.rotate(
          angle: angle,
          child: child,
        );
      },
      child: Icon(
        iconData,
        color: Colors.white,
        size: 64,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weatherIcon = icon ?? _getWeatherIcon(condition);
    final weatherGradient = gradient ?? _getWeatherGradient(condition);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.all(12),
        child: Container(
          decoration: BoxDecoration(
            gradient: weatherGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLocation(),
              const SizedBox(height: 8),
              _buildAnimatedIcon(weatherIcon),
              const SizedBox(height: 8),
              _buildTemperature(),
              const SizedBox(height: 4),
              _buildCondition(),
              if (showDetails) _buildWeatherDetails(),
            ],
          ),
        ),
      ),
    );
  }
}