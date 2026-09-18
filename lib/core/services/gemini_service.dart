import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Gemini AI service for:
/// - General AI responses
/// - Agricultural advice
/// - Crop disease/image analysis
/// - Pest control advice
/// - Soil health advice
/// - Crop recommendations
/// - Crop analysis explanations
/// - Multi-turn chat
///
/// IMPORTANT:
/// The Gemini API key is NOT stored in this Dart file.
/// It is loaded from the .env file using GEMINI_API_KEY.
class GeminiService {
  GeminiService._internal();

  static GeminiService? _instance;

  static GeminiService get instance {
    _instance ??= GeminiService._internal();
    return _instance!;
  }

  factory GeminiService() => instance;

  // ============================================================
  // GEMINI CONFIGURATION
  // ============================================================

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta';

  /// Gemini model.
  static const String _model = 'gemini-3.6-flash';

  static const Duration _requestTimeout =
  Duration(seconds: 60);

  // ============================================================
  // API KEY
  // ============================================================
  //
  // IMPORTANT:
  // The actual API key is NOT present in this source code.
  //
  // Add the key to your local .env file:
  //
  // GEMINI_API_KEY=YOUR_API_KEY_HERE
  //
  // Never commit .env to GitHub.
  // ============================================================

  static String get apiKey {
    try {
      return dotenv.env['GEMINI_API_KEY']?.trim() ?? '';
    } catch (_) {
      return '';
    }
  }

  static bool get isConfigured {
    return apiKey.isNotEmpty;
  }

  // ============================================================
  // CHAT HISTORY
  // ============================================================

  final List<Map<String, dynamic>> _chatHistory =
  <Map<String, dynamic>>[];

  // ============================================================
  // COMMON HEADERS
  // ============================================================

  Map<String, String> get _headers {
    return <String, String>{
      'Content-Type': 'application/json',
      'X-goog-api-key': apiKey,
    };
  }

  // ============================================================
  // GENERATE TEXT RESPONSE
  // ============================================================

  Future<String> generateResponse(
      String prompt,
      ) async {
    final String cleanPrompt = prompt.trim();

    if (cleanPrompt.isEmpty) {
      throw Exception('Prompt cannot be empty.');
    }

    _validateConfiguration();

    try {
      _debugLog(
        'Sending text prompt to Gemini $_model',
      );

      final http.Response response = await http
          .post(
        _generateContentUri,
        headers: _headers,
        body: jsonEncode(
          <String, dynamic>{
            'contents': <Map<String, dynamic>>[
              <String, dynamic>{
                'role': 'user',
                'parts': <Map<String, dynamic>>[
                  <String, dynamic>{
                    'text': cleanPrompt,
                  },
                ],
              },
            ],
          },
        ),
      )
          .timeout(_requestTimeout);

      return _handleResponse(response);
    } catch (error) {
      _debugLog(
        'Gemini text error: $error',
      );

      throw Exception(
        _friendlyError(error),
      );
    }
  }

  // ============================================================
  // GENERATE RESPONSE WITH IMAGE
  // ============================================================

  Future<String> generateResponseWithImage(
      String prompt,
      List<int> imageBytes, {
        String mimeType = 'image/jpeg',
      }) async {
    final String cleanPrompt = prompt.trim();

    if (cleanPrompt.isEmpty) {
      throw Exception('Prompt cannot be empty.');
    }

    if (imageBytes.isEmpty) {
      throw Exception('Image bytes cannot be empty.');
    }

    _validateConfiguration();

    final String normalizedMimeType =
    mimeType.trim().isEmpty
        ? 'image/jpeg'
        : mimeType.trim().toLowerCase();

    try {
      _debugLog(
        'Sending image prompt to Gemini $_model',
      );

      final Uint8List bytes =
      imageBytes is Uint8List
          ? imageBytes
          : Uint8List.fromList(imageBytes);

      final String base64Image =
      base64Encode(bytes);

      final http.Response response = await http
          .post(
        _generateContentUri,
        headers: _headers,
        body: jsonEncode(
          <String, dynamic>{
            'contents': <Map<String, dynamic>>[
              <String, dynamic>{
                'role': 'user',
                'parts': <Map<String, dynamic>>[
                  <String, dynamic>{
                    'text': cleanPrompt,
                  },
                  <String, dynamic>{
                    'inline_data': <String, dynamic>{
                      'mime_type': normalizedMimeType,
                      'data': base64Image,
                    },
                  },
                ],
              },
            ],
          },
        ),
      )
          .timeout(_requestTimeout);

      return _handleResponse(response);
    } catch (error) {
      _debugLog(
        'Gemini image error: $error',
      );

      throw Exception(
        _friendlyError(error),
      );
    }
  }

