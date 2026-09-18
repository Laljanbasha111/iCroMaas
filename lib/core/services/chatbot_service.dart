
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;

  // Quick action suggestions
  final List<Map<String, dynamic>> _quickActions = [
    {
      'icon': Icons.bug_report,
      'label': 'Disease Info',
      'message': 'Tell me about common crop diseases',
    },
    {
      'icon': Icons.water_drop,
      'label': 'Irrigation',
      'message': 'How often should I water my crops?',
    },
    {
      'icon': Icons.science,
      'label': 'Fertilizers',
      'message': 'What fertilizers should I use?',
    },
    {
      'icon': Icons.wb_sunny,
      'label': 'Weather Tips',
      'message': 'Give me weather-based farming tips',
    },
  ];

  // Enhanced mock responses with more keywords
  String _generateResponse(String userMessage) {
    final lowerText = userMessage.toLowerCase();

    // Disease related
    if (lowerText.contains('disease') ||
        lowerText.contains('pest') ||
        lowerText.contains('bug') ||
        lowerText.contains('infection') ||
        lowerText.contains('sick') ||
        lowerText.contains('dying')) {
      return '''Common crop diseases include:

🦠 **Leaf Rust** - Affects wheat and barley
   • Symptoms: Orange/brown pustules on leaves
   • Treatment: Fungicide application

🦠 **Blight** - Common in potatoes and tomatoes
   • Symptoms: Dark spots, wilting
   • Prevention: Crop rotation, proper spacing

🦠 **Powdery Mildew** - Affects many crops
   • Symptoms: White powdery coating
   • Treatment: Sulfur-based fungicides

💡 **Tip:** Use our AI analysis feature by taking a photo of affected crops for accurate diagnosis!''';
    }

    // Irrigation related
    if (lowerText.contains('water') ||
        lowerText.contains('irrigation') ||
        lowerText.contains('irrigate') ||
        lowerText.contains('watering')) {
      return '''Irrigation frequency depends on:

💧 **Crop type** - Different crops need different amounts
💧 **Soil type** - Sandy soil drains faster
💧 **Weather conditions** - Less in rainy season
💧 **Growth stage** - More during flowering/fruiting

**General Guidelines:**
• Vegetables: Every 2-3 days
• Grains: Once a week
• Fruits: 2-3 times per week

⚠️ **Important:** Adjust based on rainfall and temperature. Check soil moisture before watering!''';
    }

    // Fertilizer related
    if (lowerText.contains('fertilizer') ||
        lowerText.contains('nutrient') ||
        lowerText.contains('fertilize') ||
        lowerText.contains('npk') ||
        lowerText.contains('compost')) {
      return '''Fertilizer recommendations:

🌱 **NPK Ratio** varies by crop:
   • Leafy vegetables: 3-1-2
   • Fruiting crops: 5-10-10
   • Root vegetables: 5-10-5

🌱 **Application timing:**
   • Before planting (base dose)
   • During growth stages
   • Avoid during flowering

🌱 **Organic options:**
   • Compost (slow release)
   • Manure (nitrogen-rich)
   • Bone meal (phosphorus)

🌱 **Chemical fertilizers:**
   • Based on soil test results
   • Follow package instructions
   • Don't over-apply

💡 **Tip:** Get a soil test for precise recommendations!''';
    }

    // Weather related
    if (lowerText.contains('weather') ||
        lowerText.contains('rain') ||
        lowerText.contains('temperature') ||
        lowerText.contains('climate') ||
        lowerText.contains('season')) {
      return '''Weather-based farming tips:

☀️ **Clear skies:**
   • Perfect for harvesting
   • Good for spraying pesticides
   • Ideal for field preparation

🌧️ **Rain expected:**
   • Postpone irrigation
   • Delay fertilizer application
   • Protect sensitive crops

🌡️ **High temperature:**
   • Increase watering frequency
   • Provide shade for sensitive plants
   • Harvest early morning

❄️ **Cold weather:**
   • Protect frost-sensitive crops
   • Reduce watering
   • Use mulch for insulation

📱 Check our **Weather section** for detailed 7-day forecasts!''';
    }

    // Wheat specific
    if (lowerText.contains('wheat')) {
      return '''**Wheat Farming Guide:**

🌾 **Planting:**
   • Season: October-November (Rabi)
   • Seed rate: 100-125 kg/hectare
   • Row spacing: 20-23 cm

🌾 **Irrigation:**
   • 4-6 irrigations needed
   • Critical stages: Crown root, tillering, flowering

🌾 **Fertilizers:**
   • NPK: 120:60:40 kg/hectare
   • Apply in 2-3 splits

🌾 **Common diseases:**
   • Leaf rust, stem rust
   • Powdery mildew

🌾 **Harvesting:**
   • March-April
   • When grain moisture is 20-25%''';
    }

    // Rice specific
    if (lowerText.contains('rice') || lowerText.contains('paddy')) {
      return '''**Rice Farming Guide:**

🌾 **Planting:**
   • Season: June-July (Kharif)
   • Transplanting: 21-25 days old seedlings
   • Spacing: 20x15 cm

🌾 **Water management:**
   • Keep 5-7 cm standing water
   • Drain before harvesting

🌾 **Fertilizers:**
   • NPK: 120:60:40 kg/hectare
   • Apply nitrogen in 3 splits

🌾 **Common diseases:**
   • Blast, bacterial blight
   • Sheath blight

🌾 **Harvesting:**
   • October-November
   • When 80% grains turn golden''';
    }

    // Tomato specific
    if (lowerText.contains('tomato')) {
      return '''**Tomato Farming Guide:**

🍅 **Planting:**
   • Season: Year-round (with irrigation)
   • Spacing: 60x45 cm
   • Transplant 4-5 week seedlings

🍅 **Irrigation:**
   • Every 3-4 days in summer
   • Every 7-10 days in winter

🍅 **Fertilizers:**
   • NPK: 100:50:50 kg/hectare
   • Add calcium for blossom end rot

🍅 **Common diseases:**
   • Early blight, late blight
   • Leaf curl virus

🍅 **Harvesting:**
   • 60-80 days after transplanting
   • Pick when firm and colored''';
    }

    // Pest control
    if (lowerText.contains('pest control') ||
        lowerText.contains('insect') ||
        lowerText.contains('spray')) {
      return '''**Pest Control Guide:**

🐛 **Integrated Pest Management (IPM):**

1️⃣ **Prevention:**
   • Crop rotation
   • Proper spacing
   • Remove infected plants

2️⃣ **Biological control:**
   • Neem oil spray
   • Beneficial insects
   • Pheromone traps

3️⃣ **Chemical control:**
   • Use only when necessary
   • Follow safety guidelines
   • Respect pre-harvest intervals

⚠️ **Safety tips:**
   • Wear protective gear
   • Spray early morning/evening
   • Don't spray before rain

💡 **Tip:** Identify the pest correctly before treatment!''';
    }

    // Soil management
    if (lowerText.contains('soil') ||
        lowerText.contains('ph') ||
        lowerText.contains('erosion')) {
      return '''**Soil Management Tips:**

🌍 **Soil health:**
   • Test pH regularly (ideal: 6.0-7.5)
   • Add organic matter
   • Practice crop rotation

🌍 **Soil types:**
   • Sandy: Drains fast, needs frequent watering
   • Clay: Retains water, needs drainage
   • Loamy: Best for most crops

🌍 **Improving soil:**
   • Add compost/manure
   • Use cover crops
   • Mulching

🌍 **Preventing erosion:**
   • Contour farming
   • Terracing on slopes
   • Plant cover crops

💡 **Tip:** Get a soil test every 2-3 years!''';
    }

    // Organic farming
    if (lowerText.contains('organic')) {
      return '''**Organic Farming Guide:**

🌿 **Principles:**
   • No synthetic chemicals
   • Natural pest control
   • Soil health focus

🌿 **Organic fertilizers:**
   • Compost
   • Vermicompost
   • Green manure
   • Biofertilizers

🌿 **Pest management:**
   • Neem-based products
   • Botanical extracts
   • Biological control agents

🌿 **Benefits:**
   • Better soil health
   • Higher market price
   • Environmentally friendly

💡 **Tip:** Transition takes 2-3 years for certification!''';
    }

    // Harvesting
    if (lowerText.contains('harvest') ||
        lowerText.contains('reap')) {
      return '''**Harvesting Best Practices:**

🌾 **Timing:**
   • Harvest at right maturity
   • Early morning is best
   • Avoid wet conditions

🌾 **Methods:**
   • Manual: Labor-intensive but gentle
   • Mechanical: Fast but needs investment

🌾 **Post-harvest:**
   • Clean and sort immediately
   • Proper storage conditions
   • Quick transportation

🌾 **Storage tips:**
   • Cool, dry place
   • Good ventilation
   • Pest-free environment

💡 **Tip:** Proper timing increases yield and quality!''';
    }

    // Default response
    return '''I'm here to help with farming advice! 🌾

**I can help you with:**

🌱 **Crop Management**
   • Disease identification & treatment
   • Irrigation schedules
   • Fertilizer recommendations

🌱 **Specific Crops**
   • Wheat, Rice, Corn
   • Tomato, Potato
   • And many more!

🌱 **General Farming**
   • Pest control
   • Soil management
   • Weather-based tips
   • Organic farming
   • Harvesting techniques

**Try asking:**
• "How to treat wheat rust?"
• "When to water tomatoes?"
• "Best fertilizer for rice?"
• "Organic pest control methods"

What would you like to know? 😊''';
  }

  @override
  void initState() {
    super.initState();
    _addMessage(
      'Hello! 👋 I\'m your AI farming assistant. How can I help you today?',
      isUser: false,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addMessage(String text, {required bool isUser}) {
    setState(() {
      _messages.add({
        'text': text,
        'isUser': isUser,
        'timestamp': DateTime.now(),
      });
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    _addMessage(text, isUser: true);
    _messageController.clear();

    // Simulate typing
    setState(() {
      _isTyping = true;
    });

    // Simulate AI response delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      setState(() {
        _isTyping = false;
      });

      // Generate intelligent response
      String response = _generateResponse(text);
      _addMessage(response, isUser: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy, size: 24),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Assistant',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Online',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showOptionsMenu(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Actions (only show when no messages)
          if (_messages.length <= 1)
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _quickActions.map((action) {
                      return _buildQuickActionChip(action);
                    }).toList(),
                  ),
                ],
              ),
            ),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Ask me anything about farming...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF2E7D32),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send),
                      color: Colors.white,
                      onPressed: () => _sendMessage(_messageController.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionChip(Map<String, dynamic> action) {
    return InkWell(
      onTap: () => _sendMessage(action['message']),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              action['icon'],
              size: 20,
              color: const Color(0xFF2E7D32),
            ),
            const SizedBox(width: 8),
            Text(
              action['label'],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUser = message['isUser'] as bool;
    final text = message['text'] as String;
    final timestamp = message['timestamp'] as DateTime;
    final timeFormat = DateFormat('HH:mm');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Color(0xFF2E7D32),
                size: 24,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? const Color(0xFF2E7D32) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 15,
                      color: isUser ? Colors.white : Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    timeFormat.format(timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Color(0xFF2E7D32),
                size: 24,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy,
              color: Color(0xFF2E7D32),
              size: 24,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(1),
                const SizedBox(width: 4),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Opacity(
          opacity: (value + index * 0.3) % 1.0,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
      onEnd: () {
        if (mounted) setState(() {});
      },
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Clear Chat History'),
              onTap: () {
                Navigator.pop(context);
                _showClearChatDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Color(0xFF2E7D32)),
              title: const Text('About AI Assistant'),
              onTap: () {
                Navigator.pop(context);
                _showAboutDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showClearChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear Chat History?'),
        content: const Text('This will delete all messages. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _messages.clear();
                _addMessage(
                  'Hello! 👋 I\'m your AI farming assistant. How can I help you today?',
                  isUser: false,
                );
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chat history cleared'),
                  backgroundColor: Color(0xFF4CAF50),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.smart_toy, color: Color(0xFF2E7D32)),
            SizedBox(width: 12),
            Text('AI Assistant'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your intelligent farming companion powered by advanced AI.',
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(height: 16),
            Text(
              'Features:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Crop disease diagnosis'),
            Text('• Irrigation recommendations'),
            Text('• Fertilizer guidance'),
            Text('• Weather-based tips'),
            Text('• Pest control advice'),
            Text('• Soil management tips'),
            SizedBox(height: 16),
            Text(
              'Available 24/7 to help you grow better crops!',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

