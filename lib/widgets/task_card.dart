// lib/widgets/task_card.dart
import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────
/// A simple “completed / not completed” task card.
/// Manages its own isCompleted state internally.
/// ─────────────────────────────────────────────────────
class SimpleTaskCard extends StatefulWidget {
  final String title;
  // **No longer const** – remove `const` here
  const SimpleTaskCard({
    super.key,
    required this.title,
  });

  @override
  State<SimpleTaskCard> createState() => _SimpleTaskCardState();
}

class _SimpleTaskCardState extends State<SimpleTaskCard> {
  bool _isCompleted = false;

  @override
  Widget build(BuildContext context) {
    const cardColor = Color(0xFF1A2323);
    const accent    = Color(0xFFB5FB67);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _isCompleted = !_isCompleted),
            child: Icon(
              _isCompleted
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: _isCompleted ? accent : Colors.white54,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────
/// A task card with any number of subtasks and a
/// circular progress indicator computed dynamically.
/// Manages its own subtasks state and progress internally.
/// ─────────────────────────────────────────────────────
class TaskWithSubtasksCard extends StatefulWidget {
  final String title;
  final String dueText;
  final List<String> subtaskTitles;

  TaskWithSubtasksCard({
    super.key,
    required this.title,
    required this.dueText,
    required this.subtaskTitles,
  })  : assert(subtaskTitles.isNotEmpty, 'Provide at least one subtask');

  @override
  State<TaskWithSubtasksCard> createState() => _TaskWithSubtasksCardState();
}

class _TaskWithSubtasksCardState extends State<TaskWithSubtasksCard> {
  late final List<bool> _done;

  @override
  void initState() {
    super.initState();
    _done = List<bool>.filled(widget.subtaskTitles.length, false);
  }

  double get _progress =>
      _done.where((d) => d).length / _done.length;

  @override
  Widget build(BuildContext context) {
    const cardColor   = Color(0xFF1A2323);
    const accentGreen = Color(0xFFB5FB67);
    const textColor   = Colors.white;
    const subColor    = Colors.white70;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Top row: title, due, animated progress circle
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title,
                        style: const TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(widget.dueText,
                        style: const TextStyle(
                            color: subColor, fontSize: 13)),
                  ],
                ),
              ),

              // Animated progress indicator
              SizedBox(
                width: 40,
                height: 40,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: _progress),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, animatedProgress, child) {
                    final percent = (animatedProgress * 100).round();
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: animatedProgress,
                          strokeWidth: 4,
                          color: accentGreen,
                          backgroundColor: Colors.white12,
                        ),
                        Text(
                          '$percent%',
                          style: const TextStyle(
                            color: accentGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(color: Colors.white12),
          const SizedBox(height: 8),

          // Subtasks list
          Column(
            children: List.generate(widget.subtaskTitles.length, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Checkbox(
                      value: _done[i],
                      activeColor: accentGreen,
                      checkColor: cardColor,
                      onChanged: (v) => setState(() => _done[i] = v!),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.subtaskTitles[i],
                        style: TextStyle(
                          color: _done[i] ? subColor : textColor,
                          decoration: _done[i]
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}