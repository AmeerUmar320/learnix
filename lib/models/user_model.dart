class UserModel {
  final int id;
  final String name;
  final String email;
  final String? profilePictureUrl;
  bool isSelected; // for UI selection only

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profilePictureUrl,
    this.isSelected = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] is int
            ? json['id']
            : int.tryParse(json['id']?.toString() ?? '') ?? 0,
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        profilePictureUrl: json['profilePictureUrl']?.toString(),
      );
}
