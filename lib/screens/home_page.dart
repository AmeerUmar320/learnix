// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:group_chat_app/widgets/group_card.dart';
import 'package:group_chat_app/widgets/search_assistant_row.dart';
import 'package:group_chat_app/screens/group_chat_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const bgColor = Color(0xFF0E1213);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SearchAssistantRow(),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                'Groups',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Expanded(
              child: ListView(
                children: [
                  GroupCard(
                    imageAsset: 'assets/calc.png',
                    name: 'Algebra Buddies',
                    subject: 'Math',
                    lastMessageTime: '2:45 PM',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GroupChatScreen(
                            groupName: 'Algebra Buddies',
                            memberCount: 4,
                          ),
                        ),
                      );
                    },
                  ),

                  GroupCard(
                    imageAsset: 'assets/calc.png',
                    name: 'OOP Enthusiasts',
                    subject: 'OOP',
                    lastMessageTime: '1:15 PM',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GroupChatScreen(
                            groupName: 'OOP Enthusiasts',
                            memberCount: 6,
                          ),
                        ),
                      );
                    },
                  ),

                  GroupCard(
                    imageAsset: 'assets/calc.png',
                    name: 'Flutter Devs',
                    subject: 'Mobile Dev',
                    lastMessageTime: 'Yesterday',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GroupChatScreen(
                            groupName: 'Flutter Devs',
                            memberCount: 5,
                          ),
                        ),
                      );
                    },
                  ),

                  // …add more GroupCard() items here, each with its own groupName & memberCount
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
