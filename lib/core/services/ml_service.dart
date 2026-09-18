import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image/image.dart' as img;

class CropAnalysisResult {
  final String diseaseName;
  final double confidence;
  final String description;
  final List<String> symptoms;
  final List<String> treatments;
  final String severity;
  final Map<String, dynamic>? additionalInfo;

  CropAnalysisResult({
    required this.diseaseName,
    required this.confidence,
    required this.description,
    required this.symptoms,
    required this.treatments,
    required this.severity,
    this.additionalInfo,
  });

  Map<String, dynamic> toJson() => {
    'diseaseName': diseaseName,
    'confidence': confidence,
    'description': description,
    'symptoms': symptoms,
    'treatments': treatments,
    'severity': severity,
    'additionalInfo': additionalInfo,
  };

  factory CropAnalysisResult.fromJson(Map<String, dynamic> json) =>
      CropAnalysisResult(
        diseaseName: json['diseaseName'] ?? 'Unknown',
        confidence: (json['confidence'] ?? 0.0).toDouble(),
        description: json['description'] ?? '',
        symptoms: List<String>.from(json['symptoms'] ?? []),
        treatments: List<String>.from(json['treatments'] ?? []),
        severity: json['severity'] ?? 'Unknown',
        additionalInfo: json['additionalInfo'],
      );
}

class MLService {
  static final MLService _instance = MLService._internal();
  factory MLService() => _instance;
  MLService._internal();

  GenerativeModel? _model;
  bool _isInitialized = false;

