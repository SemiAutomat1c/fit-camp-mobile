/// A single meal within a [DietPlan].
class Meal {
  const Meal({
    required this.name,
    required this.time,
    required this.foods,
    this.calories,
    this.notes,
  });

  final String name;

  /// Human-readable time string, e.g. `"7:00 AM"`.
  final String time;

  final List<String> foods;
  final int? calories;
  final String? notes;

  factory Meal.fromJson(Map<String, dynamic> json) => Meal(
        name: json['name'] as String,
        time: json['time'] as String,
        foods: (json['foods'] as List<dynamic>).map((e) => e as String).toList(),
        calories: (json['calories'] as num?)?.toInt(),
        notes: json['notes'] as String?,
      );
}

/// A diet plan assigned to a member by a trainer.
///
/// [trainerName] is populated in the member view.
/// [memberName] is populated in the trainer view.
class DietPlan {
  const DietPlan({
    required this.id,
    required this.name,
    this.description,
    required this.meals,
    required this.isActive,
    required this.createdAt,
    this.trainerName,
    this.memberName,
  });

  final String id;
  final String name;
  final String? description;
  final List<Meal> meals;
  final bool isActive;
  final DateTime createdAt;

  /// Populated in the member view — the trainer who assigned the plan.
  final String? trainerName;

  /// Populated in the trainer view — the member the plan was assigned to.
  final String? memberName;

  factory DietPlan.fromJson(Map<String, dynamic> json) {
    final trainer = json['trainer'] as Map<String, dynamic>?;
    final member = json['member'] as Map<String, dynamic>?;
    return DietPlan(
      id: json['_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      meals: (json['meals'] as List<dynamic>)
          .map((e) => Meal.fromJson(e as Map<String, dynamic>))
          .toList(),
      isActive: json['isActive'] as bool? ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
          (json['createdAt'] as num).toInt()),
      trainerName: trainer?['name'] as String?,
      memberName: member?['name'] as String?,
    );
  }
}
