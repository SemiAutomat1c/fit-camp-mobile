import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Stat value + label card with an optional circular progress ring.
///
/// When [percent] is provided (0.0–1.0), renders a [CircularPercentIndicator]
/// with the value in the center. Otherwise renders a plain value/label stack.
///
/// ```dart
/// NeonStatCard(
///   value: '3',
///   label: 'Sessions\nThis Week',
///   percent: 0.6, // 3 of 5 weekly goal
///   accentColor: AppColors.primary,
/// )
/// ```
class NeonStatCard extends StatelessWidget {
  const NeonStatCard({
    super.key,
    required this.value,
    required this.label,
    this.percent,
    this.accentColor = AppColors.primary,
  });

  final String value;
  final String label;

  /// Progress fraction 0.0–1.0. If null, no ring is shown.
  final double? percent;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: percent != null
          ? _WithRing(
              value: value,
              label: label,
              percent: percent!,
              accentColor: accentColor,
            )
          : _Plain(value: value, label: label, accentColor: accentColor),
    );
  }
}

class _WithRing extends StatelessWidget {
  const _WithRing({
    required this.value,
    required this.label,
    required this.percent,
    required this.accentColor,
  });

  final String value;
  final String label;
  final double percent;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      radius: 36,
      lineWidth: 4,
      percent: percent.clamp(0.0, 1.0),
      animation: true,
      animationDuration: 800,
      backgroundColor: accentColor.withAlpha(30),
      progressColor: accentColor,
      circularStrokeCap: CircularStrokeCap.round,
      center: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(color: accentColor),
          ),
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: AppColors.textMuted,
              fontSize: 9,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

class _Plain extends StatelessWidget {
  const _Plain({
    required this.value,
    required this.label,
    required this.accentColor,
  });

  final String value;
  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTextStyles.heading3.copyWith(color: accentColor),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
      ],
    );
  }
}
