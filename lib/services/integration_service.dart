import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:plugin_integrator/models/models.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

typedef LogCallback = void Function(String message, LogLevel level);

class IntegrationService {
  Future<void> integratePlugin({
    required PluginConfig pluginConfig,
    required String projectPath,
    required String apiKey,
    required LogCallback logger,
  }) async {
    // Process each integration step
    for (final step in pluginConfig.steps) {
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

        case StepType.updateManifest:
          await _updateAndroidManifest(
            projectPath: projectPath,
            content: step.params['content'].replaceAll('{API_KEY}', apiKey),
            insertBefore: step.params['insertBefore'],
            logger: logger,
          );
          break;

        case StepType.updateInfoPlist:
          await _updateInfoPlist(
            projectPath: projectPath,
            content: step.params['content'].replaceAll('{API_KEY}', apiKey),
            insertBefore: step.params['insertBefore'],
            logger: logger,
          );
          break;

        case StepType.updateAppDelegate:
          await _updateAppDelegate(
            projectPath: projectPath,
            importStatements: step.params['importStatements'],
            initCode: step.params['initCode'].replaceAll('{API_KEY}', apiKey),
            logger: logger,
          );
          break;

        case StepType.updateBuildGradle:
          await _updateBuildGradle(
            projectPath: projectPath,
            pattern: step.params['pattern'],
            replacement: step.params['replacement'],
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

    // Add example code if available
    if (pluginConfig.exampleCode != null &&
        pluginConfig.exampleCode!.isNotEmpty) {
      await _addExampleCode(
        projectPath: projectPath,
        exampleCode: pluginConfig.exampleCode!,
        logger: logger,
      );
    }

    // Run flutter pub get
    await _runFlutterPubGet(projectPath, logger);
  }

  Future<void> _addDependency({
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
          return;
        }
      } catch (e) {
        // Section might exist but be empty
      }

      // Add plugin
      yamlEditor.update([section, dependency], version);
      pubspecFile.writeAsStringSync(yamlEditor.toString());

      logger(
        'Added $dependency:$version to $section in pubspec.yaml',
        LogLevel.success,
      );
    } catch (e) {
      logger('Failed to add dependency: $e', LogLevel.error);
      rethrow;
    }
  }

  Future<void> _updateAndroidManifest({
    required String projectPath,
    required String content,
    required String insertBefore,
    required LogCallback logger,
  }) async {
    try {
      final manifestPath = path.join(
        projectPath,
        'android',
        'app',
        'src',
        'main',
        'AndroidManifest.xml',
      );

      final manifestFile = File(manifestPath);
      if (!manifestFile.existsSync()) {
        throw 'AndroidManifest.xml not found at $manifestPath';
      }

      String manifestContent = manifestFile.readAsStringSync();

      // Check if content already exists
      if (manifestContent.contains(content)) {
        logger('Content already exists in AndroidManifest.xml', LogLevel.info);
        return;
      }

      // Insert content
      manifestContent = manifestContent.replaceFirst(
        insertBefore,
        '$content\n    $insertBefore',
      );

      manifestFile.writeAsStringSync(manifestContent);

      logger('Updated AndroidManifest.xml successfully', LogLevel.success);
    } catch (e) {
      logger('Failed to update AndroidManifest.xml: $e', LogLevel.error);
      rethrow;
    }
  }

  Future<void> _updateInfoPlist({
    required String projectPath,
    required String content,
    required String insertBefore,
    required LogCallback logger,
  }) async {
    try {
      final infoPlistPath = path.join(
        projectPath,
        'ios',
        'Runner',
        'Info.plist',
      );

      final infoPlistFile = File(infoPlistPath);
      if (!infoPlistFile.existsSync()) {
        throw 'Info.plist not found at $infoPlistPath';
      }

      String plistContent = infoPlistFile.readAsStringSync();

      // Check if content already exists
      if (plistContent.contains(content)) {
        logger('Content already exists in Info.plist', LogLevel.info);
        return;
      }

      // Insert content
      plistContent = plistContent.replaceFirst(
        insertBefore,
        '$content\n$insertBefore',
      );

      infoPlistFile.writeAsStringSync(plistContent);

      logger('Updated Info.plist successfully', LogLevel.success);
    } catch (e) {
      logger('Failed to update Info.plist: $e', LogLevel.error);
      rethrow;
    }
  }