  // ============================================================
  // CHAT
  // ============================================================

  Future<String> chat(
      String message,
      ) async {
    final String cleanMessage =
    message.trim();

    if (cleanMessage.isEmpty) {
      throw Exception('Message cannot be empty.');
    }

    _validateConfiguration();

    final Map<String, dynamic> userMessage =
    <String, dynamic>{
      'role': 'user',
      'parts': <Map<String, dynamic>>[
        <String, dynamic>{
          'text': cleanMessage,
        },
      ],
    };

    _chatHistory.add(userMessage);

    try {
      _debugLog(
        'Sending chat message to Gemini',
      );

      final http.Response response = await http
          .post(
        _generateContentUri,
        headers: _headers,
        body: jsonEncode(
          <String, dynamic>{
            'contents': _chatHistory,
          },
        ),
      )
          .timeout(_requestTimeout);

      final String text =
      _handleResponse(response);

      // Add Gemini response only after
      // successful request.
      _chatHistory.add(
        <String, dynamic>{
          'role': 'model',
          'parts': <Map<String, dynamic>>[
            <String, dynamic>{
              'text': text,
            },
          ],
        },
      );

      return text;
    } catch (error) {
      // Remove the failed user message.
      if (_chatHistory.isNotEmpty &&
          _chatHistory.last['role'] == 'user') {
        _chatHistory.removeLast();
      }

      _debugLog(
        'Gemini chat error: $error',
      );

      throw Exception(
        _friendlyError(error),
      );
    }
  }

  // ============================================================
  // RESET CHAT
  // ============================================================

  void resetChat() {
    _chatHistory.clear();

    _debugLog(
      'Gemini chat session reset',
    );
  }

  // ============================================================
  // CHAT HISTORY COUNT
  // ============================================================

  int get chatMessageCount {
    return _chatHistory.length;
  }

  // ============================================================
  // FARMING ADVICE
  // ============================================================

  Future<String> getFarmingAdvice(
      String query,
      ) {
    final String prompt = '''
Act as an expert agricultural advisor for Indian farming conditions.

Farmer query:
$query

Provide:

1. Direct answer
2. Practical field steps
3. Things to avoid
4. Expected timeline or result
5. Low-cost options when possible

Use clear, concise, farmer-friendly language.

Do not make dangerous or unsupported pesticide recommendations.
When chemical treatment is discussed, recommend following the
product label and local agricultural guidance.
''';

    return generateResponse(prompt);
  }

  // ============================================================
  // IDENTIFY CROP DISEASE
  // ============================================================

  Future<String> identifyCropDisease(
      List<int> imageBytes,
      ) {
    const String prompt = '''
Analyze this crop or plant image.

Provide:

1. Crop or plant type if visible
2. Visible disease, pest, nutrient deficiency, or stress symptoms
3. Severity level: mild, moderate, or severe
4. Recommended treatment
5. Preventive measures
6. Field monitoring suggestions

Focus on practical guidance for Indian farming conditions.

Important:
- If the image is unclear, say that clearly.
- Do not claim certainty from visual evidence alone.
- Distinguish between likely disease, nutrient deficiency,
  pest damage, and environmental stress when possible.
''';

    return generateResponseWithImage(
      prompt,
      imageBytes,
    );
  }

