import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Shows a branded [AlertDialog] explaining why a permission is needed.
///
/// Returns `true` if the user taps "Allow", `false` if they tap "Not Now"
/// or dismiss the dialog.
///
/// ```dart
/// final allowed = await showPermissionRationaleDialog(
///   context,
///   icon: Icons.camera_alt,
///   title: 'Camera Access',
///   body: 'We need camera access to let you take progress photos.',
/// );
/// if (allowed) { ... }
/// ```
Future<bool> showPermissionRationaleDialog(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String body,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withAlpha(153),
    builder: (context) => _PermissionRationaleDialog(
      icon: icon,
      title: title,
      body: body,
    ),
  );
  return result ?? false;
}

class _PermissionRationaleDialog extends StatelessWidget {
  const _PermissionRationaleDialog({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.elevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
      actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style:
                AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textMuted,
                  side: const BorderSide(color: AppColors.border),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'Not Now',
                  style: AppTextStyles.bodyMed
                      .copyWith(color: AppColors.textMuted),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'Allow',
                  style: AppTextStyles.bodyMed
                      .copyWith(color: AppColors.background),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
