import 'package:flutter/material.dart';
import '../models/group_model.dart';

class GroupDetailsScreen extends StatelessWidget {
  final GroupModel group;
  static const bgColor = Color(0xFF0E1213);
  static const accentColor = Color(0xFFB5FB67);

  const GroupDetailsScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Group Details', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 24),
            child: Column(
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: group.profilePictureUrl != null
                        ? NetworkImage('http://192.168.100.28:5241${group.profilePictureUrl!}')
                        : const AssetImage('assets/profiles/profile_7.jpg') as ImageProvider,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  group.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  group.description ?? 'No subject',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          // Tab bar (visual only for now)
          const TabBar(
            tabs: [
              Tab(text: 'Details'),
              Tab(text: 'Resources'),
            ],
            indicatorColor: accentColor,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: accentColor,
            unselectedLabelColor: Colors.white,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Members', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ...group.members.map((memberId) => ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: accentColor,
                    child: Icon(Icons.person, color: Colors.black),
                  ),
                  title: Text(
                    'User ID: $memberId',
                    style: const TextStyle(color: Colors.white),
                  ),
                )),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.person_add_alt_1, color: accentColor),
                        label: const Text('Add Members', style: TextStyle(color: accentColor)),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: accentColor)),
                        onPressed: () {
                          // TODO: Implement add members logic/navigation
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.exit_to_app, color: Colors.redAccent),
                        label: const Text('Leave Group', style: TextStyle(color: Colors.redAccent)),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent)),
                        onPressed: () {
                          // TODO: Implement leave group logic/navigation
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
