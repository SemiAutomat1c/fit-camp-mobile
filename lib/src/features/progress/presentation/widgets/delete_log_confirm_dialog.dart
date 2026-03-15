import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

/// Shows a confirmation dialog before permanently deleting a progress log.
///
/// Returns `true` if the user confirmed deletion, `false` otherwise.
Future<bool> showDeleteLogConfirmDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.elevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Delete Log?',
        style: AppTextStyles.heading4.copyWith(color: AppColors.textPrimary),
      ),
      content: Text(
        'This will permanently remove this progress entry.',
        style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(
            'Cancel',
            style: AppTextStyles.bodyMed.copyWith(color: AppColors.textMuted),
          ),
        ),
        TextButton(
          onPressed: () {
            HapticFeedback.heavyImpact();
            Navigator.of(ctx).pop(true);
          },
          child: Text(
            'Delete',
            style: AppTextStyles.bodyMed.copyWith(color: AppColors.error),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}
