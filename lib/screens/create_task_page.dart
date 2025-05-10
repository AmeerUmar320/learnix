import 'package:flutter/material.dart';
import 'package:group_chat_app/theme.dart';
import 'package:group_chat_app/widgets/common_widgets.dart';

class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({super.key});

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _taskNameController = TextEditingController();
  final List<TextEditingController> _subtaskControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  bool _hasSubtasks = false;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void dispose() {
    _taskNameController.dispose();
    for (var controller in _subtaskControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addSubtaskField() {
    if (_subtaskControllers.length < 5) {
      setState(() {
        _subtaskControllers.add(TextEditingController());
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.neonGreen,
              onPrimary: AppTheme.darkCanvas,
              surface: AppTheme.darkGray,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: AppTheme.darkCanvas,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.neonGreen,
              onPrimary: AppTheme.darkCanvas,
              surface: AppTheme.darkGray,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: AppTheme.darkCanvas,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a task name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Checkbox(
                              value: _hasSubtasks,
                              onChanged: (value) {
                                setState(() {
                                  _hasSubtasks = value!;
                                });
                              },
                              activeColor: AppTheme.neonGreen,
                            ),
                            const Text(
                              'Add Subtasks',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        if (_hasSubtasks) ...[
                          const SizedBox(height: 16),
                          ...List.generate(
                            _subtaskControllers.length,
                            (index) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _subtaskControllers[index],
                                      decoration: AppTheme.inputDecoration(
                                        labelText: 'Subtask ${index + 1}',
                                        hintText: 'Enter subtask',
                                      ),
                                      onChanged: (value) {
                                        // Add a new field if this is the last one and it's not empty
                                        if (index == _subtaskControllers.length - 1 &&
                                            value.isNotEmpty &&
                                            _subtaskControllers.length < 5) {
                                          _addSubtaskField();
                                        }
                                      },
                                    ),
                                  ),
                                  if (index > 1 || _subtaskControllers.length > 2)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        if (_subtaskControllers.length > 2) {
                                          setState(() {
                                            _subtaskControllers.removeAt(index);
                                          });
                                        }
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        const Text(
                          'Deadline',
                          style: AppTheme.subheadingStyle,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _selectDate(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.darkGray,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        color: AppTheme.textGray,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _selectTime(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.darkGray,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        color: AppTheme.textGray,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _selectedTime.format(context),
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // In a real app, you would save the task data here
                      
                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Task created successfully!'),
                          backgroundColor: AppTheme.neonGreen,
                        ),
                      );
                      
                      // Navigate back to previous screen
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
