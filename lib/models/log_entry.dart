import 'package:plugin_integrator/models/models.dart';

/// Represents a single entry in the integration log.
class LogEntry {
  LogEntry({
    required this.message,
    required this.level,
    required this.timestamp,
  });

  /// The log message.
  final String message;

  /// The severity level of the log entry.
  final LogLevel level;

  /// The time the log entry was created.
  final DateTime timestamp;
}
