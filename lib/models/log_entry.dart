import 'package:plugin_integrator/models/models.dart';

class LogEntry {
  LogEntry({
    required this.message,
    required this.level,
    required this.timestamp,
  });

  final String message;
  final LogLevel level;
  final DateTime timestamp;
}
