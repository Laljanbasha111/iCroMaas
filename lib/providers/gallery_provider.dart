import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../models/gallery_image.dart';

class GalleryProvider extends ChangeNotifier {
  final List<GalleryImage> _images = [];
  List<GalleryImage> _filteredImages = [];

  List<GalleryImage> get images => List.unmodifiable(_images);

  List<GalleryImage> get filteredImages =>
      List.unmodifiable(_filteredImages);

  /// Load Gallery
  Future<void> loadGallery() async {
    if (_images.isEmpty) {
      _images.addAll([
        GalleryImage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          path: '',
          cropType: 'Wheat',
          healthScore: 92,
          disease: '',
          date: DateTime.now().toString().split(' ').first,
        ),
        GalleryImage(
          id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          path: '',
          cropType: 'Rice',
          healthScore: 68,
          disease: 'Leaf Spot',
          date: DateTime.now().toString().split(' ').first,
        ),
      ]);
    }

    _filteredImages = List.from(_images);
    notifyListeners();
  }

  /// Add Image
  Future<void> addImage(File file) async {
    final image = GalleryImage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      path: file.path,
      cropType: 'Unknown',
      healthScore: 0,
      disease: '',
      date: DateTime.now().toString().split(' ').first,
    );

    _images.insert(0, image);
    _filteredImages = List.from(_images);

    notifyListeners();
  }

  /// Delete Images
  Future<void> deleteImages(List<String> ids) async {
    _images.removeWhere((image) => ids.contains(image.id));
    _filteredImages.removeWhere((image) => ids.contains(image.id));

    notifyListeners();
  }

  /// Share Images
  Future<void> shareImages(List<String> ids) async {
    final files = _images
        .where((e) => ids.contains(e.id))
        .where((e) => e.path.isNotEmpty)
        .map((e) => XFile(e.path))
        .toList();

    if (files.isNotEmpty) {
      await Share.shareXFiles(files);
    }
  }

  /// Export Images
  Future<void> exportImages(List<String> ids) async {
    // Placeholder
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// Search
  void searchImages(String query) {
    if (query.isEmpty) {
      _filteredImages = List.from(_images);
    } else {
      _filteredImages = _images.where((image) {
        return image.cropType
            .toLowerCase()
            .contains(query.toLowerCase()) ||
            image.disease
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            image.date
                .toLowerCase()
                .contains(query.toLowerCase());
      }).toList();
    }

    notifyListeners();
  }

  /// Filter
  void applyFilter(String filter, DateTimeRange? range) {
    switch (filter) {
      case 'Healthy':
        _filteredImages =
            _images.where((e) => e.healthScore >= 80).toList();
        break;

      case 'Moderate':
        _filteredImages = _images
            .where((e) => e.healthScore >= 50 && e.healthScore < 80)
            .toList();
        break;

      case 'Unhealthy':
        _filteredImages =
            _images.where((e) => e.healthScore < 50).toList();
        break;

      case 'Disease Detected':
        _filteredImages =
            _images.where((e) => e.disease.isNotEmpty).toList();
        break;

      case 'Wheat':
      case 'Rice':
      case 'Corn':
        _filteredImages =
            _images.where((e) => e.cropType == filter).toList();
        break;

      default:
        _filteredImages = List.from(_images);
    }

    notifyListeners();
  }

  /// Sort
  void applySort(String sort) {
    switch (sort) {
      case 'Highest Health Score':
        _filteredImages.sort(
              (a, b) => b.healthScore.compareTo(a.healthScore),
        );
        break;

      case 'Lowest Health Score':
        _filteredImages.sort(
              (a, b) => a.healthScore.compareTo(b.healthScore),
        );
        break;

      case 'Oldest First':
        _filteredImages = _filteredImages.reversed.toList();
        break;

      case 'By Crop Type':
        _filteredImages.sort(
              (a, b) => a.cropType.compareTo(b.cropType),
        );
        break;

      default:
        _filteredImages.sort(
              (a, b) => b.date.compareTo(a.date),
        );
    }

    notifyListeners();
  }

  /// Get Image By ID
  GalleryImage? getImageById(String id) {
    try {
      return _images.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}