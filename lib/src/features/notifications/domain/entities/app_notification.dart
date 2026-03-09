/// Notification entity for 24 Fit Camp.
///
/// Plain Dart — no Freezed. Maps directly from the Convex
/// `notifications:listForCurrentUser` response.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.read,
    this.data,
    required this.createdAt,
  });

  final String id;
  final String userId;

  /// One of: "booking_request", "booking_confirmed", "new_message",
  /// "training_plan_assigned", "diet_plan_assigned",
  /// "subscription_expiring", "subscription_expired",
  /// "maintenance_reported".
  final String type;

  final String title;
  final String message;
  final bool read;

  /// Optional extra payload (e.g. `{ "bookingId": "..." }`).
  final Map<String, dynamic>? data;

  final DateTime createdAt;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['_id'] as String,
        userId: json['userId'] as String,
        type: json['type'] as String,
        title: json['title'] as String,
        message: json['message'] as String,
        read: json['read'] as bool? ?? false,
        data: json['data'] as Map<String, dynamic>?,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          (json['createdAt'] as num).toInt(),
        ),
      );

  /// Returns a copy with [read] set to `true`.
  AppNotification copyWithRead() => AppNotification(
        id: id,
        userId: userId,
        type: type,
        title: title,
        message: message,
        read: true,
        data: data,
        createdAt: createdAt,
      );
}
