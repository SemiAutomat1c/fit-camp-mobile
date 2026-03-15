import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../domain/entities/booking.dart';
import '../providers/booking_provider.dart';

/// Three-step reschedule flow:
///
/// Step 1 — Confirm cancellation of the current booking.
/// Step 2 — Pick a new date via [CalendarDatePicker].
/// Step 3 — Enter the desired start/end time and confirm.
class RescheduleBookingScreen extends ConsumerStatefulWidget {
  const RescheduleBookingScreen({
    super.key,
    required this.bookingId,
    required this.booking,
  });

  final String bookingId;
  final Booking booking;

  @override
  ConsumerState<RescheduleBookingScreen> createState() =>
      _RescheduleBookingScreenState();
}

class _RescheduleBookingScreenState
    extends ConsumerState<RescheduleBookingScreen> {
  int _step = 0;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  final TextEditingController _startTimeController =
      TextEditingController(text: '09:00');
  final TextEditingController _endTimeController =
      TextEditingController(text: '10:00');
  bool _isLoading = false;

  @override
  void dispose() {
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final startTime = _startTimeController.text.trim();
    final endTime = _endTimeController.text.trim();

    if (startTime.isEmpty || endTime.isEmpty) {
      AppSnackbar.error(context, 'Please enter both start and end times.');
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      final notifier = ref.read(bookingsNotifierProvider.notifier);
      await notifier.cancelBooking(widget.booking.id);
      await notifier.requestBooking(
        date: _selectedDate,
        startTime: startTime,
        endTime: endTime,
      );

      if (!mounted) return;
      HapticFeedback.mediumImpact();
      AppSnackbar.success(context, 'Session rescheduled successfully.');
      context.pop();
      context.pop(); // pop detail screen too
    } catch (e) {
      HapticFeedback.heavyImpact();
      if (!mounted) return;
      AppSnackbar.error(
          context, 'Failed to reschedule. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Reschedule Session',
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          _StepIndicator(currentStep: _step),
          Expanded(
            child: _step == 0
                ? _Step1(
                    booking: widget.booking,
                    onNext: () => setState(() => _step = 1),
                  )
                : _step == 1
                    ? _Step2(
                        selectedDate: _selectedDate,
                        onDateChanged: (d) =>
                            setState(() => _selectedDate = d),
                        onNext: () => setState(() => _step = 2),
                      )
                    : _Step3(
                        selectedDate: _selectedDate,
                        startController: _startTimeController,
                        endController: _endTimeController,
                        isLoading: _isLoading,
                        onConfirm: _confirm,
                      ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step indicator
// ---------------------------------------------------------------------------

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    const labels = ['Cancel', 'New Date', 'Time'];
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        border: Border(
            bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: List.generate(3, (i) {
          final isActive = i == currentStep;
          final isDone = i < currentStep;
          final color = isDone
              ? AppColors.primary
              : isActive
                  ? AppColors.textPrimary
                  : AppColors.textMuted;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isDone
                        ? AppColors.primary
                        : isActive
                            ? AppColors.surface
                            : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 1.5),
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(Icons.check,
                            size: 14, color: AppColors.background)
                        : Text(
                            '${i + 1}',
                            style: AppTextStyles.label.copyWith(color: color),
                          ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    labels[i],
                    style: AppTextStyles.caption.copyWith(color: color),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (i < 2)
                  Expanded(
                    child: Container(
                      height: 1,
                      color: isDone ? AppColors.primary : AppColors.border,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 1 — Confirm cancel
// ---------------------------------------------------------------------------

class _Step1 extends StatelessWidget {
  const _Step1({required this.booking, required this.onNext});

  final Booking booking;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEE, MMM d').format(booking.date);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withAlpha(15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.warning.withAlpha(60)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    color: AppColors.warning, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your current booking on $dateStr will be cancelled '
                    'before the new one is created.',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.warning),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Current Booking',
            style: AppTextStyles.bodyMed.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateStr,
                  style: AppTextStyles.heading4
                      .copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  '${booking.startTime} – ${booking.endTime}',
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.textMuted),
                ),
                if (booking.trainerName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Trainer: ${booking.trainerName}',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textMuted),
                  ),
                ],
              ],
            ),
          ),
          const Spacer(),
          PrimaryButton(
            label: 'Continue to New Date',
            onPressed: onNext,
            icon: Icons.arrow_forward_rounded,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 2 — Pick new date
// ---------------------------------------------------------------------------

class _Step2 extends StatelessWidget {
  const _Step2({
    required this.selectedDate,
    required this.onDateChanged,
    required this.onNext,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Select a New Date',
            style: AppTextStyles.heading4
                .copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: AppColors.primary,
                  onPrimary: AppColors.background,
                  surface: AppColors.elevated,
                  onSurface: AppColors.textPrimary,
                ),
              ),
              child: CalendarDatePicker(
                initialDate: selectedDate,
                firstDate: now.add(const Duration(days: 1)),
                lastDate: now.add(const Duration(days: 90)),
                onDateChanged: onDateChanged,
              ),
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Confirm Date',
            onPressed: onNext,
            icon: Icons.check_rounded,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 3 — Pick time and confirm
// ---------------------------------------------------------------------------

class _Step3 extends StatelessWidget {
  const _Step3({
    required this.selectedDate,
    required this.startController,
    required this.endController,
    required this.isLoading,
    required this.onConfirm,
  });

  final DateTime selectedDate;
  final TextEditingController startController;
  final TextEditingController endController;
  final bool isLoading;
  final VoidCallback onConfirm;

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      hintText: 'HH:MM',
      hintStyle:
          AppTextStyles.body.copyWith(color: AppColors.textMuted),
      labelStyle:
          AppTextStyles.body.copyWith(color: AppColors.textMuted),
      floatingLabelStyle:
          AppTextStyles.caption.copyWith(color: AppColors.primary),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEE, MMM d, yyyy').format(selectedDate);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: 10),
                Text(
                  dateStr,
                  style: AppTextStyles.bodyMed
                      .copyWith(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Select Time',
            style: AppTextStyles.bodyMed.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: startController,
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.textPrimary),
                  decoration: _decoration('Start Time'),
                  keyboardType: TextInputType.text,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: endController,
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.textPrimary),
                  decoration: _decoration('End Time'),
                  keyboardType: TextInputType.text,
                ),
              ),
            ],
          ),
          const Spacer(),
          PrimaryButton(
            label: 'Confirm Reschedule',
            onPressed: isLoading ? null : onConfirm,
            isLoading: isLoading,
            icon: Icons.event_repeat_rounded,
          ),
        ],
      ),
    );
  }
}
