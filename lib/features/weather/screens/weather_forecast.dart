import 'package:flutter/material.dart';

class WeatherForecastScreen extends StatefulWidget {
  const WeatherForecastScreen({super.key});

  @override
  State<WeatherForecastScreen> createState() => _WeatherForecastScreenState();
}

class _WeatherForecastScreenState extends State<WeatherForecastScreen> {
  // Mock weather data
  final Map<String, dynamic> _currentWeather = {
    'temperature': 28,
    'feelsLike': 32,
    'condition': 'Partly Cloudy',
    'icon': Icons.wb_cloudy,
    'humidity': 65,
    'windSpeed': 12,
    'pressure': 1013,
    'uvIndex': 7,
    'visibility': 10,
    'rainfall': 0,
    'location': 'Mumbai, Maharashtra',
  };

  final List<Map<String, dynamic>> _hourlyForecast = [
    {'time': '14:00', 'temp': 29, 'icon': Icons.wb_sunny, 'rain': 10},
    {'time': '15:00', 'temp': 30, 'icon': Icons.wb_sunny, 'rain': 5},
    {'time': '16:00', 'temp': 31, 'icon': Icons.wb_cloudy, 'rain': 15},
    {'time': '17:00', 'temp': 30, 'icon': Icons.wb_cloudy, 'rain': 20},
    {'time': '18:00', 'temp': 28, 'icon': Icons.cloud, 'rain': 30},
    {'time': '19:00', 'temp': 27, 'icon': Icons.cloud, 'rain': 40},
    {'time': '20:00', 'temp': 26, 'icon': Icons.nights_stay, 'rain': 25},
  ];

  final List<Map<String, dynamic>> _dailyForecast = [
    {'day': 'Today', 'date': 'Jul 23', 'icon': Icons.wb_cloudy, 'high': 32, 'low': 24, 'rain': 20},
    {'day': 'Friday', 'date': 'Jul 24', 'icon': Icons.wb_sunny, 'high': 33, 'low': 25, 'rain': 10},
    {'day': 'Saturday', 'date': 'Jul 25', 'icon': Icons.cloud, 'high': 30, 'low': 23, 'rain': 60},
    {'day': 'Sunday', 'date': 'Jul 26', 'icon': Icons.grain, 'high': 28, 'low': 22, 'rain': 80},
    {'day': 'Monday', 'date': 'Jul 27', 'icon': Icons.wb_cloudy, 'high': 29, 'low': 23, 'rain': 40},
    {'day': 'Tuesday', 'date': 'Jul 28', 'icon': Icons.wb_sunny, 'high': 31, 'low': 24, 'rain': 15},
    {'day': 'Wednesday', 'date': 'Jul 29', 'icon': Icons.wb_sunny, 'high': 32, 'low': 25, 'rain': 5},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Current Weather Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF2E7D32),
                  const Color(0xFF66BB6A).withValues(alpha: 0.8),
                ],
              ),
            ),
            child: Column(
              children: [
                // Location
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _currentWeather['location'],
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Temperature
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_currentWeather['temperature']}',
                      style: const TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                    const Text(
                      '°C',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Condition
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _currentWeather['icon'],
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _currentWeather['condition'],
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Feels like ${_currentWeather['feelsLike']}°C',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Conditions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Conditions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.2,
                        children: [
                          _buildConditionCard(
                            icon: Icons.water_drop,
                            label: 'Humidity',
                            value: '${_currentWeather['humidity']}%',
                            color: Colors.blue,
                          ),
                          _buildConditionCard(
                            icon: Icons.air,
                            label: 'Wind',
                            value: '${_currentWeather['windSpeed']} km/h',
                            color: Colors.teal,
                          ),
                          _buildConditionCard(
                            icon: Icons.compress,
                            label: 'Pressure',
                            value: '${_currentWeather['pressure']} mb',
                            color: Colors.purple,
                          ),
                          _buildConditionCard(
                            icon: Icons.wb_sunny,
                            label: 'UV Index',
                            value: '${_currentWeather['uvIndex']}',
                            color: Colors.orange,
                          ),
                          _buildConditionCard(
                            icon: Icons.visibility,
                            label: 'Visibility',
                            value: '${_currentWeather['visibility']} km',
                            color: Colors.indigo,
                          ),
                          _buildConditionCard(
                            icon: Icons.grain,
                            label: 'Rainfall',
                            value: '${_currentWeather['rainfall']} mm',
                            color: Colors.cyan,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Hourly Forecast
                const Text(
                  'Hourly Forecast',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(16),
                    itemCount: _hourlyForecast.length,
                    itemBuilder: (context, index) {
                      final hour = _hourlyForecast[index];
                      return _buildHourlyCard(hour);
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Daily Forecast
                const Text(
                  '7-Day Forecast',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: _dailyForecast.asMap().entries.map((entry) {
                      final index = entry.key;
                      final day = entry.value;
                      return Column(
                        children: [
                          _buildDailyCard(day),
                          if (index < _dailyForecast.length - 1)
                            Divider(height: 1, color: Colors.grey[200]),
                        ],
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyCard(Map<String, dynamic> hour) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            hour['time'],
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Icon(
            hour['icon'],
            color: const Color(0xFF2E7D32),
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            '${hour['temp']}°',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.water_drop, size: 12, color: Colors.blue[400]),
              const SizedBox(width: 2),
              Text(
                '${hour['rain']}%',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyCard(Map<String, dynamic> day) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day['day'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  day['date'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Icon(
            day['icon'],
            color: const Color(0xFF2E7D32),
            size: 32,
          ),
          const Spacer(),
          Row(
            children: [
              Icon(Icons.water_drop, size: 14, color: Colors.blue[400]),
              const SizedBox(width: 4),
              Text(
                '${day['rain']}%',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Row(
            children: [
              Text(
                '${day['high']}°',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${day['low']}°',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}