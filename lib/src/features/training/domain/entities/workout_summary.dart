/// Immutable summary of a completed workout session.
///
/// Passed via GoRouter extra from [ActiveWorkoutScreen] to
/// [WorkoutCompleteScreen].
class WorkoutSummary {
  const WorkoutSummary({
    required this.planName,
    required this.exercisesDone,
    required this.setsCompleted,
    required this.elapsedSeconds,
  });

  final String planName;
  final int exercisesDone;
  final int setsCompleted;
  final int elapsedSeconds;
}
