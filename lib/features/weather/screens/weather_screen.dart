import 'package:flutter/material.dart';
import '../../../core/services/weather_service.dart';
import 'package:geolocator/geolocator.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();
  final TextEditingController _locationController = TextEditingController();

  bool _loading = true;
  String _error = '';
  bool _useCurrentLocation = true;

  String _cityName = 'Loading...';
  String _countryName = '';
  double _latitude = 0;
  double _longitude = 0;
  double _temperature = 0;
  String _condition = '';
  String _feelsLike = '';
  int _humidity = 0;
  int _windSpeed = 0;
  int _visibility = 0;
  int _uvIndex = 0;
  double _rainfall = 0;
  List<Map<String, dynamic>> _hourlyForecast = [];
  String _farmingAdvice = '';

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadWeatherData() async {
    try {
      setState(() {
        _loading = true;
        _error = '';
      });

      print('🚀 Starting weather data load...');
      print('📍 Use current location: $_useCurrentLocation');

      if (_useCurrentLocation) {
        print('📡 Getting current location...');
        Position position = await _weatherService.getCurrentLocation();
        _latitude = position.latitude;
        _longitude = position.longitude;
        print('✅ Location obtained: $_latitude, $_longitude');
      } else {
        if (_locationController.text.isEmpty) {
          setState(() {
            _error = 'Please enter a city name';
            _loading = false;
          });
          return;
        }

        print('🔍 Searching for city: ${_locationController.text}');
        Map<String, dynamic> coordinates = await _weatherService.getCoordinatesFromCity(
          _locationController.text,
        );
        _latitude = coordinates['lat'];
        _longitude = coordinates['lon'];
        print('✅ City coordinates: $_latitude, $_longitude');
      }

      print('🌍 Getting location details...');
      Map<String, String> location = await _weatherService.getLocationDetails(
        _latitude,
        _longitude,
      );
      print('✅ Location: ${location['city']}, ${location['country']}');

      print('🌤️ Fetching current weather...');
      Map<String, dynamic> currentWeather = await _weatherService.getCurrentWeather(
        _latitude,
        _longitude,
      );
      print('✅ Weather data received');

      print('📊 Fetching forecast...');
      Map<String, dynamic> forecast = await _weatherService.getHourlyForecast(
        _latitude,
        _longitude,
      );
      print('✅ Forecast data received');

      if (mounted) {
        setState(() {
          _cityName = location['city'] ?? 'Unknown';
          _countryName = location['country'] ?? '';
          _temperature = (currentWeather['main']?['temp'] ?? 0).toDouble();
          _condition = currentWeather['weather']?[0]?['main'] ?? 'Unknown';
          _feelsLike = '${(currentWeather['main']?['feels_like'] ?? 0).toInt()}°C';
          _humidity = currentWeather['main']?['humidity'] ?? 0;
          _windSpeed = ((currentWeather['wind']?['speed'] ?? 0) * 3.6).toInt();
          _visibility = 10;
          _uvIndex = 5;
          _rainfall = (currentWeather['rain']?['1h'] ?? 0).toDouble();

          _hourlyForecast = (forecast['list'] as List?)
              ?.take(4)
              .map((item) {
            int timestamp = item['dt'] ?? 0;
            DateTime dateTime;

            if (timestamp > 0) {
              dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
            } else {
              dateTime = DateTime.now();
            }

            return {
              'time': '${dateTime.hour.toString().padLeft(2, '0')}:00',
              'temp': '${(item['main']?['temp'] ?? 0).toInt()}°',
              'condition': item['weather']?[0]?['main'] ?? 'Unknown',
            };
          })
              .toList() ?? [];

          _farmingAdvice = _weatherService.getFarmingAdvice(
            _temperature,
            _humidity,
            _condition,
          );

          _loading = false;
        });
        print('✅ Weather data loaded successfully!');
      }
    } catch (e) {
      print('❌ ERROR: $e');
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _loading = false;
        });
      }
    }
  }

  void _showLocationDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Change Location',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              InkWell(
                onTap: () {
                  setState(() {
                    _useCurrentLocation = true;
                    _locationController.clear();
                  });
                  Navigator.pop(context);
                  _loadWeatherData();
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _useCurrentLocation
                        ? Colors.green[50]
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _useCurrentLocation
                          ? Colors.green[700]!
                          : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.my_location,
                        color: _useCurrentLocation
                            ? Colors.green[700]
                            : Colors.grey[600],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Use Current Location',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _useCurrentLocation
                                    ? Colors.green[700]
                                    : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Get weather for your current location',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_useCurrentLocation)
                        Icon(
                          Icons.check_circle,
                          color: Colors.green[700],
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 16),

              const Text(
                'Enter City Name',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: 'e.g., Mumbai, Delhi, Bangalore',
                  prefixIcon: Icon(Icons.search, color: Colors.green[700]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green[700]!, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                textCapitalization: TextCapitalization.words,
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      _useCurrentLocation = false;
                    });
                    Navigator.pop(context);
                    _loadWeatherData();
                  }
                },
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_locationController.text.isNotEmpty) {
                      setState(() {
                        _useCurrentLocation = false;
                      });
                      Navigator.pop(context);
                      _loadWeatherData();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Search Location',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weather & Farming',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            if (!_loading && _error.isEmpty)
              Row(
                children: [
                  Icon(
                    _useCurrentLocation ? Icons.my_location : Icons.location_on,
                    color: Colors.white.withOpacity(0.9),
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _useCurrentLocation ? 'Current Location' : 'Custom Location',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 11,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
          ],
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_loading)
            IconButton(
              icon: const Icon(Icons.location_on, color: Colors.white),
              onPressed: _showLocationDialog,
              tooltip: 'Change Location',
            ),
          if (!_loading)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadWeatherData,
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: _loading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.green),
      )
          : _error.isNotEmpty
          ? _buildErrorView()
          : RefreshIndicator(
        onRefresh: _loadWeatherData,
        color: Colors.green[700],
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildWeatherHeader(),
              const SizedBox(height: 16),
              _buildCurrentConditions(),
              const SizedBox(height: 16),
              _buildHourlyForecast(),
              const SizedBox(height: 16),
              _buildFarmingAdvice(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red[400],
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load weather data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _error,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _loadWeatherData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _showLocationDialog,
                  icon: const Icon(Icons.location_on),
                  label: const Text('Change Location'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.green[700]!,
            Colors.green[500]!,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _cityName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  if (_countryName.isNotEmpty) ...[
                    Text(
                      ', ',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    Text(
                      _countryName,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${_temperature.toInt()}°C',
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _weatherService.getWeatherIcon(_condition),
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _condition,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Feels like $_feelsLike',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentConditions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _buildConditionCard(
                  'UV Index',
                  '$_uvIndex',
                  Icons.wb_sunny,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildConditionCard(
                  'Visibility',
                  '$_visibility km',
                  Icons.visibility,
                  Colors.teal,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildConditionCard(
                  'Rainfall',
                  '${_rainfall.toStringAsFixed(1)} mm',
                  Icons.umbrella,
                  Colors.indigo,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ COMPLETELY FIXED: No overflow!
  Widget _buildConditionCard(String label, String value, IconData icon, Color color) {
    return Container(
      constraints: const BoxConstraints(minHeight: 95), // ✅ Use constraints instead of fixed height
      padding: const EdgeInsets.all(8), // ✅ Uniform padding
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // ✅ Let content determine size
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20), // ✅ Smaller icon
          const SizedBox(height: 4),
          if (value.isNotEmpty)
            Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyForecast() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hourly Forecast',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120, // ✅ Increased height
            child: _hourlyForecast.isEmpty
                ? Center(
              child: Text(
                'No forecast data available',
                style: TextStyle(color: Colors.grey[600]),
              ),
            )
                : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _hourlyForecast.length,
              itemBuilder: (context, index) {
                final data = _hourlyForecast[index];
                return Container(
                  width: 80, // ✅ Increased width
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(10), // ✅ Better padding
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        data['time'] ?? '00:00',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _weatherService.getWeatherIcon(data['condition'] ?? 'Unknown'),
                        style: const TextStyle(fontSize: 28), // ✅ Slightly smaller emoji
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data['temp'] ?? '0°',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmingAdvice() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amber[700], size: 24),
              const SizedBox(width: 8),
              const Text(
                'Farming Advice',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAdviceItem(
            Icons.water_drop,
            'Weather Advice',
            _farmingAdvice,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildAdviceItem(
            Icons.grass,
            'Crop Health',
            'Temperature: ${_temperature.toInt()}°C, Humidity: $_humidity%',
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildAdviceItem(
            Icons.air,
            'Wind Conditions',
            'Wind speed: $_windSpeed km/h. ${_windSpeed > 30 ? "High wind - secure crops" : "Moderate wind conditions"}',
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceItem(IconData icon, String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}