import 'dart:convert';

import 'package:convex_flutter/convex_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/convex_provider.dart';
import '../domain/entities/diet_plan.dart';
import '../domain/entities/training_plan.dart';
import 'training_repository.dart';

class ConvexTrainingRepository implements TrainingRepository {
  const ConvexTrainingRepository(this._client);

  final ConvexClient _client;

  @override
  Future<List<TrainingPlan>> getMyTrainingPlans() async {
    final result =
        jsonDecode(await _client.query('mobile:getMyTrainingPlans', {}))
            as List<dynamic>;
    return result
        .map((e) => TrainingPlan.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<DietPlan>> getMyDietPlans() async {
    final result =
        jsonDecode(await _client.query('mobile:getMyDietPlans', {}))
            as List<dynamic>;
    return result
        .map((e) => DietPlan.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final Provider<TrainingRepository> trainingRepositoryProvider =
    Provider<TrainingRepository>(
  (ref) => ConvexTrainingRepository(ref.watch(convexClientProvider)),
  name: 'trainingRepositoryProvider',
);
