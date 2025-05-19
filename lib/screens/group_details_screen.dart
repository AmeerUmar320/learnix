import 'package:flutter/material.dart';
import '../models/group_model.dart';
import '../models/user_model.dart';
import '../repositories/group_repository.dart';
import 'package:group_chat_app/screens/add_members.dart';

class GroupDetailsScreen extends StatefulWidget {
  final GroupModel group;
  static const bgColor = Color(0xFF0E1213);
  static const accentColor = Color(0xFFB5FB67);

  const GroupDetailsScreen({super.key, required this.group});

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  List<Map<String, dynamic>> _members = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    try {
      final members = await GroupRepository().fetchGroupMembersWithRoles(widget.group.id);
      if (!mounted) return;
      setState(() {
        _members = members;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _members = [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: GroupDetailsScreen.bgColor,
        appBar: AppBar(
          backgroundColor: GroupDetailsScreen.bgColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Group Details', style: TextStyle(color: Colors.white)),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Details'),
              Tab(text: 'Resources'),
            ],
            indicatorColor: GroupDetailsScreen.accentColor,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: GroupDetailsScreen.accentColor,
            unselectedLabelColor: Colors.white,
          ),
        ),
        body: TabBarView(
          children: [
            // --- DETAILS TAB ---
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: widget.group.profilePictureUrl != null
                        ? NetworkImage('http://192.168.100.28:5241${widget.group.profilePictureUrl!}')
                        : const AssetImage('assets/profiles/profile_7.jpg') as ImageProvider,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    widget.group.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    widget.group.description ?? 'No subject',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Members',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                if (_loading)
                  const Center(
                      child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CircularProgressIndicator(),
                  ))
                else if (_members.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text("No members found.", style: TextStyle(color: Colors.white54)),
                  )
                else
                  ..._members.map((m) {
                    final user = m['user'] as UserModel;
                    final role = m['role'];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user.profilePictureUrl != null && user.profilePictureUrl!.isNotEmpty
                            ? NetworkImage('http://192.168.100.28:5241${user.profilePictureUrl!}')
                            : const AssetImage('assets/profiles/profile_7.jpg') as ImageProvider,
                      ),
                      title: Text(user.name, style: const TextStyle(color: Colors.white)),
                      subtitle: Text(user.email, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      trailing: role == 1
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('Admin',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 12)),
                            )
                          : null,
                    );
                  }),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.person_add_alt_1, color: GroupDetailsScreen.accentColor),
                        label: const Text('Add Members', style: TextStyle(color: GroupDetailsScreen.accentColor)),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: GroupDetailsScreen.accentColor)),
                        onPressed: () async {
                          final refresh = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddMembersPage(group: widget.group),
                            ),
                          );
                          if (refresh == true) {
                            _fetchMembers();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.exit_to_app, color: Colors.redAccent),
                        label: const Text('Leave Group', style: TextStyle(color: Colors.redAccent)),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent)),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: const Color(0xFF181D1F),
                              title: const Text('Leave Group', style: TextStyle(color: Colors.white)),
                              content: const Text(
                                'Are you sure you want to leave this group?',
                                style: TextStyle(color: Colors.white70),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Leave', style: TextStyle(color: Colors.redAccent)),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            try {
                              // Optionally show a loading dialog/spinner here if desired
                              await GroupRepository().removeCurrentUserFromGroup(widget.group.id);
                              if (!mounted) return;
                              // Go to home and remove all previous routes
                              Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                              // Optionally show a snackbar on home
                              // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('You left the group.')));
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Error leaving group: $e'),
                                backgroundColor: Colors.redAccent,
                              ));
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // --- RESOURCES TAB ---
            const Center(
              child: Text(
                'No resources yet.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
