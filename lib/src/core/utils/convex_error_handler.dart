import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

/// Shared Convex error handler mixin.
///
/// Usage in repositories:
/// ```dart
/// void _handleError(Object error, Ref ref) =>
///     handleConvexError(error, ref);
/// ```
void handleConvexError(Object error, Ref ref) {
  final msg = error.toString().toLowerCase();
  if (msg.contains('unauthorized') || msg.contains('401') ||
      msg.contains('not authenticated') || msg.contains('unauthenticated')) {
    ref.read(authNotifierProvider.notifier).handleUnauthorized();
  }
}
