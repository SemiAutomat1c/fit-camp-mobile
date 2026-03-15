import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/primary_button.dart';

/// Shows details for a single exercise.
///
/// Receives [exercise] as [Map<String, dynamic>] via GoRouter extra.
/// Tapping "Start Set" pops back to the active workout screen.
class ExerciseDetailScreen extends ConsumerWidget {
  const ExerciseDetailScreen({super.key, required this.exercise});

  final Map<String, dynamic> exercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = exercise['name'] as String? ?? 'Exercise';
    final sets = (exercise['sets'] as num?)?.toInt();
    final reps = (exercise['reps'] as num?)?.toInt();
    final duration = exercise['duration'] as String?;
    final notes = exercise['notes'] as String?;

    final chips = <String>[];
    if (sets != null && reps != null) {
      chips.add('${sets}x$reps');
    } else if (sets != null) {
      chips.add('$sets sets');
    } else if (reps != null) {
      chips.add('$reps reps');
    }
    if (duration != null) {
      chips.add(duration);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(
          name,
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Heading
            Text(
              name,
              style:
                  AppTextStyles.heading2.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),

            // Info chips
            if (chips.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: chips
                    .map(
                      (chip) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.elevated,
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: AppColors.border, width: 1),
                        ),
                        child: Text(
                          chip,
                          style: AppTextStyles.bodyMed
                              .copyWith(color: AppColors.textPrimary),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Notes
            if (notes != null && notes.isNotEmpty) ...[
              Text(
                'Notes',
                style: AppTextStyles.heading4
                    .copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Text(
                  notes,
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Video placeholder
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.play_circle_outline_rounded,
                    size: 56,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Video coming soon',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Start Set CTA
            PrimaryButton(
              label: 'Start Set',
              onPressed: () => Navigator.of(context).pop(),
              icon: Icons.fitness_center_rounded,
            ),
          ],
        ),
      ),
    );
  }
}
