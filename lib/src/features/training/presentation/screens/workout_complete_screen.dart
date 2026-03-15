import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/services/convex_provider.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../domain/entities/workout_summary.dart';

/// Celebratory screen shown after a workout session ends.
///
/// Displays a Lottie animation, workout stats summary, and a "Back to Training"
/// button. Increments the completed workout count in secure storage on mount.
class WorkoutCompleteScreen extends ConsumerStatefulWidget {
  const WorkoutCompleteScreen({super.key, required this.summary});

  final WorkoutSummary summary;

  @override
  ConsumerState<WorkoutCompleteScreen> createState() =>
      _WorkoutCompleteScreenState();
}

class _WorkoutCompleteScreenState extends ConsumerState<WorkoutCompleteScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final count = await ref
          .read(storageServiceProvider)
          .incrementCompletedWorkoutCount();
      if (count >= 3) {
        try {
          await InAppReview.instance.requestReview();
        } catch (_) {
          // In-app review is best-effort; ignore errors.
        }
      }
    });
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
          child: Column(
            children: [
              // Lottie animation
              Lottie.asset(
                'assets/lottie/lottie_success.json',
                width: 200,
                height: 200,
                repeat: false,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.emoji_events_rounded,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),

              // Heading
              Text(
                'Workout Complete!',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Great work — you crushed it!',
                style:
                    AppTextStyles.body.copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Summary cards
              _SummaryCard(
                icon: Icons.fitness_center_rounded,
                label: 'Plan',
                value: summary.planName,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.repeat_rounded,
                      label: 'Exercises',
                      value: '${summary.exercisesDone}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.check_circle_outline_rounded,
                      label: 'Sets',
                      value: '${summary.setsCompleted}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _SummaryCard(
                icon: Icons.timer_outlined,
                label: 'Duration',
                value: _formatTime(summary.elapsedSeconds),
              ),

              const Spacer(),

              // CTA
              PrimaryButton(
                label: 'Back to Training',
                onPressed: () => context.go('/training'),
                icon: Icons.arrow_back_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
              ),
              Text(
                value,
                style:
                    AppTextStyles.heading4.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
