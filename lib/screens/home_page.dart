// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:group_chat_app/widgets/group_card.dart';
import 'package:group_chat_app/widgets/search_assistant_row.dart';
import 'package:group_chat_app/screens/group_chat_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  static const _bgColor = Color(0xFF0E1213);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SearchAssistantRow(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text('Groups',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('groups')
                    .where('members', arrayContains: uid)
                    .snapshots(),
                builder: (ctx, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snap.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(
                        child: Text('No groups yet',
                            style: TextStyle(color: Colors.white54)));
                  }
                  return ListView(
                    children: docs.map((d) {
                      final data = d.data();
                      final members = data['members'] as List<dynamic>? ?? [];
                      final photo   = data['photoUrl'] as String?;
                      return GroupCard(
                        imageAsset: photo ?? 'assets/calc.png',
                        name      : data['name'] ?? 'Unnamed',
                        subject   : data['subject'] ?? '',
                        lastMessageTime: '', // optional enhancement later
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GroupChatScreen(
                              groupId: d.id,
                              groupName: data['name'] ?? 'Group',
                              memberCount: members.length,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
