import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/utils/time_format.dart';
import '../../../../shared/widgets/animated_stat_value.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/neon_gradient_card.dart';
import '../../../../shared/widgets/neon_stat_card.dart';
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
              _HeroCard(user: user, greeting: greeting),
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
// Hero card (greeting + avatar + stats)
// ---------------------------------------------------------------------------

class _HeroCard extends ConsumerWidget {
  const _HeroCard({required this.user, required this.greeting});

  final dynamic user;
  final String greeting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingsNotifierProvider);
    final progressAsync = ref.watch(progressLogsProvider);

    int sessionsThisWeek = 0;
    bookingsAsync.whenData((bookings) {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekStartDay =
          DateTime(weekStart.year, weekStart.month, weekStart.day);
      sessionsThisWeek = bookings
          .where((b) =>
              (b.status == BookingStatus.confirmed ||
                  b.status == BookingStatus.completed) &&
              !b.date.isBefore(weekStartDay))
          .length;
    });

    double? latestWeight;
    progressAsync.whenData((logs) {
      if (logs.isNotEmpty) {
        final withWeight = logs.where((l) => l.weight != null).toList();
        if (withWeight.isNotEmpty) latestWeight = withWeight.first.weight;
      }
    });

    final firstName = user?.name.split(' ').first ?? 'there';
    final avatarUrl = user?.avatarUrl as String?;
    final name = user?.name as String? ?? '';

    return NeonGradientCard(
      gradientOpacity: 0.08,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting row + avatar
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.textMuted),
                    ),
                    Text(
                      firstName,
                      style: AppTextStyles.heading2
                          .copyWith(color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/profile'),
                child: AppAvatar(
                  name: name.isNotEmpty ? name : 'User',
                  imageUrl: avatarUrl,
                  size: AppAvatarSize.md,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Stats row
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: NeonStatCard(
                    value: sessionsThisWeek.toString(),
                    label: 'Sessions\nThis Week',
                    percent: (sessionsThisWeek / 5).clamp(0.0, 1.0),
                    accentColor: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: latestWeight != null
                      ? _WeightStatCard(weight: latestWeight!)
                      : const NeonStatCard(
                          value: '—',
                          label: 'Current\nWeight',
                          accentColor: AppColors.primary,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightStatCard extends StatelessWidget {
  const _WeightStatCard({required this.weight});

  final double weight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedStatValue(
            targetValue: weight,
            suffix: ' kg',
            style: AppTextStyles.heading3
                .copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 2),
          Text(
            'Current\nWeight',
            style:
                AppTextStyles.label.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
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
            child:
                _NoNextSession(onBookNow: () => context.push('/booking/calendar')),
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
    final sessionDay = DateTime(date.year, date.month, date.day);
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
        label: 'BOOK\nSESSION',
        route: '/booking',
      ),
      _ActionData(
        icon: Icons.fitness_center_rounded,
        label: 'MY\nPLANS',
        route: '/training',
      ),
      _ActionData(
        icon: Icons.trending_up_rounded,
        label: 'LOG\nPROGRESS',
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
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.primary.withAlpha(20),
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
            style: AppTextStyles.label.copyWith(
              color: AppColors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    )
        .animate()
        .shimmer(
          delay: Duration.zero,
          duration: 600.ms,
          color: AppColors.primary.withAlpha(20),
        );
  }
}
