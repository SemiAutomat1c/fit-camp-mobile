import 'dart:convert';
import 'package:convex_flutter/convex_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/convex_provider.dart';
import '../../../core/utils/convex_error_handler.dart';
import '../../training/domain/entities/member_summary.dart';
import 'trainer_repository.dart';

class ConvexTrainerRepository implements TrainerRepository {
  const ConvexTrainerRepository(this._client, this._ref);
  final ConvexClient _client;
  final Ref _ref;

  @override
  Future<List<MemberSummary>> getMyMembers() async {
    try {
      final raw = await _client.query('mobile:getMyMembers', {});
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => MemberSummary.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      handleConvexError(e, _ref);
      rethrow;
    }
  }

  @override
  Future<void> checkIn(String bookingId) async {
    try {
      await _client.mutation(
        name: 'bookings:checkIn',
        args: {'bookingId': bookingId},
      );
    } catch (e) {
      handleConvexError(e, _ref);
      rethrow;
    }
  }

  @override
  Future<void> checkOut(String bookingId) async {
    try {
      await _client.mutation(
        name: 'bookings:checkOut',
        args: {'bookingId': bookingId},
      );
    } catch (e) {
      handleConvexError(e, _ref);
      rethrow;
    }
  }
}

final Provider<TrainerRepository> trainerRepositoryProvider =
    Provider<TrainerRepository>(
  (ref) => ConvexTrainerRepository(ref.read(convexClientProvider), ref),
  name: 'trainerRepositoryProvider',
);
