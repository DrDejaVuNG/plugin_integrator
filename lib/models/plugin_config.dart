import 'package:plugin_integrator/models/models.dart';

class PluginConfig {
  PluginConfig({
    required this.id,
    required this.displayName,
    required this.pluginName,
    required this.description,
    required this.version,
    required this.steps,
    this.requiresApiKey = false,
    this.androidConfig,
    this.iosConfig,
    this.exampleCode,
    this.dependencies = const [],
  });

  final String id;
  final String displayName;
  final String pluginName;
  final String description;
  final String version;
  final List<IntegrationStep> steps;
  final bool requiresApiKey;
  final PlatformConfig? androidConfig;
  final PlatformConfig? iosConfig;
  final String? exampleCode;
  final List<String> dependencies;

  factory PluginConfig.fromJson(Map<String, dynamic> json) {
    return PluginConfig(
      id: json['id'],
      displayName: json['displayName'],
      pluginName: json['pluginName'],
      description: json['description'],
      version: json['version'],
      steps:
          (json['steps'] as List)
              .map((step) => IntegrationStep.fromJson(step))
              .toList(),
      requiresApiKey: json['requiresApiKey'] ?? false,
      androidConfig:
          json['androidConfig'] != null
              ? PlatformConfig.fromJson(json['androidConfig'])
              : null,
      iosConfig:
          json['iosConfig'] != null
              ? PlatformConfig.fromJson(json['iosConfig'])
              : null,
      exampleCode:
          json['exampleCode'] != null
              ? List<String>.from(json['exampleCode']).join('\n')
              : null,
      dependencies:
          json['dependencies'] != null
              ? List<String>.from(json['dependencies'])
              : [],
    );
  }
}
