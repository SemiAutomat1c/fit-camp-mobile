import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/skeletons/skeleton_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/training_provider.dart';
import '../widgets/plan_card.dart';

/// Sorts [plans] so active plans come first, with each group ordered by
/// [createdAt] descending.
List<T> _sortedPlans<T extends Object>(
  List<T> plans, {
  required bool Function(T) isActive,
  required DateTime Function(T) createdAt,
}) {
  bool active(T p) => isActive(p);
  int byDate(T a, T b) => createdAt(b).compareTo(createdAt(a));

  final activePlans = plans.where(active).toList()..sort(byDate);
  final inactivePlans = plans.where((p) => !active(p)).toList()..sort(byDate);
  return [...activePlans, ...inactivePlans];
}

class TrainingHomeScreen extends ConsumerStatefulWidget {
  const TrainingHomeScreen({super.key});

  @override
  ConsumerState<TrainingHomeScreen> createState() =>
      _TrainingHomeScreenState();
}

class _TrainingHomeScreenState extends ConsumerState<TrainingHomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Plans',
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2,
          labelStyle: AppTextStyles.bodyMed,
          unselectedLabelStyle: AppTextStyles.body,
          tabs: const [
            Tab(text: 'Workout Plans'),
            Tab(text: 'Diet Plans'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _WorkoutPlansTab(),
          _DietPlansTab(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Workout plans tab
// ---------------------------------------------------------------------------

class _WorkoutPlansTab extends ConsumerWidget {
  const _WorkoutPlansTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(trainingPlansProvider);
    final authState = ref.watch(authNotifierProvider);
    final isTrainer = authState.valueOrNull?.isTrainer ?? false;

    return plansAsync.when(
      loading: () => const _SkeletonList(),
      error: (e, _) => _ErrorState(
        onRetry: () => ref.invalidate(trainingPlansProvider),
      ),
      data: (plans) {
        final sorted = _sortedPlans(
          plans,
          isActive: (p) => p.isActive,
          createdAt: (p) => p.createdAt,
        );
        if (sorted.isEmpty) {
          return const _EmptyState(
            icon: Icons.fitness_center_rounded,
            title: 'No workout plans',
            subtitle: 'Your trainer will assign workout plans here.',
          );
        }
        return RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: () async {
            ref.invalidate(trainingPlansProvider);
            await ref.read(trainingPlansProvider.future);
          },
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final plan = sorted[index];
              final subtitle = isTrainer ? plan.memberName : plan.trainerName;
              final count = plan.exercises.length;
              return PlanCard(
                title: plan.name,
                subtitle: subtitle,
                itemCountIcon: Icons.fitness_center_rounded,
                itemCount: '$count ${count == 1 ? 'exercise' : 'exercises'}',
                isActive: plan.isActive,
                createdAt: plan.createdAt,
                onTap: () =>
                    context.push('/training/workout/${plan.id}', extra: plan),
              )
                  .animate(delay: Duration(milliseconds: index * 60))
                  .fadeIn(duration: 300.ms, curve: Curves.easeOut)
                  .slideY(begin: 0.12, end: 0, duration: 300.ms, curve: Curves.easeOut);
            },
          ),
        );
      },
    );
  }

}

// ---------------------------------------------------------------------------
// Diet plans tab
// ---------------------------------------------------------------------------

class _DietPlansTab extends ConsumerWidget {
  const _DietPlansTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(dietPlansProvider);
    final authState = ref.watch(authNotifierProvider);
    final isTrainer = authState.valueOrNull?.isTrainer ?? false;

    return plansAsync.when(
      loading: () => const _SkeletonList(),
      error: (e, _) => _ErrorState(
        onRetry: () => ref.invalidate(dietPlansProvider),
      ),
      data: (plans) {
        final sorted = _sortedPlans(
          plans,
          isActive: (p) => p.isActive,
          createdAt: (p) => p.createdAt,
        );
        if (sorted.isEmpty) {
          return const _EmptyState(
            icon: Icons.restaurant_menu_rounded,
            title: 'No diet plans',
            subtitle: 'Your trainer will assign diet plans here.',
          );
        }
        return RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: () async {
            ref.invalidate(dietPlansProvider);
            await ref.read(dietPlansProvider.future);
          },
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final plan = sorted[index];
              final subtitle = isTrainer ? plan.memberName : plan.trainerName;
              final count = plan.meals.length;
              return PlanCard(
                title: plan.name,
                subtitle: subtitle,
                itemCountIcon: Icons.restaurant_menu_rounded,
                itemCount: '$count ${count == 1 ? 'meal' : 'meals'}',
                isActive: plan.isActive,
                createdAt: plan.createdAt,
                onTap: () =>
                    context.push('/training/diet/${plan.id}', extra: plan),
              )
                  .animate(delay: Duration(milliseconds: index * 60))
                  .fadeIn(duration: 300.ms, curve: Curves.easeOut)
                  .slideY(begin: 0.12, end: 0, duration: 300.ms, curve: Curves.easeOut);
            },
          ),
        );
      },
    );
  }

}

// ---------------------------------------------------------------------------
// Shared states
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.heading4
                  .copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style:
                  AppTextStyles.caption.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Could not load plans',
              style: AppTextStyles.heading4
                  .copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Try again',
                style:
                    AppTextStyles.bodyMed.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonList extends StatelessWidget {
  const _SkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const SkeletonCard(),
    );
  }
}
