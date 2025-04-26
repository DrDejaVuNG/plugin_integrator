import 'package:plugin_integrator/models/models.dart';

class IntegrationStep {
  IntegrationStep({
    required this.type,
    required this.description,
    required this.params,
  });

  final StepType type;
  final String description;
  final Map<String, dynamic> params;

  factory IntegrationStep.fromJson(Map<String, dynamic> json) {
    var content = json['params']['content'];
    if (content != null) {
      content = List<String>.from(content);
      json['params']['content'] = content.join("\n");
    }
    return IntegrationStep(
      type: StepType.values.firstWhere(
        (e) => e.toString() == 'StepType.${json['type']}',
        orElse: () => StepType.addDependency,
      ),
      description: json['description'],
      params: json['params'] ?? {},
    );
  }
}