  // -------------------- Initialization --------------------
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('GEMINI_API_KEY not found in .env file');
      }

      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.4,
          topK: 32,
          topP: 1,
          maxOutputTokens: 2048,
        ),
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
        ],
      );

      _isInitialized = true;
      debugPrint('✅ ML Service initialized with Gemini AI');
    } catch (e) {
      debugPrint('❌ ML Service initialization failed: $e');
      rethrow;
    }
  }

  // -------------------- Crop Disease Analysis --------------------
  Future<CropAnalysisResult> analyzeCropImage(File imageFile) async {
    if (!_isInitialized || _model == null) {
      await initialize();
    }

    try {
      // Read and process image
      final imageBytes = await imageFile.readAsBytes();
      final processedImage = await _preprocessImage(imageBytes);

      // Create prompt for Gemini
      final prompt = _buildAnalysisPrompt();

      // Send to Gemini with image
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', processedImage),
        ])
      ];

      final response = await _model!.generateContent(content);
      final analysisText = response.text ?? '';

      // Parse response
      return _parseGeminiResponse(analysisText);
    } catch (e) {
      debugPrint('❌ Crop analysis failed: $e');
      throw Exception('Failed to analyze crop image: $e');
    }
  }

  // -------------------- Batch Analysis --------------------
  Future<List<CropAnalysisResult>> analyzeBatchImages(
      List<File> imageFiles) async {
    final results = <CropAnalysisResult>[];

    for (final imageFile in imageFiles) {
      try {
        final result = await analyzeCropImage(imageFile);
        results.add(result);
      } catch (e) {
        debugPrint('❌ Failed to analyze image: ${imageFile.path}');
        // Add error result
        results.add(CropAnalysisResult(
          diseaseName: 'Analysis Failed',
          confidence: 0.0,
          description: 'Failed to analyze this image',
          symptoms: [],
          treatments: [],
          severity: 'Unknown',
        ));
      }
    }

    return results;
  }

  // -------------------- Text-based Query --------------------
  Future<String> askCropQuestion(String question,
      {File? contextImage}) async {
    if (!_isInitialized || _model == null) {
      await initialize();
    }

    try {
      final prompt = '''
You are an expert agricultural advisor specializing in crop health and disease management.

User Question: $question

Provide a detailed, practical answer that includes:
1. Direct answer to the question
2. Relevant agricultural best practices
3. Preventive measures if applicable
4. Additional helpful tips

Keep the response clear, actionable, and farmer-friendly.
''';

      List<Part> parts = [TextPart(prompt)];

      // Add image if provided
      if (contextImage != null) {
        final imageBytes = await contextImage.readAsBytes();
        final processedImage = await _preprocessImage(imageBytes);
        parts.add(DataPart('image/jpeg', processedImage));
      }

      final content = [Content.multi(parts)];
      final response = await _model!.generateContent(content);

      return response.text ?? 'No response generated';
    } catch (e) {
      debugPrint('❌ Question answering failed: $e');
      throw Exception('Failed to answer question: $e');
    }
  }

  // -------------------- Get Treatment Recommendations --------------------
  Future<Map<String, dynamic>> getTreatmentRecommendations(
      String diseaseName) async {
    if (!_isInitialized || _model == null) {
      await initialize();
    }

    try {
      final prompt = '''
Provide comprehensive treatment recommendations for: $diseaseName

Format your response as JSON with the following structure:
{
  "organic_treatments": ["treatment1", "treatment2", ...],
  "chemical_treatments": ["treatment1", "treatment2", ...],
  "preventive_measures": ["measure1", "measure2", ...],
  "timeline": "Expected recovery timeline",
  "cost_estimate": "Approximate treatment cost",
  "effectiveness": "Treatment effectiveness rating"
}

Be specific and practical.
''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      final responseText = response.text ?? '{}';

      // Extract JSON from response
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(responseText);
      if (jsonMatch != null) {
        return jsonDecode(jsonMatch.group(0)!);
      }

      return {};
    } catch (e) {
      debugPrint('❌ Treatment recommendations failed: $e');
      return {};
    }
  }

  // -------------------- Image Preprocessing --------------------
  Future<Uint8List> _preprocessImage(Uint8List imageBytes) async {
    try {
      // Decode image
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) throw Exception('Failed to decode image');

      // Resize to optimal size (max 1024x1024 for Gemini)
      if (image.width > 1024 || image.height > 1024) {
        image = img.copyResize(
          image,
          width: image.width > image.height ? 1024 : null,
          height: image.height > image.width ? 1024 : null,
        );
      }

      // Enhance image quality
      image = img.adjustColor(
        image,
        contrast: 1.1,
        brightness: 1.05,
      );

      // Encode as JPEG
      return Uint8List.fromList(img.encodeJpg(image, quality: 85));
    } catch (e) {
      debugPrint('⚠️ Image preprocessing failed, using original: $e');
      return imageBytes;
    }
  }

  // -------------------- Prompt Building --------------------
  String _buildAnalysisPrompt() {
    return '''
You are an expert agricultural pathologist specializing in crop disease identification.

Analyze the provided crop image and identify any diseases, pests, or health issues.

Provide your analysis in the following JSON format:
{
  "diseaseName": "Name of the disease or 'Healthy' if no issues",
  "confidence": 0.95,
  "description": "Detailed description of the condition",
  "symptoms": ["symptom1", "symptom2", "symptom3"],
  "treatments": ["treatment1", "treatment2", "treatment3"],
  "severity": "Low/Medium/High/Critical",
  "additionalInfo": {
    "affected_area": "percentage or description",
    "stage": "early/moderate/advanced",
    "spread_risk": "low/medium/high",
    "recommended_action": "immediate action needed"
  }
}

Be precise, scientific, and provide actionable recommendations.
If the image is unclear or not a crop, indicate that in the response.
''';
  }

  // -------------------- Response Parsing --------------------
  CropAnalysisResult _parseGeminiResponse(String responseText) {
    try {
      // Extract JSON from response (Gemini might wrap it in markdown)
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(responseText);
      if (jsonMatch == null) {
        throw Exception('No valid JSON found in response');
      }

      final jsonString = jsonMatch.group(0)!;
      final jsonData = jsonDecode(jsonString);

      return CropAnalysisResult.fromJson(jsonData);
    } catch (e) {
      debugPrint('⚠️ Failed to parse JSON, using fallback: $e');

      // Fallback: Create result from text analysis
      return CropAnalysisResult(
        diseaseName: _extractDiseaseName(responseText),
        confidence: 0.75,
        description: responseText,
        symptoms: _extractListItems(responseText, 'symptom'),
        treatments: _extractListItems(responseText, 'treatment'),
        severity: _extractSeverity(responseText),
      );
    }
  }

  // -------------------- Fallback Parsers --------------------
  String _extractDiseaseName(String text) {
    final patterns = [
      RegExp(r'disease[:\s]+([^\n\.]+)', caseSensitive: false),
      RegExp(r'identified[:\s]+([^\n\.]+)', caseSensitive: false),
      RegExp(r'diagnosis[:\s]+([^\n\.]+)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) return match.group(1)!.trim();
    }

    return 'Unknown Condition';
  }

  List<String> _extractListItems(String text, String keyword) {
    final items = <String>[];
    final lines = text.split('\n');

    for (final line in lines) {
      if (line.toLowerCase().contains(keyword)) {
        final cleaned = line
            .replaceAll(RegExp(r'^[\-\*\d\.]+'), '')
            .replaceAll(RegExp(r'$keyword:', caseSensitive: false), '')
            .trim();
        if (cleaned.isNotEmpty) items.add(cleaned);
      }
    }

    return items.isEmpty ? ['Information not available'] : items;
  }

  String _extractSeverity(String text) {
    final lowerText = text.toLowerCase();
    if (lowerText.contains('critical') || lowerText.contains('severe')) {
      return 'Critical';
    } else if (lowerText.contains('high') || lowerText.contains('serious')) {
      return 'High';
    } else if (lowerText.contains('medium') || lowerText.contains('moderate')) {
      return 'Medium';
    } else if (lowerText.contains('low') || lowerText.contains('mild')) {
      return 'Low';
    }
    return 'Unknown';
  }

  // -------------------- Utility Methods --------------------
  bool isInitialized() => _isInitialized;

  Future<bool> checkModelAvailability() async {
    try {
      await initialize();
      return _isInitialized;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _model = null;
    _isInitialized = false;
    debugPrint('🗑️ ML Service disposed');
  }
}

