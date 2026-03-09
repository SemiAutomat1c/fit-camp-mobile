import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_text_styles.dart';
import '../../../../../shared/widgets/primary_button.dart';
import '../../providers/onboarding_provider.dart';

// ---------------------------------------------------------------------------
// Public screen
// ---------------------------------------------------------------------------

class GoalSelectionScreen extends ConsumerWidget {
  const GoalSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _StepIndicator(currentStep: 1, totalSteps: 4),
              const SizedBox(height: 32),
              Text(
                "What's your fitness goal?",
                style: AppTextStyles.heading2
                    .copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                "We'll personalize your experience.",
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.95,
                  children: _kGoals
                      .map(
                        (goal) => _GoalCard(
                          goalKey: goal.key,
                          label: goal.label,
                          icon: goal.icon,
                          isSelected: state.selectedGoal == goal.key,
                          onTap: () => notifier.setGoal(goal.key),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Next',
                onPressed: state.selectedGoal != null
                    ? () => context.push('/onboarding/waiver')
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Goal data
// ---------------------------------------------------------------------------

class _GoalData {
  const _GoalData({
    required this.key,
    required this.label,
    required this.icon,
  });

  final String key;
  final String label;
  final IconData icon;
}

const List<_GoalData> _kGoals = [
  _GoalData(
    key: 'lose_weight',
    label: 'Lose Weight',
    icon: Icons.trending_down_rounded,
  ),
  _GoalData(
    key: 'build_muscle',
    label: 'Build Muscle',
    icon: Icons.fitness_center_rounded,
  ),
  _GoalData(
    key: 'improve_fitness',
    label: 'Improve Fitness',
    icon: Icons.directions_run_rounded,
  ),
  _GoalData(
    key: 'sports_performance',
    label: 'Sports Performance',
    icon: Icons.sports_rounded,
  ),
  _GoalData(
    key: 'general_wellness',
    label: 'General Wellness',
    icon: Icons.self_improvement_rounded,
  ),
];

// ---------------------------------------------------------------------------
// Goal card
// ---------------------------------------------------------------------------

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goalKey,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String goalKey;
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        gradient: isSelected
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withAlpha(51), // ~20%
                  AppColors.surface,
                ],
              )
            : null,
        color: isSelected ? null : AppColors.surface,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primary.withAlpha(77),
                  blurRadius: 12,
                  spreadRadius: 0,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: InkWell(
          onTap: onTap,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          splashColor: AppColors.primary.withAlpha(20),
          highlightColor: AppColors.primary.withAlpha(10),
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 48,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textMuted,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption.copyWith(
                          color: isSelected
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: AppColors.background,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step indicator
// ---------------------------------------------------------------------------

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final stepNumber = index + 1;
        final isActive = stepNumber <= currentStep;
        return Container(
          width: isActive ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.border,
            borderRadius: const BorderRadius.all(Radius.circular(4)),
          ),
        );
      }),
    );
  }
}

// Export the step indicator for use in other onboarding screens.
class OnboardingStepIndicator extends StatelessWidget {
  const OnboardingStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return _StepIndicator(
      currentStep: currentStep,
      totalSteps: totalSteps,
    );
  }
}
