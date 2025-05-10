// lib/screens/group_chat_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({Key? key}) : super(key: key);

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  // Controllers
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Chat state
  bool _isLoading = false;
  final List<Map<String, dynamic>> _chatHistory = [
    {
      'role': 'other',
      'sender': 'Sarah',
      'profilePic': 'assets/profiles/profile_1.jpg',
      'content': 'Hey everyone! How\'s the project coming along?',
      'timestamp': '10:30 AM',
    },
    {
      'role': 'other',
      'sender': 'Mike',
      'profilePic': 'assets/profiles/profile_2.jpg',
      'content': 'I\'ve been working on the UI design. Almost done with the wireframes!',
      'timestamp': '10:32 AM',
    },
    {
      'role': 'user',
      'content': 'Great progress Mike! I\'ve finished the backend API integration.',
      'timestamp': '10:35 AM',
    },
    {
      'role': 'other',
      'sender': 'Jessica',
      'profilePic': 'assets/profiles/profile_3.jpg',
      'content': 'Check out this inspiration I found for our app design:',
      'timestamp': '10:40 AM',
      'image': 'assets/posts/advertisement.jpg',
    },
    {
      'role': 'other',
      'sender': 'David',
      'profilePic': 'assets/profiles/profile_4.jpg',
      'content': 'That looks amazing! Reminds me of this quote:',
      'timestamp': '10:45 AM',
    },
    {
      'role': 'other',
      'sender': 'David',
      'profilePic': 'assets/profiles/profile_4.jpg',
      'content': '"Design is not just what it looks like and feels like. Design is how it works." - Steve Jobs',
      'timestamp': '10:45 AM',
      'image': 'assets/posts/steve-jobs.webp',
    },
    {
      'role': 'user',
      'content': 'We need to focus on both aesthetics and functionality.',
      'timestamp': '10:48 AM',
    },
    {
      'role': 'other',
      'sender': 'Emma',
      'profilePic': 'assets/profiles/profile_5.jpg',
      'content': 'I\'ve scheduled a team meeting for tomorrow at 2 PM to discuss our progress. Does that work for everyone?',
      'timestamp': '10:52 AM',
    },
    {
      'role': 'other',
      'sender': 'Sarah',
      'profilePic': 'assets/profiles/profile_1.jpg',
      'content': 'Works for me!',
      'timestamp': '10:55 AM',
    },
    {
      'role': 'user',
      'content': 'I\'ll be there!',
      'timestamp': '10:56 AM',
    },
  ];

  // Color scheme (matching the chatbot screen)
  static const Color _bgColor = Color(0xFF0E1213);
  static const Color _otherBubbleColor = Color(0xFF2E3B3B);
  static const Color _userBubbleColor = Color(0xFFB5FB67);
  static const Color _inputBgColor = Color(0xFF1A2323);
  static const Color _hintColor = Color(0xFF8A9191);
  static const Color _textColor = Colors.white;

  @override
  void initState() {
    super.initState();
    // Scroll to bottom initially
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
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
      _chatHistory.add({
        'role': 'user',
        'content': msg,
        'timestamp': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')} ${DateTime.now().hour >= 12 ? 'PM' : 'AM'}',
      });
    });
    _messageController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _attachImage() {
    // This would typically open an image picker
    // For demo purposes, we'll just add a dummy image message
    setState(() {
      _chatHistory.add({
        'role': 'user',
        'content': 'Check out this design concept!',
        'timestamp': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')} ${DateTime.now().hour >= 12 ? 'PM' : 'AM'}',
        'image': 'assets/posts/advertisement.jpg', // Using a sample image
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        leading: const BackButton(color: _textColor),
        title: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage('assets/profiles/profile_7.jpg'),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Design Team',
                  style: TextStyle(color: _textColor, fontSize: 16),
                ),
                Text(
                  '5 members',
                  style: TextStyle(color: _textColor.withOpacity(0.7), fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            color: _textColor,
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _chatHistory.length,
              itemBuilder: (ctx, i) {
                final msg = _chatHistory[i];
                final isUser = msg['role'] == 'user';
                final content = (msg['content'] ?? '') as String;
                final hasImage = msg.containsKey('image');
                
                // Check if this message is from the same sender as the previous one
                final isContinuation = i > 0 && 
                    _chatHistory[i-1]['role'] == msg['role'] && 
                    (!isUser && _chatHistory[i-1]['sender'] == msg['sender']);
                
                return Padding(
                  padding: EdgeInsets.only(
                    top: isContinuation ? 4 : 12,
                    bottom: 4,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      // Profile picture for others (not for user)
                      if (!isUser && !isContinuation) ...[
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: AssetImage(msg['profilePic']),
                        ),
                        const SizedBox(width: 8),
                      ] else if (!isUser) ...[
                        const SizedBox(width: 40), // Space for alignment when continuation
                      ],
                      
                      // Message content
                      Column(
                        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          // Sender name for others (not for user)
                          if (!isUser && !isContinuation)
                            Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 4),
                              child: Text(
                                msg['sender'],
                                style: TextStyle(
                                  color: _textColor.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            
                          // Message bubble
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.75,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16, 
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isUser ? _userBubbleColor : _otherBubbleColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(isContinuation && !isUser ? 16 : 16),
                                topRight: Radius.circular(isContinuation && isUser ? 16 : 16),
                                bottomLeft: Radius.circular(isUser ? 16 : 4),
                                bottomRight: Radius.circular(isUser ? 4 : 16),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  content,
                                  style: TextStyle(
                                    color: isUser ? _bgColor : _textColor,
                                  ),
                                ),
                                
                                // Image if present
                                if (hasImage) ...[
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      msg['image'],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          
                          // Timestamp
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                            child: Text(
                              msg['timestamp'],
                              style: TextStyle(
                                color: _textColor.withOpacity(0.5),
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: _otherBubbleColor,
            child: Row(
              children: [
                // Attachment button
                GestureDetector(
                  onTap: _attachImage,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _inputBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.attach_file,
                        color: _textColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                
                // Text input
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: _inputBgColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: _textColor),
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: _hintColor),
                        border: InputBorder.none,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      enabled: !_isLoading,
                      onSubmitted: _sendMessage,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                
                // Send button
                GestureDetector(
                  onTap: () => _sendMessage(_messageController.text),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: _userBubbleColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Transform.rotate(
                        angle: -math.pi / 6, // 30° counter-clockwise
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
}