import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'active_workout_provider.g.dart';

class ActiveWorkoutState {
  const ActiveWorkoutState({
    required this.planId,
    required this.exercises,
    this.currentExerciseIndex = 0,
    this.setsCompleted = const {},
    this.weightsLogged = const {},
    this.elapsedSeconds = 0,
    this.isResting = false,
    this.restSecondsLeft = 0,
    this.isCompleted = false,
  });

  final String planId;
  final List<Map<String, dynamic>> exercises;
  final int currentExerciseIndex;
  final Map<int, int> setsCompleted; // exerciseIndex → setsCompleted
  final Map<int, double> weightsLogged; // exerciseIndex → weight
  final int elapsedSeconds;
  final bool isResting;
  final int restSecondsLeft;
  final bool isCompleted;

  Map<String, dynamic> get currentExercise =>
      currentExerciseIndex < exercises.length
          ? exercises[currentExerciseIndex]
          : {};

  int get totalSets => exercises.fold(0, (sum, e) {
        final sets = (e['sets'] as num?)?.toInt() ?? 3;
        return sum + sets;
      });

  int get completedSetsTotal =>
      setsCompleted.values.fold(0, (sum, s) => sum + s);

  double get completionPercent => totalSets == 0
      ? 0
      : (completedSetsTotal / totalSets).clamp(0.0, 1.0);

  ActiveWorkoutState copyWith({
    int? currentExerciseIndex,
    Map<int, int>? setsCompleted,
    Map<int, double>? weightsLogged,
    int? elapsedSeconds,
    bool? isResting,
    int? restSecondsLeft,
    bool? isCompleted,
  }) {
    return ActiveWorkoutState(
      planId: planId,
      exercises: exercises,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      setsCompleted: setsCompleted ?? this.setsCompleted,
      weightsLogged: weightsLogged ?? this.weightsLogged,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isResting: isResting ?? this.isResting,
      restSecondsLeft: restSecondsLeft ?? this.restSecondsLeft,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

@riverpod
class ActiveWorkoutNotifier extends _$ActiveWorkoutNotifier {
  Timer? _sessionTimer;
  Timer? _restTimer;

  @override
  ActiveWorkoutState build(
      String planId, List<Map<String, dynamic>> exercises) {
    ref.onDispose(() {
      _sessionTimer?.cancel();
      _restTimer?.cancel();
    });
    _startTimer();
    return ActiveWorkoutState(planId: planId, exercises: exercises);
  }

  void _startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    });
  }

  void completeSet(int exerciseIndex, double weight) {
    final updated = Map<int, int>.from(state.setsCompleted);
    final currentSets = updated[exerciseIndex] ?? 0;
    final targetSets =
        (state.exercises[exerciseIndex]['sets'] as num?)?.toInt() ?? 3;
    updated[exerciseIndex] = (currentSets + 1).clamp(0, targetSets);

    final weights = Map<int, double>.from(state.weightsLogged);
    weights[exerciseIndex] = weight;

    state = state.copyWith(
      setsCompleted: updated,
      weightsLogged: weights,
      isResting: true,
      restSecondsLeft: 60,
    );
    _startRestTimer();
  }

  void _startRestTimer() {
    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.restSecondsLeft <= 1) {
        _restTimer?.cancel();
        state = state.copyWith(isResting: false, restSecondsLeft: 0);
      } else {
        state = state.copyWith(restSecondsLeft: state.restSecondsLeft - 1);
      }
    });
  }

  void skipRest() {
    _restTimer?.cancel();
    state = state.copyWith(isResting: false, restSecondsLeft: 0);
  }

  void nextExercise() {
    if (state.currentExerciseIndex < state.exercises.length - 1) {
      state = state.copyWith(
        currentExerciseIndex: state.currentExerciseIndex + 1,
      );
    }
  }

  void endWorkout() {
    _sessionTimer?.cancel();
    _restTimer?.cancel();
    state = state.copyWith(isCompleted: true);
  }
}

@riverpod
double planCompletion(PlanCompletionRef ref, String planId) {
  // Returns 0.0 by default; only non-zero during active workout session.
  return 0.0;
}
