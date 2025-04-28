import 'package:flutter/material.dart';
import '../models/plugin_config.dart';

/// A widget for selecting a plugin from a list using a dropdown.
class PluginSelection extends StatelessWidget {
  const PluginSelection({
    super.key,
    required this.plugins,
    required this.selectedPlugin,
    required this.onPluginSelected,
  });

  /// The list of available plugin configurations.
  final List<PluginConfig> plugins;

  /// The currently selected plugin configuration.
  final PluginConfig? selectedPlugin;

  /// A callback function that is called when a plugin is selected.
  ///
  /// Receives the selected [PluginConfig] or null if no plugin is selected.
  final Function(PluginConfig?) onPluginSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Plugin:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          value: selectedPlugin?.id,
          hint: const Text('Select a plugin to integrate'),
          items: [
            for (final plugin in plugins)
              DropdownMenuItem(
                value: plugin.id,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(plugin.displayName),
                    const SizedBox(width: 8),
                    Text(
                      plugin.version,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
          ],
          onChanged: (value) {
            if (value != null) {
              final plugin = plugins.firstWhere((p) => p.id == value);
              onPluginSelected(plugin);
            } else {
              onPluginSelected(null);
            }
          },
        ),
        if (selectedPlugin != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              selectedPlugin!.description,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}
