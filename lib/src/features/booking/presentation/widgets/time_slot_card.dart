import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/utils/time_format.dart';

class TimeSlotCard extends StatelessWidget {
  const TimeSlotCard({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.isSelected,
    required this.onTap,
  });

  final String startTime;
  final String endTime;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? AppColors.primary : AppColors.border;
    final bgColor =
        isSelected ? AppColors.primary.withAlpha(26) : AppColors.surface;
    final textColor =
        isSelected ? AppColors.primary : AppColors.textPrimary;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.access_time_rounded,
              size: 16,
              color: textColor,
            ),
            const SizedBox(width: 6),
            Text(
              '${formatTime(startTime)} – ${formatTime(endTime)}',
              style: AppTextStyles.bodyMed.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }

}
