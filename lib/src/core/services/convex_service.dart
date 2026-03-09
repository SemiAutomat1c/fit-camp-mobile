import 'package:convex_flutter/convex_flutter.dart';

/// Manages the [ConvexClient] singleton lifecycle.
///
/// Call [initialize] once in [main] before [runApp]. After initialization,
/// access [client] from anywhere via [ConvexService().client] or through
/// [convexClientProvider].
///
/// Replace [deploymentUrl] with the actual Convex deployment URL before
/// shipping to production.
class ConvexService {
  /// The Convex deployment URL.
  ///
  static const String deploymentUrl = 'https://precious-bat-22.convex.cloud';

  /// Initializes the [ConvexClient] singleton.
  ///
  /// Must be called once before accessing [client]. Safe to await in [main].
  static Future<void> initialize() async {
    await ConvexClient.initialize(
      const ConvexConfig(
        deploymentUrl: deploymentUrl,
        clientId: 'fit-camp-flutter',
        operationTimeout: Duration(seconds: 30),
      ),
    );
  }

  /// The initialized [ConvexClient] singleton.
  ///
  /// Throws [StateError] if accessed before [initialize] completes.
  ConvexClient get client => ConvexClient.instance;
}
