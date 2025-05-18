import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupName;
  final int memberCount;

  const GroupChatScreen({
    super.key,
    required this.groupName,
    required this.memberCount,
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  final bool _isLoading = false;
  bool _isUploading = false;
  String? _errorMessage;
  final List<Map<String, dynamic>> _chatHistory = [
    {
      'role': 'other',
      'sender': 'Sarah',
      'profilePic': 'assets/profiles/profile_1.jpg',
      'content': 'Hey everyone! How\'s the project coming along?',
      'timestamp': '10:30 AM',
    },
    // ... other initial messages ...
  ];

  static const Color _bgColor = Color(0xFF0E1213);
  static const Color _otherBubbleColor = Color(0xFF2E3B3B);
  static const Color _userBubbleColor = Color(0xFFB5FB67);
  static const Color _inputBgColor = Color(0xFF1A2323);
  static const Color _hintColor = Color(0xFF8A9191);
  static const Color _textColor = Colors.white;
  static const Color _errorColor = Color(0xFFFF6B6B);

  @override
  void initState() {
    super.initState();
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
        'timestamp': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}'
            ' ${DateTime.now().hour >= 12 ? 'PM' : 'AM'}',
      });
    });

    _messageController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  Future<void> _showImageSourceOptions() async {
    setState(() {
      _errorMessage = null;
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: _inputBgColor,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_camera, color: _textColor),
                title: const Text('Take a photo', style: TextStyle(color: _textColor)),
                onTap: () {
                  Navigator.of(context).pop();
                  _getImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: _textColor),
                title: const Text('Choose from gallery', style: TextStyle(color: _textColor)),
                onTap: () {
                  Navigator.of(context).pop();
                  _getImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      setState(() {
        _isUploading = true;
        _errorMessage = null;
      });

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        setState(() {
          _isUploading = false;
        });
        return;
      }

      await Future.delayed(const Duration(milliseconds: 800));

      setState(() {
        _chatHistory.add({
          'role': 'user',
          'content': 'Check out this image!',
          'timestamp': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}'
              ' ${DateTime.now().hour >= 12 ? 'PM' : 'AM'}',
          'image': pickedFile.path,
          'isLocalImage': true,
        });
        _isUploading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } on PlatformException catch (e) {
      setState(() {
        _isUploading = false;
        _errorMessage = 'Failed to pick image: ${e.message}';
      });
      _showErrorSnackbar(_errorMessage!);
    } catch (e) {
      setState(() {
        _isUploading = false;
        _errorMessage = 'An unexpected error occurred: $e';
      });
      _showErrorSnackbar(_errorMessage!);
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _errorColor,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _navigateToGroupDetails() {
    Navigator.pushNamed(
      context,
      '/group_details',
      arguments: {
        'groupName': widget.groupName,
        'subject': 'Group Chat',
        'imageAsset': 'assets/profiles/profile_7.jpg',
      },
    );
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
                Text(
                  widget.groupName,
                  style: const TextStyle(color: _textColor, fontSize: 16),
                ),
                Text(
                  '${widget.memberCount} members',
                  style: TextStyle(
                    color: _textColor.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            color: _textColor,
            onPressed: _navigateToGroupDetails,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: _errorColor,
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.white),
              ),
            ),
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
                final isLocalImage = msg['isLocalImage'] == true;
                final isContinuation = i > 0 &&
                    _chatHistory[i - 1]['role'] == msg['role'] &&
                    (!isUser && _chatHistory[i - 1]['sender'] == msg['sender']);
                return Padding(
                  padding: EdgeInsets.only(
                    top: isContinuation ? 4 : 12,
                    bottom: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isUser && !isContinuation) ...[
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: AssetImage(msg['profilePic']),
                        ),
                        const SizedBox(width: 8),
                      ] else if (!isUser) ...[
                        const SizedBox(width: 40),
                      ],
                      Column(
                        crossAxisAlignment: isUser
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
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
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.75,
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isUser ? _userBubbleColor : _otherBubbleColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
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
                                      color: isUser ? _bgColor : _textColor),
                                ),
                                if (hasImage) ...[
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: isLocalImage
                                        ? Image.file(
                                            File(msg['image']),
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                width: 200,
                                                height: 150,
                                                color: Colors.grey[300],
                                                child: const Center(
                                                  child: Text(
                                                    'Error loading image',
                                                    style: TextStyle(color: Colors.red),
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                        : Image.asset(
                                            msg['image'],
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                width: 200,
                                                height: 150,
                                                color: Colors.grey[300],
                                                child: const Center(
                                                  child: Text(
                                                    'Error loading image',
                                                    style: TextStyle(color: Colors.red),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                  ),
                                ],
                              ],
                            ),
                          ),
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
          if (_isUploading)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: _otherBubbleColor,
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(_textColor),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Uploading image...',
                    style: TextStyle(color: _textColor.withOpacity(0.8)),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: _otherBubbleColor,
            child: Row(
              children: [
                GestureDetector(
                  onTap: _showImageSourceOptions,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _inputBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.attach_file, color: _textColor),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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
                        angle: -math.pi / 6,
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
