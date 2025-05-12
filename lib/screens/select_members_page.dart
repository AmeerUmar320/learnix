import 'package:flutter/material.dart';
import 'package:group_chat_app/theme.dart';
import 'package:group_chat_app/widgets/common_widgets.dart';
import 'package:group_chat_app/screens/group_info_page.dart';
import 'package:group_chat_app/models/contact.dart';

class SelectMembersPage extends StatefulWidget {
  const SelectMembersPage({super.key});
  @override
  State<SelectMembersPage> createState() => _SelectMembersPageState();
}

class _SelectMembersPageState extends State<SelectMembersPage> {
  final _searchController = TextEditingController();
  final List<Contact> _allContacts = [
    Contact(
      uid: 'uid1',
      name: 'Alex Johnson',
      email: 'alex@example.com',
    ),
    Contact(
      uid: 'uid2',
      name: 'Jamie Smith',
      email: 'jamie@example.com',
    ),
    // … add more with unique uids …
  ];
  late List<Contact> _filteredContacts;

  @override
  void initState() {
    super.initState();
    _filteredContacts = List.from(_allContacts);
    _searchController.addListener(_filterContacts);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterContacts);
    _searchController.dispose();
    super.dispose();
  }

  void _filterContacts() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filteredContacts = q.isEmpty
          ? List.from(_allContacts)
          : _allContacts.where((c) {
              return c.name.toLowerCase().contains(q) ||
                  c.email.toLowerCase().contains(q);
            }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final selected = _allContacts.where((c) => c.isSelected).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Select Members')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(
                title: 'Select Group Members',
                subtitle: 'Choose contacts to add to your study group',
              ),
              TextField(
                controller: _searchController,
                decoration: AppTheme.inputDecoration(
                  labelText: 'Search contacts',
                  prefixIcon:
                      const Icon(Icons.search, color: AppTheme.textGray),
                ),
              ),
              const SizedBox(height: 16),
              if (selected.isNotEmpty) ...[
                Text('Selected (${selected.length})',
                    style: AppTheme.subheadingStyle),
                const SizedBox(height: 8),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: selected.length,
                    itemBuilder: (_, i) {
                      final c = selected[i];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppTheme.mediumGray,
                                  child: Text(
                                    c.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: -4,
                                  right: -4,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() => c.isSelected = false);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close,
                                          size: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              c.name.split(' ').first,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
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
                  itemCount: _filteredContacts.length,
                  itemBuilder: (ctx, i) {
                    final c = _filteredContacts[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.mediumGray,
                        child: Text(c.name[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white)),
                      ),
                      title:
                          Text(c.name, style: const TextStyle(color: Colors.white)),
                      subtitle:
                          Text(c.email, style: const TextStyle(color: AppTheme.textGray)),
                      trailing: Checkbox(
                        value: c.isSelected,
                        activeColor: AppTheme.neonGreen,
                        onChanged: (v) => setState(() => c.isSelected = v!),
                      ),
                      onTap: () => setState(() => c.isSelected = !c.isSelected),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                text: 'Next',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GroupInfoPage(
                        selectedContacts:
                            _allContacts.where((c) => c.isSelected).toList(),
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
