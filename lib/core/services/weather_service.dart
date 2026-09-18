import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class WeatherData {
  final double temperature;
  final double feelsLike;
  final String condition;
  final String description;
  final int humidity;
  final double windSpeed;
  final int pressure;
  final int uvIndex;
  final String location;
  final DateTime timestamp;
  final String icon;

  WeatherData({
    required this.temperature,
    required this.feelsLike,
    required this.condition,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.uvIndex,
    required this.location,
    required this.timestamp,
    required this.icon,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json, String locationName) {
    return WeatherData(
      temperature: WeatherService.kelvinToCelsius(json['main']['temp']),
      feelsLike: WeatherService.kelvinToCelsius(json['main']['feels_like']),
      condition: WeatherService.formatWeatherCondition(json['weather'][0]['main']),
      description: json['weather'][0]['description'],
      humidity: json['main']['humidity'],
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      pressure: json['main']['pressure'],
      uvIndex: 0,
      location: locationName,
      timestamp: DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000),
      icon: json['weather'][0]['icon'],
    );
  }
}

class WeatherService {
  // ✅ CORRECT OPENWEATHERMAP API KEY
  static const String apiKey = 'aabc7bee80a19a2d55d44138456925ce';
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String geoUrl = 'https://api.openweathermap.org/geo/1.0';
  static const Duration timeout = Duration(seconds: 15);

  // -----------------------------
  // Get current location
  // -----------------------------
  Future<Position> getCurrentLocation() async {
    print('📍 Getting current location...');

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable GPS in settings.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      print('📱 Requesting location permission...');
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions denied. Please grant location access in app settings.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions permanently denied. Please enable in app settings.');
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      print('✅ Location obtained: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('❌ Error getting location: $e');
      throw Exception('Unable to get location. Please check GPS settings and try again.');
    }
  }

  // -----------------------------
  // Get coordinates from city name
  // -----------------------------
  Future<Map<String, dynamic>> getCoordinatesFromCity(String cityName) async {
    print('🔍 Searching for city: $cityName');

    final url = Uri.parse('$geoUrl/direct?q=$cityName,IN&limit=5&appid=$apiKey');

    try {
      final response = await http.get(url).timeout(timeout);

      print('📡 Search response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isEmpty) {
          throw Exception('City "$cityName" not found. Please check spelling.');
        }

        print('✅ City found: ${data[0]['name']}, ${data[0]['country']}');

        return {
          'lat': data[0]['lat'],
          'lon': data[0]['lon'],
        };
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key. Please check OpenWeatherMap key.');
      } else if (response.statusCode == 400) {
        throw Exception('Invalid city name. Please try again.');
      } else {
        throw Exception('Failed to find city (Error ${response.statusCode})');
      }
    } on SocketException {
      throw Exception('No Internet connection. Please check your network.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      print('❌ Error: $e');
      if (e is Exception) rethrow;
      throw Exception('Error finding city: $e');
    }
  }

