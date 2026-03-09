import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Inline error state widget: icon + message + optional retry button.
///
/// Use this for feature-level errors (failed API call, etc.).
/// For a full-screen connection failure use [NoConnectionScreen].
///
/// ```dart
/// ErrorView(
///   message: 'Failed to load sessions.',
///   onRetry: ref.read(sessionsProvider.notifier).reload,
/// )
/// ```
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.textMuted : AppColors.lightTextMuted;
    final primaryColor = isDark ? AppColors.primary : AppColors.lightPrimary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.body.copyWith(color: mutedColor),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  foregroundColor: primaryColor,
                  minimumSize: const Size(48, 48),
                ),
                child: Text(
                  'Try Again',
                  style: AppTextStyles.button.copyWith(color: primaryColor),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
