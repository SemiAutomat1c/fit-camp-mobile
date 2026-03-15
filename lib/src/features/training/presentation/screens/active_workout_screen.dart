import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../domain/entities/training_plan.dart';
import '../../domain/entities/workout_summary.dart';
import '../providers/active_workout_provider.dart';
import '../widgets/rest_timer.dart';

/// Full-screen active workout session. Must be outside the ShellRoute so the
/// tab bar is hidden during a workout.
///
/// Receives a [TrainingPlan] via GoRouter extra and converts exercises to
/// [List<Map<String, dynamic>>] for the [ActiveWorkoutNotifier].
class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  const ActiveWorkoutScreen({super.key, required this.plan});

  final TrainingPlan plan;

  @override
  ConsumerState<ActiveWorkoutScreen> createState() =>
      _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  late final List<Map<String, dynamic>> _exercises;
  final TextEditingController _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _exercises = widget.plan.exercises
        .map((e) => {
              'name': e.name,
              if (e.sets != null) 'sets': e.sets,
              if (e.reps != null) 'reps': e.reps,
              if (e.duration != null) 'duration': e.duration,
              if (e.notes != null) 'notes': e.notes,
            })
        .toList();
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _showRestTimerSheet(BuildContext context, ActiveWorkoutNotifier notifier) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: AppColors.elevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Rest Time',
                style:
                    AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Take a breather — next set incoming.',
                style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 32),
              RestTimer(
                duration: 60,
                onComplete: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
                onSkip: () {
                  notifier.skipRest();
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    ).then((_) => notifier.skipRest());
  }

  Future<void> _confirmEndWorkout(
    BuildContext context,
    ActiveWorkoutNotifier notifier,
    ActiveWorkoutState workoutState,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.elevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'End Workout?',
          style: AppTextStyles.heading4.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'Your progress will be saved and the session will end.',
          style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style:
                  AppTextStyles.bodyMed.copyWith(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'End Workout',
              style: AppTextStyles.bodyMed.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      notifier.endWorkout();
      final summary = WorkoutSummary(
        planName: widget.plan.name,
        exercisesDone: workoutState.exercises.length,
        setsCompleted: workoutState.completedSetsTotal,
        elapsedSeconds: workoutState.elapsedSeconds,
      );
      context.go('/training/complete', extra: summary);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_exercises.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
          title: Text(
            'No Exercises',
            style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
          ),
        ),
        body: Center(
          child: Text(
            'This plan has no exercises.',
            style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
          ),
        ),
      );
    }

    final notifier = ref.read(
      activeWorkoutNotifierProvider(widget.plan.id, _exercises).notifier,
    );
    final workoutState = ref.watch(
      activeWorkoutNotifierProvider(widget.plan.id, _exercises),
    );

    final exercise = workoutState.currentExercise;
    final exerciseName = exercise['name'] as String? ?? '';
    final sets = (exercise['sets'] as num?)?.toInt() ?? 3;
    final reps = (exercise['reps'] as num?)?.toInt();
    final duration = exercise['duration'] as String?;
    final currentIdx = workoutState.currentExerciseIndex;
    final totalExercises = workoutState.exercises.length;
    final completedSets = workoutState.setsCompleted[currentIdx] ?? 0;

    final setsLabel = reps != null
        ? '${sets}x$reps'
        : duration != null
            ? '${sets}x $duration'
            : '$sets sets';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(
          _formatTime(workoutState.elapsedSeconds),
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.primary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: () =>
                  _confirmEndWorkout(context, notifier, workoutState),
              child: Text(
                'End',
                style: AppTextStyles.bodyMed.copyWith(color: AppColors.error),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress header
            Row(
              children: [
                Text(
                  'Exercise ${currentIdx + 1} of $totalExercises',
                  style:
                      AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                ),
                const Spacer(),
                Text(
                  '${(workoutState.completionPercent * 100).toStringAsFixed(0)}%',
                  style: AppTextStyles.label.copyWith(color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: workoutState.completionPercent,
                backgroundColor: AppColors.border,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 32),

            // Exercise name
            Text(
              exerciseName,
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            // Sets info chip
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withAlpha(60),
                  width: 1,
                ),
              ),
              child: Text(
                setsLabel,
                style:
                    AppTextStyles.bodyMed.copyWith(color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 8),

            // Sets completed indicator
            Text(
              'Sets completed: $completedSets / $sets',
              style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 32),

            // Weight input
            Text(
              'Weight (kg)',
              style:
                  AppTextStyles.caption.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _weightController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: AppTextStyles.bodyMed
                  .copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: '0.0',
                hintStyle:
                    AppTextStyles.body.copyWith(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.border, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.border, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                suffixText: 'kg',
                suffixStyle: AppTextStyles.caption
                    .copyWith(color: AppColors.textMuted),
              ),
            ),
            const Spacer(),

            // Navigation row
            if (currentIdx < totalExercises - 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextButton.icon(
                  onPressed: notifier.nextExercise,
                  icon: const Icon(Icons.skip_next_rounded,
                      color: AppColors.primaryMuted),
                  label: Text(
                    'Next Exercise',
                    style: AppTextStyles.bodyMed
                        .copyWith(color: AppColors.primaryMuted),
                  ),
                ),
              ),

            // Complete Set button
            PrimaryButton(
              label: completedSets >= sets
                  ? 'All Sets Done'
                  : 'Complete Set ${completedSets + 1}',
              onPressed: completedSets >= sets
                  ? null
                  : () {
                      final weight =
                          double.tryParse(_weightController.text) ?? 0.0;
                      notifier.completeSet(currentIdx, weight);
                      _showRestTimerSheet(context, notifier);
                    },
              icon: Icons.check_circle_outline_rounded,
            ),
            const SizedBox(height: 16),

            // End workout text button
            Center(
              child: TextButton(
                onPressed: () =>
                    _confirmEndWorkout(context, notifier, workoutState),
                child: Text(
                  'End Workout',
                  style:
                      AppTextStyles.caption.copyWith(color: AppColors.error),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
