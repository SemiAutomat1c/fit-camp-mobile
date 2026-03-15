import 'dart:convert';

import 'package:convex_flutter/convex_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/convex_provider.dart';
import '../domain/entities/booking.dart';
import '../domain/entities/trainer_slot.dart';
import 'booking_repository.dart';

class ConvexBookingRepository implements BookingRepository {
  const ConvexBookingRepository(this._client);

  final ConvexClient _client;

  @override
  Future<List<Booking>> getMyBookings() async {
    final result =
        jsonDecode(await _client.query('mobile:getMyBookings', {}))
            as List<dynamic>;
    return result
        .map((e) => Booking.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<String> requestBooking({
    required DateTime date,
    required String startTime,
    required String endTime,
    String? notes,
  }) async {
    final args = <String, dynamic>{
      'date': date.millisecondsSinceEpoch,
      'startTime': startTime,
      'endTime': endTime,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    };
    final result = await _client.mutation(
      name: 'mobile:requestBooking',
      args: args,
    );
    return result;
  }

  @override
  Future<void> cancelMyBooking(String bookingId, {String? reason}) async {
    await _client.mutation(
      name: 'mobile:cancelMyBooking',
      args: {
        'bookingId': bookingId,
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      },
    );
  }

  @override
  Future<List<TrainerSlot>> getTrainerAvailability(String trainerId) async {
    final result = jsonDecode(await _client.query(
      'mobile:getTrainerAvailability',
      {'trainerId': jsonEncode(trainerId)},
    )) as List<dynamic>;
    return result
        .map((e) => TrainerSlot.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<String?> getMyTrainerId() async {
    final result = jsonDecode(
            await _client.query('mobile:getMyProfile', {}))
        as Map<String, dynamic>;
    return result['trainerId'] as String?;
  }
}

final Provider<BookingRepository> bookingRepositoryProvider =
    Provider<BookingRepository>(
  (ref) => ConvexBookingRepository(ref.read(convexClientProvider)),
  name: 'bookingRepositoryProvider',
);
