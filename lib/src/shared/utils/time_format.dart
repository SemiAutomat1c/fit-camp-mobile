/// Formats a "HH:mm" time string into a human-readable 12-hour AM/PM string.
///
/// Examples:
///   '09:00' → '9 AM'
///   '13:30' → '1:30 PM'
///   '00:00' → '12 AM'
String formatTime(String time) {
  final parts = time.split(':');
  final hour = int.parse(parts[0]);
  final min = parts[1];
  final period = hour < 12 ? 'AM' : 'PM';
  final displayHour = hour == 0
      ? 12
      : hour > 12
          ? hour - 12
          : hour;
  return min == '00' ? '$displayHour $period' : '$displayHour:$min $period';
}
