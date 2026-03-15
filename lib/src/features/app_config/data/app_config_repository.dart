import '../domain/entities/app_config.dart';

/// Abstract interface for fetching remote app configuration.
abstract interface class AppConfigRepository {
  /// Returns the current [AppConfig] from the backend.
  Future<AppConfig> getAppConfig();
}
