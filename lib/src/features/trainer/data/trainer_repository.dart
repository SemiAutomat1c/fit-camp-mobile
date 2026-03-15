import '../../training/domain/entities/member_summary.dart';

abstract interface class TrainerRepository {
  Future<List<MemberSummary>> getMyMembers();
  Future<void> checkIn(String bookingId);
  Future<void> checkOut(String bookingId);
}
