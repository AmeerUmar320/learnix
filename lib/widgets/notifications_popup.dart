import 'package:flutter/material.dart';

class NotificationsPopup extends StatelessWidget {
  final List<Map<String, String>> notifications;

  const NotificationsPopup({super.key, required this.notifications});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Notifications',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(color: Colors.white24),
          if (notifications.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No new notifications',
                style: TextStyle(color: Colors.white70),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const Divider(color: Colors.white12),
                itemBuilder: (_, i) {
                  final n = notifications[i];
                  return ListTile(
                    title: Text(n['title']!, style: const TextStyle(color: Colors.white)),
                    subtitle: Text(n['time']!, style: const TextStyle(color: Colors.white54)),
                    leading: const Icon(Icons.notifications, color: Colors.white70),
                    onTap: () => Navigator.pop(context),
                  );
                },
              ),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
