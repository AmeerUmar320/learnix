// lib/screens/tasks_page.dart
import 'package:flutter/material.dart';
import 'package:group_chat_app/widgets/task_card.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0E1213);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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

            // Task cards
            Expanded(
              child: ListView(
                children: [
                  // A simple toggle task
                  SimpleTaskCard(title: 'Read Chapter 1'),

                  // A task with 4 subtasks
                  TaskWithSubtasksCard(
                    title: 'Prepare Presentation',
                    dueText: 'Due Tomorrow',
                    subtaskTitles: [
                      'Draft slides',
                      'Add diagrams',
                      'Rehearse speech',
                      'Collect feedback',
                    ],
                  ),

                  // A task with 3 subtasks
                  TaskWithSubtasksCard(
                    title: 'Write Report',
                    dueText: 'Due Friday',
                    subtaskTitles: [
                      'Outline structure',
                      'Research sources',
                      'Write draft',
                    ],
                  ),

                  // You can add more cards here…
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
