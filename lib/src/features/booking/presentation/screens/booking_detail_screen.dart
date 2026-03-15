import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/app_user.dart';
import '../../../../core/services/convex_provider.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/utils/time_format.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../trainer/presentation/widgets/checkin_sheet.dart';
import '../../domain/entities/booking.dart';
import '../widgets/booking_cancel_sheet.dart';

/// Detail view for a single [Booking].
///
/// Receives the [Booking] object via GoRouter's `extra` parameter.
/// Provides "Cancel Booking" and "Reschedule" actions when applicable.
class BookingDetailScreen extends ConsumerWidget {
  const BookingDetailScreen({
    super.key,
    required this.bookingId,
    required this.booking,
  });

  final String bookingId;
  final Booking booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = _statusColor(booking.status);
    final statusLabel = _statusLabel(booking.status);
    final dateStr =
        DateFormat('EEEE, MMMM d, yyyy').format(booking.date);
    final timeStr =
        '${formatTime(booking.startTime)} – ${formatTime(booking.endTime)}';
    final canAction = booking.status == BookingStatus.pending ||
        booking.status == BookingStatus.confirmed;
    final roleAsync = ref.watch(userRoleProvider);
    final isTrainer = roleAsync.valueOrNull == AppUserRole.trainer ||
        roleAsync.valueOrNull == AppUserRole.admin;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Session Details',
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Trainer section
          _SectionCard(
            child: Row(
              children: [
                AppAvatar(
                  name: booking.trainerName ?? 'Trainer',
                  size: AppAvatarSize.lg,
                  imageUrl: booking.trainerAvatarUrl,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.trainerName ?? 'Trainer',
                        style: AppTextStyles.heading4
                            .copyWith(color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Personal Trainer',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Date & time
          _SectionCard(
            child: Column(
              children: [
                _DetailRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Date',
                  value: dateStr,
                ),
                const Divider(color: AppColors.border, height: 24),
                _DetailRow(
                  icon: Icons.access_time_rounded,
                  label: 'Time',
                  value: timeStr,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Status
          _SectionCard(
            child: _DetailRow(
              icon: Icons.info_outline_rounded,
              label: 'Status',
              value: statusLabel,
              valueColor: statusColor,
              trailing: _StatusBadge(label: statusLabel, color: statusColor),
            ),
          ),

          // Notes
          if (booking.notes != null && booking.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.note_alt_outlined,
                          size: 18, color: AppColors.textMuted),
                      const SizedBox(width: 8),
                      Text(
                        'Notes',
                        style: AppTextStyles.bodyMed
                            .copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    booking.notes!,
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
          ],

          if (canAction && isTrainer) ...[
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _showCheckinSheet(context);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(
                      color: AppColors.primary, width: 1.5),
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                icon: const Icon(
                    Icons.how_to_reg_rounded, size: 20),
                label: Text(
                  'Check In Member',
                  style: AppTextStyles.button
                      .copyWith(color: AppColors.primary),
                ),
              ),
            ),
          ],

          if (canAction) ...[
            const SizedBox(height: 32),
            // Reschedule
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.push(
                    '/booking/reschedule/${booking.id}',
                    extra: booking,
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                icon: const Icon(Icons.event_repeat_rounded, size: 20),
                label: Text(
                  'Reschedule',
                  style: AppTextStyles.button
                      .copyWith(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Cancel
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => _showCancelSheet(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error.withAlpha(20),
                  foregroundColor: AppColors.error,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.all(Radius.circular(12)),
                  ),
                  side: BorderSide(
                      color: AppColors.error.withAlpha(80), width: 1),
                ),
                icon: const Icon(Icons.cancel_outlined, size: 20),
                label: Text(
                  'Cancel Booking',
                  style:
                      AppTextStyles.button.copyWith(color: AppColors.error),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showCheckinSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CheckinSheet(bookingId: booking.id),
    );
  }

  void _showCancelSheet(BuildContext context) {
    HapticFeedback.heavyImpact();
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BookingCancelSheet(
        bookingId: booking.id,
        date: booking.date,
        startTime: booking.startTime,
        endTime: booking.endTime,
      ),
    ).then((cancelled) {
      if (cancelled == true && context.mounted) {
        context.pop();
      }
    });
  }

  static Color _statusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return AppColors.warning;
      case BookingStatus.confirmed:
        return AppColors.primary;
      case BookingStatus.cancelled:
        return AppColors.error;
      case BookingStatus.completed:
        return AppColors.textMuted;
    }
  }

  static String _statusLabel(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.completed:
        return 'Completed';
    }
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMed.copyWith(
                  color: valueColor ?? AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(color: color),
      ),
    );
  }
}
