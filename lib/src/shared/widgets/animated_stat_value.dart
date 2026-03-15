import 'package:flutter/material.dart';

/// Animates a numeric value from 0 to [targetValue] over 800 ms on first
/// build. Integer values display without decimal; fractional values show
/// one decimal place.
///
/// ```dart
/// AnimatedStatValue(
///   targetValue: 72.4,
///   suffix: ' kg',
///   style: AppTextStyles.heading2.copyWith(color: AppColors.primary),
/// )
/// ```
class AnimatedStatValue extends StatelessWidget {
  const AnimatedStatValue({
    super.key,
    required this.targetValue,
    this.suffix = '',
    required this.style,
  });

  final double targetValue;
  final String suffix;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: targetValue),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      builder: (context, value, _) {
        final isInteger = targetValue == targetValue.truncateToDouble() &&
            value == value.truncateToDouble();
        final display = isInteger
            ? '${value.toInt()}$suffix'
            : '${value.toStringAsFixed(1)}$suffix';
        return Text(display, style: style);
      },
    );
  }
}
