// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:group_chat_app/widgets/common_widgets.dart';
import 'package:group_chat_app/models/contact.dart';
import 'package:group_chat_app/screens/group_chat_screen.dart';

class GroupInfoPage extends StatefulWidget {
  final List<Contact> selectedContacts;
  const GroupInfoPage({super.key, required this.selectedContacts});

  @override
  State<GroupInfoPage> createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _groupNameController = TextEditingController();
  final _subjectController   = TextEditingController();
  // File? _groupImage;
  bool _creating = false;

  @override
  void dispose() {
    _groupNameController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _creating = true);

    final name = _groupNameController.text.trim();
    final subject = _subjectController.text.trim();
    final admin = FirebaseAuth.instance.currentUser!.uid;
    final memberUids = widget.selectedContacts.map((c) => c.uid).toList()
      ..add(admin);

    try {
      final doc = await FirebaseFirestore.instance.collection('groups').add({
        'name': name,
        'subject': subject,
        'adminId': admin,
        'members': memberUids,
      });
      final groupId = doc.id;
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => GroupChatScreen(
            groupId: groupId,
            groupName: name,
            memberCount: memberUids.length,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Group Info')),
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
                      children: [
                        // … group image selector (unchanged) …
                        const SizedBox(height: 32),
                        CustomTextField(
                          label: 'Group Name',
                          hint: 'Enter a name for your study group',
                          controller: _groupNameController,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
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
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Please enter a subject';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        // … selected members summary …
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: 'Create Group',
                  onPressed: _creating
                      ? () {}
                      : () => _createGroup(),
                  isLoading: _creating,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
