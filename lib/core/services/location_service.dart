import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationData {
  final double latitude;
  final double longitude;
  final double accuracy;
  final double altitude;
  final double speed;
  final DateTime timestamp;
  final String? address;
  final String? city;
  final String? country;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.altitude,
    required this.speed,
    required this.timestamp,
    this.address,
    this.city,
    this.country,
  });

  @override
  String toString() {
    return 'LocationData(lat: $latitude, lon: $longitude, accuracy: $accuracy, altitude: $altitude, speed: $speed, city: $city, country: $country)';
  }
}

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  StreamSubscription<Position>? _positionStream;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    await checkLocationPermission();
    _initialized = true;
  }

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<LocationPermission> checkLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  Future<LocationPermission> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
    }
    return permission;
  }

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  Future<LocationData?> getCurrentLocation({
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async {
    try {
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await checkLocationPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await requestLocationPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          throw Exception('Location permission denied.');
        }
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: accuracy,
          timeLimit: const Duration(seconds: 15),
        ),
      );

      final placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);
      final place = placemarks.isNotEmpty ? placemarks.first : null;

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        speed: position.speed,
        timestamp: position.timestamp ?? DateTime.now(),
        address: place != null
            ? '${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}'
            : null,
        city: place?.locality,
        country: place?.country,
      );
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return null;
    }
  }

  Future<LocationData?> getLastKnownLocation() async {
    try {
      final position = await Geolocator.getLastKnownPosition();
      if (position == null) return null;

      final placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);
      final place = placemarks.isNotEmpty ? placemarks.first : null;

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        speed: position.speed,
        timestamp: position.timestamp ?? DateTime.now(),
        address: place != null
            ? '${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}'
            : null,
        city: place?.locality,
        country: place?.country,
      );
    } catch (e) {
      debugPrint('Error getting last known location: $e');
      return null;
    }
  }

  Stream<LocationData> getLocationStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async* {
    final permission = await checkLocationPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      await requestLocationPermission();
    }

    final positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: 10,
      ),
    );

    await for (final position in positionStream) {
      yield LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        speed: position.speed,
        timestamp: position.timestamp ?? DateTime.now(),
      );
    }
  }

  Future<String?> getAddressFromCoordinates(double lat, double lon) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isEmpty) return null;
      final place = placemarks.first;
      return '${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}';
    } catch (e) {
      debugPrint('Error in reverse geocoding: $e');
      return null;
    }
  }

  Future<Map<String, double>?> getCoordinatesFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isEmpty) return null;
      final loc = locations.first;
      return {'latitude': loc.latitude, 'longitude': loc.longitude};
    } catch (e) {
      debugPrint('Error in forward geocoding: $e');
      return null;
    }
  }

  double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371000; // meters
    final double dLat = _degToRad(lat2 - lat1);
    final double dLon = _degToRad(lon2 - lon1);
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _degToRad(double deg) => deg * (pi / 180.0);

  String formatCoordinates(double lat, double lon) {
    return '${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)}';
  }

  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(1)} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(2)} km';
    }
  }

  bool isValidCoordinate(double lat, double lon) {
    return lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180;
  }

  String getLocationAccuracyString(LocationAccuracy accuracy) {
    switch (accuracy) {
      case LocationAccuracy.best:
        return 'Best Accuracy (GPS)';
      case LocationAccuracy.high:
        return 'High Accuracy (GPS)';
      case LocationAccuracy.medium:
        return 'Medium Accuracy (Network)';
      case LocationAccuracy.low:
        return 'Low Accuracy (Passive)';
      case LocationAccuracy.reduced:
        return 'Reduced Accuracy';
      case LocationAccuracy.bestForNavigation:
        return 'Best For Navigation';
      default:
        return 'Unknown Accuracy';
    }
  }

  Future<String?> getCurrentCity() async {
    final location = await getCurrentLocation();
    return location?.city;
  }

  Future<String?> getCurrentCountry() async {
    final location = await getCurrentLocation();
    return location?.country;
  }

  Future<String?> getFullAddress() async {
    final location = await getCurrentLocation();
    return location?.address;
  }

  LocationData getMockLocation() {
    return LocationData(
      latitude: 31.5204,
      longitude: 74.3587,
      accuracy: 5.0,
      altitude: 200.0,
      speed: 0.0,
      timestamp: DateTime.now(),
      address: 'Mock Street, Lahore, Pakistan',
      city: 'Lahore',
      country: 'Pakistan',
    );
  }

  String getMockAddress() {
    return 'Mock Street, Lahore, Pakistan';
  }

  void dispose() {
    _positionStream?.cancel();
  }
}