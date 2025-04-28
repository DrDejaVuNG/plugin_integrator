import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plugin_integrator/models/models.dart';
import 'package:plugin_integrator/notifiers/notifiers.dart';

/// State provider for the API key input.
final apiKeyProvider = StateProvider<String>((ref) => '');

/// State provider to indicate if the API key step should be skipped.
final skipApiKeyProvider = StateProvider<bool>((ref) => true);

/// Notifier provider for the currently selected plugin configuration.
final pluginNotifierProvider = NotifierProvider<PluginNotifier, PluginConfig?>(
  PluginNotifier.new,
);

/// Notifier to manage the state of the selected plugin and related properties.
class PluginNotifier extends Notifier<PluginConfig?> {
  /// Initializes the state to null (no plugin selected).
  @override
  PluginConfig? build() => null;

  /// Text controller for the API key input field.
  final apiKeyTextController = TextEditingController();

  /// Gets the current API key value from the provider.
  String get apiKey => ref.read(apiKeyProvider);

  /// Gets the current value of the skip API key flag from the provider.
  bool get skipApiKey => ref.read(skipApiKeyProvider);

  /// Sets the API key value in the provider.
  void setApiKey(String value) =>
      ref.read(apiKeyProvider.notifier).state = value;

  /// Sets the skip API key flag in the provider.
  ///
  /// If [value] is true, it also updates the current plugin state to not require an API key.
  void setSkipApiKey(bool value) {
    ref.read(skipApiKeyProvider.notifier).state = value;
    if (value) {
      // If skipping, update the current plugin config to not require API key
      set(state?.copyWith(requiresApiKey: false));
    }
  }

  /// Sets the currently selected plugin.
  ///
  /// Clears logs and resets integration status when a new plugin is selected.
  /// Also clears the API key input field.
  void set(PluginConfig? package) {
    ref.read(logNotifierProvider.notifier).clearLogs();
    ref
        .read(integrationStatusProvider.notifier)
        .setStatus(IntegrationStatus.none);
    setApiKey(''); // Clear API key when plugin changes
    apiKeyTextController.clear(); // Clear the text field
    state = package;
    if (package != null) {
      ref
          .read(logNotifierProvider.notifier)
          .log('Selected package: ${package.displayName}', LogLevel.info);
    }
  }
}
