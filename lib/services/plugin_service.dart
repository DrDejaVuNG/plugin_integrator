import 'dart:convert' show json;

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plugin_integrator/models/models.dart';
import 'package:plugin_integrator/notifiers/notifiers.dart';

/// Provider for the [PluginService].
final pluginServiceProvider = Provider((ref) => PluginService(ref));

/// Service responsible for fetching available plugin configurations.
class PluginService {
  /// Creates a [PluginService].
  PluginService(this.ref);

  final Ref ref;

  /// Fetches the list of available plugin configurations from the assets.
  ///
  /// Reads the `AssetManifest.json` to find plugin configuration files
  /// in the `assets/plugins/` directory, decodes them, and returns a list
  /// of [PluginConfig] objects. Logs any errors encountered during loading.
  Future<List<PluginConfig>> getAvailablePlugins() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      // Filter for JSON files in the assets/plugins directory
      final configPaths =
          manifestMap.keys
              .where(
                (path) =>
                    path.startsWith('assets/plugins/') && path.endsWith('.json'),
              )
              .toList();

      final configs = <PluginConfig>[];
      for (final path in configPaths) {
        try {
          final jsonString = await rootBundle.loadString(path);
          final config = PluginConfig.fromJson(json.decode(jsonString));
          configs.add(config);
          ref
              .read(logNotifierProvider.notifier)
              .log("Loaded config for ${config.displayName}", LogLevel.info);
        } catch (e) {
          // Log error for a specific config file and continue with others
          ref
              .read(logNotifierProvider.notifier)
              .log("ERROR loading config $path: $e", LogLevel.error);
          ref
              .read(logNotifierProvider.notifier)
              .log("Skipping failed config", LogLevel.warning);
        }
      }
      return configs;
    } catch (e) {
      // Log error if AssetManifest.json cannot be loaded or decoded
      ref
          .read(logNotifierProvider.notifier)
          .log("ERROR fetching available plugins: $e", LogLevel.error);
      return []; // Return empty list on overall failure
    }
  }
}
