import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/group/group_bloc.dart';
import '../blocs/group/group_event.dart';
import '../blocs/group/group_state.dart';
import '../models/user_model.dart';
import '../utils/image_picker_util.dart';
import '../widgets/common_widgets.dart';
import '../theme.dart';

class GroupInfoPage extends StatefulWidget {
  final List<UserModel> selectedUsers;

  const GroupInfoPage({super.key, required this.selectedUsers});

  @override
  State<GroupInfoPage> createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _groupImage;
  final _formKey = GlobalKey<FormState>();

  void _onCreateGroupPressed() {
    if (!_formKey.currentState!.validate()) return;
    final name = _groupNameController.text.trim();
    final description = _descriptionController.text.trim();
    final memberIds = widget.selectedUsers.map((u) => u.id).toList();

    context.read<GroupBloc>().add(
      CreateGroupRequested(
        name: name,
        description: description.isEmpty ? null : description,
        memberIds: memberIds,
        image: _groupImage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Info'),
      ),
      body: BlocConsumer<GroupBloc, GroupState>(
        listener: (context, state) {
          if (state is GroupSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Group created successfully!'),
                backgroundColor: AppTheme.neonGreen,
              ),
            );
            Navigator.pop(context); // Go back or navigate to group screen
          } else if (state is GroupFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
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
                              label: 'Subject (Description)',
                              hint: 'Enter the subject/description',
                              controller: _descriptionController,
                              validator: (value) => null,
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
                                    'Members (${widget.selectedUsers.length})',
                                    style: AppTheme.subheadingStyle,
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: widget.selectedUsers
                                        .map((user) => Chip(
                                              avatar: CircleAvatar(
                                                backgroundColor:
                                                    AppTheme.mediumGray,
                                                backgroundImage: user.profilePictureUrl != null
                                                    ? NetworkImage('http://192.168.100.28:5241${user.profilePictureUrl!}')
                                                    : null,
                                                child: user.profilePictureUrl == null
                                                    ? Text(
                                                        user.name
                                                            .substring(0, 1)
                                                            .toUpperCase(),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                        ),
                                                      )
                                                    : null,
                                              ),
                                              label: Text(user.name),
                                              backgroundColor:
                                                  AppTheme.mediumGray,
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
                    state is GroupLoading
                        ? const Center(child: CircularProgressIndicator())
                        : PrimaryButton(
                            text: 'Create Group',
                            onPressed: _onCreateGroupPressed,
                          ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
