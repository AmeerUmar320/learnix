// lib/screens/chat_bot.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen>
    with SingleTickerProviderStateMixin {
  // Controllers
  final TextEditingController _queryController = TextEditingController();
  final ScrollController _scrollController   = ScrollController();

  // Animation
  late final AnimationController _animationController;

  // Chat state — now accepts dynamic values
  bool _isLoading = false;
  final List<Map<String, dynamic>> _chatHistory = [];

  // Color scheme
  static const Color _bgColor         = Color(0xFF0E1213);
  static const Color _botBubbleColor  = Color(0xFF2E3B3B);
  static const Color _userBubbleColor = Color(0xFFB5FB67);
  static const Color _inputBgColor    = Color(0xFF1A2323);
  static const Color _hintColor       = Color(0xFF8A9191);
  static const Color _textColor       = Colors.white;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _queryController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage(String text) {
    final msg = text.trim();
    if (msg.isEmpty || _isLoading) return;

    setState(() {
      _chatHistory.add({'role': 'user', 'content': msg});
      _isLoading = true;
    });
    _queryController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _chatHistory.add({
          'role': 'assistant',
          'content': '🤖 Here’s a response to "$msg".'
        });
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    });
  }

  void _clearChat() {
    setState(() {
      _chatHistory.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        leading: const BackButton(color: _textColor),
        title: const Text(
          'Learnix AI Assistant',
          style: TextStyle(color: _textColor),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            color: _userBubbleColor,
            onPressed: _clearChat,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _chatHistory.isEmpty
                ? _buildWelcome()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: _chatHistory.length,
                    itemBuilder: (ctx, i) {
                      final msg = _chatHistory[i];
                      final isUser = msg['role'] == 'user';
                      final content = (msg['content'] ?? '') as String;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75,
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? _userBubbleColor
                                  : _botBubbleColor,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(
                                    isUser ? 16 : 4),
                                bottomRight: Radius.circular(
                                    isUser ? 4 : 16),
                              ),
                            ),
                            child: Text(
                              content,
                              style: TextStyle(
                                  color: isUser ? _bgColor : _textColor),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const SizedBox(width: 48),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _botBubbleColor,
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
                            color: _userBubbleColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Thinking...',
                            style: TextStyle(color: _textColor)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 8),
            color: _botBubbleColor,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: _inputBgColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _queryController,
                      style: const TextStyle(color: _textColor),
                      decoration: InputDecoration(
                        hintText: 'Ask Learnix…',
                        hintStyle:
                            const TextStyle(color: _hintColor),
                        border: InputBorder.none,
                      ),
                      textCapitalization:
                          TextCapitalization.sentences,
                      enabled: !_isLoading,
                      onSubmitted: _sendMessage,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _sendMessage(_queryController.text),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: _userBubbleColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Transform.rotate(
                        angle: -math.pi / 6, // 30° counter‑clockwise
                        child: const Icon(Icons.send, color: _bgColor),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcome() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                final dy = math.sin(
                        _animationController.value * 2 * math.pi) *
                    12;
                return Transform.translate(
                  offset: Offset(0, dy),
                  child: child,
                );
              },
              child: Image.asset(
                'assets/logo.png',
                width: 120,
                height: 120,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Hello! I’m Learnix',
              style: TextStyle(
                color: _userBubbleColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Your AI study assistant. Ask me anything!',
                textAlign: TextAlign.center,
                style: TextStyle(color: _textColor, fontSize: 16),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSuggestionChip('Help me understand algebra'),
                  _buildSuggestionChip('Explain the water cycle'),
                  _buildSuggestionChip('How do I prepare for exams?'),
                  _buildSuggestionChip('What are good study techniques?'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: _botBubbleColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _sendMessage(label),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 12, horizontal: 16),
            child: Text(label,
                style: const TextStyle(color: _textColor)),
          ),
        ),
      ),
    );
  }
}