  Future<void> _updateAppDelegate({
    required String projectPath,
    required String importStatements,
    required String initCode,
    required LogCallback logger,
  }) async {
    try {
      final appDelegatePath = path.join(
        projectPath,
        'ios',
        'Runner',
        'AppDelegate.swift',
      );

      final appDelegateFile = File(appDelegatePath);
      if (!appDelegateFile.existsSync()) {
        throw 'AppDelegate.swift not found at $appDelegatePath';
      }

      String appDelegateContent = appDelegateFile.readAsStringSync();

      // Check if import already exists
      if (!appDelegateContent.contains(importStatements)) {
        // Add import
        appDelegateContent = appDelegateContent.replaceFirst(
          'import UIKit',
          'import UIKit\n$importStatements',
        );
      }

      // Check if initialization code already exists
      if (!appDelegateContent.contains(initCode)) {
        // Add initialization code
        appDelegateContent = appDelegateContent.replaceFirst(
          'GeneratedPluginRegistrant.register(with: self)',
          '$initCode\n        GeneratedPluginRegistrant.register(with: self)',
        );
      }

      appDelegateFile.writeAsStringSync(appDelegateContent);

      logger('Updated AppDelegate.swift successfully', LogLevel.success);
    } catch (e) {
      logger('Failed to update AppDelegate.swift: $e', LogLevel.error);
      rethrow;
    }
  }

  Future<void> _updateBuildGradle({
    required String projectPath,
    required String pattern,
    required String replacement,
    required LogCallback logger,
  }) async {
    try {
      final buildGradlePath = path.join(
        projectPath,
        'android',
        'app',
        'build.gradle',
      );

      final buildGradleFile = File(buildGradlePath);
      if (!buildGradleFile.existsSync()) {
        throw 'build.gradle not found at $buildGradlePath';
      }

      String buildGradleContent = buildGradleFile.readAsStringSync();

      // Check if pattern exists
      final regex = RegExp(pattern);
      if (!regex.hasMatch(buildGradleContent)) {
        logger(
          'Pattern "$pattern" not found in build.gradle',
          LogLevel.warning,
        );
        return;
      }

      // Replace pattern
      buildGradleContent = buildGradleContent.replaceFirst(regex, replacement);

      buildGradleFile.writeAsStringSync(buildGradleContent);

      logger('Updated build.gradle successfully', LogLevel.success);
    } catch (e) {
      logger('Failed to update build.gradle: $e', LogLevel.error);
      rethrow;
    }
  }

  Future<void> _createFile({
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

      // Write content to file
      await file.writeAsString(content);

      logger('Created file at $filePath', LogLevel.success);
    } catch (e) {
      logger('Failed to create file: $e', LogLevel.error);
      rethrow;
    }
  }

  Future<void> _runCommand({
    required String projectPath,
    required String command,
    required List<dynamic> args,
    required LogCallback logger,
  }) async {
    try {
      final List<String> arguments = args.map((arg) => arg.toString()).toList();

      logger('Running command: $command ${arguments.join(' ')}', LogLevel.info);

      final result = await Process.run(
        command,
        arguments,
        workingDirectory: projectPath,
      );

      if (result.exitCode != 0) {
        throw 'Command failed with exit code ${result.exitCode}:\n${result.stderr}';
      }

      logger('Command completed successfully', LogLevel.success);
      logger('Output: ${result.stdout}', LogLevel.info);
    } catch (e) {
      logger('Failed to run command: $e', LogLevel.error);
      rethrow;
    }
  }

  Future<void> _addExampleCode({
    required String projectPath,
    required String exampleCode,
    required LogCallback logger,
  }) async {
    try {
      // Parse example code to find file paths and content
      final pattern = RegExp(
        r'^\/\/ ((?:[\w.-]+\/)*[\w.-]+\.\w+)\n([\s\S]*?)(?=^\/\/ (?:[\w.-]+\/)*[\w.-]+\.\w+ |$)',
      );
      final matches = pattern.allMatches(exampleCode);

      if (matches.isEmpty) {
        throw 'No files found in example code';
      }

      for (final match in matches) {
        final filePath = match.group(1)!.trim();
        final content = match.group(2)!;

        final fullPath = path.join(projectPath, filePath);

        // Create directory if it doesn't exist
        final directory = path.dirname(fullPath);
        await Directory(directory).create(recursive: true);

        // Backup original file if it exists
        final file = File(fullPath);
        if (file.existsSync()) {
          final backupPath = '$fullPath.backup';
          await file.copy(backupPath);
          logger('Backed up original file to $backupPath', LogLevel.info);
        }

        // Write content to file
        await file.writeAsString(content);

        logger('Created/updated $filePath', LogLevel.success);
      }
    } catch (e) {
      logger('Failed to add example code: $e', LogLevel.error);
      rethrow;
    }
  }

  Future<void> _runFlutterPubGet(String projectPath, LogCallback logger) async {
    try {
      logger('Running flutter pub get...', LogLevel.info);

      final result = await Process.run('flutter', [
        'pub',
        'get',
      ], workingDirectory: projectPath);

      if (result.exitCode != 0) {
        throw 'flutter pub get failed with exit code ${result.exitCode}:\n${result.stderr}';
      }

      logger('flutter pub get completed successfully', LogLevel.success);
    } catch (e) {
      logger('Failed to run flutter pub get: $e', LogLevel.error);
      rethrow;
    }
  }
}
