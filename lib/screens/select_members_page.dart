import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common_widgets.dart';
import '../models/user_model.dart';
import '../repositories/group_repository.dart';
import 'group_info_page.dart';

class SelectMembersPage extends StatefulWidget {
  const SelectMembersPage({super.key});

  @override
  State<SelectMembersPage> createState() => _SelectMembersPageState();
}

class _SelectMembersPageState extends State<SelectMembersPage> {
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];
  Set<int> _selectedUserIds = {};

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterUsers);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    final users = await GroupRepository().fetchAllUsers();
    setState(() {
      _allUsers = users;
      _filteredUsers = users;
    });
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = List.from(_allUsers);
      } else {
        _filteredUsers = _allUsers
            .where((user) =>
                user.name.toLowerCase().contains(query) ||
                user.email.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedUsers =
        _allUsers.where((u) => _selectedUserIds.contains(u.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Members'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(
                title: 'Select Group Members',
                subtitle: 'Choose platform users to add to your study group',
              ),
              TextField(
                controller: _searchController,
                decoration: AppTheme.inputDecoration(
                  labelText: 'Search users',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.textGray),
                ),
              ),
              const SizedBox(height: 16),
              if (selectedUsers.isNotEmpty) ...[
                Text(
                  'Selected (${selectedUsers.length})',
                  style: AppTheme.subheadingStyle,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: selectedUsers.length,
                    itemBuilder: (context, index) {
                      final user = selectedUsers[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppTheme.mediumGray,
                                  backgroundImage: user.profilePictureUrl != null
                                      ? NetworkImage('http://192.168.100.28:5241${user.profilePictureUrl!}')
                                      : null,
                                  child: user.profilePictureUrl == null
                                      ? Text(
                                          user.name.substring(0, 1).toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : null,
                                ),
                                Positioned(
                                  right: -4,
                                  top: -4,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedUserIds.remove(user.id);
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.name.split(' ')[0],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const Divider(height: 24),
              ],
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = _filteredUsers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.mediumGray,
                        backgroundImage: user.profilePictureUrl != null
                            ? NetworkImage('http://192.168.100.28:5241${user.profilePictureUrl!}')
                            : null,
                        child: user.profilePictureUrl == null
                            ? Text(
                                user.name.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      title: Text(
                        user.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        user.email,
                        style: const TextStyle(color: AppTheme.textGray),
                      ),
                      trailing: Checkbox(
                        value: _selectedUserIds.contains(user.id),
                        activeColor: AppTheme.neonGreen,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedUserIds.add(user.id);
                            } else {
                              _selectedUserIds.remove(user.id);
                            }
                          });
                        },
                      ),
                      onTap: () {
                        setState(() {
                          if (_selectedUserIds.contains(user.id)) {
                            _selectedUserIds.remove(user.id);
                          } else {
                            _selectedUserIds.add(user.id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                text: 'Next',
                onPressed: () {
                  if (selectedUsers.isEmpty) return; // do nothing if no users
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupInfoPage(
                        selectedUsers: selectedUsers,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
