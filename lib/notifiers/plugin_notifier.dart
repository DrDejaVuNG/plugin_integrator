import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plugin_integrator/models/models.dart';
import 'package:plugin_integrator/notifiers/notifiers.dart';

final apiKeyProvider = StateProvider<String>((ref) => '');
final skipApiKeyProvider = StateProvider<bool>((ref) => true);

final pluginNotifierProvider = NotifierProvider<PluginNotifier, PluginConfig?>(
  PluginNotifier.new,
);

class PluginNotifier extends Notifier<PluginConfig?> {
  @override
  PluginConfig? build() => null;

  final apiKeyTextController = TextEditingController();

  String get apiKey => ref.read(apiKeyProvider);
  bool get skipApiKey => ref.read(skipApiKeyProvider);

  void setApiKey(String value) =>
      ref.read(apiKeyProvider.notifier).state = value;
  void setSkipApiKey(bool value) {
    ref.read(skipApiKeyProvider.notifier).state = value;
    if (value) set(state?.copyWith(requiresApiKey: false));
  }

  void set(PluginConfig? package) {
    ref.read(logNotifierProvider.notifier).clearLogs();
    ref
        .read(integrationStatusProvider.notifier)
        .setStatus(IntegrationStatus.none);
    setApiKey('');
    apiKeyTextController.clear();
    state = package;
    if (package != null) {
      ref
          .read(logNotifierProvider.notifier)
          .log('Selected package: ${package.displayName}', LogLevel.info);
    }
  }
}
