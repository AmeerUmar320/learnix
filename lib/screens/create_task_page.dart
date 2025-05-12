import 'package:flutter/material.dart';
import 'package:group_chat_app/theme.dart';
import 'package:group_chat_app/widgets/common_widgets.dart';

// ─── Firebase ─────────────────────────────────────────────
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateTaskPage extends StatefulWidget {
  final String groupId;
  const CreateTaskPage({super.key, required this.groupId});

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _formKey            = GlobalKey<FormState>();
  final _taskNameController = TextEditingController();
  final List<TextEditingController> _subControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  bool _hasSubtasks = false;
  bool _saving      = false;
  DateTime _selDate  = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selTime = TimeOfDay.now();

  @override
  void dispose() {
    _taskNameController.dispose();
    for (final c in _subControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addSub() {
    if (_subControllers.length < 5) {
      setState(() => _subControllers.add(TextEditingController()));
    }
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (c, child) => Theme(
        data: Theme.of(c).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.neonGreen,
            onPrimary: AppTheme.darkCanvas,
            surface: AppTheme.darkGray,
            onSurface: Colors.white,
          ),
        ), child: child!),
    );
    if (d != null) setState(() => _selDate = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _selTime,
      builder: (c, child) => Theme(
        data: Theme.of(c).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.neonGreen,
            onPrimary: AppTheme.darkCanvas,
            surface: AppTheme.darkGray,
            onSurface: Colors.white,
          ),
        ), child: child!),
    );
    if (t != null) setState(() => _selTime = t);
  }

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final due = DateTime(
      _selDate.year, _selDate.month, _selDate.day,
      _selTime.hour, _selTime.minute,
    );
    final subtasks = _hasSubtasks
        ? _subControllers
            .where((c) => c.text.trim().isNotEmpty)
            .map((c) => {'title': c.text.trim(), 'done': false})
            .toList()
        : [];

    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('tasks')
          .add({
        'title': _taskNameController.text.trim(),
        'due': Timestamp.fromDate(due),
        'subtasks': subtasks,
        'createdBy': FirebaseAuth.instance.currentUser!.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task created'),
          backgroundColor: AppTheme.neonGreen,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Task')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PageHeader(
                  title: 'Create a New Task',
                  subtitle: 'Add details for your study task',
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          label: 'Task Name',
                          hint: 'Enter task name',
                          controller: _taskNameController,
                          validator: (v) => v == null || v.isEmpty
                              ? 'Please enter a task name'
                              : null,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Checkbox(
                              value: _hasSubtasks,
                              onChanged: (v) =>
                                  setState(() => _hasSubtasks = v!),
                              activeColor: AppTheme.neonGreen,
                            ),
                            const Text('Add Subtasks',
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                        if (_hasSubtasks) ...[
                          const SizedBox(height: 16),
                          ...List.generate(
                            _subControllers.length,
                            (i) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _subControllers[i],
                                      decoration: AppTheme.inputDecoration(
                                        labelText: 'Subtask ${i + 1}',
                                        hintText: 'Enter subtask',
                                      ),
                                      onChanged: (v) {
                                        if (i ==
                                                _subControllers.length - 1 &&
                                            v.isNotEmpty) {
                                          _addSub();
                                        }
                                      },
                                    ),
                                  ),
                                  if (i >= 2)
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () => setState(
                                          () => _subControllers.removeAt(i)),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        const Text('Deadline',
                            style: AppTheme.subheadingStyle),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: _pickDate,
                                child: _dateBox(
                                  '${_selDate.day}/${_selDate.month}/${_selDate.year}',
                                  Icons.calendar_today,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: _pickTime,
                                child: _dateBox(
                                    _selTime.format(context),
                                    Icons.access_time),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: 'Create Task',
                  onPressed: _saving
                      ? () {}
                      : () => _createTask(),
                  isLoading: _saving,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dateBox(String txt, IconData icon) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.darkGray,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.textGray),
            const SizedBox(width: 8),
            Text(txt, style: const TextStyle(color: Colors.white)),
          ],
        ),
      );
}
