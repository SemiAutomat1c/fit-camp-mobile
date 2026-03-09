enum BookingStatus { pending, confirmed, cancelled, completed }

class Booking {
  const Booking({
    required this.id,
    required this.memberId,
    required this.trainerId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.trainerName,
    this.trainerAvatarUrl,
  });

  final String id;
  final String memberId;
  final String trainerId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final BookingStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? trainerName;
  final String? trainerAvatarUrl;

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['_id'] as String,
      memberId: json['memberId'] as String,
      trainerId: json['trainerId'] as String,
      date: DateTime.fromMillisecondsSinceEpoch((json['date'] as num).toInt()),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      status: BookingStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => BookingStatus.pending,
      ),
      notes: json['notes'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
          (json['createdAt'] as num).toInt()),
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (json['updatedAt'] as num).toInt())
          : null,
      trainerName:
          (json['trainer'] as Map<String, dynamic>?)?['name'] as String?,
      trainerAvatarUrl:
          (json['trainer'] as Map<String, dynamic>?)?['avatarUrl'] as String?,
    );
  }
}
