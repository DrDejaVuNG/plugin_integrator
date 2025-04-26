import 'package:plugin_integrator/models/models.dart';

class PlatformConfig {
  PlatformConfig({required this.fileModifications});

  final List<FileModification> fileModifications;

  factory PlatformConfig.fromJson(Map<String, dynamic> json) {
    return PlatformConfig(
      fileModifications:
          (json['fileModifications'] as List)
              .map((mod) => FileModification.fromJson(mod))
              .toList(),
    );
  }
}
