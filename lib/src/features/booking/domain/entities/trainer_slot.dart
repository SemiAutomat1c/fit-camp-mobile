class TrainerSlot {
  const TrainerSlot({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  final String id;
  final int dayOfWeek; // 0=Sunday, 6=Saturday
  final String startTime; // "09:00"
  final String endTime; // "12:00"

  factory TrainerSlot.fromJson(Map<String, dynamic> json) {
    return TrainerSlot(
      id: json['_id'] as String,
      dayOfWeek: (json['dayOfWeek'] as num).toInt(),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
    );
  }

  /// Generate 1-hour slot intervals from this availability window.
  /// e.g., 09:00-12:00 → [09:00-10:00, 10:00-11:00, 11:00-12:00]
  List<({String start, String end})> generateHourlySlots() {
    final startParts = startTime.split(':');
    final endParts = endTime.split(':');
    final int startHour = int.parse(startParts[0]);
    final int startMin = int.parse(startParts[1]);
    final int endHour = int.parse(endParts[0]);
    final int endMin = int.parse(endParts[1]);

    final slots = <({String start, String end})>[];
    int currentHour = startHour;
    int currentMin = startMin;

    while (currentHour < endHour ||
        (currentHour == endHour && currentMin < endMin)) {
      final nextHour = currentHour + 1;
      // Stop if the next hour slot would exceed the availability window.
      if (nextHour > endHour || (nextHour == endHour && currentMin > endMin)) {
        break;
      }

      final start =
          '${currentHour.toString().padLeft(2, '0')}:${currentMin.toString().padLeft(2, '0')}';
      final end =
          '${nextHour.toString().padLeft(2, '0')}:${currentMin.toString().padLeft(2, '0')}';
      slots.add((start: start, end: end));
      currentHour = nextHour;
    }
    return slots;
  }
}
