import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../domain/entities/app_notification.dart';

/// A single notification row in the notification list.
///
/// Unread notifications use [AppColors.elevated] (`#1A1A1A`) as the
/// background; read notifications use [AppColors.surface] (`#111111`).
class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bgColor =
        notification.read ? AppColors.surface : AppColors.elevated;

    return Material(
      color: bgColor,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.primary.withAlpha(20),
        highlightColor: AppColors.primary.withAlpha(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TypeIcon(type: notification.type),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: AppTextStyles.bodyMed
                                .copyWith(color: AppColors.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!notification.read)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 8, top: 4),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      notification.message,
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.textMuted),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _relativeTime(notification.createdAt),
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Returns a human-friendly relative timestamp string.
  static String _relativeTime(DateTime createdAt) {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';

    final todayStart = DateTime(now.year, now.month, now.day);
    final createdDay =
        DateTime(createdAt.year, createdAt.month, createdAt.day);
    final dayDiff = todayStart.difference(createdDay).inDays;

    if (dayDiff == 1) return 'Yesterday';

    // e.g. "Mar 5"
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[createdAt.month - 1]} ${createdAt.day}';
  }
}

// ---------------------------------------------------------------------------
// Type icon
// ---------------------------------------------------------------------------

class _TypeIcon extends StatelessWidget {
  const _TypeIcon({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _bgColor(type),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      alignment: Alignment.center,
      child: Icon(
        _iconForType(type),
        size: 20,
        color: _iconColor(type),
      ),
    );
  }

  static IconData _iconForType(String type) => switch (type) {
        'booking_request' => Icons.calendar_today_rounded,
        'booking_confirmed' => Icons.event_available_rounded,
        'new_message' => Icons.chat_bubble_rounded,
        'training_plan_assigned' => Icons.fitness_center_rounded,
        'diet_plan_assigned' => Icons.restaurant_menu_rounded,
        'subscription_expiring' => Icons.warning_rounded,
        'subscription_expired' => Icons.error_rounded,
        'maintenance_reported' => Icons.build_rounded,
        _ => Icons.notifications_rounded,
      };

  static Color _bgColor(String type) => switch (type) {
        'subscription_expiring' =>
          const Color(0xFFF59E0B).withAlpha(26), // warning tint
        'subscription_expired' =>
          const Color(0xFFEF4444).withAlpha(26), // error tint
        _ => AppColors.primary.withAlpha(26),
      };

  static Color _iconColor(String type) => switch (type) {
        'subscription_expiring' => const Color(0xFFF59E0B),
        'subscription_expired' => const Color(0xFFEF4444),
        _ => AppColors.primary,
      };
}
