import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/animated_stat_value.dart';
import '../../domain/entities/progress_log.dart';

/// 60/40 stats layout: weight card (prominent left) + BMI & Logs stacked right.
class StatsSummary extends StatelessWidget {
  const StatsSummary({super.key, required this.logs});

  final List<ProgressLog> logs;

  @override
  Widget build(BuildContext context) {
    final latest = logs.isNotEmpty ? logs.first : null;
    final weight = latest?.weight;
    final bmiVal = latest?.bmi;
    final totalLogs = logs.length;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Weight card — 60% width, prominent
          Expanded(
            flex: 6,
            child: _WeightCard(weight: weight),
          ),
          const SizedBox(width: 8),
          // BMI + Logs stacked — 40% width
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Expanded(
                  child: _SmallStatCard(
                    value: bmiVal != null
                        ? bmiVal.toStringAsFixed(1)
                        : '—',
                    label: 'BMI',
                    accentColor: _bmiColor(bmiVal),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _SmallStatCard(
                    value: totalLogs.toString(),
                    label: 'Total\nLogs',
                    accentColor: AppColors.primaryMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Color _bmiColor(double? bmi) {
    if (bmi == null) return AppColors.textMuted;
    if (bmi < 18.5) return AppColors.warning;
    if (bmi < 25.0) return AppColors.success;
    if (bmi < 30.0) return AppColors.warning;
    return AppColors.error;
  }
}

class _WeightCard extends StatelessWidget {
  const _WeightCard({required this.weight});

  final double? weight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.primary.withAlpha(60)),
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x0A39FF14), Color(0x00000000)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (weight != null)
            AnimatedStatValue(
              targetValue: weight!,
              suffix: ' kg',
              style: AppTextStyles.heading1.copyWith(color: AppColors.primary),
            )
          else
            Text(
              '—',
              style: AppTextStyles.heading1.copyWith(color: AppColors.primary),
            ),
          const SizedBox(height: 4),
          Text(
            'Current Weight',
            style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SmallStatCard extends StatelessWidget {
  const _SmallStatCard({
    required this.value,
    required this.label,
    required this.accentColor,
  });

  final String value;
  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(color: accentColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
