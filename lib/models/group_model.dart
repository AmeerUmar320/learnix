class GroupModel {
  final int id;
  final String name;
  final String? description;
  final String? profilePictureUrl;
  final List<int> members;

  GroupModel({
    required this.id,
    required this.name,
    this.description,
    this.profilePictureUrl,
    required this.members,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    List<int> membersList = [];
    if (json['members'] != null) {
      if (json['members'] is List) {
        membersList = List<int>.from(json['members']);
      } else if (json['members'] is String) {
        // "1,2,3" => [1,2,3]
        membersList = (json['members'] as String)
            .split(',')
            .map((e) => int.tryParse(e.trim()) ?? 0)
            .where((e) => e != 0)
            .toList();
      }
    }
    return GroupModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      profilePictureUrl: json['profilePictureUrl'],
      members: membersList,
    );
  }
}
