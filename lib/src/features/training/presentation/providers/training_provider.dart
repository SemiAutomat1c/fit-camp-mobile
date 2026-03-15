import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/convex_training_repository.dart';
import '../../domain/entities/diet_plan.dart';
import '../../domain/entities/member_summary.dart';
import '../../domain/entities/training_plan.dart';

part 'training_provider.g.dart';

@riverpod
Future<List<TrainingPlan>> trainingPlans(TrainingPlansRef ref) async {
  final repo = ref.watch(trainingRepositoryProvider);
  return repo.getMyTrainingPlans();
}

@riverpod
Future<List<DietPlan>> dietPlans(DietPlansRef ref) async {
  final repo = ref.watch(trainingRepositoryProvider);
  return repo.getMyDietPlans();
}

@riverpod
Future<List<MemberSummary>> myMembers(MyMembersRef ref) async {
  final repo = ref.watch(trainingRepositoryProvider);
  return repo.getMyMembers();
}

@riverpod
class TrainingPlansNotifier extends _$TrainingPlansNotifier {
  @override
  Future<void> build() async {}

  /// Trainer only — marks a training plan inactive then invalidates the list.
  Future<void> deactivatePlan(String planId) async {
    final repo = ref.read(trainingRepositoryProvider);
    await repo.deactivatePlan(planId);
    ref.invalidate(trainingPlansProvider);
  }
}
