import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plugin_integrator/models/models.dart';

/// Provider for the list of log entries.
final logNotifierProvider = NotifierProvider<LogNotifier, List<LogEntry>>(
  LogNotifier.new,
);

/// Notifier to manage the list of log entries.
class LogNotifier extends Notifier<List<LogEntry>> {
  /// Initializes the state with an empty list of log entries.
  @override
  List<LogEntry> build() => [];

  /// Adds a new log entry to the list.
  ///
  /// [message]: The log message.
  /// [level]: The severity level of the log entry.
  void log(String message, LogLevel level) {
    state = [
      ...state,
      LogEntry(message: message, level: level, timestamp: DateTime.now()),
    ];
  }

  /// Clears all log entries from the list.
  void clearLogs() => state = [];
}
