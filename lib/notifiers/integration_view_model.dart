import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plugin_integrator/models/models.dart';
import 'package:plugin_integrator/notifiers/notifiers.dart';
import 'package:plugin_integrator/services/services.dart';

/// Provider for the current integration status.
final integrationStatusProvider =
    NotifierProvider<IntegrationStatusNotifier, IntegrationStatus>(
      IntegrationStatusNotifier.new,
    );

/// Provider to indicate if the integration process is currently running.
final isIntegratingProvider = NotifierProvider<IsIntegratingNotifier, bool>(
  IsIntegratingNotifier.new,
);

/// Notifier to manage the boolean state indicating if integration is in progress.
class IsIntegratingNotifier extends Notifier<bool> {
  /// Initializes the state to false.
  @override
  bool build() => false;

  /// Sets the integration status.
  void setIntegrating(bool value) => state = value;
}

/// Notifier to manage the current integration status.
class IntegrationStatusNotifier extends Notifier<IntegrationStatus> {
  /// Initializes the state to none.
  @override
  IntegrationStatus build() => IntegrationStatus.none;

  /// Sets the integration status.
  void setStatus(IntegrationStatus status) => state = status;
}

/// Provider for the [IntegrationViewModel].
///
/// Provides the necessary dependencies to the view model.
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
    skipApiKey: ref.watch(skipApiKeyProvider),
  );
});

/// ViewModel responsible for managing the integration process and its state.
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
    required this.skipApiKey,
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
  final bool skipApiKey;

  /// Checks if the integration process can be started.
  ///
  /// Returns true if a valid project is selected, a plugin is selected,
  /// and if an API key is required, it has been provided.
  bool get canStartIntegration {
    // Check if we have all necessary info to start integration
    if (projectPath.isEmpty || !isValidProject) return false;
    if (selectedPlugin == null) return false;
    // If API key is required and the user hasn't chosen to skip, check if API key is provided.
    if (selectedPlugin!.requiresApiKey && apiKey.isEmpty) {
      return false;
    }
    return true;
  }

  /// Starts the plugin integration process.
  ///
  /// Clears previous logs, updates the integration status, and calls the
  /// [IntegrationService] to perform the integration steps. Logs any errors
  /// that occur during the process.
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
