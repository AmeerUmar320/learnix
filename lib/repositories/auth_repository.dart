import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import '../models/user_model.dart';

class AuthRepository {
  static const String baseUrl = 'http://192.168.100.28:5241/api/auth';

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required Uint8List imageBytes,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/register'));
    request.fields['name'] = name;
    request.fields['email'] = email;
    request.fields['password'] = password;
    request.files.add(http.MultipartFile.fromBytes(
      'image',
      imageBytes,
      filename: 'profile.jpg',
      contentType: http_parser.MediaType('image', 'jpeg'),
    ));

    final response = await request.send();
    if (response.statusCode == 200 || response.statusCode == 201) {
      final respStr = await response.stream.bytesToString();
      final data = json.decode(respStr);
      return UserModel.fromJson(data);
    } else {
      throw Exception('Failed to register: ${response.statusCode}');
    }
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Add robust null-handling here:
      return UserModel.fromJson({
        'id': data['id'] ?? 0,
        'name': data['name'] ?? '',
        'email': data['email'] ?? '',
        'profilePictureUrl': data['profilePictureUrl'] ?? '',
      });
    } else {
      // Try to extract error message if possible
      String err = 'Failed to login: ';
      try {
        final Map<String, dynamic> jsonErr = json.decode(response.body);
        err += jsonErr['error']?.toString() ?? response.body;
      } catch (_) {
        err += response.body;
      }
      throw Exception(err);
    }
  }

  Future<UserModel> registerWithProfilePicture({
    required String name,
    required String email,
    required String password,
    required File imageFile,
  }) async {
    final uri = Uri.parse('$baseUrl/register');
    final request = http.MultipartRequest('POST', uri)
      ..fields['name'] = name
      ..fields['email'] = email
      ..fields['password'] = password
      ..files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: http_parser.MediaType('image', 'jpeg'),
      ));

    final response = await request.send();
    if (response.statusCode == 200 || response.statusCode == 201) {
      final respStr = await response.stream.bytesToString();
      final data = json.decode(respStr);
      return UserModel.fromJson(data);
    } else {
      throw Exception('Failed to register: ${response.statusCode}');
    }
  }
}
