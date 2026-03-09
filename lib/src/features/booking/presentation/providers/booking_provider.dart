import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/convex_booking_repository.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/trainer_slot.dart';

part 'booking_provider.g.dart';

@riverpod
class BookingsNotifier extends _$BookingsNotifier {
  @override
  Future<List<Booking>> build() async {
    final repo = ref.read(bookingRepositoryProvider);
    return repo.getMyBookings();
  }

  Future<void> requestBooking({
    required DateTime date,
    required String startTime,
    required String endTime,
    String? notes,
  }) async {
    final repo = ref.read(bookingRepositoryProvider);
    await repo.requestBooking(
      date: date,
      startTime: startTime,
      endTime: endTime,
      notes: notes,
    );
    ref.invalidateSelf();
    await future;
  }

  Future<void> cancelBooking(String bookingId) async {
    final repo = ref.read(bookingRepositoryProvider);
    await repo.cancelMyBooking(bookingId);
    ref.invalidateSelf();
    await future;
  }
}

@riverpod
Future<String?> myTrainerId(Ref ref) async {
  final repo = ref.watch(bookingRepositoryProvider);
  return repo.getMyTrainerId();
}

@riverpod
Future<List<TrainerSlot>> trainerAvailability(
    Ref ref, String trainerId) async {
  final repo = ref.watch(bookingRepositoryProvider);
  return repo.getTrainerAvailability(trainerId);
}
