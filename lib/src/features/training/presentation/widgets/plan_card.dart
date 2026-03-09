import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import 'plan_detail_widgets.dart';

/// Reusable card for displaying a training plan or diet plan in a list.
///
/// [title] — plan name
/// [subtitle] — trainer or member name
/// [itemCountIcon] — icon that precedes [itemCount] (e.g. `Icons.fitness_center_rounded`)
/// [itemCount] — e.g. "5 exercises" or "4 meals"
/// [isActive] — whether the plan is currently active
/// [createdAt] — creation date, formatted as "Mar 5, 2026"
/// [onTap] — navigation callback
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
  });

  final String title;
  final String? subtitle;
  final IconData itemCountIcon;
  final String itemCount;
  final bool isActive;
  final DateTime createdAt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, yyyy').format(createdAt);

    return Material(
      color: AppColors.surface,
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        splashColor: AppColors.primary.withAlpha(30),
        highlightColor: AppColors.primary.withAlpha(15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          // Minimum 48 dp touch target is satisfied by the content padding;
          // the inner Column always renders taller than 48 dp in practice.
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.heading4
                          .copyWith(color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  PlanActiveBadge(isActive: isActive),
                ],
              ),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textMuted),
                ),
              ],
              const SizedBox(height: 10),
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
    );
  }
}
