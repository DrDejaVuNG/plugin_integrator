import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plugin_integrator/models/models.dart';
import 'package:plugin_integrator/notifiers/notifiers.dart';
import 'package:plugin_integrator/services/services.dart';
import 'package:plugin_integrator/ui/ui.dart';

final availablePluginsProvider = FutureProvider<List<PluginConfig>>((
  ref,
) async {
  final pluginService = ref.watch(pluginServiceProvider);
  return await pluginService.getAvailablePlugins();
});

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  Future<void> _selectDirectory(WidgetRef ref) async {
    String? directoryPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select Flutter Project',
    );

    if (directoryPath != null) {
      ref.read(projectNotifierProvider.notifier).set(directoryPath);
    }
  }

  Future<void> _startIntegration(WidgetRef ref) async {
    final notifier = ref.read(integrationProvider);

    if (ref.read(projectNotifierProvider).isEmpty) {
      ref
          .read(logNotifierProvider.notifier)
          .log('Please select a Flutter project first', LogLevel.error);
      return;
    }

    if (ref.read(pluginNotifierProvider) == null) {
      ref
          .read(logNotifierProvider.notifier)
          .log('Please select a plugin to integrate', LogLevel.error);
      return;
    }

    await notifier.startIntegration();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectPath = ref.watch(projectNotifierProvider);
    final isValidProject =
        ref.watch(projectNotifierProvider.notifier).isValidProject;
    final selectedPlugin = ref.watch(pluginNotifierProvider);
    final logs = ref.watch(logNotifierProvider);
    final integrationStatus = ref.watch(integrationStatusProvider);
    final isIntegrating = ref.watch(isIntegratingProvider);
    final pluginsAsync = ref.watch(availablePluginsProvider);
    final notifier = ref.watch(integrationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Plugin Integrator')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProjectSelector(
              projectPath: projectPath,
              onSelectProject: () => _selectDirectory(ref),
              isValid: isValidProject,
            ),
            const SizedBox(height: 24),
            pluginsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error loading plugins: $err'),
              data:
                  (plugins) => PluginSelection(
                    plugins: plugins,
                    selectedPlugin: selectedPlugin,
                    onPluginSelected:
                        ref.read(pluginNotifierProvider.notifier).set,
                  ),
            ),
            const SizedBox(height: 24),
            if (selectedPlugin?.requiresApiKey == true)
              Visibility(
                visible: !notifier.skipApiKey, // ask first
                replacement: Row(
                  children: [
                    Text("Do you want to add an API Key?"),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed:
                          () => ref
                              .read(pluginNotifierProvider.notifier)
                              .setSkipApiKey(false),
                      child: Text("Yes"),
                    ),
                    const SizedBox(width: 5),
                    ElevatedButton(
                      onPressed:
                          () => ref
                              .read(pluginNotifierProvider.notifier)
                              .setSkipApiKey(true),
                      child: Text("Skip"),
                    ),
                  ],
                ),
                child: TextField(
                  controller:
                      ref
                          .read(pluginNotifierProvider.notifier)
                          .apiKeyTextController,
                  decoration: InputDecoration(
                    labelText: 'API Key for ${selectedPlugin?.displayName}',
                    hintText: 'Enter your API key',
                    border: const OutlineInputBorder(),
                  ),
                  onChanged:
                      ref.read(pluginNotifierProvider.notifier).setApiKey,
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed:
                  isIntegrating || !notifier.canStartIntegration
                      ? null
                      : () => _startIntegration(ref),
              icon: const Icon(Icons.integration_instructions),
              label: const Text('Start Integration'),
            ),
            const SizedBox(height: 24),
            StatusWidget(status: integrationStatus),
            const SizedBox(height: 16),
            const Divider(),
            const Text(
              'Integration Logs:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(child: LogConsole(logs: logs)),
          ],
        ),
      ),
    );
  }
}
