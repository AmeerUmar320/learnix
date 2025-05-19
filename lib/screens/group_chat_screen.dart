import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../models/chat_message.dart';
import '../models/group_model.dart';

class GroupChatScreen extends StatefulWidget {
  final GroupModel group;
  const GroupChatScreen({super.key, required this.group});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final List<ChatMessage> _messages = [];
  late HubConnection _hubConnection;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  int? _userId;
  String? _userName;
  bool _connecting = true;

  @override
  void initState() {
    super.initState();
    _initUserAndLoad();
  }

  Future<void> _initUserAndLoad() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('userId');
    _userName = prefs.getString('userName') ?? 'Me';
    await _fetchMessages();
    await _initSignalR();
  }

  Future<void> _fetchMessages() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.100.28:5241/api/messages/group/${widget.group.id}?limit=30'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = List.from(jsonDecode(response.body));
        setState(() {
          _messages.clear();
          // Reverse the list so oldest messages are first
          _messages.addAll(
            jsonList.map((msg) => ChatMessage.fromJson(msg, _userId!)).toList().reversed,
          );
        });
        _scrollToBottom();
      }
    } catch (e) {
      // TODO: handle error UI
    }
  }

  Future<void> _initSignalR() async {
    _hubConnection = HubConnectionBuilder()
        .withUrl('http://192.168.100.28:5241/chathub',
          HttpConnectionOptions(
            transport: HttpTransportType.webSockets,
            logging: (level, message) => debugPrint(message),
          ))
        .build();

    _hubConnection.on('ReceiveMessage', (args) {
      final senderId = args![0] as int;
      final userName = args[1] as String;
      final text = args[2] as String;
      final messageId = args[3] as int;
      final sentAt = DateTime.parse(args[4] as String);
      final userProfilePic = args.length > 5 ? args[5] as String : null;

      final isMe = senderId == _userId;

      setState(() {
        _messages.add(ChatMessage(
          id: messageId,
          senderName: userName,
          senderId: senderId,
          content: text,
          sentAt: sentAt,
          isMe: isMe,
          profilePic: userProfilePic,
        ));
      });
      _scrollToBottom();
    });

    await _hubConnection.start();
    await _hubConnection.invoke('JoinGroup', args: [widget.group.id.toString()]);
    setState(() => _connecting = false);
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _userId == null || _userName == null) return;

    // Step 1: Send message to backend API (save to DB and trigger SignalR)
    final resp = await http.post(
      Uri.parse('http://192.168.100.28:5241/api/messages'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'text': text,
        'userId': _userId,
        'groupId': widget.group.id,
        'sentAt': DateTime.now().toUtc().toIso8601String(), // Add this if backend requires
      }),
    );

    if (resp.statusCode == 201 || resp.statusCode == 200) {
      // Success! The message will be received from SignalR soon
      _messageController.clear();
    } else {
      // TODO: show error snackbar
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _hubConnection.stop();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2323),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Colors.white),
                title: const Text('Take a photo', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  _getImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: const Text('Choose from gallery', style: TextStyle(color: Colors.white)),
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
    // You can implement image upload and send logic here later
  }

  @override
  Widget build(BuildContext context) {
    final int memberCount = widget.group.members.length;
    return Scaffold(
      backgroundColor: const Color(0xFF0E1213),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1213),
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.group.profilePictureUrl != null &&
                      widget.group.profilePictureUrl!.isNotEmpty
                  ? NetworkImage(
                      'http://192.168.100.28:5241${widget.group.profilePictureUrl!}')
                  : const AssetImage('assets/calc.png') as ImageProvider,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.group.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$memberCount member${memberCount == 1 ? '' : 's'}',
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/group_details',
                  arguments: {'group': widget.group},
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Message List
          Expanded(
            child: _connecting
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _messages.length,
                    padding: const EdgeInsets.all(12),
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isMe = msg.isMe;
                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isMe
                                ? const Color(0xFFB5FB67)
                                : const Color(0xFF22282a),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              if (!isMe)
                                Text(
                                  msg.senderName,
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                ),
                              Text(
                                msg.content,
                                style: TextStyle(
                                  color: isMe
                                      ? const Color(0xFF0E1213)
                                      : Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                "${msg.sentAt.hour}:${msg.sentAt.minute.toString().padLeft(2, '0')}",
                                style: TextStyle(
                                  color: isMe
                                      ? const Color(0xFF0E1213).withOpacity(0.6)
                                      : Colors.white54,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // Input Box with Image Picker Button (left), TextField (center), Send (right)
          Container(
            color: const Color(0xFF181b1f),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFFB5FB67)),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
