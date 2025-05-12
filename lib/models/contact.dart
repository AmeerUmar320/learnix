/// A simple model for a user/contact in the app.
class Contact {
  /// The Firebase UID of this user.
  final String uid;

  final String name;
  final String email;
  final String? avatarUrl;

  /// Used locally to mark selection.
  bool isSelected;

  Contact({
    required this.uid,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.isSelected = false,
  });
}
