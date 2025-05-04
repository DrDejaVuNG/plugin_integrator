import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:plugin_integrator/models/models.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

/// Typedef for a logging function used by the integration service.
typedef LogCallback = void Function(String message, LogLevel level);

/// Service responsible for performing the plugin integration steps.
class IntegrationService {
  Future<void> integratePlugin({
    required PluginConfig pluginConfig,
    required String projectPath,
    required String apiKey,
    required bool skipApiKey,
    required LogCallback logger,
  }) async {
    // Process each integration step
    for (final step in pluginConfig.steps) {
      if (step.params.containsKey('content') &&
          step.params['content'].contains('{API_KEY}') &&
          skipApiKey) {
        continue;
      }
      logger('Processing step: ${step.description}', LogLevel.info);

      switch (step.type) {
        case StepType.addDependency:
          await _addDependency(
            projectPath: projectPath,
            dependency: step.params['dependency'],
            version: step.params['version'],
            isDev: step.params['isDev'] ?? false,
            logger: logger,
          );
          break;

        case StepType.updateFile:
          await _updateFile(
            projectPath: projectPath,
            file: step.getFileType,
            content: step.params['content'].replaceAll('{API_KEY}', apiKey),
            insertBefore: step.params['insertBefore'],
            insertAfter: step.params['insertAfter'],
            logger: logger,
          );
          break;

        case StepType.replacePattern:
          await _replacePattern(
            projectPath: projectPath,
            file: step.getFileType,
            pattern: step.params['pattern'],
            replacement: step.params['replacement'],
            logger: logger,
          );
          break;

        case StepType.replaceOrUpdate:
          await _replaceOrUpdate(
            projectPath: projectPath,
            file: step.getFileType,
            pattern: step.params['pattern'],
            content: step.params['content'],
            begin: step.params['begin'],
            end: step.params['end'],
            insertBefore: step.params['insertBefore'],
            logger: logger,
          );
          break;

        case StepType.createFile:
          await _createFile(
            projectPath: projectPath,
            filePath: step.params['filePath'],
            content: step.params['content'],
            logger: logger,
          );
          break;

        case StepType.runCommand:
          await _runCommand(
            projectPath: projectPath,
            command: step.params['command'],
            args: step.params['args'],
            logger: logger,
          );
          break;
      }
    }

    // Run flutter pub get after all steps
    await _runCommand(
      projectPath: projectPath,
      command: 'flutter',
      args: ['pub', 'get'],
      logger: logger,
    );
  }

  String _getPath({required String projectPath, required FileType file}) {
    return switch (file) {
      FileType.androidManifest => path.join(
        projectPath,
        'android',
        'app',
        'src',
        'main',
        'AndroidManifest.xml',
      ),
      FileType.appDelegate => path.join(
        projectPath,
        'ios',
        'Runner',
        'AppDelegate.swift',
      ),
      FileType.buildGradle => path.join(
        projectPath,
        'android',
        'app',
        'build.gradle',
      ),
      FileType.buildGradleKts => path.join(
        projectPath,
        'android',
        'app',
        'build.gradle.kts',
      ),
      FileType.infoPlist => path.join(
        projectPath,
        'ios',
        'Runner',
        'Info.plist',
      ),
    };
  }

