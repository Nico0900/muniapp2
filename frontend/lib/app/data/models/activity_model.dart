enum ActivityType {
  upload,
  download,
  delete,
  share,
  edit,
  view,
}

class ActivityModel {
  final String id;
  final ActivityType type;
  final String title;
  final String description;
  final DateTime timestamp;
  final String userId;
  final String userName;
  final String? documentId;
  final String? departmentId;

  ActivityModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.userId,
    required this.userName,
    this.documentId,
    this.departmentId,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] ?? '',
      type: _parseActivityType(json['type'] ?? 'view'),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      documentId: json['documentId'],
      departmentId: json['departmentId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'userName': userName,
      'documentId': documentId,
      'departmentId': departmentId,
    };
  }

  static ActivityType _parseActivityType(String type) {
    switch (type.toLowerCase()) {
      case 'upload':
        return ActivityType.upload;
      case 'download':
        return ActivityType.download;
      case 'delete':
        return ActivityType.delete;
      case 'share':
        return ActivityType.share;
      case 'edit':
        return ActivityType.edit;
      case 'view':
        return ActivityType.view;
      default:
        return ActivityType.view;
    }
  }
}
