import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/utils/time_format.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../domain/entities/booking.dart';

/// Booking card with a prominent date block on the left (replaces thin bar).
///
/// Shows:
/// - Date block (day number + month label) in accent color
/// - Trainer avatar + name
/// - Date string + time range
/// - Status badge
/// - Optional notes
class BookingCard extends StatelessWidget {
  const BookingCard({
    super.key,
    required this.booking,
    this.onLongPress,
  });

  final Booking booking;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(booking.status);
    final statusLabel = _statusLabel(booking.status);
    final dayStr = DateFormat('d').format(booking.date);
    final monthStr = DateFormat('MMM').format(booking.date).toUpperCase();
    final timeStr =
        '${formatTime(booking.startTime)} – ${formatTime(booking.endTime)}';

    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Date block — mirrors calendar app conventions
            Container(
              width: 52,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: statusColor.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: statusColor.withAlpha(60), width: 1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dayStr,
                    style: AppTextStyles.heading2.copyWith(
                      color: statusColor,
                      height: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    monthStr,
                    style: AppTextStyles.label.copyWith(
                      color: statusColor,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trainer row with avatar
                  Row(
                    children: [
                      AppAvatar(
                        name: booking.trainerName ?? 'Trainer',
                        size: AppAvatarSize.sm,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          booking.trainerName ?? 'Trainer',
                          style: AppTextStyles.bodyMed
                              .copyWith(color: AppColors.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _StatusBadge(label: statusLabel, color: statusColor),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeStr,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  if (booking.notes != null &&
                      booking.notes!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      booking.notes!,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textMuted),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _statusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return const Color(0xFFF59E0B);
      case BookingStatus.confirmed:
        return AppColors.primary;
      case BookingStatus.completed:
        return const Color(0xFF3B82F6);
      case BookingStatus.cancelled:
        return AppColors.error.withAlpha(153);
    }
  }

  static String _statusLabel(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: const BorderRadius.all(Radius.circular(6)),
        border: Border.all(color: color.withAlpha(77), width: 1),
      ),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(color: color),
      ),
    );
  }
}
