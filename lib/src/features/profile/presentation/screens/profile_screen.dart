import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_confirm_dialog.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/neon_gradient_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).valueOrNull;
    final profileAsync = ref.watch(myProfileProvider);
    final subscriptionAsync = ref.watch(mySubscriptionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Profile',
            onPressed: () => context.push('/profile/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => ErrorView(
          message: 'Could not load profile.',
          onRetry: () => ref.invalidate(myProfileProvider),
        ),
        data: (profile) {
          final displayName =
              (profile?['user']?['name'] as String?) ?? user?.name ?? '';
          final email =
              (profile?['user']?['email'] as String?) ?? user?.email ?? '';
          final phone =
              (profile?['user']?['phone'] as String?) ?? user?.phone ?? '';
          final avatarUrl =
              (profile?['user']?['avatarUrl'] as String?) ?? user?.avatarUrl;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ----------------------------------------------------------------
                // User header
                // ----------------------------------------------------------------
                _UserHeader(
                  name: displayName,
                  email: email,
                  phone: phone,
                  avatarUrl: avatarUrl,
                ),
                const SizedBox(height: 28),

                // ----------------------------------------------------------------
                // Subscription section
                // ----------------------------------------------------------------
                _SectionHeader(title: 'Subscription'),
                const SizedBox(height: 10),
                subscriptionAsync.when(
                  loading: () => const _SubscriptionLoading(),
                  error: (_, __) => const _SubscriptionEmpty(),
                  data: (sub) => sub == null
                      ? const _SubscriptionEmpty()
                      : _SubscriptionCard(subscription: sub),
                ),
                const SizedBox(height: 28),

                // ----------------------------------------------------------------
                // Assigned trainer section
                // ----------------------------------------------------------------
                if (profile != null && profile['trainer'] != null) ...[
                  _SectionHeader(title: 'Assigned Trainer'),
                  const SizedBox(height: 10),
                  _TrainerCard(trainer: profile['trainer'] as Map<String, dynamic>),
                  const SizedBox(height: 28),
                ],

                // ----------------------------------------------------------------
                // Profile details section
                // ----------------------------------------------------------------
                if (profile != null) ...[
                  _SectionHeader(title: 'Profile Details'),
                  const SizedBox(height: 10),
                  _ProfileDetailsCard(profile: profile),
                  const SizedBox(height: 28),
                ] else ...[
                  AppCard(
                    child: Text(
                      'Complete your profile in onboarding.',
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.textMuted),
                    ),
                  ),
                  const SizedBox(height: 28),
                ],

                // ----------------------------------------------------------------
                // Sign out
                // ----------------------------------------------------------------
                Center(
                  child: SizedBox(
                    height: 48,
                    child: TextButton(
                      onPressed: () => _confirmSignOut(context, ref),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                        minimumSize: const Size(120, 48),
                      ),
                      child: Text(
                        'Sign Out',
                        style: AppTextStyles.button
                            .copyWith(color: AppColors.error),
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () => context.push('/profile/delete-account'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textMuted,
                    ),
                    child: Text(
                      'Delete Account',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textMuted),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    await showAppConfirmDialog(
      context,
      title: 'Sign Out?',
      body: 'Are you sure you want to sign out?',
      confirmLabel: 'Sign Out',
      confirmColor: AppColors.error,
      onConfirm: () => ref.read(authNotifierProvider.notifier).signOut(),
    );
  }
}

// ---------------------------------------------------------------------------
// User header
// ---------------------------------------------------------------------------

class _UserHeader extends StatelessWidget {
  const _UserHeader({
    required this.name,
    required this.email,
    required this.phone,
    this.avatarUrl,
  });

  final String name;
  final String email;
  final String phone;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withAlpha(38), // ~15%
            AppColors.background,
          ],
        ),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Avatar with neon ring
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryMuted],
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.background,
              ),
              child: AppAvatar(
                name: name.isNotEmpty ? name : 'User',
                imageUrl: avatarUrl,
                size: AppAvatarSize.xl,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (name.isNotEmpty)
            Text(
              name,
              style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              email,
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
          if (phone.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              phone,
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.heading4.copyWith(color: AppColors.textPrimary),
    );
  }
}

