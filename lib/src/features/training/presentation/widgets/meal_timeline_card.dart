import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../domain/entities/diet_plan.dart';

/// A single meal displayed as a timeline card.
///
/// Layout: a neon-green dot on the vertical timeline line sits at the
/// left edge; the meal content is inset to the right.
///
/// [isLast] controls whether the vertical line extends below the dot,
/// so the last card does not draw a dangling line.
class MealTimelineCard extends StatelessWidget {
  const MealTimelineCard({
    super.key,
    required this.meal,
    required this.isLast,
  });

  final Meal meal;
  final bool isLast;

  static const double _dotSize = 8;
  static const double _lineWidth = 2;
  static const int _lineColor = 0xFF222222;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline track
          SizedBox(
            width: 20,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Vertical line — full height except for last card
                if (!isLast)
                  Positioned(
                    top: _dotSize,
                    bottom: 0,
                    child: Container(
                      width: _lineWidth,
                      color: const Color(_lineColor),
                    ),
                  ),
                // Green dot
                Positioned(
                  top: 0,
                  child: Container(
                    width: _dotSize,
                    height: _dotSize,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Meal content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time badge + meal name
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _TimeBadge(time: meal.time),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          meal.name,
                          style: AppTextStyles.heading4
                              .copyWith(color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Food chips
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: meal.foods
                        .map((food) => _FoodChip(food: food))
                        .toList(),
                  ),
                  if (meal.calories != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${meal.calories} cal',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.primary),
                    ),
                  ],
                  if (meal.notes != null && meal.notes!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      meal.notes!,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeBadge extends StatelessWidget {
  const _TimeBadge({required this.time});

  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: const BorderRadius.all(Radius.circular(6)),
        border: Border.all(color: AppColors.primary, width: 1),
      ),
      child: Text(
        time,
        style: AppTextStyles.label.copyWith(color: AppColors.primary),
      ),
    );
  }
}

class _FoodChip extends StatelessWidget {
  const _FoodChip({required this.food});

  final String food;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.elevated,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Text(
        food,
        style: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
      ),
    );
  }
}
