import 'dart:io';
import 'package:flutter/material.dart';
import '../models/group_model.dart';
import '../models/user_model.dart';
import '../models/group_resource_model.dart'; // You need to create this model
import '../repositories/group_repository.dart';
import 'package:group_chat_app/screens/add_members.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroupDetailsScreen extends StatefulWidget {
  final GroupModel group;
  static const bgColor = Color(0xFF0E1213);
  static const accentColor = Color(0xFFB5FB67);

  const GroupDetailsScreen({super.key, required this.group});

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _members = [];
  bool _loading = true;
  int _tabIndex = 0;
  late TabController _tabController;

  // Image picker state
  File? _pickedImage;
  String? _pickedImageName;
  bool _isUploading = false;

  // Resource list
  List<GroupResourceModel> _resources = [];
  bool _resourcesLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchMembers();
    _fetchResources();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _tabIndex = _tabController.index;
      });
      if (_tabController.index == 1) {
        _fetchResources();
      }
    });
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

  Future<void> _fetchResources() async {
    setState(() { _resourcesLoading = true; });
    try {
      final res = await GroupRepository().fetchGroupResources(widget.group.id);
      if (!mounted) return;
      setState(() {
        _resources = res;
        _resourcesLoading = false;
      });
    } catch (e) {
      setState(() { _resources = []; _resourcesLoading = false; });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _showAddResourceOptions() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: GroupDetailsScreen.bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: GroupDetailsScreen.accentColor),
                title: const Text('Take Photo', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: GroupDetailsScreen.accentColor),
                title: const Text('Choose from Gallery', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 70);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
        _pickedImageName = picked.name;
      });
      _showPreview();
    }
  }

  void _showPreview() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GroupDetailsScreen.bgColor,
        title: const Text('Preview', style: TextStyle(color: Colors.white)),
        content: _pickedImage == null
            ? const Text('No image selected.', style: TextStyle(color: Colors.white54))
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_pickedImageName != null)
                    Text(
                      _pickedImageName!,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  const SizedBox(height: 10),
                  if (_pickedImage != null)
                    Image.file(_pickedImage!, width: 180, height: 180, fit: BoxFit.cover),
                  if (_isUploading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: CircularProgressIndicator(),
                    ),
                  const SizedBox(height: 10),
                  const Text('Press "Upload" to add this resource.',
                      style: TextStyle(color: Colors.white54, fontSize: 13)),
                ],
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: Colors.white70)),
          ),
          if (!_isUploading)
            TextButton(
              onPressed: () async {
                await _uploadResource(ctx);
              },
              child: const Text('Upload', style: TextStyle(color: GroupDetailsScreen.accentColor)),
            ),
        ],
      ),
    );
  }

  Future<void> _uploadResource(BuildContext dialogCtx) async {
    if (_pickedImage == null) return;
    setState(() => _isUploading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final uploadedById = prefs.getInt('userId');
      if (uploadedById == null) throw Exception("User not logged in");
      await GroupRepository().uploadGroupResource(
        groupId: widget.group.id,
        uploadedById: uploadedById,
        file: _pickedImage!,
      );
      setState(() {
        _pickedImage = null;
        _pickedImageName = null;
        _isUploading = false;
      });
      Navigator.pop(dialogCtx);
      await _fetchResources();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Resource uploaded!"),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      setState(() { _isUploading = false; });
      Navigator.pop(dialogCtx);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to upload: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GroupDetailsScreen.bgColor,
      appBar: AppBar(
        backgroundColor: GroupDetailsScreen.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Group Details', style: TextStyle(color: Colors.white)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
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
        controller: _tabController,
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
                            await GroupRepository().removeCurrentUserFromGroup(widget.group.id);
                            if (!mounted) return;
                            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
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
          _resourcesLoading
              ? const Center(child: CircularProgressIndicator())
              : _resources.isEmpty
                  ? const Center(
                      child: Text(
                        'No resources yet.',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1,
                        ),
                        itemCount: _resources.length,
                        itemBuilder: (ctx, i) {
                          final r = _resources[i];
                          return GestureDetector(
                            onTap: () {
                              // TODO: open image viewer or file if needed
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.black26,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  r.type == "image"
                                      ? Image.network(
                                          'http://192.168.100.28:5241${r.fileUrl}',
                                          width: 90, height: 90, fit: BoxFit.cover)
                                      : const Icon(Icons.insert_drive_file, size: 60, color: GroupDetailsScreen.accentColor),
                                  const SizedBox(height: 12),
                                  Text(
                                    r.fileName,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ],
      ),
      floatingActionButton: _tabIndex == 1
          ? FloatingActionButton(
              backgroundColor: GroupDetailsScreen.accentColor,
              child: const Icon(Icons.add, color: GroupDetailsScreen.bgColor),
              onPressed: _showAddResourceOptions,
              tooltip: 'Add resource',
            )
          : null,
    );
  }
}
