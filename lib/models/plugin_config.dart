import 'package:plugin_integrator/models/models.dart';

/// Represents the configuration for a single plugin.
class PluginConfig {
  PluginConfig({
    required this.id,
    required this.displayName,
    required this.pluginName,
    required this.description,
    required this.version,
    required this.steps,
    this.requiresApiKey = false,
    this.dependencies = const [],
  });

  /// A unique identifier for the plugin.
  final String id;

  /// The human-readable name of the plugin.
  final String displayName;

  /// The package name of the plugin on pub.dev.
  final String pluginName;

  /// A brief description of the plugin.
  final String description;

  /// The recommended version of the plugin.
  final String version;

  /// A list of integration steps required for this plugin.
  final List<IntegrationStep> steps;

  /// Indicates if the plugin requires an API key.
  final bool requiresApiKey;

  /// Additional dependencies required by this plugin.
  final List<String> dependencies;

  /// Creates a [PluginConfig] instance from a JSON map.
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
      dependencies:
          json['dependencies'] != null
              ? List<String>.from(json['dependencies'])
              : [],
    );
  }

  /// Creates a copy of this [PluginConfig] with optional new values.
  PluginConfig copyWith({
    String? id,
    String? displayName,
    String? pluginName,
    String? description,
    String? version,
    List<IntegrationStep>? steps,
    bool? requiresApiKey,
    List<String>? dependencies,
  }) {
    return PluginConfig(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      pluginName: pluginName ?? this.pluginName,
      description: description ?? this.description,
      version: version ?? this.version,
      steps: steps ?? this.steps,
      requiresApiKey: requiresApiKey ?? this.requiresApiKey,
      dependencies: dependencies ?? this.dependencies,
    );
  }
}
