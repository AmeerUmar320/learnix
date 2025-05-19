import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:group_chat_app/blocs/task/task_bloc.dart';
import 'package:group_chat_app/widgets/task_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadAndFetch();
  }

  Future<void> _loadAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('userId');
    });
    if (_userId != null) {
      BlocProvider.of<TaskBloc>(context).add(FetchTasksForUserEvent(_userId!));
    }
  }

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
              child: BlocBuilder<TaskBloc, TaskState>(
                builder: (context, state) {
                  if (state is TaskLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is TasksLoaded) {
                    if (state.tasks.isEmpty) {
                      return const Center(
                        child: Text("No tasks found.", style: TextStyle(color: Colors.white70)),
                      );
                    }
                    return ListView.builder(
                      itemCount: state.tasks.length,
                      itemBuilder: (context, idx) {
                        final task = state.tasks[idx];
                        final subtasks = (task['subtasks'] as List<dynamic>);
                        if (subtasks.isEmpty) {
                          // No subtasks
                          return SimpleTaskCard(
                            title: task['title'] ?? '',
                            dueText: 'Due: ${_formatDateTime(task['dueDate'])}',
                            groupName: task['groupName'] ?? '',
                          );
                        } else {
                          // Has subtasks
                          return TaskWithSubtasksCard(
                            title: task['title'] ?? '',
                            dueText: 'Due: ${_formatDateTime(task['dueDate'])}',
                            groupName: task['groupName'] ?? '',
                            subtaskTitles: subtasks.map((st) => st['title'] as String).toList(),
                          );
                        }
                      },
                    );
                  } else if (state is TaskError) {
                    return Center(
                      child: Text(state.message, style: const TextStyle(color: Colors.redAccent)),
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(dynamic dt) {
    // dt is string in ISO format
    if (dt is String) {
      final date = DateTime.tryParse(dt);
      if (date != null) {
        final dateStr = "${date.day}/${date.month}/${date.year}";
        final timeStr =
            "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
        return "$dateStr, $timeStr";
      }
    }
    return dt.toString();
  }
}