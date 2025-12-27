import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../model/reminders.dart';

class HealthChatScreen extends StatefulWidget {
  const HealthChatScreen({super.key});

  @override
  State<HealthChatScreen> createState() => _HealthChatScreenState();
}

class _HealthChatScreenState extends State<HealthChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  /// ⚠️ MOVE THIS TO env.dart LATER
  final String _apiKey = 'AIzaSyD3e6nm4_D7GR9PZtvSEm2AiWzJQMCjlVU';

  @override
  void initState() {
    super.initState();
    _addBotMessage(
      "Hi! I can help you manage your medicines.\n"
          "For example, you can ask:\n"
          "• What medicines should I carry for my trip?\n"
          "• Explain my medication schedule\n"
          "• What happens if I miss a dose?",
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // 🧠 CONTEXT LOGIC
  // ─────────────────────────────────────────────

  bool _needsMedicationContext(String message) {
    final m = message.toLowerCase();
    return m.contains('travel') ||
        m.contains('vacation') ||
        m.contains('trip') ||
        m.contains('carry') ||
        m.contains('medicine') ||
        m.contains('tablet');
  }

  Future<String> _buildMedicationContext() async {
    final reminders = await ReminderDatabase().getReminders();

    if (reminders.isEmpty) {
      return "The user currently has no active medications.";
    }

    final buffer = StringBuffer();
    buffer.writeln("User medication schedule:");

    for (final r in reminders) {
      final start = (r.startDate);
      final end   = (r.endDate);


    buffer.writeln("""
- Medicine: ${r.medicineName}
  Intake quantity: ${r.intakeQuantity}
  Times per day: ${r.times.length}
  Start date: ${start.toIso8601String().split('T')[0]}
  End date: ${end.toIso8601String().split('T')[0]}
""");
    }

    return buffer.toString();
  }

  // ─────────────────────────────────────────────
  // 💬 CHAT HANDLING
  // ─────────────────────────────────────────────

  void _addMessage(String message, bool isUser) {
    setState(() {
      _messages.add({
        'message': message,
        'isUser': isUser,
        'time': DateTime.now(),
      });
    });
    _scrollToBottom();
  }

  void _addBotMessage(String message) {
    _addMessage(message, false);
  }

  Future<void> _sendMessage() async {
    final userMessage = _messageController.text.trim();
    if (userMessage.isEmpty || _isLoading) return;

    _messageController.clear();
    _addMessage(userMessage, true);
    setState(() => _isLoading = true);

    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.5,
          maxOutputTokens: 800,
        ),
        systemInstruction: Content.text(
          'You are a helpful health assistant. Provide accurate, helpful, and safe health information. '
              'Always remind users to consult with a healthcare professional for medical advice. '
              'Keep responses concise and easy to understand.',
        ),
      );

      String finalPrompt = userMessage;

      if (_needsMedicationContext(userMessage)) {
        final context = await _buildMedicationContext();

        finalPrompt = """
CONTEXT:
$context

USER QUESTION:
$userMessage

INSTRUCTIONS:
- Use the context strictly
- Calculate medicine quantities accurately
- Handle dates carefully
- Add a short safety note
""";
      }

      final response = await model.generateContent([
        Content.text(finalPrompt),
      ]);

      _addBotMessage(
        response.text ??
            "Sorry, I couldn't generate a response. Please try again.",
      );
    } catch (e) {
      _addBotMessage(
        "Something went wrong. Please check your internet connection and try again.",
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ─────────────────────────────────────────────
  // 🧩 UI
  // ─────────────────────────────────────────────

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime time) {
    final hour =
    time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B46C1),
        foregroundColor: Colors.white,
        title: const Text('Health Assistant', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['isUser'] as bool;
                return Align(
                  alignment:
                  isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color(0xFF6B46C1)
                          : const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          msg['message'],
                          style: TextStyle(
                            color: isUser ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(msg['time']),
                          style: TextStyle(
                            fontSize: 10,
                            color: isUser
                                ? Colors.white70
                                : Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 160),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              enabled: !_isLoading,
              decoration: const InputDecoration(
                hintText: 'Ask about your medicines…',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            color: const Color(0xFF6B46C1),
            onPressed: _isLoading ? null : _sendMessage,
          ),
        ],
      ),
    );
  }
}
