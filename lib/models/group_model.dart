class GroupModel {
  final int id;
  final String name;
  final String? description;
  final String? profilePictureUrl;

  GroupModel({
    required this.id,
    required this.name,
    this.description,
    this.profilePictureUrl,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      profilePictureUrl: json['profilePictureUrl'],
    );
  }
}
