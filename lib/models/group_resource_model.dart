class GroupResourceModel {
  final String fileUrl;
  final String fileName;
  final String type; // should be "image"

  GroupResourceModel({
    required this.fileUrl,
    required this.fileName,
    required this.type,
  });

  factory GroupResourceModel.fromJson(Map<String, dynamic> json) {
    return GroupResourceModel(
      fileUrl: json['fileUrl'] as String,
      fileName: json['fileName'] as String,
      type: json['type'] as String,
    );
  }
}
