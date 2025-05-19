import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';

class ChatRepository {
  static const String baseUrl = 'http://192.168.100.28:5241/api';

  Future<List<ChatMessage>> fetchGroupMessages(
    int groupId, {
    required int myUserId,
    int skip = 0,
    int take = 20,
  }) async {
    final url = '$baseUrl/messages/group/$groupId?skip=$skip&take=$take';
    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode != 200) throw Exception('Failed to load messages');
    final List<dynamic> data = jsonDecode(resp.body);
    return data.map((e) => ChatMessage.fromJson(e, myUserId)).toList();
  }
}
