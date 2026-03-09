/// A single exercise within a [TrainingPlan].
class Exercise {
  const Exercise({
    required this.name,
    this.sets,
    this.reps,
    this.duration,
    this.notes,
  });

  final String name;
  final int? sets;
  final int? reps;
  final String? duration;
  final String? notes;

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        name: json['name'] as String,
        sets: (json['sets'] as num?)?.toInt(),
        reps: (json['reps'] as num?)?.toInt(),
        duration: json['duration'] as String?,
        notes: json['notes'] as String?,
      );
}

/// A training plan assigned to a member by a trainer.
///
/// [trainerName] is populated in the member view.
/// [memberName] is populated in the trainer view.
class TrainingPlan {
  const TrainingPlan({
    required this.id,
    required this.name,
    this.description,
    required this.exercises,
    required this.isActive,
    required this.createdAt,
    this.trainerName,
    this.memberName,
  });

  final String id;
  final String name;
  final String? description;
  final List<Exercise> exercises;
  final bool isActive;
  final DateTime createdAt;

  /// Populated in the member view — the trainer who assigned the plan.
  final String? trainerName;

  /// Populated in the trainer view — the member the plan was assigned to.
  final String? memberName;

  factory TrainingPlan.fromJson(Map<String, dynamic> json) {
    final trainer = json['trainer'] as Map<String, dynamic>?;
    final member = json['member'] as Map<String, dynamic>?;
    return TrainingPlan(
      id: json['_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      isActive: json['isActive'] as bool? ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
          (json['createdAt'] as num).toInt()),
      trainerName: trainer?['name'] as String?,
      memberName: member?['name'] as String?,
    );
  }
}
