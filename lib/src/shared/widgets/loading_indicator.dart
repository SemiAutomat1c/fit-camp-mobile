import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Centered brand-green circular progress indicator.
///
/// Drop into any screen or widget that is in a loading state.
/// Non-interactive — wrap with [AbsorbPointer] if needed to block input.
///
/// ```dart
/// if (state.isLoading) const LoadingIndicator()
/// ```
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.primary : AppColors.lightPrimary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeWidth: 2.5,
          ),
        ),
      ),
    );
  }
}
