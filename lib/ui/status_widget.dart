import 'package:flutter/material.dart';
import 'package:plugin_integrator/models/models.dart';

/// A widget that displays the current integration status with an icon and text.
class StatusWidget extends StatelessWidget {
  const StatusWidget({super.key, required this.status});

  /// The current integration status.
  final IntegrationStatus status;

  @override
  Widget build(BuildContext context) {
    // Hide the widget if the status is none
    if (status == IntegrationStatus.none) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getStatusColor(status)),
      ),
      child: Row(
        children: [
          _getStatusIcon(status),
          const SizedBox(width: 12),
          Expanded( // Use Expanded to prevent text overflow
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  switch (status) {
                    IntegrationStatus.inProgress => 'Integration in Progress',
                    IntegrationStatus.success => 'Integration Successful',
                    IntegrationStatus.failed => 'Integration Failed',
                    _ => '', // Should not happen if status is not none
                  },
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(status),
                  ),
                ),
                Text(switch (status) {
                  IntegrationStatus.inProgress =>
                    'Please wait while we integrate the plugin...',
                  IntegrationStatus.success =>
                    'Plugin has been successfully integrated into your project!',
                  IntegrationStatus.failed =>
                    'Something went wrong. Please check the logs for details.',
                  _ => '', // Should not happen
                }, style: TextStyle(color: Colors.grey.shade700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Returns an icon widget based on the integration status.
  ///
  /// Displays a CircularProgressIndicator for in-progress status,
  /// and icons for success and failed statuses.
  Widget _getStatusIcon(IntegrationStatus status) {
    Color color = _getStatusColor(status);

    if (status == IntegrationStatus.inProgress) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }
    return Icon(
      switch (status) {
        IntegrationStatus.success => Icons.check_circle,
        IntegrationStatus.failed => Icons.error,
        _ => Icons.info, // Default icon for other statuses (though none is hidden)
      },
      color: color,
      size: 24,
    );
  }

  /// Returns a color based on the integration status.
  Color _getStatusColor(IntegrationStatus status) {
    return switch (status) {
      IntegrationStatus.inProgress => Colors.blue,
      IntegrationStatus.success => Colors.green,
      IntegrationStatus.failed => Colors.red,
      _ => Colors.grey, // Default color for none status (though hidden)
    };
  }
}
