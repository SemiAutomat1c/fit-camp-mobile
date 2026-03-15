import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import 'plan_detail_widgets.dart';

/// Reusable card for displaying a training plan or diet plan in a list.
///
/// Active plans render a left neon gradient bar + neon background tint +
/// pulsing shimmer on the active badge.
///
/// If [completionPercent] is non-null and greater than 0, a thin
/// [LinearProgressIndicator] is rendered at the bottom of the card.
class PlanCard extends StatelessWidget {
  const PlanCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.itemCountIcon,
    required this.itemCount,
    required this.isActive,
    required this.createdAt,
    required this.onTap,
    this.completionPercent,
  });

  final String title;
  final String? subtitle;
  final IconData itemCountIcon;
  final String itemCount;
  final bool isActive;
  final DateTime createdAt;
  final VoidCallback onTap;

  /// When non-null and > 0, renders a progress bar at the bottom of the card.
  final double? completionPercent;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, yyyy').format(createdAt);

    return Material(
      color: Colors.transparent,
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        splashColor: AppColors.primary.withAlpha(30),
        highlightColor: AppColors.primary.withAlpha(15),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            border: Border.all(
              color: isActive
                  ? AppColors.primary.withAlpha(60)
                  : AppColors.border,
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left gradient bar — active plans only
                    if (isActive)
                      Container(
                        width: 3,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [AppColors.primary, AppColors.primaryMuted],
                          ),
                        ),
                      ),
                    // Card body
                    Expanded(
                      child: Container(
                        // Very subtle neon tint for active cards
                        decoration: isActive
                            ? const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0x0A39FF14),
                                    Color(0x00000000),
                                  ],
                                ),
                              )
                            : null,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 44px icon block
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.elevated,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    itemCountIcon,
                                    size: 22,
                                    color: isActive
                                        ? AppColors.primary
                                        : AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: AppTextStyles.heading4.copyWith(
                                            color: AppColors.textPrimary),
                                      ),
                                      if (subtitle != null &&
                                          subtitle!.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          subtitle!,
                                          style: AppTextStyles.caption.copyWith(
                                              color: AppColors.textMuted),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _AnimatedActiveBadge(isActive: isActive),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  itemCountIcon,
                                  size: 14,
                                  color: AppColors.textMuted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  itemCount,
                                  style: AppTextStyles.caption
                                      .copyWith(color: AppColors.textMuted),
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 14,
                                  color: AppColors.textMuted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  dateStr,
                                  style: AppTextStyles.caption
                                      .copyWith(color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Completion progress bar — shown only when non-null and > 0
                if (completionPercent != null && completionPercent! > 0)
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    child: LinearProgressIndicator(
                      value: completionPercent,
                      minHeight: 3,
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedActiveBadge extends StatelessWidget {
  const _AnimatedActiveBadge({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final badge = PlanActiveBadge(isActive: isActive);
    if (!isActive) return badge;
    return badge
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(
          delay: 2.seconds,
          duration: 1500.ms,
          color: AppColors.primary.withAlpha(80),
        );
  }
}
