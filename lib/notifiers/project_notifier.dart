import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:plugin_integrator/models/enums.dart';
import 'package:plugin_integrator/notifiers/notifiers.dart';

/// Notifier provider for the currently selected project path.
final projectNotifierProvider = NotifierProvider<ProjectNotifier, String>(
  ProjectNotifier.new,
);

/// Notifier to manage the state of the selected project path and its validity.
class ProjectNotifier extends Notifier<String> {
  /// Initializes the state with an empty string (no project selected).
  @override
  String build() => '';

  /// Indicates whether the currently selected path is a valid Flutter project.
  bool isValidProject = false;

  /// Sets the selected project path and validates it.
  ///
  /// Clears logs, resets plugin selection and integration status when a new
  /// project path is set. Updates [isValidProject] based on the validation result.
  void set(String path) async {
    ref.read(logNotifierProvider.notifier).clearLogs();
    ref.read(pluginNotifierProvider.notifier).set(null); // Clear selected plugin
    ref
        .read(integrationStatusProvider.notifier)
        .setStatus(IntegrationStatus.none); // Reset integration status
    isValidProject = await _validateFlutterProject(path);
    state = path;
    if (isValidProject) {
      ref
          .read(logNotifierProvider.notifier)
          .log('Selected valid Flutter project at: $path', LogLevel.success);
    } else {
      ref
          .read(logNotifierProvider.notifier)
          .log(
            'Invalid Flutter project at: $path. Please select a valid Flutter project.',
            LogLevel.error,
          );
    }
  }

  /// Validates if the given path is a valid Flutter project directory.
  ///
  /// Checks for the existence of a `pubspec.yaml` file in the root of the directory.
  /// Returns true if `pubspec.yaml` exists, false otherwise.
  Future<bool> _validateFlutterProject(String projectPath) async {
    File pubspecFile = File(path.join(projectPath, 'pubspec.yaml'));
    return pubspecFile.exists();
  }
}
