import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plugin_integrator/models/models.dart';
import 'package:plugin_integrator/notifiers/notifiers.dart';
import 'package:plugin_integrator/services/services.dart';

final integrationStatusProvider =
    NotifierProvider<IntegrationStatusNotifier, IntegrationStatus>(
      IntegrationStatusNotifier.new,
    );

final isIntegratingProvider = NotifierProvider<IsIntegratingNotifier, bool>(
  IsIntegratingNotifier.new,
);

class IsIntegratingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setIntegrating(bool value) => state = value;
}

class IntegrationStatusNotifier extends Notifier<IntegrationStatus> {
  @override
  IntegrationStatus build() => IntegrationStatus.none;

  void setStatus(IntegrationStatus status) => state = status;
}

final integrationProvider = Provider((ref) {
  final projectNotifier = ref.watch(projectNotifierProvider.notifier);
  final logNotifier = ref.watch(logNotifierProvider.notifier);
  final integrationStatusNotifier = ref.watch(
    integrationStatusProvider.notifier,
  );
  final isIntegratingNotifier = ref.watch(isIntegratingProvider.notifier);

  return IntegrationViewModel(
    ref: ref,
    projectPath: ref.watch(projectNotifierProvider),
    selectedPlugin: ref.watch(pluginNotifierProvider),
    isValidProject: projectNotifier.isValidProject,
    integrationService: IntegrationService(),
    logNotifier: logNotifier,
    integrationStatusNotifier: integrationStatusNotifier,
    isIntegratingNotifier: isIntegratingNotifier,
    apiKey: ref.watch(apiKeyProvider),
  );
});

class IntegrationViewModel {
  IntegrationViewModel({
    required this.ref,
    required this.projectPath,
    required this.selectedPlugin,
    required this.isValidProject,
    required this.integrationService,
    required this.logNotifier,
    required this.integrationStatusNotifier,
    required this.isIntegratingNotifier,
    required this.apiKey,
  });

  final Ref ref;
  final String projectPath;
  final PluginConfig? selectedPlugin;
  final bool isValidProject;
  final IntegrationService integrationService;
  final LogNotifier logNotifier;
  final IntegrationStatusNotifier integrationStatusNotifier;
  final IsIntegratingNotifier isIntegratingNotifier;
  final String apiKey;

  bool get canStartIntegration {
    // Check if we have all necessary info to start integration
    if (projectPath.isEmpty || !isValidProject) return false;
    if (selectedPlugin == null) return false;
    if (selectedPlugin!.requiresApiKey && apiKey.isEmpty) return false;
    return true;
  }

  Future<void> startIntegration() async {
    if (selectedPlugin == null) {
      logNotifier.log('No package selected', LogLevel.error);
      return;
    }

    isIntegratingNotifier.setIntegrating(true);
    integrationStatusNotifier.setStatus(IntegrationStatus.inProgress);
    logNotifier.clearLogs();
    logNotifier.log(
      'Starting integration of ${selectedPlugin!.displayName}...',
      LogLevel.info,
    );

    try {
      await integrationService.integratePlugin(
        pluginConfig: selectedPlugin!,
        projectPath: projectPath,
        apiKey: apiKey,
        logger: logNotifier.log,
      );

      integrationStatusNotifier.setStatus(IntegrationStatus.success);
      logNotifier.log('Integration completed successfully!', LogLevel.success);
    } catch (e) {
      integrationStatusNotifier.setStatus(IntegrationStatus.failed);
      logNotifier.log('Integration failed: $e', LogLevel.error);
    } finally {
      isIntegratingNotifier.setIntegrating(false);
    }
  }
}