  // -----------------------------
  // Get location details
  // -----------------------------
  Future<Map<String, String>> getLocationDetails(double lat, double lon) async {
    print('🌍 Getting location details for: $lat, $lon');

    try {
      // Try OpenWeatherMap reverse geocoding
      final url = Uri.parse('$geoUrl/reverse?lat=$lat&lon=$lon&limit=1&appid=$apiKey');
      final response = await http.get(url).timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final location = data[0];
          final city = location['name'] ?? 'Unknown';
          final country = location['country'] ?? '';

          print('✅ Location from API: $city, $country');

          return {
            'city': city,
            'country': country,
          };
        }
      }
    } catch (e) {
      print('⚠️ API location failed: $e, trying geocoding...');
    }

    // Fallback: Use geocoding
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks[0];
        final city = placemark.locality ??
            placemark.subAdministrativeArea ??
            placemark.administrativeArea ??
            'Unknown Location';
        final country = placemark.country ?? '';

        print('✅ Location from geocoding: $city, $country');

        return {
          'city': city,
          'country': country,
        };
      }
    } catch (e) {
      print('⚠️ Geocoding failed: $e');
    }

    // Final fallback
    return {
      'city': 'Lat: ${lat.toStringAsFixed(2)}, Lon: ${lon.toStringAsFixed(2)}',
      'country': ''
    };
  }

  // -----------------------------
  // Get current weather
  // -----------------------------
  Future<Map<String, dynamic>> getCurrentWeather(double lat, double lon) async {
    print('🌤️ Fetching current weather for: $lat, $lon');

    final url = Uri.parse('$baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric');

    try {
      print('📡 API URL: $url');

      final response = await http.get(url).timeout(timeout);

      print('📊 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Weather data received successfully!');
        return data;
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key. Check your OpenWeatherMap key.');
      } else if (response.statusCode == 400) {
        throw Exception('Invalid location coordinates.');
      } else {
        throw Exception('Failed to load weather (Error ${response.statusCode})');
      }
    } on SocketException {
      throw Exception('No Internet connection. Please check your network.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      print('❌ ERROR: $e');
      if (e is Exception) rethrow;
      throw Exception('Error fetching weather: $e');
    }
  }

  // -----------------------------
  // Get hourly forecast
  // -----------------------------
  Future<Map<String, dynamic>> getHourlyForecast(double lat, double lon) async {
    print('📅 Fetching hourly forecast for: $lat, $lon');

    final url = Uri.parse('$baseUrl/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric');

    try {
      final response = await http.get(url).timeout(timeout);

      print('📊 Forecast response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Forecast data received!');
        print('✅ Parsed ${data['list'].length} hourly forecasts');
        return data;
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key. Check your OpenWeatherMap key.');
      } else {
        throw Exception('Failed to load forecast (Error ${response.statusCode})');
      }
    } on SocketException {
      throw Exception('No Internet connection. Please check your network.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      print('❌ ERROR: $e');
      if (e is Exception) rethrow;
      throw Exception('Error fetching forecast: $e');
    }
  }

  // -----------------------------
  // Search locations
  // -----------------------------
  Future<List<Map<String, dynamic>>> searchLocations(String query) async {
    if (query.isEmpty) return [];

    print('🔍 Searching locations: $query');

    // Search specifically in India
    final url = Uri.parse('$geoUrl/direct?q=$query,IN&limit=10&appid=$apiKey');

    try {
      final response = await http.get(url).timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('✅ Found ${data.length} locations');

        return data.map((location) {
          return {
            'name': location['name'] ?? 'Unknown',
            'region': location['state'] ?? '',
            'country': location['country'] ?? '',
            'lat': location['lat'] ?? 0.0,
            'lon': location['lon'] ?? 0.0,
          };
        }).toList();
      } else {
        print('⚠️ Search failed: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Search error: $e');
      return [];
    }
  }

  // -----------------------------
  // Get weather by coordinates
  // -----------------------------
  Future<Map<String, dynamic>> getWeatherByCoordinates(double lat, double lon) async {
    return await getCurrentWeather(lat, lon);
  }

  // -----------------------------
  // Get weather icon emoji
  // -----------------------------
  String getWeatherIcon(String condition) {
    final conditionLower = condition.toLowerCase();

    if (conditionLower.contains('clear') || conditionLower.contains('sunny')) {
      return '☀️';
    }
    if (conditionLower.contains('cloud') || conditionLower.contains('overcast')) {
      return '☁️';
    }
    if (conditionLower.contains('rain') || conditionLower.contains('drizzle')) {
      return '🌧️';
    }
    if (conditionLower.contains('thunder') || conditionLower.contains('storm')) {
      return '⛈️';
    }
    if (conditionLower.contains('snow') || conditionLower.contains('blizzard')) {
      return '❄️';
    }
    if (conditionLower.contains('mist') || conditionLower.contains('fog') ||
        conditionLower.contains('haze')) {
      return '🌫️';
    }
    if (conditionLower.contains('wind')) {
      return '💨';
    }

    return '🌤️';
  }

  // -----------------------------
  // Get farming advice
  // -----------------------------
  String getFarmingAdvice(double temp, int humidity, String condition) {
    final conditionLower = condition.toLowerCase();

    if (conditionLower.contains('rain') || conditionLower.contains('drizzle')) {
      return 'Rainy conditions detected. Avoid irrigation and pesticide application. Good for water storage.';
    } else if (temp > 35) {
      return 'High temperature alert! Increase irrigation frequency. Provide shade for sensitive crops.';
    } else if (temp < 10) {
      return 'Low temperature warning. Protect crops from frost. Consider covering sensitive plants.';
    } else if (humidity > 80) {
      return 'High humidity detected. Monitor for fungal diseases. Ensure good air circulation.';
    } else if (humidity < 30) {
      return 'Low humidity. Increase irrigation. Mulch soil to retain moisture.';
    } else if (temp >= 20 && temp <= 30 && humidity >= 40 && humidity <= 70) {
      return 'Ideal conditions for farming! Good time for planting and field operations.';
    } else {
      return 'Moderate conditions. Monitor crops regularly and maintain proper irrigation schedule.';
    }
  }

  // -----------------------------
  // LEGACY METHODS (for backward compatibility)
  // -----------------------------
  static Future<WeatherData?> getWeatherByCity(String city) async {
    final url = Uri.parse('$baseUrl/weather?q=$city,IN&appid=$apiKey&units=metric');
    try {
      final response = await http.get(url).timeout(timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WeatherData.fromJson(data, data['name']);
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key');
      } else {
        throw HttpException('Failed to fetch weather: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No Internet connection');
    } on TimeoutException {
      throw Exception('Request timed out');
    } catch (e) {
      throw Exception('Error fetching weather: $e');
    }
  }

  static Future<List<WeatherData>> getForecast(double lat, double lon, int days) async {
    final url = Uri.parse('$baseUrl/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric&cnt=${days * 8}');
    try {
      final response = await http.get(url).timeout(timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final locationName = data['city']['name'] ?? 'Unknown Location';
        final List<dynamic> forecastList = data['list'] ?? [];

        final forecasts = forecastList.map((item) {
          return WeatherData.fromJson(item, locationName);
        }).toList();
        return forecasts;
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key');
      } else {
        throw HttpException('Failed to fetch forecast: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No Internet connection');
    } on TimeoutException {
      throw Exception('Request timed out');
    } catch (e) {
      throw Exception('Error fetching forecast: $e');
    }
  }

  static Future<WeatherData?> getWeatherForCurrentLocation() async {
    try {
      final weatherService = WeatherService();
      final position = await weatherService.getCurrentLocation();

      final url = Uri.parse('$baseUrl/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric');
      final response = await http.get(url).timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WeatherData.fromJson(data, data['name']);
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key');
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching weather for current location: $e');
    }
  }

  // -----------------------------
  // Helper Methods
  // -----------------------------
  static double kelvinToCelsius(dynamic temp) {
    if (temp is num) {
      return temp.toDouble();
    }
    return 0.0;
  }

  static String formatWeatherCondition(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return 'Clear Sky';
      case 'clouds':
        return 'Cloudy';
      case 'rain':
        return 'Rainy';
      case 'drizzle':
        return 'Drizzle';
      case 'thunderstorm':
        return 'Thunderstorm';
      case 'snow':
        return 'Snowy';
      case 'mist':
      case 'fog':
        return 'Foggy';
      default:
        return condition;
    }
  }

  static WeatherData getMockWeatherData() {
    return WeatherData(
      temperature: 28.5,
      feelsLike: 30.0,
      condition: 'Sunny',
      description: 'Clear sky',
      icon: '01d',
      humidity: 65,
      windSpeed: 12.5,
      pressure: 1013,
      uvIndex: 7,
      location: 'Mock City',
      timestamp: DateTime.now(),
    );
  }
}