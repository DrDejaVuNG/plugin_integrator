import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plugin_integrator/models/models.dart';
import 'package:plugin_integrator/notifiers/notifiers.dart';

final apiKeyProvider = StateProvider<String>((ref) => '');

final pluginNotifierProvider = NotifierProvider<PluginNotifier, PluginConfig?>(
  PluginNotifier.new,
);

class PluginNotifier extends Notifier<PluginConfig?> {
  @override
  PluginConfig? build() => null;

  String get apiKey => ref.read(apiKeyProvider);

  void setApiKey(String value) =>
      ref.read(apiKeyProvider.notifier).state = value;

  void set(PluginConfig? package) {
    ref.read(logNotifierProvider.notifier).clearLogs();
    ref
        .read(integrationStatusProvider.notifier)
        .setStatus(IntegrationStatus.none);
    setApiKey('');
    state = package;
    if (package != null) {
      ref
          .read(logNotifierProvider.notifier)
          .log('Selected package: ${package.displayName}', LogLevel.info);
    }
  }
}
