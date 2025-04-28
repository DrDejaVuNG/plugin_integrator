import 'package:flutter/material.dart';
import 'package:plugin_integrator/models/models.dart';

/// A widget that displays a console-like view of log entries.
class LogConsole extends StatelessWidget {
  const LogConsole({super.key, required this.logs});

  /// The list of log entries to display.
  final List<LogEntry> logs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Visibility(
        visible: logs.isNotEmpty,
        replacement: const Center(
          child: Text(
            'No logs yet. Start integration to see logs.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        child: ListView.builder(
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      _formatTime(log.timestamp),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                  _buildLogIcon(log.level),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      log.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: switch (log.level) {
                          LogLevel.warning => Colors.orange,
                          LogLevel.error => Colors.red.shade300,
                          LogLevel.success => Colors.green.shade300,
                          _ => Colors.white,
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Formats the timestamp into a HH:mm:ss string.
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}';
  }

  /// Builds an icon widget based on the log level.
  Widget _buildLogIcon(LogLevel level) {
    if (level == LogLevel.success) {
      return const Icon(Icons.check_circle, color: Colors.green, size: 16);
    }
    if (level == LogLevel.warning) {
      return const Icon(Icons.warning, color: Colors.orange, size: 16);
    }
    if (level == LogLevel.error) {
      return Icon(Icons.error, color: Colors.red.shade300, size: 16);
    }
    return const Icon(Icons.info, color: Colors.blue, size: 16);
  }
}
