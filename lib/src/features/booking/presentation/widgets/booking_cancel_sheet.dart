import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/utils/time_format.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../providers/booking_provider.dart';

class BookingCancelSheet extends ConsumerStatefulWidget {
  const BookingCancelSheet({
    super.key,
    required this.bookingId,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  final String bookingId;
  final DateTime date;
  final String startTime;
  final String endTime;

  @override
  ConsumerState<BookingCancelSheet> createState() => _BookingCancelSheetState();
}

class _BookingCancelSheetState extends ConsumerState<BookingCancelSheet> {
  bool _isCancelling = false;
  String? _selectedReason;

  static const List<String> _reasons = [
    'Change of plans',
    'Emergency',
    'Scheduling conflict',
    'Other',
  ];

  Future<void> _cancel() async {
    HapticFeedback.mediumImpact();
    setState(() => _isCancelling = true);

    try {
      await ref
          .read(bookingsNotifierProvider.notifier)
          .cancelBooking(widget.bookingId, reason: _selectedReason);

      if (!mounted) return;
      Navigator.of(context).pop(true);
      AppSnackbar.success(context, 'Booking cancelled.');
    } catch (e) {
      HapticFeedback.heavyImpact();
      if (!mounted) return;
      setState(() => _isCancelling = false);
      AppSnackbar.error(
          context, 'Could not cancel booking. Only pending bookings can be cancelled.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEE, MMM d').format(widget.date);
    final timeStr =
        '${formatTime(widget.startTime)} – ${formatTime(widget.endTime)}';

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.elevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: const BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.all(Radius.circular(2)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.error.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cancel_outlined,
              color: AppColors.error,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Cancel Session?',
            style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            '$dateStr · $timeStr',
            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'This action cannot be undone.',
            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Reason chips
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Reason (optional)',
              style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _reasons.map((reason) {
              final selected = _selectedReason == reason;
              return FilterChip(
                label: Text(reason),
                selected: selected,
                onSelected: _isCancelling
                    ? null
                    : (_) => setState(
                          () => _selectedReason =
                              selected ? null : reason,
                        ),
                selectedColor: AppColors.error.withAlpha(30),
                checkmarkColor: AppColors.error,
                side: BorderSide(
                  color: selected ? AppColors.error : AppColors.border,
                  width: selected ? 1.5 : 1,
                ),
                backgroundColor: AppColors.surface,
                labelStyle: AppTextStyles.caption.copyWith(
                  color: selected ? AppColors.error : AppColors.textMuted,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isCancelling ? null : _cancel,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.error.withAlpha(100),
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              child: _isCancelling
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Cancel Booking',
                      style: AppTextStyles.button
                          .copyWith(color: Colors.white),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _isCancelling
                ? null
                : () => Navigator.of(context).pop(false),
            child: Text(
              'Keep It',
              style: AppTextStyles.bodyMed
                  .copyWith(color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
