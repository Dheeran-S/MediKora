import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../model/reminders.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/language_provider.dart';

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
  final String _apiKey = 'AIzaSyAgYG4OrYyFcvtNuojhKMA4TqW24MHpUO8';

  @override
  void initState() {
    super.initState();
    _addBotMessage(
      context.read<LanguageProvider>().translate('health_chat.welcome_message'),
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

    // Check for trip/travel related questions
    final isTripQuestion = m.contains('trip') ||
        m.contains('travel') ||
        m.contains('vacation') ||
        m.contains('journey');

    // Check for personal medication questions
    final isPersonalMedQuestion = (m.contains('my') ||
            m.contains('mine') ||
            m.contains('i ') ||
            m.contains('i\'m') ||
            m.contains('we ') ||
            m.contains('our')) &&
        (m.contains('medicine') ||
            m.contains('medication') ||
            m.contains('tablet') ||
            m.contains('pill') ||
            m.contains('dose') ||
            m.contains('schedule'));

    // Check for "how many/much" questions about medications
    final isQuantityQuestion =
        (m.contains('how many') || m.contains('how much')) &&
            (m.contains('medicine') ||
                m.contains('medication') ||
                m.contains('tablet') ||
                m.contains('pill') ||
                m.contains('carry') ||
                m.contains('take') ||
                m.contains('need'));

    return isTripQuestion || isPersonalMedQuestion || isQuantityQuestion;
  }

  Future<String> _buildMedicationContext() async {
    try {
      final reminders = await ReminderDatabase().getReminders();

      if (reminders.isEmpty) {
        return context
            .read<LanguageProvider>()
            .translate('health_chat.no_medications');
      }

      final buffer = StringBuffer();
      buffer.writeln("USER'S MEDICATIONS:");
      buffer.writeln();

      // Remove duplicates by medicine name
      final uniqueMeds = <String, Reminder>{};
      for (var r in reminders) {
        if (!uniqueMeds.containsKey(r.medicineName)) {
          uniqueMeds[r.medicineName] = r;
        }
      }

      int index = 1;
      for (var entry in uniqueMeds.entries) {
        final r = entry.value;
        final duration = r.endDate.difference(r.startDate).inDays + 1;
        final tabletsPerDay = r.times.length * r.intakeQuantity;

        buffer.writeln("$index. ${r.medicineName}");
        buffer.writeln("   - ${r.intakeQuantity} tablet(s) per dose");
        buffer.writeln("   - ${r.times.length} times per day");
        buffer.writeln("   - ${tabletsPerDay} tablets per day");
        buffer.writeln("   - Course duration: $duration days");
        buffer.writeln();
        index++;
      }

      final now = DateTime.now();
      buffer.writeln("Today's date: ${now.day}/${now.month}/${now.year}");

      return buffer.toString();
    } catch (e) {
      return "Error loading medications: $e";
    }
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
          temperature: 0.7,
          maxOutputTokens: 4096,
        ),
        systemInstruction: Content.text(
          'You are a helpful medication assistant.\n\n'
          'For general health questions: Provide clear, accurate information and remind users to consult healthcare professionals.\n\n'
          'For trip/medication questions with context provided:\n'
          '- List EACH medicine clearly with bullet points\n'
          '- Calculate: (tablets per dose) × (times per day) × (trip days)\n'
          '- Dont show your calculation just list medication:(Number of tablets)\n'
          '- Keep responses organized and complete\n\n'
          'Always be helpful, accurate, and complete your responses.',
        ),
      );

      String finalPrompt = userMessage;

      if (_needsMedicationContext(userMessage)) {
        debugPrint("📋 Building medication context...");
        final context = await _buildMedicationContext();

        finalPrompt = """
$context

USER QUESTION: $userMessage

Please answer the user's question using the medication data above. If this is about a trip, calculate the exact quantity needed for each medicine, add 2-3 extra days as backup, and show your calculations clearly. List each medicine with bullet points.
""";

        debugPrint("✅ Context added to prompt");
      } else {
        debugPrint("💬 General health question - no context needed");
      }

      final response = await model.generateContent([
        Content.text(finalPrompt),
      ]);

      debugPrint("=== AI RESPONSE DEBUG ===");
      debugPrint(
          "Response text: ${response.text?.substring(0, response.text!.length > 100 ? 100 : response.text!.length)}...");
      debugPrint("Response text length: ${response.text?.length ?? 0}");

      if (response.candidates != null && response.candidates!.isNotEmpty) {
        final candidate = response.candidates![0];
        debugPrint("Finish reason: ${candidate.finishReason}");
        debugPrint("Content parts: ${candidate.content.parts.length}");
      }

      final responseText = response.text;

      if (responseText != null && responseText.isNotEmpty) {
        debugPrint("✅ Response received: ${responseText.length} characters");
        _addBotMessage(responseText);
      } else {
        debugPrint("⚠️ Empty response received");

        // Check if there's a prompt feedback (usually means blocked)
        if (response.promptFeedback != null) {
          debugPrint("Prompt feedback: ${response.promptFeedback}");
        }

        _addBotMessage(
          context
              .read<LanguageProvider>()
              .translate('health_chat.error_generating'),
        );
      }

      debugPrint("======================");
    } catch (e) {
      debugPrint("❌ Error: $e");
      _addBotMessage(
        context
            .read<LanguageProvider>()
            .translate('health_chat.connection_error'),
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
        title: const Text('Health Assistant',
            style: TextStyle(fontWeight: FontWeight.w600)),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg['message'],
                          style: TextStyle(
                            color: isUser ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            _formatTime(msg['time']),
                            style: TextStyle(
                              fontSize: 10,
                              color: isUser ? Colors.white70 : Colors.black45,
                            ),
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                enabled: !_isLoading,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Ask about your medicines…',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF6B46C1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send),
                color: Colors.white,
                onPressed: _isLoading ? null : _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
