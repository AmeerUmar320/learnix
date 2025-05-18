// models/user_model.dart
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
        id: json['id'],
        name: json['name'],
        email: json['email'],
        profilePictureUrl: json['profilePictureUrl'],
      );
}
