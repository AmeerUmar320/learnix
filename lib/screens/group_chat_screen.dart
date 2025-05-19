import 'package:flutter/material.dart';
import '../models/group_model.dart';
import 'group_details_screen.dart';

const Color bgColor = Color(0xFF0E1213);
const Color otherBubbleColor = Color(0xFF2E3B3B);
const Color userBubbleColor = Color(0xFFB5FB67);
const Color inputBgColor = Color(0xFF1A2323);
const Color hintColor = Color(0xFF8A9191);
const Color textColor = Colors.white;
const Color errorColor = Color(0xFFFF6B6B);

class GroupChatScreen extends StatefulWidget {
  final GroupModel group;

  const GroupChatScreen({
    super.key,
    required this.group,
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  // ... unchanged ...

  void _navigateToGroupDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupDetailsScreen(group: widget.group),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: const BackButton(color: textColor),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: widget.group.profilePictureUrl != null
                  ? NetworkImage('http://192.168.100.28:5241${widget.group.profilePictureUrl!}')
                  : const AssetImage('assets/profiles/profile_7.jpg') as ImageProvider,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.group.name,
                  style: const TextStyle(color: textColor, fontSize: 16),
                ),
                Text(
                  '${widget.group.members.length} members',
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
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
            color: textColor,
            onPressed: _navigateToGroupDetails,
          ),
        ],
      ),
      body: Center(child: Text('Group chat UI coming soon!', style: TextStyle(color: Colors.white))),
    );
  }
}
