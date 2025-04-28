/// Represents the different statuses of the plugin integration process.
enum IntegrationStatus {
  /// No integration process is currently active.
  none,

  /// The integration process is currently running.
  inProgress,

  /// The integration process completed successfully.
  success,

  /// The integration process failed.
  failed
}

/// Represents the different levels of log entries.
enum LogLevel {
  /// Informational messages.
  info,

  /// Warning messages indicating potential issues.
  warning,

  /// Error messages indicating failures.
  error,

  /// Success messages indicating successful operations.
  success
}

/// Represents the different types of integration steps that can be performed.
enum StepType {
  /// Adds a dependency to the `pubspec.yaml` file.
  addDependency,

  /// Updates the AndroidManifest.xml file.
  updateManifest,

  /// Updates the Info.plist file for iOS.
  updateInfoPlist,

  /// Updates the AppDelegate.swift file for iOS.
  updateAppDelegate,

  /// Updates the build.gradle file for Android.
  updateBuildGradle,

  /// Creates a new file with specified content.
  createFile,

  /// Runs a command-line process.
  runCommand,
}
