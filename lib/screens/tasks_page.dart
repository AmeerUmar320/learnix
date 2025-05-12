// lib/screens/tasks_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:group_chat_app/widgets/task_card.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0E1213);
    // Get current user’s UID
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                'Tasks',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // ── Firestore “collectionGroup” stream ───────────
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collectionGroup('tasks')
                    .where('createdBy', isEqualTo: uid)
                    .orderBy('due')
                    .snapshots(),
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snap.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No tasks yet',
                        style: TextStyle(color: Colors.white54),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: docs.length,
                    itemBuilder: (ctx, i) {
                      final data = docs[i].data();
                      // Parse timestamp → DateTime
                      final dueTs = (data['due'] as Timestamp).toDate();
                      final dueText = _formatDue(dueTs);
                      // Pull out subtasks titles
                      final subtasks = (data['subtasks'] as List<dynamic>?)
                              ?.map((e) => e['title'] as String)
                              .toList() ??
                          [];

                      return TaskWithSubtasksCard(
                        title: data['title'] as String,
                        dueText: dueText,
                        subtaskTitles: subtasks,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Smart formatting: “Due Today”, “Due Tomorrow”, “Due Wed”, or a date
  String _formatDue(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = d.difference(today).inDays;

    if (diff == 0) return 'Due Today';
    if (diff == 1) return 'Due Tomorrow';
    if (diff > 1 && diff < 7) {
      return 'Due ${DateFormat.E().format(d)}'; // e.g. “Due Wed”
    }
    return 'Due ${DateFormat.yMMMd().format(d)}';  // e.g. “Due Jan 5, 2025”
  }
}
