import 'package:flutter/material.dart';

class WeatherData {
  final DateTime forecastDate;
  final String weatherCondition;
  final String weatherDescription;
  final double temp;
  final double humidityLevel;
  final double windSpeedKmh;
  final double rainAmount;
  final DateTime sunriseTime;
  final DateTime sunsetTime;
  final double uvIndexValue;
  final double pressureHpa;

  WeatherData({
    required this.forecastDate,
    required this.weatherCondition,
    required this.weatherDescription,
    required this.temp,
    required this.humidityLevel,
    required this.windSpeedKmh,
    required this.rainAmount,
    required this.sunriseTime,
    required this.sunsetTime,
    required this.uvIndexValue,
    required this.pressureHpa,
  });
}

class WeatherProvider extends ChangeNotifier {
  List<WeatherData> _forecastList = [];
  WeatherData? _currentWeather;
  bool _isLoading = false;
  String? _errorMessage;
  String _currentLocation = 'Unknown';

  List<WeatherData> get forecastList => _forecastList;
  WeatherData? get currentWeather => _currentWeather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentLocation => _currentLocation;

  Future<void> fetchCurrentWeather() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));

      final now = DateTime.now();
      _currentWeather = WeatherData(
        forecastDate: now,
        weatherCondition: 'Sunny',
        weatherDescription: 'Clear sky with bright sunshine',
        temp: 28.5,
        humidityLevel: 65.0,
        windSpeedKmh: 12.0,
        rainAmount: 0.0,
        sunriseTime: DateTime(now.year, now.month, now.day, 6, 30),
        sunsetTime: DateTime(now.year, now.month, now.day, 18, 45),
        uvIndexValue: 7.5,
        pressureHpa: 1013.0,
      );

      _currentLocation = 'New Delhi';
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchWeatherForecast(int days) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));

      _forecastList = List.generate(days, (index) {
        final date = DateTime.now().add(Duration(days: index));
        return WeatherData(
          forecastDate: date,
          weatherCondition: _getRandomCondition(),
          weatherDescription: 'Weather forecast for the day',
          temp: 20 + (index * 2.0),
          humidityLevel: 60 + (index * 3.0),
          windSpeedKmh: 10 + (index * 1.5),
          rainAmount: index * 2.0,
          sunriseTime: DateTime(date.year, date.month, date.day, 6, 30),
          sunsetTime: DateTime(date.year, date.month, date.day, 18, 45),
          uvIndexValue: 5 + (index * 0.5),
          pressureHpa: 1013 + (index * 2.0),
        );
      });

      _currentLocation = 'New Delhi';
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchWeatherByCity(String city) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      _currentLocation = city;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  String getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return '☀️';
      case 'cloudy':
      case 'partly cloudy':
        return '⛅';
      case 'rainy':
      case 'rain':
        return '🌧️';
      case 'stormy':
      case 'thunderstorm':
        return '⛈️';
      case 'snowy':
      case 'snow':
        return '❄️';
      case 'foggy':
      case 'mist':
        return '🌫️';
      default:
        return '🌤️';
    }
  }

  String _getRandomCondition() {
    final conditions = ['Sunny', 'Cloudy', 'Rainy', 'Partly Cloudy', 'Clear'];
    return conditions[DateTime.now().millisecond % conditions.length];
  }
}