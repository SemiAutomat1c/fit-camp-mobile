import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/convex_provider.dart';
import '../../data/convex_progress_repository.dart';
import '../../domain/entities/progress_log.dart';

part 'progress_provider.g.dart';

// ---------------------------------------------------------------------------
// Progress logs — notifier that supports delete + invalidation
// ---------------------------------------------------------------------------

@riverpod
class ProgressLogsNotifier extends _$ProgressLogsNotifier {
  @override
  Future<List<ProgressLog>> build() async {
    final repo = ref.watch(progressRepositoryProvider);
    return repo.getMyProgress();
  }

  Future<void> deleteLog(String logId) async {
    final repo = ref.read(progressRepositoryProvider);
    await repo.deleteProgressLog(logId);
    ref.invalidateSelf();
  }
}

// Keep legacy provider alias so existing screens that watch progressLogsProvider
// continue to compile without modification.
@riverpod
Future<List<ProgressLog>> progressLogs(ProgressLogsRef ref) async {
  return ref.watch(progressLogsNotifierProvider.future);
}

// ---------------------------------------------------------------------------
// Member height
// ---------------------------------------------------------------------------

@riverpod
Future<double?> memberHeightCm(MemberHeightCmRef ref) async {
  final repo = ref.watch(progressRepositoryProvider);
  return repo.getMyHeightCm();
}

// ---------------------------------------------------------------------------
// Goal weight — reads from the member's profile on Convex
// ---------------------------------------------------------------------------

@riverpod
Future<double?> goalWeight(GoalWeightRef ref) async {
  final client = ref.watch(convexClientProvider);
  final raw = await client.query('mobile:getMyProfile', {});
  final profile = raw as Map<String, dynamic>;
  final gw = profile['goalWeight'];
  if (gw == null) return null;
  final value = (gw as num).toDouble();
  return value > 0 ? value : null;
}

// ---------------------------------------------------------------------------
// Progress streak — consecutive days ending today with at least one log
// ---------------------------------------------------------------------------

@riverpod
int progressStreak(ProgressStreakRef ref) {
  final logsAsync = ref.watch(progressLogsNotifierProvider);
  return logsAsync.when(
    data: (logs) => _computeStreak(logs),
    loading: () => 0,
    error: (_, __) => 0,
  );
}

int _computeStreak(List<ProgressLog> logs) {
  if (logs.isEmpty) return 0;

  // Collect unique calendar dates that have at least one log.
  final loggedDates = <DateTime>{};
  for (final log in logs) {
    loggedDates.add(_dateOnly(log.date));
  }

  final today = _dateOnly(DateTime.now());

  // Streak must include today. If no log today, streak is 0.
  if (!loggedDates.contains(today)) return 0;

  int streak = 0;
  DateTime cursor = today;
  while (loggedDates.contains(cursor)) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}

DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
