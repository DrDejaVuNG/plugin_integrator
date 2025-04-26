import 'dart:convert' show json;

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plugin_integrator/models/models.dart';
import 'package:plugin_integrator/notifiers/notifiers.dart';

final pluginServiceProvider = Provider((ref) => PluginService(ref));

class PluginService {
  PluginService(this.ref);

  final Ref ref;

  Future<List<PluginConfig>> getAvailablePlugins() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

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
        ref
            .read(logNotifierProvider.notifier)
            .log("ERROR loading config $path: $e", LogLevel.error);
        ref
            .read(logNotifierProvider.notifier)
            .log("Skipping failed config", LogLevel.info);
      }
    }
    return configs;
  }
}
