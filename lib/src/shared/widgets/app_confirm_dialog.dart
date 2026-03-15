import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Shows a branded confirmation dialog.
///
/// Returns true if confirmed, false/null if cancelled.
Future<bool> showAppConfirmDialog(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  required VoidCallback onConfirm,
  Color? confirmColor,
  VoidCallback? onCancel,
  bool showWarningIcon = false,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.elevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      title: Row(
        children: [
          if (showWarningIcon) ...[
            Icon(Icons.warning_amber_rounded,
                color: confirmColor ?? AppColors.error, size: 22),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.heading3.copyWith(
                  color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
      content: Text(
        body,
        style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop(false);
            onCancel?.call();
          },
          style: TextButton.styleFrom(foregroundColor: AppColors.textMuted),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final isDestructive =
                (confirmColor ?? AppColors.primary) == AppColors.error;
            if (isDestructive) {
              HapticFeedback.heavyImpact();
            } else {
              HapticFeedback.mediumImpact();
            }
            Navigator.of(ctx).pop(true);
            onConfirm();
          },
          style: TextButton.styleFrom(
            foregroundColor: confirmColor ?? AppColors.primary,
          ),
          child: Text(
            confirmLabel,
            style: AppTextStyles.button.copyWith(
              color: confirmColor ?? AppColors.primary,
            ),
          ),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
