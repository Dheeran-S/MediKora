import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class HealthChatScreen extends StatefulWidget {
  const HealthChatScreen({super.key});

  @override
  State<HealthChatScreen> createState() => _HealthChatScreenState();
}

class _HealthChatScreenState extends State<HealthChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  final String _apiKey = 'AIzaSyD3e6nm4_D7GR9PZtvSEm2AiWzJQMCjlVU';

  @override
  void initState() {
    super.initState();
    _addBotMessage("Hello! I'm your health assistant. How can I help you today?");
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isLoading) return;

    _messageController.clear();
    _addMessage(message, true);
    setState(() => _isLoading = true);

    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 1000,
        ),
        systemInstruction: Content.text(
          'You are a helpful health assistant. Provide accurate, helpful, and safe health information. '
              'Always remind users to consult with a healthcare professional for medical advice. '
              'Keep responses concise and easy to understand.',
        ),
      );

      final content = [Content.text(message)];
      final response = await model.generateContent(content);
      final responseText = response.text ?? 'I\'m sorry, I couldn\'t process that.';

      _addBotMessage(responseText);
    } catch (e) {
      _addBotMessage('Sorry, I encountered an error. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.health_and_safety, size: 24),
            SizedBox(width: 8),
            Text('Health Assistant', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: const Color(0xFF6B46C1),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF6B46C1).withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _buildMessageBubble(
                    message: message['message'] as String,
                    isUser: message['isUser'] as bool,
                    time: message['time'] as DateTime,
                  );
                },
              ),
            ),
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              const Color(0xFF6B46C1),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Thinking...',
                          style: TextStyle(
                            color: const Color(0xFF6B46C1),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF6B46C1).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.medical_services_outlined,
              size: 64,
              color: Color(0xFF6B46C1),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your Health Assistant',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Ask me anything about your health and wellbeing',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required String message,
    required bool isUser,
    required DateTime time,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF6B46C1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6B46C1).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.medical_services,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF6B46C1) : const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isUser
                        ? const Color(0xFF6B46C1).withOpacity(0.3)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: TextStyle(
                      color: isUser ? Colors.white : const Color(0xFF1F2937),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(time),
                    style: TextStyle(
                      color: isUser ? Colors.white.withOpacity(0.7) : const Color(0xFF9CA3AF),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6B46C1),
                    const Color(0xFF8B5CF6),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6B46C1).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Type your health question...',
                          hintStyle: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        style: const TextStyle(
                          color: Color(0xFF1F2937),
                          fontSize: 15,
                          height: 1.4,
                        ),
                        maxLines: 5,
                        minLines: 1,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        enabled: !_isLoading,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isLoading
                      ? [Colors.grey.shade400, Colors.grey.shade500]
                      : [
                    const Color(0xFF6B46C1),
                    const Color(0xFF8B5CF6),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: _isLoading
                    ? []
                    : [
                  BoxShadow(
                    color: const Color(0xFF6B46C1).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: _isLoading ? null : _sendMessage,
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}