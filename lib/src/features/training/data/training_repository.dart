import '../domain/entities/diet_plan.dart';
import '../domain/entities/training_plan.dart';

/// Abstract contract for the training data layer.
///
/// The concrete implementation ([ConvexTrainingRepository]) fetches from
/// Convex. Tests can override with a fake implementation.
abstract class TrainingRepository {
  Future<List<TrainingPlan>> getMyTrainingPlans();
  Future<List<DietPlan>> getMyDietPlans();
}
