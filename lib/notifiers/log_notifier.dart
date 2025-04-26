import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plugin_integrator/models/models.dart';

final logNotifierProvider = NotifierProvider<LogNotifier, List<LogEntry>>(
  LogNotifier.new,
);

class LogNotifier extends Notifier<List<LogEntry>> {
  @override
  List<LogEntry> build() => [];

  void log(String message, LogLevel level) {
    state = [
      ...state,
      LogEntry(message: message, level: level, timestamp: DateTime.now()),
    ];
  }

  void clearLogs() => state = [];
}