  /// Adds a dependency to the `pubspec.yaml` file.
  ///
  /// [projectPath]: The root path of the Flutter project.
  /// [dependency]: The name of the dependency.
  /// [version]: The version constraint for the dependency.
  /// [isDev]: Whether it's a dev dependency.
  /// [logger]: A callback function to log messages.
  Future<bool> _addDependency({
    required String projectPath,
    required String dependency,
    required String version,
    required bool isDev,
    required LogCallback logger,
  }) async {
    try {
      final pubspecPath = path.join(projectPath, 'pubspec.yaml');
      final pubspecFile = File(pubspecPath);

      if (!pubspecFile.existsSync()) {
        throw 'pubspec.yaml not found in $projectPath';
      }

      final pubspecContent = pubspecFile.readAsStringSync();
      final yamlEditor = YamlEditor(pubspecContent);

      // Determine dependencies section to modify
      final String section = isDev ? 'dev_dependencies' : 'dependencies';

      // Check if dependencies section exists
      final yamlDoc = loadYaml(pubspecContent);
      if (yamlDoc[section] == null) {
        // Create the section if it doesn't exist
        yamlEditor.update([section], {});
      }

      // Check if plugin already exists
      try {
        YamlMap dependencies = loadYaml(pubspecContent)[section];
        if (dependencies.containsKey(dependency)) {
          logger('$dependency already exists in pubspec.yaml', LogLevel.info);
          return true; // Dependency already exists, no need to add again
        }
      } catch (e) {
        // Section might exist but be empty
        logger(
          'Warning: Could not check existing dependencies in $section: $e',
          LogLevel.warning,
        );
      }

      // Add plugin
      yamlEditor.update([section, dependency], version);
      pubspecFile.writeAsStringSync(yamlEditor.toString());

      logger(
        'Added $dependency:$version to $section in pubspec.yaml',
        LogLevel.success,
      );
      return true;
    } catch (e) {
      logger('Failed to add dependency: $e', LogLevel.error);
      rethrow;
    }
  }

  /// Updates the specified file.
  ///
  /// Inserts the specified [content] after the [insertAfter] pattern or before the [insertBefore].
  /// [projectPath]: The root path of the Flutter project.
  /// [file]: The specified file type to be updated e.g AndroidManifest.xml.
  /// [content]: The content to insert.
  /// [logger]: A callback function to log messages.
  /// [insertAfter]: The string pattern to insert after.
  /// [insertBefore]: The string pattern to insert before.
  Future<bool> _updateFile({
    required String projectPath,
    required FileType file,
    required String content,
    required LogCallback logger,
    String? insertAfter,
    String? insertBefore,
  }) async {
    assert(insertBefore != null || insertAfter != null);
    final fullPath = _getPath(projectPath: projectPath, file: file);
    final filename = fullPath.split(path.separator).last;
    try {
      final projectFile = File(fullPath);
      if (!projectFile.existsSync()) {
        throw '$filename not found at $fullPath';
      }

      String projectContent = projectFile.readAsStringSync();

      // Check if content already exists
      if (projectContent.contains(content)) {
        logger('Content already exists in $filename', LogLevel.info);
        return true;
      }

      if (insertBefore != null) {
        // Check if pattern exists
        if (!projectContent.contains(insertBefore)) {
          logger('$insertBefore not found in $filename', LogLevel.info);
          return false;
        }
        projectContent = projectContent.replaceFirst(
          insertBefore,
          '$content\n$insertBefore',
        );
      } else {
        // Check if pattern exists
        if (!projectContent.contains(insertAfter!)) {
          logger('$insertAfter not found in $filename', LogLevel.info);
          return false;
        }
        projectContent = projectContent.replaceFirst(
          insertAfter,
          '$insertAfter\n$content',
        );
      }

      projectFile.writeAsStringSync(projectContent);

      logger('Updated $filename successfully', LogLevel.success);
      return true;
    } catch (e) {
      logger('Failed to update $filename: $e', LogLevel.error);
      rethrow;
    }
  }

  /// Updates the specified file.
  ///
  /// Replaces the first occurrence of the [pattern] with the [replacement].
  /// [projectPath]: The root path of the Flutter project.
  /// [file]: The specified file type to be updated e.g AndroidManifest.xml.
  /// [pattern]: The regex pattern to search for.
  /// [replacement]: The string to replace the pattern with.
  /// [logger]: A callback function to log messages.
  Future<bool> _replacePattern({
    required String projectPath,
    required FileType file,
    required String pattern,
    required String replacement,
    required LogCallback logger,
  }) async {
    final fullPath = _getPath(projectPath: projectPath, file: file);
    final filename = fullPath.split(path.separator).last;
    try {
      final projectFile = File(fullPath);
      if (!projectFile.existsSync()) {
        throw '$filename not found at $fullPath';
      }

      String projectContent = projectFile.readAsStringSync();

      // Check if pattern exists
      final regex = RegExp(pattern);
      if (!regex.hasMatch(projectContent)) {
        logger('Pattern "$pattern" not found in $filename', LogLevel.warning);
        return false; // Pattern not found, nothing to replace
      }

      // Replace pattern
      projectContent = projectContent.replaceFirst(regex, replacement);

      projectFile.writeAsStringSync(projectContent);

      logger('Updated $filename successfully', LogLevel.success);
      return true;
    } catch (e) {
      logger('Failed to update $filename: $e', LogLevel.error);
      rethrow;
    }
  }

