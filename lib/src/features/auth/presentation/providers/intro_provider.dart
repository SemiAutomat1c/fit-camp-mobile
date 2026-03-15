import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/convex_provider.dart';

part 'intro_provider.g.dart';

/// Tracks whether the user has seen the onboarding intro carousel.
///
/// State is a [bool]:
/// - `false` — intro not yet seen (show carousel)
/// - `true` — intro has been seen (skip to login)
@riverpod
class IntroNotifier extends _$IntroNotifier {
  @override
  bool build() => false;

  /// Marks the intro carousel as seen and persists the flag via [StorageService].
  Future<void> markSeen() async {
    final storage = ref.read(storageServiceProvider);
    await storage.saveIntroSeen();
    state = true;
  }
}
