import 'package:flutter/material.dart';

/// Represents current weather data and forecast information for the Crop Analyzer app.
class WeatherModel {
  /// Unique identifier for the weather record.
  final String id;

  /// Location name.
  final String location;

  /// GPS latitude.
  final double latitude;

  /// GPS longitude.
  final double longitude;

  /// Current temperature in Celsius.
  final double temperature;

  /// Feels like temperature (optional).
  final double? feelsLike;

  /// Minimum temperature (optional).
  final double? minTemperature;

  /// Maximum temperature (optional).
  final double? maxTemperature;

  /// Humidity percentage.
  final double humidity;

  /// Rainfall in mm.
  final double rainfall;

  /// Wind speed in km/h.
  final double windSpeed;

  /// Wind direction (N/S/E/W/NE/NW/SE/SW).
  final String? windDirection;

  /// Atmospheric pressure in hPa (optional).
  final double? pressure;

  /// Visibility in km (optional).
  final double? visibility;

  /// UV index (optional).
  final double? uvIndex;

  /// Cloud cover percentage (optional).
  final double? cloudCover;

  /// Weather condition (Sunny/Cloudy/Rainy/Stormy/etc).
  final String weatherCondition;

  /// Weather condition code (optional).
  final int? weatherCode;

  /// Weather description.
  final String description;

  /// Weather icon code (optional).
  final String? icon;

  /// Sunrise time (optional).
  final DateTime? sunrise;

  /// Sunset time (optional).
  final DateTime? sunset;

  /// Observation timestamp.
  final DateTime timestamp;

  /// Weather forecast list (optional).
  final List<WeatherForecast>? forecast;

  /// Weather alerts (optional).
  final List<String>? alerts;

  /// Air quality index (optional).
  final int? airQualityIndex;

  /// Dew point temperature (optional).
  final double? dewPoint;

  /// Precipitation probability % (optional).
  final double? precipitationProbability;

  /// Data source (optional).
  final String? source;

  /// Record creation timestamp.
  final DateTime createdAt;

  /// Last update timestamp (optional).
  final DateTime? updatedAt;

