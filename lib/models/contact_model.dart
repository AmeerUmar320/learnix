class Contact {
  final int? id; // Optionally use backend user IDs if available
  final String name;
  final String email;
  final String? avatarUrl;
  bool isSelected;

  Contact({
    this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.isSelected = false,
  });
}