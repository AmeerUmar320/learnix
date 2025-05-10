import 'package:flutter/material.dart';
import 'package:group_chat_app/widgets/group_card.dart';
import 'package:group_chat_app/widgets/search_assistant_row.dart';
import 'package:group_chat_app/screens/group_details_screen.dart'; // Add this import

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
            // extracted search/assistant row
            const SearchAssistantRow(),

            // Groups header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Text(
                'Groups',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // List of groups
            Expanded(
              child: ListView(
                children: [
                  GroupCard(
                    imageAsset: 'assets/calc.png',
                    name: 'Algebra Buddies',
                    subject: 'Math',
                    lastMessageTime: '2:45 PM',
                    onTap: () => _navigateToGroupDetails(
                      'Algebra Buddies',
                      'Math',
                      'assets/calc.png',
                    ),
                  ),
                  GroupCard(
                    imageAsset: 'assets/calc.png',
                    name: 'OOP Enthusiasts',
                    subject: 'OOP',
                    lastMessageTime: '1:15 PM',
                    onTap: () => _navigateToGroupDetails(
                      'OOP Enthusiasts',
                      'OOP',
                      'assets/calc.png',
                    ),
                  ),
                  GroupCard(
                    imageAsset: 'assets/calc.png',
                    name: 'Flutter Devs',
                    subject: 'Mobile Dev',
                    lastMessageTime: 'Yesterday',
                    onTap: () => _navigateToGroupDetails(
                      'Flutter Devs',
                      'Mobile Dev',
                      'assets/calc.png',
                    ),
                  ),
                  // add more GroupCard(...) here
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToGroupDetails(String name, String subject, String imageAsset) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupDetailsScreen(
          groupName: name,
          subject: subject,
          imageAsset: imageAsset,
        ),
      ),
    );
  }
}