class GroupResourceModel {
  final int id;
  final int groupId;
  final int uploadedById;
  final String fileName;
  final String fileUrl;
  final String type;
  final String? uploadedAt;

  GroupResourceModel({
    required this.id,
    required this.groupId,
    required this.uploadedById,
    required this.fileName,
    required this.fileUrl,
    required this.type,
    this.uploadedAt,
  });

  factory GroupResourceModel.fromJson(Map<String, dynamic> json) {
    return GroupResourceModel(
      id: json['id'],
      groupId: json['groupId'],
      uploadedById: json['uploadedById'],
      fileName: json['fileName'],
      fileUrl: json['fileUrl'],
      type: json['type'],
      uploadedAt: json['uploadedAt'],
    );
  }
}
