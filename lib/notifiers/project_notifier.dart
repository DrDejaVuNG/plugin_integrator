import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:plugin_integrator/models/enums.dart';
import 'package:plugin_integrator/notifiers/notifiers.dart';

final projectNotifierProvider = NotifierProvider<ProjectNotifier, String>(
  ProjectNotifier.new,
);

class ProjectNotifier extends Notifier<String> {
  @override
  String build() => '';

  bool isValidProject = false;

  void set(String path) async {
    ref.read(logNotifierProvider.notifier).clearLogs();
    ref.read(pluginNotifierProvider.notifier).set(null);
    ref
        .read(integrationStatusProvider.notifier)
        .setStatus(IntegrationStatus.none);
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

  Future<bool> _validateFlutterProject(String projectPath) async {
    File pubspecFile = File(path.join(projectPath, 'pubspec.yaml'));
    return pubspecFile.exists();
  }
}
