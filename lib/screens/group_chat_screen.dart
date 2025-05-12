// lib/screens/group_chat_screen.dart
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final int memberCount;
  const GroupChatScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.memberCount,
  });
  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController  = ScrollController();
  final _picker            = ImagePicker();
  bool   _isUploading      = false;

  static const _bgColor   = Color(0xFF0E1213);
  static const _userColor = Color(0xFFB5FB67);
  static const _otherCol  = Color(0xFF2E3B3B);
  static const _inputBg   = Color(0xFF1A2323);
  static const _hintCol   = Color(0xFF8A9191);

  late final String _uid;
  CollectionReference<Map<String, dynamic>> get _msgCol => FirebaseFirestore
      .instance.collection('groups').doc(widget.groupId).collection('messages');

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendText(String raw) async {
    final msg = raw.trim();
    if (msg.isEmpty) return;
    await _msgCol.add({
      'senderId': _uid,
      'text'    : msg,
      'sentAt'  : FieldValue.serverTimestamp(),
    });
    _messageController.clear();
    _scrollToBottom();
  }

  Future<void> _sendImage(File file) async {
    try {
      setState(() => _isUploading = true);
      final ref = FirebaseStorage.instance.ref(
          'chatImages/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      await _msgCol.add({
        'senderId': _uid,
        'imageUrl': url,
        'sentAt'  : FieldValue.serverTimestamp(),
      });
    } finally {
      setState(() => _isUploading = false);
      _scrollToBottom();
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

  Future<void> _pick(ImageSource src) async {
    try {
      final XFile? x = await _picker.pickImage(source: src, imageQuality: 85);
      if (x != null) await _sendImage(File(x.path));
    } on PlatformException catch (e) {
      _showSnack('Image error: ${e.message}');
    }
  }

  void _showSnack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  // ─── Build ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: _appBar(),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _msgCol.orderBy('sentAt').snapshots(),
              builder: (_, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snap.data!.docs;
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: docs.length,
                  itemBuilder: (_, i) => _bubble(docs[i]),
                );
              },
            ),
          ),
          if (_isUploading)
            Container(
              color: _otherCol,
              padding: const EdgeInsets.all(8),
              child: Row(children: const [
                SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                SizedBox(width: 12),
                Text('Uploading image…', style: TextStyle(color: Colors.white70)),
              ]),
            ),
          _inputBar(),
        ],
      ),
    );
  }

  // ── Widgets ────────────────────────────────────────────
  PreferredSizeWidget _appBar() => AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Row(children: [
          const CircleAvatar(radius: 16, backgroundImage: AssetImage('assets/profiles/profile_7.jpg')),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.groupName, style: const TextStyle(color: Colors.white, fontSize: 16)),
            Text('${widget.memberCount} members', style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ])
        ]),
      );

  Widget _bubble(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d       = doc.data();
    final isUser  = d['senderId'] == _uid;
    final text    = d['text'] as String?;
    final image   = d['imageUrl'] as String?;
    final ts      = (d['sentAt'] as Timestamp?)?.toDate();
    final timeStr = ts == null ? '…' : TimeOfDay.fromDateTime(ts).format(context);

    final bubble = Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .75),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isUser ? _userColor : _otherCol,
        borderRadius: BorderRadius.circular(16).copyWith(
          bottomLeft : Radius.circular(isUser ? 16 : 4),
          bottomRight: Radius.circular(isUser ? 4  : 16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (text != null)
            Text(text, style: TextStyle(color: isUser ? _bgColor : Colors.white)),
          if (image != null) ...[
            if (text != null) const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(image, fit: BoxFit.cover),
            ),
          ],
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [bubble, const SizedBox(height: 2),
            Text(timeStr, style: const TextStyle(color: Colors.white54, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _inputBar() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        color: _otherCol,
        child: Row(children: [
          GestureDetector(
            onTap: () => _sheet(),
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(color: _inputBg, shape: BoxShape.circle),
              child: const Center(child: Icon(Icons.attach_file, color: Colors.white)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: _inputBg, borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(hintText: 'Type a message…', hintStyle: TextStyle(color: _hintCol), border: InputBorder.none),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: _sendText,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _sendText(_messageController.text),
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(color: _userColor, shape: BoxShape.circle),
              child: Center(child: Transform.rotate(angle: -math.pi / 6, child: const Icon(Icons.send, color: _bgColor))),
            ),
          ),
        ]),
      );

  void _sheet() => showModalBottomSheet(
        context: context,
        backgroundColor: _inputBg,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (_) => SafeArea(
          child: Wrap(children: [
            ListTile(
              leading: const Icon(Icons.photo_camera, color: Colors.white),
              title: const Text('Take photo', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pick(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: const Text('Choose from gallery', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pick(ImageSource.gallery);
              },
            ),
          ]),
        ),
      );
}
