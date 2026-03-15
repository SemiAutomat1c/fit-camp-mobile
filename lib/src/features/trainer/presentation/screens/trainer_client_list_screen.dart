import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../training/domain/entities/member_summary.dart';
import '../providers/trainer_provider.dart';

/// Trainer-only screen listing all assigned members.
///
/// Watches [trainerClientsProvider] and renders a tile per [MemberSummary]
/// with a "Message" action that navigates to /chat.
class TrainerClientListScreen extends ConsumerWidget {
  const TrainerClientListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsync = ref.watch(trainerClientsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: clientsAsync.when(
          loading: () => const Center(
            key: ValueKey('loading'),
            child: LoadingIndicator(),
          ),
          error: (e, _) => ErrorView(
            key: const ValueKey('error'),
            message: 'Failed to load clients.',
            onRetry: () => ref.invalidate(trainerClientsProvider),
          ),
          data: (clients) {
            if (clients.isEmpty) {
              return const EmptyState(
                key: ValueKey('empty'),
                icon: Icons.people_outline_rounded,
                title: 'No clients yet',
                subtitle:
                    'Members will appear here when assigned to you.',
              );
            }
            return ListView.separated(
              key: const ValueKey('list'),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: clients.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _ClientTile(member: clients[index]),
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Client tile
// ---------------------------------------------------------------------------

class _ClientTile extends StatelessWidget {
  const _ClientTile({required this.member});

  final MemberSummary member;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          AppAvatar(
            name: member.name,
            imageUrl: member.avatarUrl,
            size: AppAvatarSize.md,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: AppTextStyles.bodyMed
                      .copyWith(color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                _SubscriptionBadge(),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () => context.go('/chat'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Message',
              style: AppTextStyles.label
                  .copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary.withAlpha(100)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Active Member',
        style: AppTextStyles.label
            .copyWith(color: AppColors.primary, fontSize: 10),
      ),
    );
  }
}
