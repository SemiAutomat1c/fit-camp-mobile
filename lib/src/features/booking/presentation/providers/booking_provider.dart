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

  Future<void> cancelBooking(String bookingId, {String? reason}) async {
    final repo = ref.read(bookingRepositoryProvider);
    await repo.cancelMyBooking(bookingId, reason: reason);
    ref.invalidateSelf();
    await future;
  }
}

@riverpod
Future<String?> myTrainerId(MyTrainerIdRef ref) async {
  final repo = ref.watch(bookingRepositoryProvider);
  return repo.getMyTrainerId();
}

@riverpod
Future<List<TrainerSlot>> trainerAvailability(
    TrainerAvailabilityRef ref, String trainerId) async {
  final repo = ref.watch(bookingRepositoryProvider);
  return repo.getTrainerAvailability(trainerId);
}
