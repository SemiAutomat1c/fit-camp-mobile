import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/convex_progress_repository.dart';
import '../../domain/entities/progress_log.dart';

part 'progress_provider.g.dart';

@riverpod
Future<List<ProgressLog>> progressLogs(Ref ref) async {
  final repo = ref.watch(progressRepositoryProvider);
  return repo.getMyProgress();
}

@riverpod
Future<double?> memberHeightCm(Ref ref) async {
  final repo = ref.watch(progressRepositoryProvider);
  return repo.getMyHeightCm();
}
