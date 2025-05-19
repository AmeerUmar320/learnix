import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/group_model.dart';
import '../repositories/group_repository.dart';

class AddMembersPage extends StatefulWidget {
  final GroupModel group;
  const AddMembersPage({super.key, required this.group});

  @override
  State<AddMembersPage> createState() => _AddMembersPageState();
}

class _AddMembersPageState extends State<AddMembersPage> {
  List<UserModel> _allUsers = [];
  List<UserModel> _selected = [];
  bool _loading = true;
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _filtered = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final repo = GroupRepository();
      final users = await repo.fetchAllUsers();
      // Filter out users who are already members, and set a flag for them
      for (final user in users) {
        if (widget.group.members.contains(user.id)) {
          user.isSelected = true; // used as "already in group"
        }
      }
      setState(() {
        _allUsers = users;
        _filtered = users;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _allUsers = [];
        _filtered = [];
        _loading = false;
      });
    }
  }

  void _filterContacts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filtered = List.from(_allUsers);
      } else {
        _filtered = _allUsers
            .where((u) =>
                u.name.toLowerCase().contains(query) ||
                u.email.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  Future<void> _addSelectedMembers() async {
    final repo = GroupRepository();
    int added = 0, failed = 0;
    for (final user in _selected) {
      try {
        await repo.addUserToGroup(user.id, widget.group.id);
        added++;
      } catch (_) {
        failed++;
      }
    }
    if (!mounted) return;
    Navigator.pop(context, true); // true means "refresh members"
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $added member(s)' + (failed > 0 ? ', $failed failed' : '')),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Members'),
        backgroundColor: const Color(0xFF0E1213),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Search users',
                        prefixIcon: const Icon(Icons.search),
                      ),
                      onChanged: (_) => _filterContacts(),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _filtered.length,
                        itemBuilder: (context, i) {
                          final user = _filtered[i];
                          final alreadyInGroup = widget.group.members.contains(user.id);
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: alreadyInGroup ? Colors.grey : Colors.blue,
                              backgroundImage: user.profilePictureUrl != null &&
                                      user.profilePictureUrl!.isNotEmpty
                                  ? NetworkImage('http://192.168.100.28:5241${user.profilePictureUrl!}')
                                  : null,
                              child: user.profilePictureUrl == null || user.profilePictureUrl!.isEmpty
                                  ? Text(user.name.substring(0, 1).toUpperCase())
                                  : null,
                            ),
                            title: Text(user.name, style: const TextStyle(color: Colors.white)),
                            subtitle: Text(user.email, style: const TextStyle(color: Colors.white60)),
                            trailing: alreadyInGroup
                                ? const Text('Member',
                                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                                : Checkbox(
                                    value: _selected.contains(user),
                                    onChanged: (val) {
                                      setState(() {
                                        if (val == true) {
                                          _selected.add(user);
                                        } else {
                                          _selected.remove(user);
                                        }
                                      });
                                    }),
                            enabled: !alreadyInGroup,
                            onTap: alreadyInGroup
                                ? null
                                : () {
                                    setState(() {
                                      if (_selected.contains(user)) {
                                        _selected.remove(user);
                                      } else {
                                        _selected.add(user);
                                      }
                                    });
                                  },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.person_add),
                      label: const Text('Add to Group'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(45),
                        backgroundColor: Colors.green,
                      ),
                      onPressed: _selected.isEmpty ? null : _addSelectedMembers,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
