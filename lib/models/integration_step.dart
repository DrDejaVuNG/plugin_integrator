import 'package:plugin_integrator/models/models.dart';

/// Represents a single step in the plugin integration process.
class IntegrationStep {
  IntegrationStep({
    required this.type,
    required this.description,
    required this.params,
  });

  /// The type of the integration step.
  final StepType type;

  /// A human-readable description of the step.
  final String description;

  /// A map of parameters required for the step.
  final Map<String, dynamic> params;

  static String _getContent(dynamic content) {
    if (content is List) {
      // Join list of strings into a single string for content parameter
      return List<String>.from(content).join('\n');
    }
    return content.toString();
  }

  FileType get getFileType {
    return FileType.values.firstWhere(
      (e) => e.toString() == 'FileType.${params['file']}',
    );
  }

  /// Creates an [IntegrationStep] instance from a JSON map.
  factory IntegrationStep.fromJson(Map<String, dynamic> json) {
    var content = json['params']['content'];
    if (content != null) {
      json['params']['content'] = _getContent(content);
    }
    return IntegrationStep(
      type: StepType.values.firstWhere(
        (e) => e.toString() == 'StepType.${json['type']}',
        orElse: () => StepType.addDependency, // Default to addDependency
      ),
      description: json['description'],
      params: json['params'] ?? {}, // Handle potentially null params
    );
  }
}
