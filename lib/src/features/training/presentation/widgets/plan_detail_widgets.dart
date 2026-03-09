import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

/// Active / Inactive badge used on plan detail screens and list cards.
class PlanActiveBadge extends StatelessWidget {
  const PlanActiveBadge({super.key, required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary.withAlpha(26)
            : AppColors.textMuted.withAlpha(20),
        borderRadius: const BorderRadius.all(Radius.circular(6)),
        border: Border.all(
          color: isActive
              ? AppColors.primary.withAlpha(77)
              : AppColors.textMuted.withAlpha(50),
          width: 1,
        ),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: AppTextStyles.label.copyWith(color: color),
      ),
    );
  }
}

/// A small icon + text row used for trainer/member name and creation date.
class PlanMetaRow extends StatelessWidget {
  const PlanMetaRow({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Text(
          text,
          style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }
}
