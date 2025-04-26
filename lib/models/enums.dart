enum IntegrationStatus { none, inProgress, success, failed }

enum LogLevel { info, warning, error, success }

enum StepType {
  addDependency,
  updateManifest,
  updateInfoPlist,
  updateAppDelegate,
  updateBuildGradle,
  createFile,
  runCommand,
}
