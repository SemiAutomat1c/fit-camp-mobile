/// Remote app configuration returned by the Convex backend.
///
/// Used to gate access based on a minimum required version and to show a
/// maintenance mode screen when the backend is temporarily unavailable.
class AppConfig {
  const AppConfig({
    required this.minimumVersion,
    required this.maintenanceMode,
    this.maintenanceMessage,
  });

  /// Minimum semantic version string the client must be at (e.g. `'2.0.0'`).
  final String minimumVersion;

  /// When true, the app shows [MaintenanceScreen] and blocks all navigation.
  final bool maintenanceMode;

  /// Optional human-readable reason for maintenance. Shown on [MaintenanceScreen].
  final String? maintenanceMessage;
}
