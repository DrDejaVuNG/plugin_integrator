/// Represents the different types of integration files that can be edited.
enum FileType {
  /// The AndroidManifest.xml file.
  androidManifest,

  /// The Info.plist file for iOS.
  infoPlist,

  /// The AppDelegate.swift file for iOS.
  appDelegate,

  /// The build.gradle file for Android.
  buildGradle,
  /// The build.gradle.kts file for Android.
  buildGradleKts,
}

/// Represents the different statuses of the plugin integration process.
enum IntegrationStatus {
  /// No integration process is currently active.
  none,

  /// The integration process is currently running.
  inProgress,

  /// The integration process completed successfully.
  success,

  /// The integration process failed.
  failed,
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
  success,
}

/// Represents the different types of integration steps that can be performed.
enum StepType {
  /// Adds a dependency to the `pubspec.yaml` file.
  addDependency,

  /// Replaces an identified pattern with the specified content in the file.
  replacePattern,

  /// Updates a file with the specified content.
  updateFile,

  /// Replace a pattern if available or update a file with the given content.
  replaceOrUpdate,

  /// Creates a new file with the specified content.
  createFile,

  /// Runs a command-line process.
  runCommand,
}
