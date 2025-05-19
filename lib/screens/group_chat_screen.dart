import 'package:flutter/material.dart';
import '../models/group_model.dart';
import '../repositories/group_repository.dart'; // Make sure this path is correct

class GroupChatScreen extends StatefulWidget {
  final GroupModel group;

  const GroupChatScreen({super.key, required this.group});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  int? _memberCount;
  bool _loadingMembers = true;

  @override
  void initState() {
    super.initState();
    _fetchMemberCount();
  }

  Future<void> _fetchMemberCount() async {
    try {
      final repo = GroupRepository();
      final count = await repo.fetchGroupMemberCount(widget.group.id);
      setState(() {
        _memberCount = count;
        _loadingMembers = false;
      });
    } catch (e) {
      setState(() {
        _memberCount = 0;
        _loadingMembers = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.group.profilePictureUrl != null
                  ? NetworkImage('http://192.168.100.28:5241${widget.group.profilePictureUrl!}')
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
                    _loadingMembers
                        ? 'Loading members...'
                        : '$_memberCount member${_memberCount == 1 ? '' : 's'}',
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
        backgroundColor: const Color(0xFF0E1213),
        elevation: 0,
      ),
      body: Center(child: Text("Your group chat UI here")),
    );
  }
}
