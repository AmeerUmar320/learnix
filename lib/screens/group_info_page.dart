import 'dart:io';
import 'package:flutter/material.dart';
import 'package:group_chat_app/screens/create_task_page.dart';
import 'package:group_chat_app/screens/select_members_page.dart';
import 'package:group_chat_app/theme.dart';
import 'package:group_chat_app/utils/image_picker_util.dart';
import 'package:group_chat_app/widgets/common_widgets.dart';

class GroupInfoPage extends StatefulWidget {
  final List<Contact> selectedContacts;

  const GroupInfoPage({
    super.key,
    required this.selectedContacts,
  });

  @override
  State<GroupInfoPage> createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  File? _groupImage;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _groupNameController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Info'),
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
                  title: 'Create Your Study Group',
                  subtitle: 'Add details about your new study group',
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              ImagePickerUtil.showImageSourceDialog(
                                context: context,
                                onImageSelected: (image) {
                                  if (image != null) {
                                    setState(() {
                                      _groupImage = image;
                                    });
                                  }
                                },
                              );
                            },
                            child: Stack(
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: AppTheme.darkGray,
                                    shape: BoxShape.circle,
                                    image: _groupImage != null
                                        ? DecorationImage(
                                            image: FileImage(_groupImage!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: _groupImage == null
                                      ? const Icon(
                                          Icons.groups,
                                          size: 60,
                                          color: AppTheme.lightGray,
                                        )
                                      : null,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: AppTheme.neonGreen,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: AppTheme.darkCanvas,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        CustomTextField(
                          label: 'Group Name',
                          hint: 'Enter a name for your study group',
                          controller: _groupNameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a group name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Subject',
                          hint: 'Enter the subject of your study group',
                          controller: _subjectController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a subject';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.darkGray,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Members (${widget.selectedContacts.length})',
                                style: AppTheme.subheadingStyle,
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: widget.selectedContacts
                                    .map((contact) => Chip(
                                          avatar: CircleAvatar(
                                            backgroundColor: AppTheme.mediumGray,
                                            child: Text(
                                              contact.name
                                                  .substring(0, 1)
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          label: Text(contact.name),
                                          backgroundColor: AppTheme.mediumGray,
                                          labelStyle: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: 'Create Group',
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // In a real app, you would save the group data here
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Group created successfully!'),
                          backgroundColor: AppTheme.neonGreen,
                        ),
                      );
                      
                      // Navigate to the Create Task page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateTaskPage(),
                        ),
                      );
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
