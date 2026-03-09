import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/skeletons/skeleton_card.dart';
import '../../domain/entities/trainer_slot.dart';
import '../providers/booking_provider.dart';
import '../widgets/booking_confirm_sheet.dart';
import '../widgets/time_slot_card.dart';

class BookingCalendarScreen extends ConsumerStatefulWidget {
  const BookingCalendarScreen({super.key});

  @override
  ConsumerState<BookingCalendarScreen> createState() =>
      _BookingCalendarScreenState();
}

class _BookingCalendarScreenState
    extends ConsumerState<BookingCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  ({String start, String end})? _selectedSlot;

  bool _isAvailableDay(DateTime day, List<TrainerSlot> slots) {
    final weekday = day.weekday % 7; // Flutter: Mon=1..Sun=7 → convert to 0=Sun
    return slots.any((s) => s.dayOfWeek == weekday);
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay,
      List<TrainerSlot> slots) {
    final today = DateTime.now();
    final isToday = isSameDay(selectedDay, today);
    final isPast = selectedDay.isBefore(
        DateTime(today.year, today.month, today.day));

    if (isPast && !isToday) return;
    if (!_isAvailableDay(selectedDay, slots)) return;

    HapticFeedback.selectionClick();
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedSlot = null;
    });
  }

  Future<void> _openConfirmSheet(
      String trainerName,
      DateTime date,
      ({String start, String end}) slot) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BookingConfirmSheet(
        trainerName: trainerName,
        selectedDate: date,
        startTime: slot.start,
        endTime: slot.end,
      ),
    );

    if (result == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final trainerIdAsync = ref.watch(myTrainerIdProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Book a Session',
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: trainerIdAsync.when(
        loading: () => const _LoadingBody(),
        error: (e, _) => const _NoTrainerState(),
        data: (trainerId) {
          if (trainerId == null) {
            return const _NoTrainerState();
          }

          return _CalendarBody(
            trainerId: trainerId,
            selectedDay: _selectedDay,
            focusedDay: _focusedDay,
            selectedSlot: _selectedSlot,
            onDaySelected: (day, focused, slots) =>
                _onDaySelected(day, focused, slots),
            onSlotSelected: (slot) {
              setState(() => _selectedSlot = slot);
            },
            onConfirm: (trainerName, date, slot) =>
                _openConfirmSheet(trainerName, date, slot),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Calendar body (shown when trainer ID is available)
// ---------------------------------------------------------------------------

class _CalendarBody extends ConsumerWidget {
  const _CalendarBody({
    required this.trainerId,
    required this.selectedDay,
    required this.focusedDay,
    required this.selectedSlot,
    required this.onDaySelected,
    required this.onSlotSelected,
    required this.onConfirm,
  });

  final String trainerId;
  final DateTime? selectedDay;
  final DateTime focusedDay;
  final ({String start, String end})? selectedSlot;
  final void Function(DateTime, DateTime, List<TrainerSlot>) onDaySelected;
  final void Function(({String start, String end})) onSlotSelected;
  final void Function(String, DateTime, ({String start, String end})) onConfirm;

  bool _isAvailableDay(DateTime day, List<TrainerSlot> slots) {
    final weekday = day.weekday % 7;
    return slots.any((s) => s.dayOfWeek == weekday);
  }

  List<({String start, String end})> _slotsForDay(
      DateTime day, List<TrainerSlot> slots) {
    final weekday = day.weekday % 7;
    final matchingSlots =
        slots.where((s) => s.dayOfWeek == weekday).toList();
    final hourlySlots = <({String start, String end})>[];
    for (final slot in matchingSlots) {
      hourlySlots.addAll(slot.generateHourlySlots());
    }
    return hourlySlots;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availabilityAsync =
        ref.watch(trainerAvailabilityProvider(trainerId));

    return availabilityAsync.when(
      loading: () => const _LoadingBody(),
      error: (e, _) => const _ErrorBody(),
      data: (slots) {
        final availableSlots = selectedDay != null
            ? _slotsForDay(selectedDay!, slots)
            : <({String start, String end})>[];

        // Try to find a trainer name from bookings or just use generic
        final trainerName = 'Your Trainer';

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StyledCalendar(
                focusedDay: focusedDay,
                selectedDay: selectedDay,
                availabilitySlots: slots,
                onDaySelected: (day, focused) =>
                    onDaySelected(day, focused, slots),
                isAvailableDay: (day) => _isAvailableDay(day, slots),
              ),
              const SizedBox(height: 8),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 20),
              if (selectedDay == null)
                const _SelectDayPrompt()
              else if (availableSlots.isEmpty)
                const _NoSlotsState()
              else
                _TimeSlotSection(
                  slots: availableSlots,
                  selectedSlot: selectedSlot,
                  onSlotSelected: onSlotSelected,
                  onConfirm: (slot) =>
                      onConfirm(trainerName, selectedDay!, slot),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Styled TableCalendar
// ---------------------------------------------------------------------------

class _StyledCalendar extends StatelessWidget {
  const _StyledCalendar({
    required this.focusedDay,
    required this.selectedDay,
    required this.availabilitySlots,
    required this.onDaySelected,
    required this.isAvailableDay,
  });

  final DateTime focusedDay;
  final DateTime? selectedDay;
  final List<TrainerSlot> availabilitySlots;
  final void Function(DateTime, DateTime) onDaySelected;
  final bool Function(DateTime) isAvailableDay;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return TableCalendar(
      firstDay: DateTime(today.year, today.month, today.day),
      lastDay: DateTime(today.year + 1, today.month, today.day),
      focusedDay: focusedDay,
      selectedDayPredicate: (day) =>
          selectedDay != null && isSameDay(day, selectedDay!),
      onDaySelected: onDaySelected,
      rowHeight: 52,
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle:
            AppTextStyles.bodyMed.copyWith(color: AppColors.textPrimary),
        leftChevronIcon: const Icon(
          Icons.chevron_left_rounded,
          color: AppColors.textMuted,
        ),
        rightChevronIcon: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textMuted,
        ),
        decoration: const BoxDecoration(color: Colors.transparent),
      ),
      calendarStyle: CalendarStyle(
        defaultTextStyle:
            AppTextStyles.body.copyWith(color: AppColors.textPrimary),
        weekendTextStyle:
            AppTextStyles.body.copyWith(color: AppColors.textPrimary),
        outsideTextStyle:
            AppTextStyles.body.copyWith(color: AppColors.textMuted),
        disabledTextStyle:
            AppTextStyles.body.copyWith(color: AppColors.textMuted),
        todayDecoration: BoxDecoration(
          color: AppColors.primary.withAlpha(26),
          shape: BoxShape.circle,
        ),
        todayTextStyle:
            AppTextStyles.bodyMed.copyWith(color: AppColors.primary),
        selectedDecoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        selectedTextStyle:
            AppTextStyles.bodyMed.copyWith(color: AppColors.background),
        markerDecoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        markerSize: 5,
        markersMaxCount: 1,
        isTodayHighlighted: true,
        outsideDaysVisible: false,
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle:
            AppTextStyles.label.copyWith(color: AppColors.textMuted),
        weekendStyle:
            AppTextStyles.label.copyWith(color: AppColors.textMuted),
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, events) {
          if (isAvailableDay(day)) {
            final isSelected =
                selectedDay != null && isSameDay(day, selectedDay!);
            if (isSelected) return const SizedBox.shrink();
            return Positioned(
              bottom: 4,
              child: Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
        disabledBuilder: (context, day, focusedDay) {
          return Center(
            child: Text(
              '${day.day}',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textMuted.withAlpha(100),
              ),
            ),
          );
        },
      ),
      enabledDayPredicate: (day) {
        final isPast = day.isBefore(
            DateTime(today.year, today.month, today.day));
        if (isPast) return false;
        return isAvailableDay(day);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Time slot section
// ---------------------------------------------------------------------------

class _TimeSlotSection extends StatelessWidget {
  const _TimeSlotSection({
    required this.slots,
    required this.selectedSlot,
    required this.onSlotSelected,
    required this.onConfirm,
  });

  final List<({String start, String end})> slots;
  final ({String start, String end})? selectedSlot;
  final void Function(({String start, String end})) onSlotSelected;
  final void Function(({String start, String end})) onConfirm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Times',
            style:
                AppTextStyles.heading4.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: slots.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final slot = slots[index];
              final isSelected = selectedSlot != null &&
                  selectedSlot!.start == slot.start &&
                  selectedSlot!.end == slot.end;

              return TimeSlotCard(
                startTime: slot.start,
                endTime: slot.end,
                isSelected: isSelected,
                onTap: () {
                  onSlotSelected(slot);
                  onConfirm(slot);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Prompts and empty states
// ---------------------------------------------------------------------------

class _SelectDayPrompt extends StatelessWidget {
  const _SelectDayPrompt();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.touch_app_rounded,
              size: 40,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              'Select a highlighted date',
              style: AppTextStyles.bodyMed
                  .copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Green dots show your trainer\'s available days.',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoSlotsState extends StatelessWidget {
  const _NoSlotsState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.event_busy_rounded,
              size: 40,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              'No slots available',
              style: AppTextStyles.bodyMed
                  .copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoTrainerState extends StatelessWidget {
  const _NoTrainerState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_off_rounded,
              size: 48,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'No trainer assigned',
              style: AppTextStyles.heading4
                  .copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Contact your gym admin to get a trainer assigned to your account.',
              style:
                  AppTextStyles.caption.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const SkeletonCard(),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Could not load availability',
              style: AppTextStyles.heading4
                  .copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
