class DocumentModel {
  final String id;
  final String name;
  final String description;
  final String type;
  final String extension;
  final int size;
  final String category;
  final String url;
  final String thumbnailUrl;
  final String uploadedBy;
  final String uploadedByName;
  final String departmentId;
  final String departmentName;
  final List<String> tags;
  final bool isPublic;
  final bool isFavorite;
  final int downloadCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  DocumentModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.extension,
    required this.size,
    required this.category,
    required this.url,
    required this.thumbnailUrl,
    required this.uploadedBy,
    required this.uploadedByName,
    required this.departmentId,
    required this.departmentName,
    required this.tags,
    required this.isPublic,
    required this.isFavorite,
    required this.downloadCount,
    required this.createdAt,
    required this.updatedAt,
  });

  String get sizeFormatted {
    if (size <= 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    double sizeDouble = size.toDouble();

    while (sizeDouble >= 1024 && i < suffixes.length - 1) {
      sizeDouble /= 1024;
      i++;
    }

    return '${sizeDouble.toStringAsFixed(1)} ${suffixes[i]}';
  }

  String get fileIcon {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'assets/icons/pdf.svg';
      case 'doc':
      case 'docx':
        return 'assets/icons/word.svg';
      case 'xls':
      case 'xlsx':
        return 'assets/icons/excel.svg';
      case 'ppt':
      case 'pptx':
        return 'assets/icons/powerpoint.svg';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return 'assets/icons/image.svg';
      case 'txt':
        return 'assets/icons/text.svg';
      case 'zip':
      case 'rar':
        return 'assets/icons/archive.svg';
      default:
        return 'assets/icons/file.svg';
    }
  }

  bool get isImage {
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    return imageExtensions.contains(extension.toLowerCase());
  }

  bool get isPdf => extension.toLowerCase() == 'pdf';

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      extension: json['extension'] ?? '',
      size: json['size'] ?? 0,
      category: json['category'] ?? '',
      url: json['url'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      uploadedBy: json['uploadedBy'] ?? '',
      uploadedByName: json['uploadedByName'] ?? '',
      departmentId: json['departmentId'] ?? '',
      departmentName: json['departmentName'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      isPublic: json['isPublic'] ?? false,
      isFavorite: json['isFavorite'] ?? false,
      downloadCount: json['downloadCount'] ?? 0,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'extension': extension,
      'size': size,
      'category': category,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'uploadedBy': uploadedBy,
      'uploadedByName': uploadedByName,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'tags': tags,
      'isPublic': isPublic,
      'isFavorite': isFavorite,
      'downloadCount': downloadCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  DocumentModel copyWith({
    String? id,
    String? name,
    String? description,
    String? type,
    String? extension,
    int? size,
    String? category,
    String? url,
    String? thumbnailUrl,
    String? uploadedBy,
    String? uploadedByName,
    String? departmentId,
    String? departmentName,
    List<String>? tags,
    bool? isPublic,
    bool? isFavorite,
    int? downloadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      extension: extension ?? this.extension,
      size: size ?? this.size,
      category: category ?? this.category,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploadedByName: uploadedByName ?? this.uploadedByName,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      tags: tags ?? this.tags,
      isPublic: isPublic ?? this.isPublic,
      isFavorite: isFavorite ?? this.isFavorite,
      downloadCount: downloadCount ?? this.downloadCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
