import '../domain/entities/booking.dart';
import '../domain/entities/trainer_slot.dart';

abstract interface class BookingRepository {
  Future<List<Booking>> getMyBookings();
  Future<String> requestBooking({
    required DateTime date,
    required String startTime,
    required String endTime,
    String? notes,
  });
  Future<void> cancelMyBooking(String bookingId);
  Future<List<TrainerSlot>> getTrainerAvailability(String trainerId);
  Future<String?> getMyTrainerId();
}