  WeatherModel({
    required this.id,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.temperature,
    this.feelsLike,
    this.minTemperature,
    this.maxTemperature,
    required this.humidity,
    required this.rainfall,
    required this.windSpeed,
    this.windDirection,
    this.pressure,
    this.visibility,
    this.uvIndex,
    this.cloudCover,
    required this.weatherCondition,
    this.weatherCode,
    required this.description,
    this.icon,
    this.sunrise,
    this.sunset,
    required this.timestamp,
    this.forecast,
    this.alerts,
    this.airQualityIndex,
    this.dewPoint,
    this.precipitationProbability,
    this.source,
    required this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor for creating a [WeatherModel] from JSON data.
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      id: json['id'] ?? '',
      location: json['location'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      temperature: (json['temperature'] ?? 0).toDouble(),
      feelsLike: json['feelsLike'] != null ? (json['feelsLike'] as num).toDouble() : null,
      minTemperature: json['minTemperature'] != null ? (json['minTemperature'] as num).toDouble() : null,
      maxTemperature: json['maxTemperature'] != null ? (json['maxTemperature'] as num).toDouble() : null,
      humidity: (json['humidity'] ?? 0).toDouble(),
      rainfall: (json['rainfall'] ?? 0).toDouble(),
      windSpeed: (json['windSpeed'] ?? 0).toDouble(),
      windDirection: json['windDirection'],
      pressure: json['pressure'] != null ? (json['pressure'] as num).toDouble() : null,
      visibility: json['visibility'] != null ? (json['visibility'] as num).toDouble() : null,
      uvIndex: json['uvIndex'] != null ? (json['uvIndex'] as num).toDouble() : null,
      cloudCover: json['cloudCover'] != null ? (json['cloudCover'] as num).toDouble() : null,
      weatherCondition: json['weatherCondition'] ?? 'Unknown',
      weatherCode: json['weatherCode'],
      description: json['description'] ?? '',
      icon: json['icon'],
      sunrise: json['sunrise'] != null ? DateTime.parse(json['sunrise']) : null,
      sunset: json['sunset'] != null ? DateTime.parse(json['sunset']) : null,
      timestamp: DateTime.parse(json['timestamp']),
      forecast: json['forecast'] != null
          ? List<Map<String, dynamic>>.from(json['forecast'])
          .map((f) => WeatherForecast.fromJson(f))
          .toList()
          : null,
      alerts: json['alerts'] != null ? List<String>.from(json['alerts']) : null,
      airQualityIndex: json['airQualityIndex'],
      dewPoint: json['dewPoint'] != null ? (json['dewPoint'] as num).toDouble() : null,
      precipitationProbability: json['precipitationProbability'] != null
          ? (json['precipitationProbability'] as num).toDouble()
          : null,
      source: json['source'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  /// Converts the [WeatherModel] instance to a JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'location': location,
    'latitude': latitude,
    'longitude': longitude,
    'temperature': temperature,
    'feelsLike': feelsLike,
    'minTemperature': minTemperature,
    'maxTemperature': maxTemperature,
    'humidity': humidity,
    'rainfall': rainfall,
    'windSpeed': windSpeed,
    'windDirection': windDirection,
    'pressure': pressure,
    'visibility': visibility,
    'uvIndex': uvIndex,
    'cloudCover': cloudCover,
    'weatherCondition': weatherCondition,
    'weatherCode': weatherCode,
    'description': description,
    'icon': icon,
    'sunrise': sunrise?.toIso8601String(),
    'sunset': sunset?.toIso8601String(),
    'timestamp': timestamp.toIso8601String(),
    'forecast': forecast?.map((f) => f.toJson()).toList(),
    'alerts': alerts,
    'airQualityIndex': airQualityIndex,
    'dewPoint': dewPoint,
    'precipitationProbability': precipitationProbability,
    'source': source,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  /// Creates a copy of this [WeatherModel] with updated fields.
  WeatherModel copyWith({
    String? id,
    String? location,
    double? latitude,
    double? longitude,
    double? temperature,
    double? feelsLike,
    double? minTemperature,
    double? maxTemperature,
    double? humidity,
    double? rainfall,
    double? windSpeed,
    String? windDirection,
    double? pressure,
    double? visibility,
    double? uvIndex,
    double? cloudCover,
    String? weatherCondition,
    int? weatherCode,
    String? description,
    String? icon,
    DateTime? sunrise,
    DateTime? sunset,
    DateTime? timestamp,
    List<WeatherForecast>? forecast,
    List<String>? alerts,
    int? airQualityIndex,
    double? dewPoint,
    double? precipitationProbability,
    String? source,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WeatherModel(
      id: id ?? this.id,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      temperature: temperature ?? this.temperature,
      feelsLike: feelsLike ?? this.feelsLike,
      minTemperature: minTemperature ?? this.minTemperature,
      maxTemperature: maxTemperature ?? this.maxTemperature,
      humidity: humidity ?? this.humidity,
      rainfall: rainfall ?? this.rainfall,
      windSpeed: windSpeed ?? this.windSpeed,
      windDirection: windDirection ?? this.windDirection,
      pressure: pressure ?? this.pressure,
      visibility: visibility ?? this.visibility,
      uvIndex: uvIndex ?? this.uvIndex,
      cloudCover: cloudCover ?? this.cloudCover,
      weatherCondition: weatherCondition ?? this.weatherCondition,
      weatherCode: weatherCode ?? this.weatherCode,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      sunrise: sunrise ?? this.sunrise,
      sunset: sunset ?? this.sunset,
      timestamp: timestamp ?? this.timestamp,
      forecast: forecast ?? this.forecast,
      alerts: alerts ?? this.alerts,
      airQualityIndex: airQualityIndex ?? this.airQualityIndex,
      dewPoint: dewPoint ?? this.dewPoint,
      precipitationProbability: precipitationProbability ?? this.precipitationProbability,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Returns color representing the weather condition.
  Color getConditionColor() {
    switch (weatherCondition.toLowerCase()) {
      case 'sunny':
        return Colors.orange;
      case 'cloudy':
        return Colors.grey;
      case 'rainy':
        return Colors.blue;
      case 'stormy':
        return Colors.deepPurple;
      case 'foggy':
        return Colors.blueGrey;
      default:
        return Colors.teal;
    }
  }

  /// Returns icon representing the weather condition.
  IconData getConditionIcon() {
    switch (weatherCondition.toLowerCase()) {
      case 'sunny':
        return Icons.wb_sunny;
      case 'cloudy':
        return Icons.cloud;
      case 'rainy':
        return Icons.grain;
      case 'stormy':
        return Icons.flash_on;
      case 'foggy':
        return Icons.blur_on;
      default:
        return Icons.wb_cloudy;
    }
  }

  bool isRainy() => weatherCondition.toLowerCase().contains('rain');
  bool isSunny() => weatherCondition.toLowerCase().contains('sun');
  bool isCloudy() => weatherCondition.toLowerCase().contains('cloud');
  bool isStormy() => weatherCondition.toLowerCase().contains('storm');

  /// Returns temperature status (Hot/Warm/Cool/Cold).
  String getTemperatureStatus() {
    if (temperature >= 35) return 'Hot';
    if (temperature >= 25) return 'Warm';
    if (temperature >= 15) return 'Cool';
    return 'Cold';
  }

  /// Returns humidity status (Low/Normal/High).
  String getHumidityStatus() {
    if (humidity < 30) return 'Low';
    if (humidity <= 70) return 'Normal';
    return 'High';
  }

  /// Returns wind status (Calm/Moderate/Strong).
  String getWindStatus() {
    if (windSpeed < 10) return 'Calm';
    if (windSpeed <= 25) return 'Moderate';
    return 'Strong';
  }

  /// Checks if weather is good for farming.
  bool isGoodForFarming() {
    return !isStormy() &&
        !isRainy() &&
        humidity >= 40 &&
        humidity <= 80 &&
        temperature >= 18 &&
        temperature <= 32;
  }

  /// Checks if irrigation is needed.
  bool needsIrrigation() {
    return rainfall < 2 && humidity < 50 && !isRainy();
  }

  /// Returns short summary.
  String getSummary() {
    return '$location: $weatherCondition, ${temperature.toStringAsFixed(1)}°C, Humidity ${humidity.toStringAsFixed(0)}%';
  }

  @override
  String toString() =>
      'WeatherModel(id: $id, location: $location, condition: $weatherCondition, temp: $temperature°C)';

  // -----------------------------
  // Constants
  // -----------------------------

  static const List<String> weatherConditions = [
    'Sunny',
    'Cloudy',
    'Rainy',
    'Stormy',
    'Foggy',
    'Windy',
    'Snowy',
  ];

  static const List<String> temperatureStatuses = [
    'Hot',
    'Warm',
    'Cool',
    'Cold',
  ];

  static const List<String> humidityStatuses = [
    'Low',
    'Normal',
    'High',
  ];

  static const List<String> windStatuses = [
    'Calm',
    'Moderate',
    'Strong',
  ];
}

/// Represents a single forecast entry for a specific date.
class WeatherForecast {
  /// Forecast date.
  final DateTime date;

  /// Minimum temperature.
  final double minTemp;

  /// Maximum temperature.
  final double maxTemp;

  /// Weather condition.
  final String condition;

  /// Weather description (optional).
  final String? description;

  /// Rain probability percentage.
  final double rainProbability;

  /// Expected rainfall in mm (optional).
  final double? rainfall;

  /// Humidity percentage (optional).
  final double? humidity;

  /// Wind speed in km/h (optional).
  final double? windSpeed;

  /// Weather icon code (optional).
  final String? icon;

  WeatherForecast({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.condition,
    this.description,
    required this.rainProbability,
    this.rainfall,
    this.humidity,
    this.windSpeed,
    this.icon,
  });

  /// Factory constructor for creating a [WeatherForecast] from JSON data.
  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      date: DateTime.parse(json['date']),
      minTemp: (json['minTemp'] ?? 0).toDouble(),
      maxTemp: (json['maxTemp'] ?? 0).toDouble(),
      condition: json['condition'] ?? 'Unknown',
      description: json['description'],
      rainProbability: (json['rainProbability'] ?? 0).toDouble(),
      rainfall: json['rainfall'] != null ? (json['rainfall'] as num).toDouble() : null,
      humidity: json['humidity'] != null ? (json['humidity'] as num).toDouble() : null,
      windSpeed: json['windSpeed'] != null ? (json['windSpeed'] as num).toDouble() : null,
      icon: json['icon'],
    );
  }

  /// Converts the [WeatherForecast] instance to a JSON map.
  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'minTemp': minTemp,
    'maxTemp': maxTemp,
    'condition': condition,
    'description': description,
    'rainProbability': rainProbability,
    'rainfall': rainfall,
    'humidity': humidity,
    'windSpeed': windSpeed,
    'icon': icon,
  };

  /// Creates a copy of this [WeatherForecast] with updated fields.
  WeatherForecast copyWith({
    DateTime? date,
    double? minTemp,
    double? maxTemp,
    String? condition,
    String? description,
    double? rainProbability,
    double? rainfall,
    double? humidity,
    double? windSpeed,
    String? icon,
  }) {
    return WeatherForecast(
      date: date ?? this.date,
      minTemp: minTemp ?? this.minTemp,
      maxTemp: maxTemp ?? this.maxTemp,
      condition: condition ?? this.condition,
      description: description ?? this.description,
      rainProbability: rainProbability ?? this.rainProbability,
      rainfall: rainfall ?? this.rainfall,
      humidity: humidity ?? this.humidity,
      windSpeed: windSpeed ?? this.windSpeed,
      icon: icon ?? this.icon,
    );
  }

  /// Returns average temperature.
  double getAverageTemp() => (minTemp + maxTemp) / 2;

  /// Checks if the day is rainy.
  bool isRainyDay() => condition.toLowerCase().contains('rain');

  @override
  String toString() =>
      'WeatherForecast(date: ${date.toIso8601String()}, condition: $condition, min: $minTemp, max: $maxTemp)';
}
