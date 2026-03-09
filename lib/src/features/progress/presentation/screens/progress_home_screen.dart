import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../providers/progress_provider.dart';
import '../widgets/bmi_indicator.dart';
import '../widgets/photo_grid.dart';
import '../widgets/stats_summary.dart';
import '../widgets/weight_chart.dart';

/// Main progress tracking screen.
///
/// Displays:
///  1. Stats summary (weight, BMI, log count)
///  2. Weight chart
///  3. BMI indicator bar
///  4. Progress photo grid
///  5. FAB to log new progress
class ProgressHomeScreen extends ConsumerWidget {
  const ProgressHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(progressLogsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'My Progress',
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/progress/log'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        icon: const Icon(Icons.add),
        label: Text(
          'Log Today',
          style: AppTextStyles.button.copyWith(color: AppColors.background),
        ),
      ),
      body: logsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (_, __) => ErrorView(
          message: 'Unable to load progress. Pull down to retry.',
          onRetry: () => ref.invalidate(progressLogsProvider),
        ),
        data: (logs) {
          if (logs.isEmpty) {
            return _EmptyState(onTap: () => context.push('/progress/log'));
          }

          final latestBmi = logs.firstWhere(
            (l) => l.bmi != null,
            orElse: () => logs.first,
          ).bmi;

          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            onRefresh: () async => ref.invalidate(progressLogsProvider),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              children: [
                StatsSummary(logs: logs),
                const SizedBox(height: 20),
                _SectionTitle(title: 'Weight Over Time'),
                const SizedBox(height: 8),
                WeightChart(logs: logs),
                const SizedBox(height: 20),
                _SectionTitle(title: 'BMI'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: BmiIndicator(bmi: latestBmi),
                ),
                const SizedBox(height: 20),
                _SectionTitle(title: 'Progress Photos'),
                const SizedBox(height: 8),
                PhotoGrid(logs: logs),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.heading4.copyWith(color: AppColors.textPrimary),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.monitor_weight_outlined,
              size: 80,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 24),
            Text(
              'Start tracking your progress today!',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Log your weight and photos to visualize your fitness journey.',
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add),
              label: Text(
                'Log Today',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.background,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
