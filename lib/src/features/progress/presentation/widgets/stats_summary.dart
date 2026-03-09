import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../domain/entities/progress_log.dart';

/// Row of 3 stat cards: Current Weight, Current BMI, Total Logs.
class StatsSummary extends StatelessWidget {
  const StatsSummary({super.key, required this.logs});

  final List<ProgressLog> logs;

  @override
  Widget build(BuildContext context) {
    final latest = logs.isNotEmpty ? logs.first : null;
    final weightStr =
        latest?.weight != null ? latest!.weight!.toStringAsFixed(1) : '—';
    final bmiStr =
        latest?.bmi != null ? latest!.bmi!.toStringAsFixed(1) : '—';
    final totalStr = logs.length.toString();

    return Row(
      children: [
        _StatCard(value: weightStr, label: 'Weight (kg)'),
        const SizedBox(width: 8),
        _StatCard(value: bmiStr, label: 'Current BMI'),
        const SizedBox(width: 8),
        _StatCard(value: totalStr, label: 'Total Logs'),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
