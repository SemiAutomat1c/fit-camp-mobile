/// A single progress log entry for a member.
///
/// Plain Dart — no Freezed, no code generation.
class ProgressLog {
  const ProgressLog({
    required this.id,
    required this.memberId,
    required this.date,
    this.weight,
    this.bmi,
    this.notes,
    this.photoUrl,
  });

  final String id;
  final String memberId;
  final DateTime date;
  final double? weight;
  final double? bmi;
  final String? notes;
  final String? photoUrl;

  factory ProgressLog.fromJson(Map<String, dynamic> json) => ProgressLog(
        id: json['_id'] as String,
        memberId: json['memberId'] as String,
        date: DateTime.fromMillisecondsSinceEpoch(
          (json['date'] as num).toInt(),
        ),
        weight: (json['weight'] as num?)?.toDouble(),
        bmi: (json['bmi'] as num?)?.toDouble(),
        notes: json['notes'] as String?,
        photoUrl: json['photoUrl'] as String?,
      );
}
