import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/group_model.dart';
import '../models/user_model.dart';

class GroupRepository {
  static const String baseUrl = 'http://192.168.100.28:5241/api';

  /// Fetch all users (for SelectMembersPage)
  Future<List<UserModel>> fetchAllUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => UserModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load users: ${response.statusCode}');
    }
  }

  /// Fetch groups for a user (userId)
  Future<List<GroupModel>> fetchGroupsForUser(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/groupmemberships'));
    if (response.statusCode == 200) {
      final List<dynamic> allMemberships = jsonDecode(response.body);
      debugPrint('All group memberships from API: $allMemberships');
      debugPrint('Looking for userId: $userId');

      final List<dynamic> userMemberships = allMemberships.where((m) {
        final membershipUserId = m['userId'];
        debugPrint('Checking membership: $m, membershipUserId: $membershipUserId');
        return membershipUserId.toString() == userId.toString();
      }).toList();

      debugPrint('User $userId memberships: $userMemberships');
      final groupIds = userMemberships.map((m) => m['groupId']).toSet().toList();
      debugPrint('User $userId groupIds: $groupIds');

      List<GroupModel> groups = [];
      for (final groupId in groupIds) {
        try {
          groups.add(await fetchGroupById(groupId));
        } catch (e) {
          debugPrint('Error loading group $groupId: $e');
        }
      }
      debugPrint('Fetched groups: ${groups.map((g) => g.name).toList()}');
      return groups;
    } else {
      debugPrint('Failed to load group memberships: ${response.statusCode}');
      throw Exception('Failed to load group memberships');
    }
  }


  /// Fetch single group by ID
  Future<GroupModel> fetchGroupById(int groupId) async {
    final response = await http.get(Uri.parse('$baseUrl/groups/$groupId'));
    if (response.statusCode == 200) {
      return GroupModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch group');
    }
  }

  /// Create a group with optional image and memberIds (comma-separated)
  Future<GroupModel> createGroupWithImage({
    required String name,
    String? description,
    required List<int> memberIds,
    required File? image,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final creatorId = prefs.getInt('userId');
    if (creatorId == null) {
      throw Exception('User not logged in');
    }
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/groups/create-with-image'),
    );
    request.fields['name'] = name;
    if (description != null) request.fields['description'] = description;
    request.fields['memberIds'] = memberIds.join(',');
    request.fields['creatorId'] = creatorId.toString();
    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }
    final response = await request.send();
    if (response.statusCode == 200 || response.statusCode == 201) {
      final respStr = await response.stream.bytesToString();
      final Map<String, dynamic> json = jsonDecode(respStr);
      return GroupModel.fromJson(json);
    } else {
      throw Exception('Failed to create group: ${response.statusCode}');
    }
  }

  Future<int> fetchGroupMemberCount(int groupId) async {
    final response = await http.get(Uri.parse('$baseUrl/groupmemberships'));
    if (response.statusCode == 200) {
      final List<dynamic> allMemberships = jsonDecode(response.body);
      final count = allMemberships.where((m) => m['groupId'] == groupId).length;
      return count;
    } else {
      throw Exception('Failed to load group memberships');
    }
  }

  Future<void> removeCurrentUserFromGroup(int groupId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId == null) throw Exception('User not logged in');
    // Delete group membership
    final membershipsResp = await http.get(Uri.parse('$baseUrl/groupmemberships'));
    if (membershipsResp.statusCode != 200) throw Exception('Failed to load memberships');
    final memberships = (jsonDecode(membershipsResp.body) as List)
        .where((m) => m['groupId'] == groupId && m['userId'].toString() == userId.toString())
        .toList();
    if (memberships.isNotEmpty) {
      // Use [userId, groupId] as keys for DELETE
      await http.delete(Uri.parse('$baseUrl/groupmemberships/$userId/$groupId'));
    }
  }

  Future<List<Map<String, dynamic>>> fetchGroupMembersWithRoles(int groupId) async {
    final response = await http.get(Uri.parse('$baseUrl/groupmemberships'));
    if (response.statusCode == 200) {
      final List<dynamic> allMemberships = jsonDecode(response.body);
      // Filter for the given groupId
      final members = allMemberships
          .where((m) => m['groupId'] == groupId && m['user'] != null)
          .map((m) => {
                'user': UserModel.fromJson(m['user']),
                'role': m['role'],
              })
          .toList();
      return members;
    } else {
      throw Exception('Failed to load group members');
    }
  }
}
