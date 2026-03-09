import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/utils/time_format.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../providers/booking_provider.dart';

class BookingConfirmSheet extends ConsumerStatefulWidget {
  const BookingConfirmSheet({
    super.key,
    required this.trainerName,
    required this.selectedDate,
    required this.startTime,
    required this.endTime,
  });

  final String trainerName;
  final DateTime selectedDate;
  final String startTime;
  final String endTime;

  @override
  ConsumerState<BookingConfirmSheet> createState() =>
      _BookingConfirmSheetState();
}

class _BookingConfirmSheetState extends ConsumerState<BookingConfirmSheet> {
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    HapticFeedback.mediumImpact();
    setState(() => _isSubmitting = true);

    try {
      await ref.read(bookingsNotifierProvider.notifier).requestBooking(
            date: DateTime.utc(
              widget.selectedDate.year,
              widget.selectedDate.month,
              widget.selectedDate.day,
            ),
            startTime: widget.startTime,
            endTime: widget.endTime,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );

      if (!mounted) return;
      Navigator.of(context).pop(true);
      AppSnackbar.success(context, 'Session requested successfully!');
    } catch (e) {
      HapticFeedback.heavyImpact();
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      AppSnackbar.error(context, 'Failed to request session. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr =
        DateFormat('EEEE, MMMM d, y').format(widget.selectedDate);
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
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Text(
            'Confirm Booking',
            style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 20),
          _InfoRow(
            icon: Icons.person_rounded,
            label: 'Trainer',
            value: widget.trainerName,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.calendar_today_rounded,
            label: 'Date',
            value: dateStr,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.access_time_rounded,
            label: 'Time',
            value: timeStr,
          ),
          const SizedBox(height: 20),
          AppTextField(
            label: 'Notes (optional)',
            hint: 'Any special requests or goals for this session...',
            controller: _notesController,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            maxLength: 500,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Request Session',
            onPressed: _isSubmitting ? null : _submit,
            isLoading: _isSubmitting,
            icon: Icons.check_rounded,
          ),
        ],
      ),
    );
  }

}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style:
                    AppTextStyles.label.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMed
                    .copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
