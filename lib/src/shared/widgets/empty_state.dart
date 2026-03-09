import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Empty state illustration: icon + title + optional subtitle + optional CTA.
///
/// ```dart
/// EmptyState(
///   icon: Icons.calendar_month_outlined,
///   title: 'No sessions booked',
///   subtitle: 'Book your first session to get started.',
///   action: PrimaryButton(label: 'Browse Sessions', onPressed: _browse),
/// )
/// ```
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final mutedColor = isDark ? AppColors.textMuted : AppColors.lightTextMuted;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: mutedColor),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppTextStyles.heading3.copyWith(color: titleColor),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: AppTextStyles.body.copyWith(color: mutedColor),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 48),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
