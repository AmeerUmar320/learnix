import 'package:flutter/material.dart';

/// A single “group chat” card, mimicking your bills UI.
class GroupCard extends StatelessWidget {
  final String imageAsset;
  final String name;
  final String subject;
  final String lastMessageTime;
  final VoidCallback? onTap;

  const GroupCard({
    super.key,
    required this.imageAsset,
    required this.name,
    required this.subject,
    required this.lastMessageTime,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const cardColor = Color.fromARGB(77, 136, 141, 141);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                imageAsset,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subject,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              lastMessageTime,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
