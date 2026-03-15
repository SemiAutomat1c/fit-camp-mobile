import '../domain/entities/diet_plan.dart';
import '../domain/entities/member_summary.dart';
import '../domain/entities/training_plan.dart';

/// Abstract contract for the training data layer.
///
/// The concrete implementation ([ConvexTrainingRepository]) fetches from
/// Convex. Tests can override with a fake implementation.
abstract class TrainingRepository {
  Future<List<TrainingPlan>> getMyTrainingPlans();
  Future<List<DietPlan>> getMyDietPlans();

  /// Trainer only — returns the members assigned to the authenticated trainer.
  Future<List<MemberSummary>> getMyMembers();

  /// Trainer only — creates a workout plan for [memberId].
  /// [exercises] is a list of exercise maps; it is JSON-encoded before
  /// transmission to satisfy the convex_flutter v3 SDK constraint.
  Future<String> createTrainingPlan({
    required String memberId,
    required String name,
    String? description,
    required List<Map<String, dynamic>> exercises,
  });

  /// Trainer only — creates a diet plan for [memberId].
  /// [meals] is JSON-encoded before transmission for the same reason.
  Future<String> createDietPlan({
    required String memberId,
    required String name,
    String? description,
    required List<Map<String, dynamic>> meals,
  });

  /// Trainer only — marks a training plan as inactive.
  Future<void> deactivatePlan(String planId);
}
