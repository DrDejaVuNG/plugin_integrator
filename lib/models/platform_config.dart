import 'package:plugin_integrator/models/models.dart';

/// Represents platform-specific configuration for a plugin (e.g., Android or iOS).
class PlatformConfig {
  PlatformConfig({required this.fileModifications});

  /// A list of file modifications specific to this platform.
  final List<FileModification> fileModifications;

  /// Creates a [PlatformConfig] instance from a JSON map.
  factory PlatformConfig.fromJson(Map<String, dynamic> json) {
    return PlatformConfig(
      fileModifications:
          (json['fileModifications'] as List)
              .map((mod) => FileModification.fromJson(mod))
              .toList(),
    );
  }
}
