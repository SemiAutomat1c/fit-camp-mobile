import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/convex_provider.dart';

part 'typing_provider.g.dart';

// ---------------------------------------------------------------------------
// TypingNotifier — manages own typing state for a conversation
// ---------------------------------------------------------------------------

@riverpod
class TypingNotifier extends _$TypingNotifier {
  Timer? _clearTimer;

  @override
  bool build(String conversationId) {
    ref.onDispose(() {
      _clearTimer?.cancel();
    });
    return false;
  }

  /// Notifies the backend that the current user is typing.
  ///
  /// Automatically stops typing after 3 seconds of inactivity.
  Future<void> startTyping() async {
    // Reset the auto-clear timer on every keystroke.
    _clearTimer?.cancel();
    _clearTimer = Timer(const Duration(seconds: 3), stopTyping);

    if (state) return; // Already flagged as typing — avoid redundant calls.
    state = true;

    try {
      final client = ref.read(convexClientProvider);
      await client.mutation(
        name: 'chat:setTyping',
        args: {'conversationId': jsonEncode(conversationId)},
      );
    } catch (_) {
      // Best-effort — typing status is non-critical.
    }
  }

  /// Notifies the backend that the current user has stopped typing.
  Future<void> stopTyping() async {
    _clearTimer?.cancel();
    if (!state) return;
    state = false;

    try {
      final client = ref.read(convexClientProvider);
      await client.mutation(
        name: 'chat:clearTyping',
        args: {'conversationId': jsonEncode(conversationId)},
      );
    } catch (_) {
      // Best-effort.
    }
  }
}

// ---------------------------------------------------------------------------
// isOtherTypingProvider — polls whether the other participant is typing
// ---------------------------------------------------------------------------

@riverpod
Future<bool> isOtherTyping(
  Ref ref,
  String conversationId,
) async {
  ref.keepAlive();

  final timer = Timer.periodic(const Duration(seconds: 3), (_) {
    ref.invalidateSelf();
  });
  ref.onDispose(timer.cancel);

  final client = ref.read(convexClientProvider);
  try {
    final raw = await client.query(
      'mobile:getTypingStatus',
      {'conversationId': jsonEncode(conversationId)},
    );
    // The Convex SDK returns a String — parse it.
    final decoded = jsonDecode(raw);
    if (decoded is bool) return decoded;
    return false;
  } catch (_) {
    return false;
  }
}