  // ============================================================
  // PEST CONTROL ADVICE
  // ============================================================

  Future<String> getPestControlAdvice({
    required String pestName,
    required String cropName,
  }) {
    final String prompt = '''
Provide pest control guidance for Indian farming conditions.

Pest:
$pestName

Crop:
$cropName

Include:

1. Identification signs
2. Crop damage symptoms
3. Organic control methods
4. Chemical control only when necessary
5. Safe application timing
6. Prevention strategy

Prioritize cost-effective and environmentally responsible options.

For chemical pesticides:
- Do not invent dosage rates.
- Recommend following the registered product label.
- Mention appropriate protective equipment.
- Consider local agricultural extension guidance.
''';

    return generateResponse(prompt);
  }

  // ============================================================
  // SOIL HEALTH ADVICE
  // ============================================================

  Future<String> getSoilHealthAdvice(
      Map<String, dynamic> soilData,
      ) {
    final String soilText = soilData.entries
        .map(
          (
          MapEntry<String, dynamic> entry,
          ) =>
      '${entry.key}: ${entry.value}',
    )
        .join('\n');

    final String prompt = '''
Analyze the following soil information for Indian farming conditions.

Soil data:
$soilText

Provide:

1. Soil health assessment
2. Possible nutrient deficiencies
3. Recommended fertilizers or amendments
4. Organic improvement methods
5. Suitable crops
6. Irrigation and pH management suggestions

Clearly distinguish measured soil information from assumptions.
''';

    return generateResponse(prompt);
  }

  // ============================================================
  // CROP RECOMMENDATION
  // ============================================================

  Future<String> getCropRecommendation({
    required String season,
    required String soilType,
    required String region,
  }) {
    final String prompt = '''
Recommend suitable crops for Indian farming conditions.

Season:
$season

Soil type:
$soilType

Region:
$region

Provide:

1. Top recommended crops
2. Water requirement
3. Fertilizer requirement
4. Expected yield range
5. Market demand
6. Approximate profitability factors
7. Key risks

Clearly state that yield and profitability vary with local conditions,
weather, management, market prices, and variety.
''';

    return generateResponse(prompt);
  }

  // ============================================================
  // EXPLAIN CROP ANALYSIS RESULT
  // ============================================================

  Future<String> explainAnalysisResult({
    required String cropType,
    required String nitrogenLevel,
    required String biomassLevel,
    String? weatherSummary,
  }) {
    final String weather =
    weatherSummary?.trim().isNotEmpty == true
        ? weatherSummary!.trim()
        : 'Not provided';

    final String prompt = '''
Explain the following crop analysis result in simple agricultural language.

Crop type:
$cropType

Nitrogen level:
$nitrogenLevel

Biomass level:
$biomassLevel

Weather:
$weather

Provide:

1. Crop health interpretation
2. Nitrogen management recommendation
3. Biomass improvement recommendation
4. Irrigation guidance
5. Immediate action plan
6. Follow-up monitoring schedule

Clearly distinguish model predictions from field-confirmed observations.
''';

    return generateResponse(prompt);
  }

  // ============================================================
  // GEMINI URI
  // ============================================================

  Uri get _generateContentUri {
    return Uri.parse(
      '$_baseUrl/models/$_model:generateContent',
    );
  }

  // ============================================================
  // CONFIGURATION VALIDATION
  // ============================================================

  void _validateConfiguration() {
    if (!isConfigured) {
      throw Exception(
        'Gemini API key is not configured. '
            'Add GEMINI_API_KEY to your .env file.',
      );
    }
  }

  // ============================================================
  // HANDLE RESPONSE
  // ============================================================

