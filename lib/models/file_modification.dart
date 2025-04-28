/// Represents a modification to be made to a file during plugin integration.
class FileModification {
  FileModification({
    required this.path,
    required this.content,
    required this.insertBefore,
    this.insertAfter,
  });

  /// The path to the file to be modified, relative to the project root.
  final String path;

  /// The content to be inserted into the file.
  final String content;

  /// A string pattern to find and insert the content before.
  final String insertBefore;

  /// An optional string pattern to find and insert the content after.
  final String? insertAfter;

  /// Creates a [FileModification] instance from a JSON map.
  factory FileModification.fromJson(Map<String, dynamic> json) {
    return FileModification(
      path: json['path'],
      content: json['content'],
      insertBefore: json['insertBefore'],
      insertAfter: json['insertAfter'],
    );
  }
}
