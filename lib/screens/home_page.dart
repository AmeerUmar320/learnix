import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../blocs/group/group_bloc.dart';
import '../blocs/group/group_event.dart';
import '../blocs/group/group_state.dart';
import '../widgets/group_card.dart';
import 'group_chat_screen.dart';
import '../models/group_model.dart';
import '../widgets/search_assistant_row.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? userId;

  @override
  void initState() {
    super.initState();
    _loadUserAndFetchGroups();
  }

  Future<void> _loadUserAndFetchGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getInt('userId');
    debugPrint("Loaded userId: $uid");
    if (uid != null) {
      setState(() {
        userId = uid;
      });
      context.read<GroupBloc>().add(FetchGroupsForUser(uid));
    }
  }

  Future<void> _refresh() async {
    if (userId != null) {
      context.read<GroupBloc>().add(FetchGroupsForUser(userId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1213),
      body: SafeArea(
        child: userId == null
            ? const Center(
                child: Text(
                  'No user found. Please login again.',
                  style: TextStyle(color: Colors.white70),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SearchAssistantRow(userId: userId!),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text(
                      'Groups',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: BlocBuilder<GroupBloc, GroupState>(
                      builder: (context, state) {
                        if (state is GroupLoading) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (state is GroupsLoaded) {
                          final List<GroupModel> groups = state.groups;
                          debugPrint('Loaded groups for user $userId: ${groups.map((g) => g.name).toList()}');
                          if (groups.isEmpty) {
                            return const Center(
                              child: Text(
                                'You are not part of any groups.',
                                style: TextStyle(color: Colors.white54),
                              ),
                            );
                          }
                          return RefreshIndicator(
                            onRefresh: _refresh,
                            child: ListView.builder(
                              itemCount: groups.length,
                              itemBuilder: (context, i) {
                                final group = groups[i];
                                return GroupCard(
                                  imageUrl: group.profilePictureUrl != null && group.profilePictureUrl!.isNotEmpty
                                      ? 'http://192.168.100.28:5241${group.profilePictureUrl!}'
                                      : null,
                                  name: group.name,
                                  subject: group.description ?? 'No subject',
                                  lastMessageTime: '—',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => GroupChatScreen(group: group),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        } else if (state is GroupFailure) {
                          return Center(
                            child: Text(
                              'Error: ${state.error}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
