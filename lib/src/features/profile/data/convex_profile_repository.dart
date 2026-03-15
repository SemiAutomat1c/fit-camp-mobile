import 'package:convex_flutter/convex_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/convex_provider.dart';
import '../../../core/utils/convex_error_handler.dart';
import 'profile_repository.dart';

class ConvexProfileRepository implements ProfileRepository {
  const ConvexProfileRepository(this._client, this._ref);

  final ConvexClient _client;
  final Ref _ref;

  @override
  Future<void> deleteAccount() async {
    try {
      await _client.mutation(name: 'users:deleteAccount', args: {});
    } catch (e) {
      handleConvexError(e, _ref);
      rethrow;
    }
  }

  @override
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
    String? goal,
    int? height,
    int? weight,
    int? age,
    String? gender,
  }) async {
    try {
      // Update user fields (name, phone, avatarUrl)
      final userArgs = <String, dynamic>{};
      if (name != null) userArgs['name'] = name;
      if (phone != null) userArgs['phone'] = phone;
      if (avatarUrl != null) userArgs['avatarUrl'] = avatarUrl;
      if (userArgs.isNotEmpty) {
        await _client.mutation(name: 'users:update', args: userArgs);
      }

      // Update profile fields (goal, height, weight, age, gender)
      final profileArgs = <String, dynamic>{};
      if (goal != null) profileArgs['goal'] = goal;
      if (height != null) profileArgs['heightCm'] = height.toString();
      if (weight != null) profileArgs['weightKg'] = weight.toString();
      if (age != null) profileArgs['age'] = age.toString();
      if (gender != null) profileArgs['gender'] = gender;
      if (profileArgs.isNotEmpty) {
        await _client.mutation(
            name: 'mobile:updateMyProfile', args: profileArgs);
      }
    } catch (e) {
      handleConvexError(e, _ref);
      rethrow;
    }
  }
}

final Provider<ProfileRepository> profileRepositoryProvider =
    Provider<ProfileRepository>(
  (ref) => ConvexProfileRepository(
    ref.read(convexClientProvider),
    ref,
  ),
  name: 'profileRepositoryProvider',
);
