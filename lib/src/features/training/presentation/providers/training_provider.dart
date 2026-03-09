import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/convex_training_repository.dart';
import '../../domain/entities/diet_plan.dart';
import '../../domain/entities/training_plan.dart';

part 'training_provider.g.dart';

@riverpod
Future<List<TrainingPlan>> trainingPlans(Ref ref) async {
  final repo = ref.watch(trainingRepositoryProvider);
  return repo.getMyTrainingPlans();
}

@riverpod
Future<List<DietPlan>> dietPlans(Ref ref) async {
  final repo = ref.watch(trainingRepositoryProvider);
  return repo.getMyDietPlans();
}
