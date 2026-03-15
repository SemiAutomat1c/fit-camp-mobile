import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/neon_gradient_card.dart';

/// Displays the user's current progress logging streak.
///
/// Only rendered when the streak is 2 or more consecutive days.
class StreakCard extends StatelessWidget {
  const StreakCard({super.key, required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    return NeonGradientCard(
      padding: const EdgeInsets.all(16),
      gradientOpacity: 0.08,
      child: Row(
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            size: 36,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$streak day streak!',
                style: AppTextStyles.heading4
                    .copyWith(color: AppColors.textPrimary),
              ),
              Text(
                'Keep it up!',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
