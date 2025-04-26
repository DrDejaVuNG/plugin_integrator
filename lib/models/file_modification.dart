class FileModification {
  FileModification({
    required this.path,
    required this.content,
    required this.insertBefore,
    this.insertAfter,
  });

  final String path;
  final String content;
  final String insertBefore;
  final String? insertAfter;

  factory FileModification.fromJson(Map<String, dynamic> json) {
    return FileModification(
      path: json['path'],
      content: json['content'],
      insertBefore: json['insertBefore'],
      insertAfter: json['insertAfter'],
    );
  }
}
