import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme.dart';
import '../widgets/common_widgets.dart';
import '../blocs/task/task_bloc.dart';

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

  List<Map<String, dynamic>> _groups = [];
  int? _selectedGroupId;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<TaskBloc>(context).add(FetchGroupsEvent());
  }

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
            dialogTheme: DialogTheme(backgroundColor: AppTheme.darkCanvas),
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
            dialogTheme: DialogTheme(backgroundColor: AppTheme.darkCanvas),
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

  void _onSubmit() {
    if (_formKey.currentState!.validate() && _selectedGroupId != null) {
      final dueDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      final subtasks = _hasSubtasks
          ? _subtaskControllers
              .where((c) => c.text.trim().isNotEmpty)
              .map((c) => c.text.trim())
              .toList()
          : <String>[];

      BlocProvider.of<TaskBloc>(context).add(
        CreateTaskEvent(
          title: _taskNameController.text.trim(),
          groupId: _selectedGroupId!,
          dueDate: dueDate,
          subtasks: subtasks,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state is TaskCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task created successfully!'), backgroundColor: AppTheme.neonGreen),
          );
          Navigator.pop(context);
        } else if (state is TaskError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is GroupsLoaded) {
          setState(() {
            _groups = state.groups;
            if (_groups.isNotEmpty) {
              _selectedGroupId = _groups.first['id'] as int;
            }
          });
        }
      },
      builder: (context, state) {
        final isLoading = state is TaskLoading;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Create Task'),
          ),
          body: SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: (_groups.isEmpty && !isLoading)
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const PageHeader(
                                  title: 'Create a New Task',
                                  subtitle: 'Add details for your study task',
                                ),
                                const SizedBox(height: 24),
                                const Text('Group', style: AppTheme.subheadingStyle),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white10,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<int>(
                                      value: _selectedGroupId,
                                      dropdownColor: AppTheme.darkCanvas,
                                      iconEnabledColor: Colors.white70,
                                      style: const TextStyle(color: Colors.white),
                                      items: _groups
                                          .map((g) => DropdownMenuItem<int>(
                                                value: g['id'] as int,
                                                child: Text(g['name'] ?? 'Group'),
                                              ))
                                          .toList(),
                                      onChanged: (g) {
                                        if (g != null) {
                                          setState(() => _selectedGroupId = g);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                CustomTextField(
                                  label: 'Task Name',
                                  hint: 'Enter task name',
                                  controller: _taskNameController,
                                  validator: (value) =>
                                      value == null || value.isEmpty ? 'Please enter a task name' : null,
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _hasSubtasks,
                                      onChanged: (v) => setState(() => _hasSubtasks = v!),
                                      activeColor: AppTheme.neonGreen,
                                    ),
                                    const Text('Add Subtasks', style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                                if (_hasSubtasks) ...[
                                  const SizedBox(height: 16),
                                  ...List.generate(_subtaskControllers.length, (index) {
                                    return Padding(
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
                                              icon: const Icon(Icons.delete, color: Colors.red),
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
                                    );
                                  }),
                                ],
                                const SizedBox(height: 24),
                                const Text('Deadline', style: AppTheme.subheadingStyle),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => _selectDate(context),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          decoration: BoxDecoration(
                                            color: AppTheme.darkGray,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.calendar_today, color: AppTheme.textGray),
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
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          decoration: BoxDecoration(
                                            color: AppTheme.darkGray,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.access_time, color: AppTheme.textGray),
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
                                const SizedBox(height: 24),
                                PrimaryButton(
                                  text: 'Create Task',
                                  onPressed: isLoading ? () {} : _onSubmit,
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ),
                ),
                if (isLoading)
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
