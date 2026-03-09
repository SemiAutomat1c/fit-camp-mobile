import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/utils/time_format.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../booking/domain/entities/booking.dart';
import '../../../booking/presentation/providers/booking_provider.dart';
import '../../../progress/presentation/providers/progress_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).valueOrNull;
    final greeting = _greeting();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                '$greeting,',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textMuted),
              ),
              Text(
                user?.name.split(' ').first ?? 'there',
                style: AppTextStyles.heading2
                    .copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              const _StatsStrip(),
              const SizedBox(height: 24),
              Text(
                'Next Session',
                style: AppTextStyles.heading4
                    .copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              const _NextSessionCard(),
              const SizedBox(height: 24),
              Text(
                'Quick Actions',
                style: AppTextStyles.heading4
                    .copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              const _QuickActions(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  static String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

// ---------------------------------------------------------------------------
// Next session card
// ---------------------------------------------------------------------------

class _NextSessionCard extends ConsumerWidget {
  const _NextSessionCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingsNotifierProvider);

    return bookingsAsync.when(
      loading: () => _buildShell(
        context,
        child: const _NextSessionLoading(),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (bookings) {
        final now = DateTime.now();
        final upcoming = bookings
            .where((b) =>
                (b.status == BookingStatus.pending ||
                    b.status == BookingStatus.confirmed) &&
                !b.date.isBefore(DateTime(now.year, now.month, now.day)))
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));

        if (upcoming.isEmpty) {
          return _buildShell(
            context,
            child: _NoNextSession(onBookNow: () => context.push('/booking/calendar')),
          );
        }

        final next = upcoming.first;
        return _buildShell(
          context,
          onTap: () => context.go('/booking'),
          child: _NextSessionContent(booking: next),
        );
      },
    );
  }

  Widget _buildShell(BuildContext context,
      {Widget? child, VoidCallback? onTap}) {
    return AppCard(onTap: onTap, child: child ?? const SizedBox.shrink());
  }
}

class _NextSessionContent extends StatelessWidget {
  const _NextSessionContent({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(booking.status);
    final statusLabel =
        booking.status == BookingStatus.pending ? 'Pending' : 'Confirmed';
    final relativeDate = _relativeDate(booking.date, booking.startTime);

    return Row(
      children: [
        Container(
          width: 4,
          height: 52,
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: const BorderRadius.all(Radius.circular(4)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                booking.trainerName ?? 'Your Trainer',
                style: AppTextStyles.bodyMed
                    .copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 2),
              Text(
                relativeDate,
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: statusColor.withAlpha(26),
            borderRadius: const BorderRadius.all(Radius.circular(6)),
            border: Border.all(color: statusColor.withAlpha(77), width: 1),
          ),
          child: Text(
            statusLabel,
            style: AppTextStyles.label.copyWith(color: statusColor),
          ),
        ),
      ],
    );
  }

  static Color _statusColor(BookingStatus status) {
    if (status == BookingStatus.confirmed) return AppColors.primary;
    return const Color(0xFFF59E0B);
  }

  static String _relativeDate(DateTime date, String startTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDay =
        DateTime(date.year, date.month, date.day);
    final diff = sessionDay.difference(today).inDays;
    final timeStr = formatTime(startTime);

    if (diff == 0) return 'Today at $timeStr';
    if (diff == 1) return 'Tomorrow at $timeStr';
    return '${DateFormat('EEE, MMM d').format(date)} at $timeStr';
  }

}

class _NoNextSession extends StatelessWidget {
  const _NoNextSession({required this.onBookNow});

  final VoidCallback onBookNow;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'No upcoming sessions',
            style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
          ),
        ),
        TextButton(
          onPressed: onBookNow,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: const Size(48, 48),
          ),
          child: Text(
            'Book Now',
            style: AppTextStyles.bodyMed.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _NextSessionLoading extends StatelessWidget {
  const _NextSessionLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      decoration: const BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quick actions grid
// ---------------------------------------------------------------------------

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    const actions = [
      _ActionData(
        icon: Icons.calendar_month_rounded,
        label: 'Book Session',
        route: '/booking',
      ),
      _ActionData(
        icon: Icons.fitness_center_rounded,
        label: 'My Plans',
        route: '/training',
      ),
      _ActionData(
        icon: Icons.trending_up_rounded,
        label: 'Log Progress',
        route: '/progress',
      ),
    ];

    return Row(
      children: actions
          .map(
            (action) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: action == actions.last ? 0 : 8,
                ),
                child: _ActionCard(data: action),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ActionData {
  const _ActionData({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;
}

// ---------------------------------------------------------------------------
// Stats strip
// ---------------------------------------------------------------------------

class _StatsStrip extends ConsumerWidget {
  const _StatsStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingsNotifierProvider);
    final progressAsync = ref.watch(progressLogsProvider);

    // Sessions this week
    int sessionsThisWeek = 0;
    bookingsAsync.whenData((bookings) {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekStartDay = DateTime(weekStart.year, weekStart.month, weekStart.day);
      sessionsThisWeek = bookings
          .where((b) =>
              (b.status == BookingStatus.confirmed ||
                  b.status == BookingStatus.completed) &&
              !b.date.isBefore(weekStartDay))
          .length;
    });

    // Latest weight
    double? latestWeight;
    progressAsync.whenData((logs) {
      if (logs.isNotEmpty) {
        final withWeight = logs.where((l) => l.weight != null).toList();
        if (withWeight.isNotEmpty) {
          latestWeight = withWeight.first.weight;
        }
      }
    });

    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _StatItem(
                value: sessionsThisWeek.toString(),
                label: 'Sessions\nThis Week',
              ),
            ),
            const VerticalDivider(
              color: AppColors.border,
              thickness: 1,
              width: 1,
            ),
            Expanded(
              child: _StatItem(
                value: latestWeight != null
                    ? '${latestWeight!.toStringAsFixed(1)} kg'
                    : '—',
                label: 'Current\nWeight',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTextStyles.heading2.copyWith(color: AppColors.primary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.data});

  final _ActionData data;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      onTap: () => context.go(data.route),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0x1F39FF14), // primary @ ~12% opacity
            ),
            child: Icon(
              data.icon,
              size: 24,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.label,
            textAlign: TextAlign.center,
            style: AppTextStyles.label
                .copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
