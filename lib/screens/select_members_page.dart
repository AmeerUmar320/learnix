import 'package:flutter/material.dart';
import 'package:group_chat_app/theme.dart';
import 'package:group_chat_app/widgets/common_widgets.dart';
import 'package:group_chat_app/screens/group_info_page.dart';

class Contact {
  final String name;
  final String email;
  final String? avatarUrl;
  bool isSelected;

  Contact({
    required this.name,
    required this.email,
    this.avatarUrl,
    this.isSelected = false,
  });
}

class SelectMembersPage extends StatefulWidget {
  const SelectMembersPage({super.key});

  @override
  State<SelectMembersPage> createState() => _SelectMembersPageState();
}

class _SelectMembersPageState extends State<SelectMembersPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<Contact> _allContacts = [
    Contact(name: 'Alex Johnson', email: 'alex@example.com'),
    Contact(name: 'Jamie Smith', email: 'jamie@example.com'),
    Contact(name: 'Taylor Brown', email: 'taylor@example.com'),
    Contact(name: 'Morgan Davis', email: 'morgan@example.com'),
    Contact(name: 'Casey Wilson', email: 'casey@example.com'),
    Contact(name: 'Jordan Miller', email: 'jordan@example.com'),
    Contact(name: 'Riley Moore', email: 'riley@example.com'),
    Contact(name: 'Quinn Thomas', email: 'quinn@example.com'),
    Contact(name: 'Avery Martinez', email: 'avery@example.com'),
    Contact(name: 'Reese Anderson', email: 'reese@example.com'),
  ];
  List<Contact> _filteredContacts = [];

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
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredContacts = List.from(_allContacts);
      } else {
        _filteredContacts = _allContacts
            .where((contact) =>
                contact.name.toLowerCase().contains(query) ||
                contact.email.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedContacts = _allContacts.where((c) => c.isSelected).toList();

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
                subtitle: 'Choose contacts to add to your study group',
              ),
              TextField(
                controller: _searchController,
                decoration: AppTheme.inputDecoration(
                  labelText: 'Search contacts',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.textGray),
                ),
              ),
              const SizedBox(height: 16),
              if (selectedContacts.isNotEmpty) ...[
                Text(
                  'Selected (${selectedContacts.length})',
                  style: AppTheme.subheadingStyle,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: selectedContacts.length,
                    itemBuilder: (context, index) {
                      final contact = selectedContacts[index];
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
                                    contact.name.substring(0, 1).toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: -4,
                                  top: -4,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        contact.isSelected = false;
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
                              contact.name.split(' ')[0],
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
                  itemCount: _filteredContacts.length,
                  itemBuilder: (context, index) {
                    final contact = _filteredContacts[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.mediumGray,
                        child: Text(
                          contact.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        contact.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        contact.email,
                        style: const TextStyle(color: AppTheme.textGray),
                      ),
                      trailing: Checkbox(
                        value: contact.isSelected,
                        activeColor: AppTheme.neonGreen,
                        onChanged: (value) {
                          setState(() {
                            contact.isSelected = value!;
                          });
                        },
                      ),
                      onTap: () {
                        setState(() {
                          contact.isSelected = !contact.isSelected;
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupInfoPage(
                        selectedContacts: _allContacts
                            .where((c) => c.isSelected)
                            .toList(),
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
