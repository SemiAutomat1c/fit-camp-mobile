import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/skeletons/skeleton_list_tile.dart';
import '../providers/notification_provider.dart';
import '../widgets/notification_card.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsNotifierProvider);

    final hasUnread = notificationsAsync.valueOrNull
            ?.any((n) => !n.read) ??
        false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Notifications'),
        actions: [
          if (hasUnread)
            TextButton(
              onPressed: () =>
                  ref.read(notificationsNotifierProvider.notifier).markAllRead(),
              child: Text(
                'Mark All Read',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.primary),
              ),
            ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => _buildSkeletons(),
        error: (error, _) => ErrorView(
          message: 'Could not load notifications.',
          onRetry: () => ref.invalidate(notificationsNotifierProvider),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const EmptyState(
              icon: Icons.check_circle_outline_rounded,
              title: "You're all caught up!",
              subtitle: 'No notifications',
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            onRefresh: () async {
              ref.invalidate(notificationsNotifierProvider);
              await ref.read(notificationsNotifierProvider.future);
            },
            child: ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                color: AppColors.border,
              ),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return NotificationCard(
                  notification: notification,
                  onTap: () => _onTap(context, ref, notification.id,
                      notification.type, notification.data),
                )
                    .animate(delay: Duration(milliseconds: index * 60))
                    .fadeIn(duration: 300.ms, curve: Curves.easeOut)
                    .slideY(begin: 0.12, end: 0, duration: 300.ms, curve: Curves.easeOut);
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _onTap(
    BuildContext context,
    WidgetRef ref,
    String id,
    String type,
    Map<String, dynamic>? data,
  ) async {
    // Mark as read first (fire-and-forget optimistic update).
    await ref.read(notificationsNotifierProvider.notifier).markRead(id);

    if (!context.mounted) return;
    _navigateForType(context, type, data);
  }

  void _navigateForType(
    BuildContext context,
    String type,
    Map<String, dynamic>? data,
  ) {
    switch (type) {
      case 'booking_request':
      case 'booking_confirmed':
        context.go('/booking');
      case 'new_message':
        context.go('/chat');
      case 'training_plan_assigned':
      case 'diet_plan_assigned':
        context.go('/training');
      case 'subscription_expiring':
      case 'subscription_expired':
        context.push('/profile');
      default:
        break; // No navigation for maintenance_reported, etc.
    }
  }

  Widget _buildSkeletons() {
    return ListView.separated(
      itemCount: 6,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        color: AppColors.border,
      ),
      itemBuilder: (_, __) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: SkeletonListTile(),
      ),
    );
  }
}
