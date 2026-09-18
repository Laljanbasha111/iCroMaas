import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../app/constants/env.dart';

class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatbotProvider extends ChangeNotifier {
  final List<Message> _messages = [];
  bool _isLoading = false;
  GenerativeModel? _model;
  String? _initError;

  ChatbotProvider() {
    _initializeAI();
    _addWelcomeMessage();
  }

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isInitialized => _model != null;
  String? get initError => _initError;

  void _initializeAI() {
    try {
      final apiKey = Env.geminiApiKey;

      if (apiKey.isEmpty) {
        _initError = 'API key is missing';
        debugPrint('❌ GEMINI_API_KEY is empty!');
        return;
      }

      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );

      debugPrint("✅ Gemini AI initialized with gemini-1.5-flash");
      _initError = null;
    } catch (e) {
      _initError = e.toString();
      debugPrint('❌ Error initializing AI: $e');
    }
  }

  void _addWelcomeMessage() {
    _messages.add(
      Message(
        text: '👋 Hello! I\'m your AI Assistant!\n\n'
            'I can help you with:\n'
            '💬 General questions & conversations\n'
            '📚 Learning & education\n'
            '🌾 Farming & agriculture\n'
            '🔬 Science & technology\n'
            '💡 Creative ideas & brainstorming\n'
            '🌍 Travel, culture & more!\n\n'
            'Ask me anything!',
        isUser: false,
      ),
    );
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    if (_model == null) {
      _messages.add(
        Message(
          text: '❌ AI not initialized. Retrying...',
          isUser: false,
        ),
      );
      notifyListeners();

      _initializeAI();

      if (_model == null) {
        _messages.add(
          Message(
            text: '❌ Failed to initialize. Please check your API key.',
            isUser: false,
          ),
        );
        notifyListeners();
        return;
      }
    }

    _messages.add(Message(text: text, isUser: true));
    notifyListeners();

    _isLoading = true;
    notifyListeners();

    try {
      final content = [Content.text(text)];
      final response = await _model!.generateContent(content);

      final responseText = response.text?.trim();

      if (responseText == null || responseText.isEmpty) {
        throw Exception('Empty response from AI');
      }

      _messages.add(
        Message(
          text: responseText,
          isUser: false,
        ),
      );
    } catch (e) {
      debugPrint('❌ Chatbot error: $e');

      String errorMessage = '❌ Sorry, I encountered an error.\n\n';

      String errorStr = e.toString().toLowerCase();

      if (errorStr.contains('api') && errorStr.contains('key')) {
        errorMessage += 'Issue: Invalid API key\n';
        errorMessage += 'Solution: Check your .env file';
      } else if (errorStr.contains('quota') || errorStr.contains('exhausted')) {
        errorMessage += 'Issue: API quota exceeded\n';
        errorMessage += 'Solution: Try again later';
      } else if (errorStr.contains('network') || errorStr.contains('connection')) {
        errorMessage += 'Issue: Network error\n';
        errorMessage += 'Solution: Check your internet';
      } else if (errorStr.contains('blocked') || errorStr.contains('safety')) {
        errorMessage += 'Issue: Content blocked\n';
        errorMessage += 'Solution: Rephrase your question';
      } else {
        errorMessage += 'Please try again.';
      }

      _messages.add(
        Message(
          text: errorMessage,
          isUser: false,
        ),
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearChat() {
    _messages.clear();
    _addWelcomeMessage();
    notifyListeners();
  }

  void sendQuickQuestion(String question) => sendMessage(question);

  void retryInitialization() {
    _initializeAI();
    notifyListeners();
  }

  @override
  void dispose() {
    _messages.clear();
    _model = null;
    super.dispose();
  }
}