import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_confirm_dialog.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/training_plan.dart';
import '../providers/training_provider.dart';
import '../widgets/plan_detail_widgets.dart';

class TrainingPlanDetailScreen extends ConsumerWidget {
  const TrainingPlanDetailScreen({super.key, required this.plan});

  final TrainingPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateStr = DateFormat('MMM d, yyyy').format(plan.createdAt);
    final subtitle = plan.trainerName ?? plan.memberName;
    final isTrainer =
        ref.watch(authNotifierProvider).valueOrNull?.isTrainer ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(
          plan.name,
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          if (isTrainer && plan.isActive)
            IconButton(
              tooltip: 'Deactivate Plan',
              icon: const Icon(Icons.block_rounded, color: AppColors.error),
              onPressed: () => showAppConfirmDialog(
                context,
                title: 'Deactivate Plan?',
                body:
                    'This plan will be marked inactive and the member will no longer see it as their active plan.',
                confirmLabel: 'Deactivate',
                confirmColor: AppColors.error,
                showWarningIcon: true,
                onConfirm: () async {
                  try {
                    await ref
                        .read(trainingPlansNotifierProvider.notifier)
                        .deactivatePlan(plan.id);
                    if (context.mounted) {
                      AppSnackbar.success(context, 'Plan deactivated.');
                      Navigator.of(context).pop();
                    }
                  } catch (_) {
                    if (context.mounted) {
                      AppSnackbar.error(
                          context, 'Failed to deactivate plan. Try again.');
                    }
                  }
                },
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                // Active badge
                Align(
                  alignment: Alignment.centerLeft,
                  child: PlanActiveBadge(isActive: plan.isActive),
                ),
                const SizedBox(height: 12),
                // Description
                if (plan.description != null &&
                    plan.description!.isNotEmpty) ...[
                  Text(
                    plan.description!,
                    style:
                        AppTextStyles.body.copyWith(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 12),
                ],
                // Trainer / Member
                if (subtitle != null && subtitle.isNotEmpty) ...[
                  PlanMetaRow(
                    icon: Icons.person_outline_rounded,
                    text: subtitle,
                  ),
                  const SizedBox(height: 6),
                ],
                // Created date
                PlanMetaRow(
                  icon: Icons.calendar_today_outlined,
                  text: dateStr,
                ),
                const SizedBox(height: 24),
                // Section heading
                Text(
                  'Exercises',
                  style: AppTextStyles.heading4
                      .copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                // Exercise list
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: plan.exercises.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final exercise = plan.exercises[index];
                    return _ExerciseTile(
                      number: index + 1,
                      exercise: exercise,
                    );
                  },
                ),
              ],
            ),
          ),
          // Start Workout button — members only
          if (!isTrainer && plan.exercises.isNotEmpty)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: PrimaryButton(
                  label: 'Start Workout',
                  icon: Icons.play_arrow_rounded,
                  onPressed: () => context.push(
                    '/training/session/${plan.id}',
                    extra: plan,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Exercise tile
// ---------------------------------------------------------------------------

class _ExerciseTile extends StatelessWidget {
  const _ExerciseTile({
    required this.number,
    required this.exercise,
  });

  final int number;
  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final hasNotes = exercise.notes != null && exercise.notes!.isNotEmpty;

    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(56, 0, 16, 12),
          collapsedBackgroundColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          leading: _NumberCircle(number: number),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  exercise.name,
                  style: AppTextStyles.bodyMed
                      .copyWith(color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(width: 8),
              _InfoChips(exercise: exercise),
            ],
          ),
          // Only show expand arrow when there are notes
          trailing: hasNotes ? null : const SizedBox.shrink(),
          children: hasNotes
              ? [
                  Text(
                    exercise.notes!,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textMuted),
                  ),
                ]
              : [],
        ),
      ),
    );
  }
}

class _NumberCircle extends StatelessWidget {
  const _NumberCircle({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.elevated,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border, width: 1),
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
      ),
    );
  }
}

class _InfoChips extends StatelessWidget {
  const _InfoChips({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];

    final sets = exercise.sets;
    final reps = exercise.reps;
    final duration = exercise.duration;

    if (sets != null && reps != null) {
      chips.add(_Chip(label: '${sets}x$reps'));
    } else if (sets != null) {
      chips.add(_Chip(label: '${sets}x'));
    } else if (reps != null) {
      chips.add(_Chip(label: '$reps reps'));
    }

    if (duration != null) {
      chips.add(_Chip(label: duration));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: chips
          .expand((c) => [c, const SizedBox(width: 4)])
          .toList()
        ..removeLast(),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.elevated,
        borderRadius: const BorderRadius.all(Radius.circular(6)),
      ),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
      ),
    );
  }
}