  Future<bool> _replaceOrUpdate({
    required String projectPath,
    required FileType file,
    required String pattern,
    required String content,
    required String begin,
    required String end,
    required String insertBefore,
    required LogCallback logger,
  }) async {
    final fullPath = _getPath(projectPath: projectPath, file: file);
    final filename = fullPath.split(path.separator).last;
    try {
      final projectFile = File(fullPath);
      if (!projectFile.existsSync()) {
        throw '$filename not found at $fullPath';
      }

      String projectContent = projectFile.readAsStringSync();

      // Check if pattern exists
      final hasMatch = await _replacePattern(
        projectPath: projectPath,
        file: file,
        pattern: pattern,
        replacement: content,
        logger: logger,
      );
      if (hasMatch) return true;

      if (!projectContent.contains(begin)) {
        return _updateFile(
          projectPath: projectPath,
          file: file,
          content: '$begin\n$content\n$end\n\n',
          logger: logger,
          insertBefore: insertBefore,
        );
      }

      projectContent = projectContent.replaceFirst(begin, '$begin\n$content');

      projectFile.writeAsStringSync(projectContent);

      logger('Updated $filename successfully', LogLevel.success);
      return true;
    } catch (e) {
      logger('Failed to update $filename: $e', LogLevel.error);
      rethrow;
    }
  }

  /// Creates a new file with the specified content.
  ///
  /// Creates parent directories if they don't exist.
  /// [projectPath]: The root path of the Flutter project.
  /// [filePath]: The path to the file to create, relative to the project root.
  /// [content]: The content to write to the file.
  /// [logger]: A callback function to log messages.
  Future<bool> _createFile({
    required String projectPath,
    required String filePath,
    required String content,
    required LogCallback logger,
  }) async {
    try {
      final fullPath = path.join(projectPath, filePath);
      final file = File(fullPath);

      // Create directory if it doesn't exist
      final directory = path.dirname(fullPath);
      await Directory(directory).create(recursive: true);

      // Backup original file if it exists
      if (file.existsSync()) {
        final backupPath = '$fullPath.backup';
        await file.copy(backupPath);
        logger('Backed up original file to $backupPath', LogLevel.info);
      }

      // Write content to file
      await file.writeAsString(content);

      logger('Created file at $filePath', LogLevel.success);
      return true;
    } catch (e) {
      logger('Failed to create file at $filePath: $e', LogLevel.error);
      rethrow;
    }
  }

  /// Runs a command-line process within the project directory.
  ///
  /// [projectPath]: The root path of the Flutter project.
  /// [command]: The command to run (e.g., 'flutter').
  /// [args]: A list of arguments for the command.
  /// [logger]: A callback function to log messages.
  Future<bool> _runCommand({
    required String projectPath,
    required String command,
    required List<dynamic> args,
    required LogCallback logger,
  }) async {
    final List<String> arguments = args.map((arg) => arg.toString()).toList();
    final cmd = '$command ${arguments.join(' ')}'.trim();
    try {
      logger('Running command: $cmd', LogLevel.info);

      final result = await Process.run(
        command,
        arguments,
        workingDirectory: projectPath,
        runInShell: true, // Use shell to find command on PATH
      );

      if (result.exitCode != 0) {
        logger('$cmd stdout:\n${result.stdout}', LogLevel.error);
        logger('$cmd stderr:\n${result.stderr}', LogLevel.error);
        throw '$cmd failed with exit code ${result.exitCode}:\n${result.stderr}';
      }

      logger('$cmd result: \n${result.stdout}', LogLevel.info);
      logger('$cmd completed successfully', LogLevel.success);
      return true;
    } catch (e) {
      logger('Failed to run $cmd: $e', LogLevel.error);
      rethrow;
    }
  }
}
