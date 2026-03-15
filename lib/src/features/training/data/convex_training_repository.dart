import 'dart:convert';

import 'package:convex_flutter/convex_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/convex_provider.dart';
import '../domain/entities/diet_plan.dart';
import '../domain/entities/member_summary.dart';
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

  @override
  Future<List<MemberSummary>> getMyMembers() async {
    final result =
        jsonDecode(await _client.query('mobile:getMyMembers', {}))
            as List<dynamic>;
    return result
        .map((e) => MemberSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<String> createTrainingPlan({
    required String memberId,
    required String name,
    String? description,
    required List<Map<String, dynamic>> exercises,
  }) async {
    final args = <String, dynamic>{
      'memberId': memberId,
      'name': name,
      'exercisesJson': jsonEncode(exercises),
      if (description != null && description.isNotEmpty)
        'description': description,
    };
    final result = await _client.mutation(
      name: 'mobile:createTrainingPlan',
      args: args,
    );
    if (result is! String) {
      throw StateError('createTrainingPlan: expected String ID, got ${result.runtimeType}');
    }
    return result;
  }

  @override
  Future<String> createDietPlan({
    required String memberId,
    required String name,
    String? description,
    required List<Map<String, dynamic>> meals,
  }) async {
    final args = <String, dynamic>{
      'memberId': memberId,
      'name': name,
      'mealsJson': jsonEncode(meals),
      if (description != null && description.isNotEmpty)
        'description': description,
    };
    final result = await _client.mutation(
      name: 'mobile:createDietPlan',
      args: args,
    );
    if (result is! String) {
      throw StateError('createDietPlan: expected String ID, got ${result.runtimeType}');
    }
    return result;
  }

  @override
  Future<void> deactivatePlan(String planId) async {
    await _client.mutation(
      name: 'trainingPlans:update',
      args: <String, dynamic>{'planId': planId, 'isActive': false},
    );
  }
}

final Provider<TrainingRepository> trainingRepositoryProvider =
    Provider<TrainingRepository>(
  (ref) => ConvexTrainingRepository(ref.watch(convexClientProvider)),
  name: 'trainingRepositoryProvider',
);
