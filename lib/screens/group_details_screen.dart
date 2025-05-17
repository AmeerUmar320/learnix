import 'package:flutter/material.dart';
import 'package:group_chat_app/screens/add_members.dart';

class GroupDetailsScreen extends StatefulWidget {
  final String groupName;
  final String subject;
  final String imageAsset;

  const GroupDetailsScreen({
    super.key,
    required this.groupName,
    required this.subject,
    required this.imageAsset,
  });

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  static const bgColor = Color(0xFF0E1213);
  static const accentColor = Color(0xFFB5FB67);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onLeaveGroup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: bgColor,
        title: const Text('Leave Group', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to leave "${widget.groupName}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: accentColor)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Leave', style: TextStyle(color: Colors.redAccent)),
            onPressed: () {
              // TODO: Your leave logic here.
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('You have left the group.'),
                  backgroundColor: Colors.redAccent,
                ),
              );
              Navigator.of(context).pop(); // Go back to previous page
            },
          ),
        ],
      ),
    );
  }

  void _onAddMembers() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddMembersPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(''),
      ),
      body: Column(
        children: [
          // Group profile header
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage(widget.imageAsset),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.groupName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.subject,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          // Tab bar
          TabBar(
            controller: _tabController,
            indicatorColor: accentColor,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: accentColor,
            unselectedLabelColor: Colors.white,
            tabs: const [
              Tab(text: 'Details'),
              Tab(text: 'Resources'),
            ],
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Details Tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Created at:',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        '10 May 2025',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // --- Add/Leave Buttons Here ---
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: accentColor),
                                foregroundColor: accentColor,
                                backgroundColor: bgColor,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              icon: const Icon(Icons.person_add_alt_1, size: 20),
                              label: const Text('Add Members'),
                              onPressed: _onAddMembers,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.redAccent),
                                foregroundColor: Colors.redAccent,
                                backgroundColor: bgColor,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              icon: const Icon(Icons.exit_to_app, size: 20),
                              label: const Text('Leave Group'),
                              onPressed: _onLeaveGroup,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'Admin',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildAdminCard(
                        name: 'Emilyxox',
                        role: 'Group Admin',
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Members',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildMemberCard(name: 'Alice Smith'),
                      const SizedBox(height: 8),
                      _buildMemberCard(name: 'Bob Johnson'),
                      const SizedBox(height: 8),
                      _buildMemberCard(name: 'Carol Williams'),
                    ],
                  ),
                ),
                // Resources Tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildResourceItem(
                        icon: Icons.picture_as_pdf,
                        title: 'Study Notes.pdf',
                        type: 'PDF',
                        time: '2 hours ago',
                      ),
                      const SizedBox(height: 12),
                      _buildResourceItem(
                        icon: Icons.image,
                        title: 'Lecture Diagram.png',
                        type: 'Picture',
                        time: '1 day ago',
                      ),
                      const SizedBox(height: 12),
                      _buildResourceItem(
                        icon: Icons.link,
                        title: 'Research Article',
                        type: 'Link',
                        time: '3 days ago',
                      ),
                      const SizedBox(height: 12),
                      _buildResourceItem(
                        icon: Icons.picture_as_pdf,
                        title: 'Assignment.pdf',
                        type: 'PDF',
                        time: '1 week ago',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: const BoxDecoration(
          color: bgColor,
          border: Border(
            top: BorderSide(color: Colors.white24, width: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Group details: ${widget.subject}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.check_circle,
              color: accentColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard({required String name, required String role}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage('assets/profile (7).jpg'),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                role,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard({required String name}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white24,
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceItem({
    required IconData icon,
    required String title,
    required String type,
    required String time,
  }) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    type,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              time,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