// ---------------------------------------------------------------------------
// Subscription card
// ---------------------------------------------------------------------------

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard({required this.subscription});

  final Map<String, dynamic> subscription;

  @override
  Widget build(BuildContext context) {
    final type = subscription['type'] as String? ?? '';
    final typeLabel = _typeLabel(type);
    final startMs = (subscription['startDate'] as num?)?.toInt();
    final endMs = (subscription['endDate'] as num?)?.toInt();
    final pricePaid = subscription['pricePaid'] as num?;
    final isStudent = subscription['isStudent'] as bool? ?? false;

    final startDate = startMs != null
        ? DateFormat('MMM d, y').format(
            DateTime.fromMillisecondsSinceEpoch(startMs))
        : null;
    final endDate = endMs != null
        ? DateFormat('MMM d, y').format(
            DateTime.fromMillisecondsSinceEpoch(endMs))
        : null;

    // Days remaining progress
    double? daysPercent;
    int? daysLeft;
    Color progressColor = AppColors.primary;
    if (startMs != null && endMs != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final totalDays = (endMs - startMs) / 86400000;
      final elapsedDays = (now - startMs) / 86400000;
      daysLeft = ((endMs - now) / 86400000).ceil().clamp(0, 9999);
      daysPercent =
          (1 - (elapsedDays / totalDays)).clamp(0.0, 1.0);
      if (daysLeft < 7) {
        progressColor = AppColors.error;
      } else if (daysLeft < 14) {
        progressColor = AppColors.warning;
      }
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(26),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              border: Border.all(
                  color: AppColors.primary.withAlpha(77), width: 1),
            ),
            child: Text(
              typeLabel,
              style: AppTextStyles.label.copyWith(color: AppColors.primary),
            ),
          ),
          if (startDate != null && endDate != null) ...[
            const SizedBox(height: 10),
            Text(
              '$startDate – $endDate',
              style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
            ),
          ],
          if (pricePaid != null) ...[
            const SizedBox(height: 4),
            Text(
              isStudent
                  ? '₱${_formatPrice(pricePaid)} · Student rate'
                  : '₱${_formatPrice(pricePaid)}',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textMuted),
            ),
          ],
          // Days remaining progress bar
          if (daysPercent != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$daysLeft days remaining',
                  style: AppTextStyles.label.copyWith(
                    color: progressColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            LinearPercentIndicator(
              lineHeight: 4,
              percent: daysPercent,
              backgroundColor: AppColors.border,
              progressColor: progressColor,
              barRadius: const Radius.circular(4),
              padding: EdgeInsets.zero,
              animation: true,
              animationDuration: 800,
            ),
          ],
        ],
      ),
    );
  }

  static String _typeLabel(String type) => switch (type) {
        'daily' => 'Daily Pass',
        'monthly_1' => 'Monthly (1 month)',
        'monthly_3' => 'Monthly (3 months)',
        'monthly_6' => 'Monthly (6 months)',
        'monthly_12' => 'Annual (12 months)',
        _ => type,
      };

  static String _formatPrice(num price) {
    final digits = price.toInt().toString();
    final buffer = StringBuffer();
    final offset = digits.length % 3;
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (i - offset) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}

class _SubscriptionEmpty extends StatelessWidget {
  const _SubscriptionEmpty();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No active subscription',
            style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          Text(
            'Contact your gym admin for membership details.',
            style:
                AppTextStyles.caption.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionLoading extends StatelessWidget {
  const _SubscriptionLoading();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Container(
        height: 20,
        decoration: const BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Trainer card
// ---------------------------------------------------------------------------

class _TrainerCard extends StatelessWidget {
  const _TrainerCard({required this.trainer});

  final Map<String, dynamic> trainer;

  @override
  Widget build(BuildContext context) {
    final name = trainer['name'] as String? ?? 'Your Trainer';
    final avatarUrl = trainer['avatarUrl'] as String?;

    return NeonGradientCard(
      child: Row(
        children: [
          AppAvatar(
            name: name,
            imageUrl: avatarUrl,
            size: AppAvatarSize.md,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style:
                  AppTextStyles.bodyMed.copyWith(color: AppColors.textPrimary),
            ),
          ),
          OutlinedButton(
            onPressed: () => context.push('/chat'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary.withAlpha(120)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: const Size(0, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Message',
              style: AppTextStyles.label.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Profile details card
// ---------------------------------------------------------------------------

class _ProfileDetailsCard extends StatelessWidget {
  const _ProfileDetailsCard({required this.profile});

  final Map<String, dynamic> profile;

  @override
  Widget build(BuildContext context) {
    final goal = profile['goal'] as String?;
    final age = profile['age'] as num?;
    final gender = profile['gender'] as String?;
    final height = profile['height'] as num?;
    final weight = profile['weight'] as num?;

    final chips = <_ChipData>[
      if (goal != null)
        _ChipData(label: 'Goal', value: _goalLabel(goal)),
      if (age != null)
        _ChipData(label: 'Age', value: '${age.toInt()} yrs'),
      if (gender != null)
        _ChipData(label: 'Gender', value: _capitalise(gender)),
      if (height != null)
        _ChipData(label: 'Height', value: '${height.toInt()} cm'),
      if (weight != null)
        _ChipData(label: 'Weight', value: '${weight.toInt()} kg'),
    ];

    if (chips.isEmpty) return const SizedBox.shrink();

    return AppCard(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: chips.map(_buildChip).toList(),
      ),
    );
  }

  Widget _buildChip(_ChipData data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.elevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.label,
            style: AppTextStyles.label.copyWith(
              color: AppColors.textMuted,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data.value,
            style: AppTextStyles.bodyMed.copyWith(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  static String _goalLabel(String goal) => switch (goal) {
        'gain_muscle' => 'Gain Muscle',
        'lose_weight' => 'Lose Weight',
        'improve_endurance' => 'Improve Endurance',
        'general_fitness' => 'General Fitness',
        'sports_performance' => 'Sports Performance',
        _ => _capitalise(goal.replaceAll('_', ' ')),
      };

  static String _capitalise(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _ChipData {
  const _ChipData({required this.label, required this.value});
  final String label;
  final String value;
}
