import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class RenderAnalysisService {
  RenderAnalysisService._();

  static const String baseUrl = 'https://icromaas.onrender.com';

  static Future<Map<String, dynamic>> analyzeImage(
      String imagePath,
      ) async {
    final file = File(imagePath);

    if (!await file.exists()) {
      throw Exception('Image file not found: $imagePath');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/analyze'),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imagePath,
        contentType: _getImageContentType(imagePath),
      ),
    );

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 180),
    );

    final response = await http.Response.fromStream(
      streamedResponse,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Analysis request failed';

      try {
        final errorBody = jsonDecode(response.body);

        if (errorBody is Map<String, dynamic> &&
            errorBody['detail'] != null) {
          message = errorBody['detail'].toString();
        }
      } catch (_) {
        if (response.body.isNotEmpty) {
          message = response.body;
        }
      }

      throw Exception(
        '$message (HTTP ${response.statusCode})',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception(
        'Invalid response received from Render API',
      );
    }

    return decoded;
  }

  static http.MediaType _getImageContentType(String path) {
    final extension = path.toLowerCase();

    if (extension.endsWith('.png')) {
      return http.MediaType('image', 'png');
    }

    if (extension.endsWith('.webp')) {
      return http.MediaType('image', 'webp');
    }

    if (extension.endsWith('.heic')) {
      return http.MediaType('image', 'heic');
    }

    return http.MediaType('image', 'jpeg');
  }
}