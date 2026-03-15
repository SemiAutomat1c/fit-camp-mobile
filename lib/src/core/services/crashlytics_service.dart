import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Thin wrapper around Firebase Crashlytics for error reporting.
///
/// All methods are no-ops in debug mode to avoid polluting the dashboard.
class CrashlyticsService {
  static final CrashlyticsService _instance = CrashlyticsService._();
  CrashlyticsService._();
  factory CrashlyticsService() => _instance;

  FirebaseCrashlytics get _crashlytics => FirebaseCrashlytics.instance;

  Future<void> initialize() async {
    if (kDebugMode) return;
    await _crashlytics.setCrashlyticsCollectionEnabled(true);
    FlutterError.onError = (details) {
      _crashlytics.recordFlutterFatalError(details);
    };
  }

  void recordError(Object error, StackTrace? stack, {bool fatal = false}) {
    if (kDebugMode) return;
    _crashlytics.recordError(error, stack, fatal: fatal);
  }

  void log(String message) {
    if (kDebugMode) return;
    _crashlytics.log(message);
  }

  Future<void> setUserId(String id) async {
    if (kDebugMode) return;
    await _crashlytics.setUserIdentifier(id);
  }

  Future<void> setCustomKey(String key, dynamic value) async {
    if (kDebugMode) return;
    await _crashlytics.setCustomKey(key, value.toString());
  }
}
