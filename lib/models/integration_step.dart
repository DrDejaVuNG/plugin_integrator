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

  /// Creates an [IntegrationStep] instance from a JSON map.
  factory IntegrationStep.fromJson(Map<String, dynamic> json) {
    var content = json['params']['content'];
    if (content != null) {
      // Join list of strings into a single string for content parameter
      content = List<String>.from(content);
      json['params']['content'] = content.join("\n");
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
