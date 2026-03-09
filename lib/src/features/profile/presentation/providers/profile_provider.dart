import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/convex_provider.dart';

part 'profile_provider.g.dart';

/// Fetches the current user's fitness profile from Convex.
///
/// Returns `null` if no profile has been created yet (pre-onboarding state).
@riverpod
Future<Map<String, dynamic>?> myProfile(Ref ref) async {
  final client = ref.watch(convexClientProvider);
  final raw = await client.query('mobile:getMyProfile', {});
  if (raw == 'null') return null;
  return jsonDecode(raw) as Map<String, dynamic>;
}

/// Fetches the current user's active subscription from Convex.
///
/// Returns `null` if there is no active subscription on record.
@riverpod
Future<Map<String, dynamic>?> mySubscription(Ref ref) async {
  final client = ref.watch(convexClientProvider);
  final raw = await client.query('mobile:getMySubscription', {});
  if (raw == 'null') return null;
  return jsonDecode(raw) as Map<String, dynamic>;
}
