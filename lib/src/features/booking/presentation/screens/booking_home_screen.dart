import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/skeletons/skeleton_card.dart';
import '../../domain/entities/booking.dart';
import '../providers/booking_provider.dart';
import '../widgets/booking_cancel_sheet.dart';
import '../widgets/booking_card.dart';

class BookingHomeScreen extends ConsumerStatefulWidget {
  const BookingHomeScreen({super.key});

  @override
  ConsumerState<BookingHomeScreen> createState() => _BookingHomeScreenState();
}

class _BookingHomeScreenState extends ConsumerState<BookingHomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showCancelSheet(Booking booking) {
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(bookingsNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'My Bookings',
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2,
          labelStyle: AppTextStyles.bodyMed,
          unselectedLabelStyle: AppTextStyles.body,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: PrimaryButton(
              label: 'Book a Session',
              onPressed: () => context.push('/booking/calendar'),
              icon: Icons.calendar_month_rounded,
            ),
          ),
          Expanded(
            child: bookingsAsync.when(
              loading: () => const _SkeletonList(),
              error: (e, _) => _ErrorState(
                onRetry: () =>
                    ref.invalidate(bookingsNotifierProvider),
              ),
              data: (bookings) {
                final upcoming = bookings
                    .where((b) =>
                        b.status == BookingStatus.pending ||
                        b.status == BookingStatus.confirmed)
                    .toList()
                  ..sort((a, b) => a.date.compareTo(b.date));

                final past = bookings
                    .where((b) =>
                        b.status == BookingStatus.completed ||
                        b.status == BookingStatus.cancelled)
                    .toList()
                  ..sort((a, b) => b.date.compareTo(a.date));

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _BookingList(
                      bookings: upcoming,
                      emptyTitle: 'No upcoming sessions',
                      emptySubtitle:
                          'Tap "Book a Session" to schedule your first session.',
                      allowSwipe: true,
                      onCancel: _showCancelSheet,
                    ),
                    _BookingList(
                      bookings: past,
                      emptyTitle: 'No past sessions',
                      emptySubtitle: 'Your completed sessions will appear here.',
                      allowSwipe: false,
                      onCancel: null,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Booking list
// ---------------------------------------------------------------------------

class _BookingList extends StatelessWidget {
  const _BookingList({
    required this.bookings,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.allowSwipe,
    required this.onCancel,
  });

  final List<Booking> bookings;
  final String emptyTitle;
  final String emptySubtitle;
  final bool allowSwipe;
  final void Function(Booking)? onCancel;

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return _EmptyState(title: emptyTitle, subtitle: emptySubtitle);
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final isPending = booking.status == BookingStatus.pending;

        if (allowSwipe && isPending && onCancel != null) {
          return Dismissible(
            key: ValueKey(booking.id),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) async {
              HapticFeedback.mediumImpact();
              final result = await showModalBottomSheet<bool>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => BookingCancelSheet(
                  bookingId: booking.id,
                  date: booking.date,
                  startTime: booking.startTime,
                  endTime: booking.endTime,
                ),
              );
              return result == true;
            },
            background: const _SwipeBackground(),
            child: BookingCard(
              booking: booking,
              onLongPress: isPending ? () => onCancel!(booking) : null,
            ),
          )
              .animate(delay: Duration(milliseconds: index * 60))
              .fadeIn(duration: 300.ms, curve: Curves.easeOut)
              .slideY(begin: 0.12, end: 0, duration: 300.ms, curve: Curves.easeOut);
        }

        return BookingCard(booking: booking)
            .animate(delay: Duration(milliseconds: index * 60))
            .fadeIn(duration: 300.ms, curve: Curves.easeOut)
            .slideY(begin: 0.12, end: 0, duration: 300.ms, curve: Curves.easeOut);
      },
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.error.withAlpha(26),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: AppColors.error.withAlpha(77), width: 1),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(
        Icons.cancel_outlined,
        color: AppColors.error,
        size: 28,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 48,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style:
                  AppTextStyles.heading4.copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
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

// ---------------------------------------------------------------------------
// Error state
// ---------------------------------------------------------------------------

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

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
              'Could not load bookings',
              style:
                  AppTextStyles.heading4.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Try again',
                style: AppTextStyles.bodyMed
                    .copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Skeleton loading
// ---------------------------------------------------------------------------

class _SkeletonList extends StatelessWidget {
  const _SkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const SkeletonCard(),
    );
  }
}