  String _handleResponse(
      http.Response response,
      ) {
    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      try {
        final dynamic decoded =
        jsonDecode(response.body);

        if (decoded is! Map<String, dynamic>) {
          throw Exception(
            'Invalid Gemini response format.',
          );
        }

        final dynamic candidates =
        decoded['candidates'];

        if (candidates is! List ||
            candidates.isEmpty) {
          throw Exception(
            'Gemini returned no candidates.',
          );
        }

        final dynamic firstCandidate =
            candidates.first;

        if (firstCandidate is! Map) {
          throw Exception(
            'Invalid Gemini candidate.',
          );
        }

        final dynamic content =
        firstCandidate['content'];

        if (content is! Map) {
          throw Exception(
            'Gemini response contains no content.',
          );
        }

        final dynamic parts =
        content['parts'];

        if (parts is! List ||
            parts.isEmpty) {
          throw Exception(
            'Gemini response contains no parts.',
          );
        }

        final StringBuffer textBuffer =
        StringBuffer();

        for (final dynamic part in parts) {
          if (part is Map &&
              part['text'] != null) {
            textBuffer.write(
              part['text'].toString(),
            );
          }
        }

        final String text =
        textBuffer.toString().trim();

        if (text.isEmpty) {
          throw Exception(
            'Empty Gemini response.',
          );
        }

        _debugLog(
          'Gemini response received successfully.',
        );

        return text;
      } catch (error) {
        if (error is FormatException) {
          throw Exception(
            'Gemini returned invalid JSON.',
          );
        }

        rethrow;
      }
    }

    String errorMessage =
        'Gemini request failed.';

    try {
      final dynamic decoded =
      jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        final dynamic errorData =
        decoded['error'];

        if (errorData is Map) {
          final dynamic message =
          errorData['message'];

          final dynamic status =
          errorData['status'];

          if (message != null &&
              message.toString().trim().isNotEmpty) {
            errorMessage =
            status != null
                ? '${status.toString()}: '
                '${message.toString()}'
                : message.toString();
          }
        }
      }
    } catch (_) {
      if (response.body.trim().isNotEmpty) {
        errorMessage =
            response.body.trim();
      }
    }

    throw Exception(
      'HTTP ${response.statusCode}: $errorMessage',
    );
  }

  // ============================================================
  // FRIENDLY ERROR
  // ============================================================

  String _friendlyError(
      Object error,
      ) {
    final String message =
    error.toString().toLowerCase();

    if (message.contains(
      'api key not valid',
    ) ||
        message.contains(
          'invalid api key',
        ) ||
        message.contains(
          'api_key_invalid',
        ) ||
        message.contains(
          'invalid_argument',
        )) {
      return 'Invalid Gemini API key. '
          'Check your GEMINI_API_KEY.';
    }

    if (message.contains(
      'quota',
    ) ||
        message.contains(
          'resource_exhausted',
        ) ||
        message.contains(
          'rate limit',
        ) ||
        message.contains(
          '429',
        )) {
      return 'Gemini API quota or rate limit exceeded.';
    }

    if (message.contains(
      'network',
    ) ||
        message.contains(
          'socket',
        ) ||
        message.contains(
          'connection',
        ) ||
        message.contains(
          'failed host lookup',
        )) {
      return 'Network connection error while contacting Gemini.';
    }

    if (message.contains(
      'permission',
    ) ||
        message.contains(
          'unauthorized',
        ) ||
        message.contains(
          '401',
        ) ||
        message.contains(
          '403',
        )) {
      return 'Gemini API authentication or permission error.';
    }

    if (message.contains(
      'timeout',
    )) {
      return 'Gemini request timed out. Please try again.';
    }

    if (message.contains(
      '404',
    ) ||
        message.contains(
          'not_found',
        ) ||
        message.contains(
          'model not found',
        )) {
      return 'Gemini model endpoint not found. '
          'Check the configured Gemini model.';
    }

    if (message.contains(
      '400',
    )) {
      return 'Gemini rejected the request. '
          'Please check the request format and model configuration.';
    }

    return 'Gemini error: $error';
  }

  // ============================================================
  // DEBUG LOG
  // ============================================================

  static void _debugLog(
      String message,
      ) {
    if (kDebugMode) {
      debugPrint(
        '🤖 $message',
      );
    }
  }
}