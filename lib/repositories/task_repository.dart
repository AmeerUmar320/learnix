import 'dart:convert';
import 'package:http/http.dart' as http;

class TaskRepository {
  static const String baseUrl = 'http://192.168.100.28:5241/api';

  Future<List<Map<String, dynamic>>> fetchGroups() async {
    final resp = await http.get(Uri.parse('$baseUrl/groups'));
    if (resp.statusCode != 200) throw Exception('Failed to load groups');
    final List data = jsonDecode(resp.body);
    // Return as List<Map> for [id, name]
    return data.cast<Map<String, dynamic>>();
  }

  Future<bool> createTask({
    required String title,
    required int groupId,
    required DateTime dueDate,
    required List<String> subtasks,
  }) async {
    final response = await http.post(
      Uri.parse('http://192.168.100.28:5241/api/tasks'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'groupId': groupId,
        'dueDate': dueDate.toIso8601String(),
        'subTasks': subtasks.map((t) => {'title': t}).toList(),
      }),
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }

  Future<List<Map<String, dynamic>>> fetchTasksForUser(int userId) async {
    final url = 'http://192.168.100.28:5241/api/tasks/for-user/$userId';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      // Return as List<Map<String, dynamic>> for easy use in BloC/UI
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load tasks');
    }
  }
}
