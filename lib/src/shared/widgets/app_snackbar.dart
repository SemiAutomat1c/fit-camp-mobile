import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Static helpers for branded [SnackBar] messages.
///
/// ```dart
/// AppSnackbar.success(context, 'Session booked!');
/// AppSnackbar.error(context, 'Failed to load data. Try again.');
/// ```
abstract final class AppSnackbar {
  /// Shows a success SnackBar with a green left border.
  static void success(BuildContext context, String message) {
    _show(context, message: message, borderColor: AppColors.success);
  }

  /// Shows an error SnackBar with a red left border.
  static void error(BuildContext context, String message) {
    _show(context, message: message, borderColor: AppColors.error);
  }

  static void _show(
    BuildContext context, {
    required String message,
    required Color borderColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.elevated : AppColors.lightElevated;
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                width: 4,
                height: 40,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.caption.copyWith(color: textColor),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: bgColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            side: BorderSide(color: borderColor.withAlpha(77), width: 1),
          ),
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.fromLTRB(0, 14, 16, 14),
          duration: const Duration(seconds: 4),
        ),
      );
  }
}
